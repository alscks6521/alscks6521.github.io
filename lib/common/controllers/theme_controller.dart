import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:github_portfolio/common/theme/app_colors.dart';

class ThemeController extends GetxController {
  final _isDarkMode = false.obs;
  bool get isDarkMode => _isDarkMode.value;

  Color get waveColor1 => isDarkMode ? Colors.white : AppColors.waveBlue;

  Color get waveColor2 =>
      isDarkMode ? const Color(0xffcccccc) : const Color.fromARGB(255, 185, 199, 209);

  void toggleTheme() {
    _isDarkMode.value = !_isDarkMode.value;
    Get.changeTheme(_isDarkMode.value ? ThemeData.dark() : ThemeData.light());
  }
}
