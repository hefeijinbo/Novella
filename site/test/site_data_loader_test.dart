import 'dart:io';

import 'package:test/test.dart';

import 'package:novella_site/src/content/site_data_loader.dart';

void main() {
  test('loads generated data file', () async {
    final tempDir = await Directory.systemTemp.createTemp(
      'novella_site_loader',
    );
    addTearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    final generated = File('${tempDir.path}/generated.json')
      ..writeAsStringSync(_fixture('v9.9.9'));

    final loader = SiteDataLoader(generatedPath: generated.path);
    final data = await loader.load();

    expect(data.latestRelease.tagName, 'v9.9.9');
  });

  test('throws when no data file exists', () async {
    final tempDir = await Directory.systemTemp.createTemp(
      'novella_site_loader',
    );
    addTearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    final loader = SiteDataLoader(
      generatedPath: '${tempDir.path}/missing.json',
    );

    expect(loader.load, throwsStateError);
  });
}

String _fixture(String tag) {
  return '''
{
  "repository": {
    "owner": "Kanscape",
    "name": "Novella",
    "fullName": "Kanscape/Novella",
    "description": "desc",
    "url": "https://github.com/Kanscape/Novella",
    "stars": 1,
    "forks": 1,
    "watchers": 1,
    "openIssues": 1
  },
  "latestRelease": {
    "tagName": "$tag",
    "name": "Novella $tag",
    "url": "https://github.com/Kanscape/Novella/releases/tag/$tag",
    "publishedAt": "2026-03-23T00:00:00Z",
    "bodyMarkdown": "",
    "bodyHtml": "",
    "excerpt": "excerpt",
    "assets": []
  },
  "contributors": [],
  "generatedAt": "2026-03-23T00:00:00Z"
}
''';
}
