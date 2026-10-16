import 'package:flutter/material.dart';
import 'package:github_portfolio/screens/home/home_screen.dart';
import 'package:github_portfolio/screens/project/project_data.dart';
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

/// 프로젝트 그리드 페이지. `?p=<slug>`가 있으면 들어오자마자 해당 프로젝트 상세를 펼친다.
GoRoute _projectRoute(String path, String title, String description, List<ProjectItem> items) =>
    GoRoute(
      path: path,
      pageBuilder: (context, state) => _fadePage(
        state,
        ProjectScreen(
          title: title,
          description: description,
          items: items,
          open: state.uri.queryParameters['p'],
        ),
      ),
    );

final GoRouter router = GoRouter(
  initialLocation: AppScreen.home,
  routes: [
    GoRoute(
      path: AppScreen.home,
      pageBuilder: (context, state) => _fadePage(state, const HomeScreen()),
    ),
    _projectRoute(AppScreen.appPro, '앱 프로젝트',
        '출시 및 개발한 모바일 앱 프로젝트입니다. 카드를 선택하면 상세 정보를 볼 수 있습니다.', appProjects),
    _projectRoute(AppScreen.webPro, '웹 프로젝트',
        '개발한 웹 서비스 프로젝트입니다. 카드를 선택하면 상세 정보를 볼 수 있습니다.', webProjects),
    _projectRoute(AppScreen.projects, '전체 프로젝트',
        '앱·웹 구분 없이 개발한 모든 프로젝트입니다. 카드를 선택하면 상세 정보를 볼 수 있습니다.', allProjects),
  ],
);

class AppScreen {
  static const home = '/home';
  static const appPro = '/app-pro';
  static const webPro = '/web-pro';
  static const projects = '/projects';
}
