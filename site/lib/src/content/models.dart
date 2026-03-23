enum ReleasePlatform { android, windows, macos, linux, ios, other }

ReleasePlatform releasePlatformFromName(String value) {
  return ReleasePlatform.values.firstWhere(
    (item) => item.name == value,
    orElse: () => ReleasePlatform.other,
  );
}

class SiteData {
  const SiteData({
    required this.repository,
    required this.latestRelease,
    required this.contributors,
    required this.generatedAt,
  });

  factory SiteData.fromJson(Map<String, dynamic> json) {
    return SiteData(
      repository: RepositoryMeta.fromJson(
        json['repository'] as Map<String, dynamic>,
      ),
      latestRelease: LatestRelease.fromJson(
        json['latestRelease'] as Map<String, dynamic>,
      ),
      contributors: (json['contributors'] as List<dynamic>? ?? const [])
          .map((item) => Contributor.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
      generatedAt: DateTime.parse(json['generatedAt'] as String),
    );
  }

  final RepositoryMeta repository;
  final LatestRelease latestRelease;
  final List<Contributor> contributors;
  final DateTime generatedAt;

  Map<String, dynamic> toJson() {
    return {
      'repository': repository.toJson(),
      'latestRelease': latestRelease.toJson(),
      'contributors': contributors.map((item) => item.toJson()).toList(),
      'generatedAt': generatedAt.toUtc().toIso8601String(),
    };
  }
}

class RepositoryMeta {
  const RepositoryMeta({
    required this.owner,
    required this.name,
    required this.fullName,
    required this.description,
    required this.url,
    required this.stars,
    required this.forks,
    required this.watchers,
    required this.openIssues,
  });

  factory RepositoryMeta.fromJson(Map<String, dynamic> json) {
    return RepositoryMeta(
      owner: json['owner'] as String? ?? '',
      name: json['name'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      description: json['description'] as String? ?? '',
      url: json['url'] as String? ?? '',
      stars: (json['stars'] as num? ?? 0).toInt(),
      forks: (json['forks'] as num? ?? 0).toInt(),
      watchers: (json['watchers'] as num? ?? 0).toInt(),
      openIssues: (json['openIssues'] as num? ?? 0).toInt(),
    );
  }

  final String owner;
  final String name;
  final String fullName;
  final String description;
  final String url;
  final int stars;
  final int forks;
  final int watchers;
  final int openIssues;

  Map<String, dynamic> toJson() {
    return {
      'owner': owner,
      'name': name,
      'fullName': fullName,
      'description': description,
      'url': url,
      'stars': stars,
      'forks': forks,
      'watchers': watchers,
      'openIssues': openIssues,
    };
  }
}

class LatestRelease {
  const LatestRelease({
    required this.tagName,
    required this.name,
    required this.url,
    required this.publishedAt,
    required this.bodyMarkdown,
    required this.bodyHtml,
    required this.excerpt,
    required this.assets,
  });

  factory LatestRelease.fromJson(Map<String, dynamic> json) {
    return LatestRelease(
      tagName: json['tagName'] as String? ?? '',
      name: json['name'] as String? ?? '',
      url: json['url'] as String? ?? '',
      publishedAt: DateTime.parse(json['publishedAt'] as String),
      bodyMarkdown: json['bodyMarkdown'] as String? ?? '',
      bodyHtml: json['bodyHtml'] as String? ?? '',
      excerpt: json['excerpt'] as String? ?? '',
      assets: (json['assets'] as List<dynamic>? ?? const [])
          .map((item) => ReleaseAsset.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
    );
  }

  final String tagName;
  final String name;
  final String url;
  final DateTime publishedAt;
  final String bodyMarkdown;
  final String bodyHtml;
  final String excerpt;
  final List<ReleaseAsset> assets;

  bool get hasBody => bodyHtml.trim().isNotEmpty;

  Map<String, dynamic> toJson() {
    return {
      'tagName': tagName,
      'name': name,
      'url': url,
      'publishedAt': publishedAt.toUtc().toIso8601String(),
      'bodyMarkdown': bodyMarkdown,
      'bodyHtml': bodyHtml,
      'excerpt': excerpt,
      'assets': assets.map((item) => item.toJson()).toList(),
    };
  }
}

class ReleaseAsset {
  const ReleaseAsset({
    required this.name,
    required this.url,
    required this.size,
    required this.downloadCount,
    required this.contentType,
    required this.updatedAt,
    required this.platform,
  });

  factory ReleaseAsset.fromJson(Map<String, dynamic> json) {
    return ReleaseAsset(
      name: json['name'] as String? ?? '',
      url: json['url'] as String? ?? '',
      size: (json['size'] as num? ?? 0).toInt(),
      downloadCount: (json['downloadCount'] as num? ?? 0).toInt(),
      contentType: json['contentType'] as String? ?? '',
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      platform: releasePlatformFromName(json['platform'] as String? ?? 'other'),
    );
  }

  final String name;
  final String url;
  final int size;
  final int downloadCount;
  final String contentType;
  final DateTime updatedAt;
  final ReleasePlatform platform;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'url': url,
      'size': size,
      'downloadCount': downloadCount,
      'contentType': contentType,
      'updatedAt': updatedAt.toUtc().toIso8601String(),
      'platform': platform.name,
    };
  }
}

class Contributor {
  const Contributor({
    required this.login,
    required this.profileUrl,
    required this.avatarUrl,
    required this.contributions,
  });

  factory Contributor.fromJson(Map<String, dynamic> json) {
    return Contributor(
      login: json['login'] as String? ?? '',
      profileUrl: json['profileUrl'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String? ?? '',
      contributions: (json['contributions'] as num? ?? 0).toInt(),
    );
  }

  final String login;
  final String profileUrl;
  final String avatarUrl;
  final int contributions;

  Map<String, dynamic> toJson() {
    return {
      'login': login,
      'profileUrl': profileUrl,
      'avatarUrl': avatarUrl,
      'contributions': contributions,
    };
  }
}
