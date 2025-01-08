import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:github_portfolio/common/theme/app_colors.dart';

class ThemeController extends GetxController {
  final _isDarkMode = false.obs;
  bool get isDarkMode => _isDarkMode.value;

  Color get waveColor1 =>
      isDarkMode ? Colors.white.withOpacity(0.6) : AppColors.waveBlue.withOpacity(0.6);

  Color get waveColor2 => isDarkMode
      ? const Color(0xffcccccc).withOpacity(0.3)
      : const Color(0xff444444).withOpacity(0.2);

  void toggleTheme() {
    _isDarkMode.value = !_isDarkMode.value;
    Get.changeTheme(_isDarkMode.value ? ThemeData.dark() : ThemeData.light());
  }
}
