import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import 'src/components/landing_page.dart';
import 'src/content/models.dart';

class App extends StatelessComponent {
  const App({required this.siteData, required this.releaseUrl, super.key});

  final SiteData siteData;
  final String releaseUrl;

  @override
  Component build(BuildContext context) {
    return Router(
      routes: [
        Route(
          path: '/',
          title: 'Home',
          settings: const RouteSettings(
            changeFreq: ChangeFreq.daily,
            priority: 1.0,
          ),
          builder: (context, state) =>
              HomePage(siteData: siteData, releaseUrl: releaseUrl),
        ),
        Route(
          path: '/download',
          title: 'Download',
          settings: const RouteSettings(
            changeFreq: ChangeFreq.daily,
            priority: 0.9,
          ),
          builder: (context, state) => DownloadPage(siteData: siteData),
        ),
        Route(
          path: '/changelog',
          title: 'Changelog',
          settings: const RouteSettings(
            changeFreq: ChangeFreq.daily,
            priority: 0.8,
          ),
          builder: (context, state) => ChangelogPage(siteData: siteData),
        ),
      ],
    );
  }
}
