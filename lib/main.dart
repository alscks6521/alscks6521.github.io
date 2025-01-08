import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:github_portfolio/common/controllers/themeController.dart';
import 'package:github_portfolio/common/theme/app_theme.dart';
import 'package:github_portfolio/common/widgets/mouse_widget.dart';
import 'package:github_portfolio/router/app_router.dart';

void main() {
  Get.put(ThemeController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return MouseFollowerWrapper(
      child: Obx(() => MaterialApp.router(
            title: 'alscks6521 Portfolio',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeController.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            routerConfig: router,
          )),
    );
  }
}
