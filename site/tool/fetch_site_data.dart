import 'dart:convert';
import 'dart:io';

import 'package:markdown/markdown.dart';
import 'package:novella_site/src/content/models.dart';
import 'package:novella_site/src/utils/platform_assets.dart';

Future<void> main() async {
  final repositorySlug =
      Platform.environment['GITHUB_REPOSITORY'] ?? 'Kanscape/Novella';
  final token = Platform.environment['GITHUB_TOKEN'];
  final outputPath =
      Platform.environment['SITE_DATA_PATH'] ?? '.generated/site_data.json';

  try {
    final client = _GitHubApiClient(token: token);

    final repositoryJson = await client.getObject('/repos/$repositorySlug');
    final releaseJson = await client.getObject(
      '/repos/$repositorySlug/releases/latest',
    );
    final contributorsJson = await client.getList(
      '/repos/$repositorySlug/contributors?per_page=100',
    );

    final siteData = SiteData(
      repository: RepositoryMeta(
        owner:
            (repositoryJson['owner'] as Map<String, dynamic>)['login']
                as String? ??
            '',
        name: repositoryJson['name'] as String? ?? '',
        fullName: repositoryJson['full_name'] as String? ?? repositorySlug,
        description:
            repositoryJson['description'] as String? ??
            '基于 Flutter + Rust 打造的轻小说阅读器。',
        url:
            repositoryJson['html_url'] as String? ??
            'https://github.com/$repositorySlug',
        stars: (repositoryJson['stargazers_count'] as num? ?? 0).toInt(),
        forks: (repositoryJson['forks_count'] as num? ?? 0).toInt(),
        watchers:
            (repositoryJson['subscribers_count'] as num? ??
                    repositoryJson['watchers_count'] as num? ??
                    0)
                .toInt(),
        openIssues: (repositoryJson['open_issues_count'] as num? ?? 0).toInt(),
      ),
      latestRelease: _buildLatestRelease(releaseJson),
      contributors: contributorsJson
          .whereType<Map<String, dynamic>>()
          .where((item) => item['type'] == 'User')
          .map(
            (item) => Contributor(
              login: item['login'] as String? ?? '',
              profileUrl: item['html_url'] as String? ?? '',
              avatarUrl: item['avatar_url'] as String? ?? '',
              contributions: (item['contributions'] as num? ?? 0).toInt(),
            ),
          )
          .where((item) => item.login.isNotEmpty)
          .toList(growable: false),
      generatedAt: DateTime.now().toUtc(),
    );

    final outputFile = File(outputPath)..createSync(recursive: true);
    outputFile.writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(siteData.toJson()),
    );

    stdout.writeln(
      'Fetched release data for $repositorySlug -> ${outputFile.path}',
    );
  } catch (error, stackTrace) {
    stderr.writeln('Failed to fetch GitHub data: $error');
    stderr.writeln(stackTrace);
    exitCode = 1;
  }
}

LatestRelease _buildLatestRelease(Map<String, dynamic> releaseJson) {
  final bodyMarkdown = releaseJson['body'] as String? ?? '';
  final cleanedExcerpt = _extractExcerpt(bodyMarkdown);
  final assets = (releaseJson['assets'] as List<dynamic>? ?? const [])
      .whereType<Map<String, dynamic>>()
      .map(
        (asset) => ReleaseAsset(
          name: asset['name'] as String? ?? '',
          url: asset['browser_download_url'] as String? ?? '',
          size: (asset['size'] as num? ?? 0).toInt(),
          downloadCount: (asset['download_count'] as num? ?? 0).toInt(),
          contentType: asset['content_type'] as String? ?? '',
          updatedAt: DateTime.parse(
            asset['updated_at'] as String? ??
                releaseJson['published_at'] as String,
          ),
          platform: detectReleasePlatform(
            asset['name'] as String? ?? '',
            asset['browser_download_url'] as String?,
          ),
        ),
      )
      .toList(growable: false);

  return LatestRelease(
    tagName: releaseJson['tag_name'] as String? ?? 'latest',
    name:
        releaseJson['name'] as String? ??
        releaseJson['tag_name'] as String? ??
        'Latest Release',
    url: releaseJson['html_url'] as String? ?? '',
    publishedAt: DateTime.parse(
      releaseJson['published_at'] as String? ??
          releaseJson['created_at'] as String,
    ),
    bodyMarkdown: bodyMarkdown,
    bodyHtml: markdownToHtml(bodyMarkdown),
    excerpt: cleanedExcerpt.isEmpty
        ? '最新版本已经发布，可直接从官网或 GitHub Release 下载。'
        : cleanedExcerpt,
    assets: assets,
  );
}

String _extractExcerpt(String markdown) {
  final lines = markdown
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList();

  if (lines.isEmpty) {
    return '';
  }

  for (final line in lines) {
    final cleaned = line
        .replaceAll(RegExp(r'^[#>*\-\d\.\s]+'), '')
        .replaceAll(RegExp(r'[`*_~\[\]\(\)!]'), '')
        .trim();

    if (cleaned.isEmpty) {
      continue;
    }
    if (RegExp(
      r"^(what'?s changed|update|updates)$",
      caseSensitive: false,
    ).hasMatch(cleaned)) {
      continue;
    }
    if (cleaned.length < 8) {
      continue;
    }

    return cleaned;
  }

  return lines.first
      .replaceAll(RegExp(r'^[#>*\-\d\.\s]+'), '')
      .replaceAll(RegExp(r'[`*_~\[\]\(\)!]'), '')
      .trim();
}

class _GitHubApiClient {
  _GitHubApiClient({this.token});

  final String? token;

  Future<Map<String, dynamic>> getObject(String path) async {
    final result = await _get(path);
    return jsonDecode(result) as Map<String, dynamic>;
  }

  Future<List<dynamic>> getList(String path) async {
    final result = await _get(path);
    return jsonDecode(result) as List<dynamic>;
  }

  Future<String> _get(String path) async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(
        Uri.parse('https://api.github.com$path'),
      );
      request.headers.set(
        HttpHeaders.acceptHeader,
        'application/vnd.github+json',
      );
      request.headers.set('X-GitHub-Api-Version', '2022-11-28');
      request.headers.set(HttpHeaders.userAgentHeader, 'novella-site-builder');
      if (token != null && token!.isNotEmpty) {
        request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      }

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException(
          'GitHub API request failed (${response.statusCode}): $responseBody',
          uri: request.uri,
        );
      }

      return responseBody;
    } finally {
      client.close(force: true);
    }
  }
}
