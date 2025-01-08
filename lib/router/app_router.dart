import 'package:flutter/material.dart';
import 'package:github_portfolio/screens/home/home_screen.dart';
import 'package:github_portfolio/screens/splash/splash_screen.dart';
import 'package:go_router/go_router.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => const NoTransitionPage(
        child: SplashScreen(),
      ),
    ),
    GoRoute(
      path: AppScreen.home,
      pageBuilder: (context, state) => CustomTransitionPage(
        child: const HomeScreen(),
        transitionDuration: const Duration(milliseconds: 500),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurveTween(
              curve: Curves.easeInOut,
            ).animate(animation),
            child: child,
          );
        },
      ),
    ),
  ],
);

class AppScreen {
  static const home = '/home';
}
