import 'package:flutter/material.dart';
import 'package:github_portfolio/common/responsive/responsive_scope.dart';
import 'package:github_portfolio/common/theme/app_theme.dart';
import 'package:github_portfolio/l10n/app_localizations.dart';
import 'package:github_portfolio/router/app_router.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

void main() {
  setUrlStrategy(PathUrlStrategy());
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'alscks6521 Portfolio',
      theme: AppTheme.theme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
      builder: (context, child) {
        if (child == null) return const SizedBox.shrink();
        return ResponsiveBuilder(
          builder: (_, __) => child,
        );
      },
    );
  }
}
