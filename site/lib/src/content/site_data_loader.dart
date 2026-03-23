import 'dart:convert';
import 'dart:io';

import 'models.dart';

class SiteDataLoader {
  const SiteDataLoader({
    this.generatedPath = '.generated/site_data.json',
  });

  final String generatedPath;

  Future<SiteData> load() async {
    final generatedFile = File(generatedPath);
    if (await generatedFile.exists()) {
      return parse(await generatedFile.readAsString());
    }

    throw StateError(
      'No site data found at "$generatedPath". '
      'Run `dart run tool/fetch_site_data.dart` first.',
    );
  }

  SiteData parse(String source) {
    return SiteData.fromJson(jsonDecode(source) as Map<String, dynamic>);
  }
}

