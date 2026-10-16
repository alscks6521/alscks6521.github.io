import 'package:flutter/material.dart';
import 'package:github_portfolio/app/di/app_dependencies.dart';
import 'package:github_portfolio/app/di/dependency_scope.dart';
import 'package:github_portfolio/app/router/app_router.dart';
import 'package:github_portfolio/core/responsive/responsive_scope.dart';
import 'package:github_portfolio/core/theme/app_theme.dart';
import 'package:github_portfolio/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class MyApp extends StatefulWidget {
  final AppDependencies dependencies;
  const MyApp({super.key, required this.dependencies});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router =
      createRouter(getProjects: widget.dependencies.getProjects);

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DependencyScope(
      dependencies: widget.dependencies,
      child: MaterialApp.router(
        title: 'Minsung Kim Portfolio',
        theme: AppTheme.theme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: _router,
        builder: (context, child) {
          if (child == null) return const SizedBox.shrink();
          return ResponsiveBuilder(
            builder: (_, __) => child,
          );
        },
      ),
    );
  }
}
