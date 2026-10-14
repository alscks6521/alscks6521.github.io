import 'package:flutter/material.dart';
import 'package:github_portfolio/common/app_assets.dart';
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
          description: '출시 및 개발한 모바일 앱 프로젝트입니다. 카드를 선택하면 상세 정보를 볼 수 있습니다.',
          items: [
            ProjectItem(
              title: 'ISay App',
              summary: '언어 치료 아동·보호자·치료사를 연결하는 모바일 앱',
              description:
                  '언어 치료가 필요한 아동과 보호자, 그리고 치료사를 연결하여 치료 일정 관리와 상담을 지원하는 모바일 애플리케이션입니다.',
              icon: AppAssets.isayIcon,
              skills: ['Flutter', 'Riverpod', 'Kakao Auth & Map', 'iOS Auth', 'Firebase Cloud Messaging', 'PortOne API', 'WebSocket'],
              screens: AppAssets.isayScreens,
            ),
          ],
        ),
      ),
    ),
    GoRoute(
      path: AppScreen.webPro,
      pageBuilder: (context, state) => _fadePage(
        state,
        const ProjectScreen(
          title: '웹 프로젝트',
          description: '개발한 웹 서비스 프로젝트입니다. 카드를 선택하면 상세 정보를 볼 수 있습니다.',
          items: [
            ProjectItem(
              title: 'ISay Web',
              summary: '언어 치료 이용자와 치료사를 위한 관리 웹 플랫폼',
              description:
                  '언어 치료 서비스 이용자와 치료사를 위한 관리 플랫폼으로, 치료 일정 관리, 상담, 사용자 관리 기능을 제공하는 웹 서비스입니다.',
              icon: AppAssets.isayWebIcon,
              skills: ['Flutter Web', 'Dio', 'Firebase Cloud Messaging', 'PortOne JS SDK', 'WebSocket'],
              screens: AppAssets.isayWebScreens,
            ),
          ],
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
