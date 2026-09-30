import 'package:flutter/material.dart';
import 'package:github_portfolio/screens/home/home_screen.dart';
import 'package:github_portfolio/screens/project/project_screen.dart';
import 'package:go_router/go_router.dart';

CustomTransitionPage<void> _fadePage(GoRouterState state, Widget child) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 500),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
        child: child,
      );
    },
  );
}

final GoRouter router = GoRouter(
  initialLocation: AppScreen.home,
  routes: [
    GoRoute(
      path: AppScreen.home,
      pageBuilder: (context, state) => _fadePage(state, const HomeScreen()),
    ),
    GoRoute(
      path: AppScreen.appPro,
      pageBuilder: (context, state) => _fadePage(
        state,
        const ProjectScreen(
          title: '앱 프로젝트',
          description: 'ISay App 프로젝트 상세 페이지를 준비 중입니다.',
        ),
      ),
    ),
    GoRoute(
      path: AppScreen.webPro,
      pageBuilder: (context, state) => _fadePage(
        state,
        const ProjectScreen(
          title: '웹 프로젝트',
          description: 'ISay Web 프로젝트 상세 페이지를 준비 중입니다.',
        ),
      ),
    ),
  ],
);

class AppScreen {
  static const home = '/home';
  static const appPro = '/app-pro';
  static const webPro = '/web-pro';
}
