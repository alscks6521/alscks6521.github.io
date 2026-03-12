import 'dart:ui' show FontVariation;

import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:github_portfolio/common/theme/app_colors.dart';

class AppTheme {
  static const String fontFamily = 'SUIT';

  static List<FontVariation> _wght(FontWeight fontWeight) {
    // FontWeight.index는 0~8 (w100~w900)
    final weight = (fontWeight.index + 1) * 100; // 100~900
    return [FontVariation('wght', weight.toDouble())];
  }

  static TextStyle _ts({
    required double fontSize,
    required FontWeight fontWeight,
    double? letterSpacing,
    double? height,
    Color? color = Colors.black,
  }) {
    // Android에서 fontWeight만으로 적용이 불안정한 케이스가 있어서
    // fontVariations를 항상 넣고, fontWeight도 같이 둠(대부분 안정적)
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontVariations: _wght(fontWeight),
      letterSpacing: letterSpacing,
      height: height,
      color: color,
    );
  }

  static TextTheme get suitTextTheme => TextTheme(
        // 필요 범위만 유지/확장
        displayLarge: _ts(fontSize: 57, fontWeight: FontWeight.w900, letterSpacing: -0.2), //
        displayMedium: _ts(fontSize: 24, fontWeight: FontWeight.w600, letterSpacing: -0.2),
        displaySmall: _ts(fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: -0.2),

        headlineLarge: _ts(fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.2), //
        headlineMedium: _ts(fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.2), //
        headlineSmall: _ts(fontSize: 18, fontWeight: FontWeight.w700), //

        titleLarge: _ts(fontSize: 35, fontWeight: FontWeight.w600, letterSpacing: -0.2), //
        titleMedium: _ts(fontSize: 25, fontWeight: FontWeight.w400, letterSpacing: -0.2), //
        titleSmall: _ts(fontSize: 25, fontWeight: FontWeight.w200, letterSpacing: -0.2), //

        bodyLarge: _ts(fontSize: 18, fontWeight: FontWeight.w400, letterSpacing: -0.2), //
        bodyMedium: _ts(fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: -0.2), //
        bodySmall: _ts(fontSize: 18, fontWeight: FontWeight.w200, letterSpacing: -0.2),

        labelLarge: _ts(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: -0.2),
        labelMedium: _ts(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: -0.2),
        labelSmall: _ts(fontSize: 11, fontWeight: FontWeight.w400, letterSpacing: -0.2),
      );

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily, // 전역 SUIT
      textTheme: suitTextTheme, // 전역 TextTheme도 SUIT 기반

      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        },
      ),
      splashColor: Colors.transparent,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      scaffoldBackgroundColor: Colors.white,

      colorScheme: const ColorScheme.light(
        primary: AppColors.glay80,
        secondary: Color(0xFF757575),
        surface: Colors.white,
        onSurface: AppColors.glay80,
        error: AppColors.redColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        outline: AppColors.line,
        surfaceContainerHighest: Color(0xFFF5F5F5),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.glay80),
        titleTextStyle: _ts(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.glay80,
        ),
      ),
    );
  }

  // “자주 쓰는 프리셋”도 전부 SUIT로 통일
  static TextStyle suit({double size = 14, FontWeight w = FontWeight.w400, Color? color}) =>
      _ts(fontSize: size, fontWeight: w, color: color);

  static TextStyle suitBoldText(
          {double fontSize = 22, Color? color, double? letterSpacing = -0.2, double? height = 1}) =>
      _ts(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: letterSpacing,
          height: height);

  static TextStyle suitExtraBoldText(
          {double fontSize = 20, Color? color, double? letterSpacing = -0.4, double? height = 1}) =>
      _ts(
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: letterSpacing,
          height: height);
}
