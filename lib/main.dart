import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:github_portfolio/common/controllers/theme_controller.dart';
import 'package:github_portfolio/common/theme/app_theme.dart';
import 'package:github_portfolio/common/widgets/mouse_widget.dart';
import 'package:github_portfolio/router/app_router.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

void main() {
  Get.put(ThemeController());
  // Hash 방식을 Path 방식으로
  setUrlStrategy(PathUrlStrategy());
  WidgetsFlutterBinding.ensureInitialized();
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
