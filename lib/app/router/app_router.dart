import 'package:flutter/material.dart';
import 'package:github_portfolio/app/router/app_routes.dart';
import 'package:github_portfolio/features/home/presentation/pages/home_screen.dart';
import 'package:github_portfolio/features/project/domain/entities/project.dart';
import 'package:github_portfolio/features/project/domain/usecases/get_projects.dart';
import 'package:github_portfolio/features/project/presentation/pages/project_screen.dart';
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

/// 프로젝트 페이지 문구 (프레젠테이션 관심사라 라우터에 둔다).
const _projectPages = {
  ProjectScope.app: (
    '앱 프로젝트',
    '출시 및 개발한 모바일 앱 프로젝트입니다. 카드를 선택하면 상세 정보를 볼 수 있습니다.',
  ),
  ProjectScope.web: (
    '웹 프로젝트',
    '개발한 웹 서비스 프로젝트입니다. 카드를 선택하면 상세 정보를 볼 수 있습니다.',
  ),
  ProjectScope.all: (
    '전체 프로젝트',
    '앱·웹 구분 없이 개발한 모든 프로젝트입니다. 카드를 선택하면 상세 정보를 볼 수 있습니다.',
  ),
};

/// 프로젝트 그리드 페이지. `?p=<slug>`가 있으면 들어오자마자 해당 프로젝트 상세를 펼친다.
GoRoute _projectRoute(ProjectScope scope, GetProjects getProjects) {
  final (title, description) = _projectPages[scope]!;
  return GoRoute(
    path: AppRoutes.ofScope(scope),
    pageBuilder: (context, state) => _fadePage(
      state,
      ProjectScreen(
        title: title,
        description: description,
        items: getProjects(scope),
        open: state.uri.queryParameters['p'],
      ),
    ),
  );
}

GoRouter createRouter({required GetProjects getProjects}) => GoRouter(
      initialLocation: AppRoutes.home,
      routes: [
        GoRoute(
          path: AppRoutes.home,
          pageBuilder: (context, state) => _fadePage(state, const HomeScreen()),
        ),
        for (final scope in ProjectScope.values)
          _projectRoute(scope, getProjects),
      ],
    );
