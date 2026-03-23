import 'package:test/test.dart';

import 'package:novella_site/src/content/models.dart';
import 'package:novella_site/src/utils/platform_assets.dart';

void main() {
  group('detectReleasePlatform', () {
    test('detects mobile assets', () {
      expect(detectReleasePlatform('novella.apk'), ReleasePlatform.android);
      expect(detectReleasePlatform('novella.ipa'), ReleasePlatform.ios);
    });

    test('detects desktop assets', () {
      expect(
        detectReleasePlatform('novella-setup.exe'),
        ReleasePlatform.windows,
      );
      expect(detectReleasePlatform('novella.dmg'), ReleasePlatform.macos);
      expect(detectReleasePlatform('novella.AppImage'), ReleasePlatform.linux);
      expect(detectReleasePlatform('novella.deb'), ReleasePlatform.linux);
    });

    test('falls back to other', () {
      expect(detectReleasePlatform('checksums.txt'), ReleasePlatform.other);
      expect(detectReleasePlatform('source.tar.gz'), ReleasePlatform.other);
    });
  });

  test('featuredAssets keeps one asset per platform in priority order', () {
    final assets = [
      _asset('checksums.txt', ReleasePlatform.other),
      _asset('novella.dmg', ReleasePlatform.macos),
      _asset('novella.apk', ReleasePlatform.android),
      _asset('novella-setup.exe', ReleasePlatform.windows),
      _asset('novella-setup-2.exe', ReleasePlatform.windows),
    ];

    final featured = featuredAssets(assets);

    expect(featured.map((item) => item.platform).toList(), [
      ReleasePlatform.android,
      ReleasePlatform.windows,
      ReleasePlatform.macos,
      ReleasePlatform.other,
    ]);
    expect(
      featured.where((item) => item.platform == ReleasePlatform.windows).length,
      1,
    );
  });
}

ReleaseAsset _asset(String name, ReleasePlatform platform) {
  return ReleaseAsset(
    name: name,
    url: 'https://example.com/$name',
    size: 1024,
    downloadCount: 0,
    contentType: 'application/octet-stream',
    updatedAt: DateTime.utc(2026, 3, 23),
    platform: platform,
  );
}
