import '../content/models.dart';

ReleasePlatform detectReleasePlatform(String name, [String? url]) {
  final haystack = '${name.toLowerCase()} ${(url ?? '').toLowerCase()}';

  if (haystack.contains('.apk') || haystack.contains('android')) {
    return ReleasePlatform.android;
  }
  if (haystack.contains('.ipa') || haystack.contains('ios')) {
    return ReleasePlatform.ios;
  }
  if (haystack.contains('.exe') ||
      haystack.contains('.msi') ||
      haystack.contains('.msix') ||
      haystack.contains('windows') ||
      haystack.contains('win64') ||
      haystack.contains('win32')) {
    return ReleasePlatform.windows;
  }
  if (haystack.contains('.dmg') ||
      haystack.contains('.pkg') ||
      haystack.contains('macos') ||
      haystack.contains('darwin') ||
      haystack.contains('osx')) {
    return ReleasePlatform.macos;
  }
  if (haystack.contains('.appimage') ||
      haystack.contains('.deb') ||
      haystack.contains('.rpm') ||
      haystack.contains('linux')) {
    return ReleasePlatform.linux;
  }

  return ReleasePlatform.other;
}

List<ReleaseAsset> featuredAssets(Iterable<ReleaseAsset> assets) {
  final picked = <ReleasePlatform, ReleaseAsset>{};

  for (final asset in assets) {
    picked.putIfAbsent(asset.platform, () => asset);
  }

  final ordered = <ReleasePlatform>[
    ReleasePlatform.android,
    ReleasePlatform.windows,
    ReleasePlatform.macos,
    ReleasePlatform.linux,
    ReleasePlatform.ios,
    ReleasePlatform.other,
  ];

  return [
    for (final platform in ordered)
      if (picked.containsKey(platform)) picked[platform]!,
  ];
}

String platformLabel(ReleasePlatform platform) {
  switch (platform) {
    case ReleasePlatform.android:
      return 'Android';
    case ReleasePlatform.windows:
      return 'Windows';
    case ReleasePlatform.macos:
      return 'macOS';
    case ReleasePlatform.linux:
      return 'Linux';
    case ReleasePlatform.ios:
      return 'iOS';
    case ReleasePlatform.other:
      return '其他文件';
  }
}

String platformHint(ReleasePlatform platform) {
  switch (platform) {
    case ReleasePlatform.android:
      return '已签名的 APK 安装包。';
    case ReleasePlatform.windows:
      return 'Windows 桌面端安装程序。';
    case ReleasePlatform.macos:
      return 'macOS 桌面端安装程序。';
    case ReleasePlatform.linux:
      return '兼容常见 Linux 发行版。';
    case ReleasePlatform.ios:
      return '可签名侧载的 IPA 安装包。';
    case ReleasePlatform.other:
      return '校验文件、源码包或其他资源。';
  }
}
