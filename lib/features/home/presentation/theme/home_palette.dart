import 'package:flutter/material.dart';

class HomePalette {
  final Color bg, surface, text, muted, line, accent, accentSoft;
  const HomePalette({
    required this.bg,
    required this.surface,
    required this.text,
    required this.muted,
    required this.line,
    required this.accent,
    required this.accentSoft,
  });

  static const dark = HomePalette(
    bg: Color(0xFF0B0D10),
    surface: Color(0xFF161A1E),
    text: Color(0xFFEEF1F4),
    muted: Color(0xFF9AA5B1),
    line: Color(0xFF262C32),
    accent: Color(0xFF4CC2FF),
    accentSoft: Color(0xFF12232D),
  );

  static const light = HomePalette(
    bg: Color(0xFFFFFFFF),
    surface: Color(0xFFF6F8FA),
    text: Color(0xFF14181C),
    muted: Color(0xFF5B6672),
    line: Color(0xFFE4E8EC),
    accent: Color(0xFF0A7FC2),
    accentSoft: Color(0xFFE6F4FC),
  );

  static HomePalette lerp(HomePalette a, HomePalette b, double t) =>
      HomePalette(
        bg: Color.lerp(a.bg, b.bg, t)!,
        surface: Color.lerp(a.surface, b.surface, t)!,
        text: Color.lerp(a.text, b.text, t)!,
        muted: Color.lerp(a.muted, b.muted, t)!,
        line: Color.lerp(a.line, b.line, t)!,
        accent: Color.lerp(a.accent, b.accent, t)!,
        accentSoft: Color.lerp(a.accentSoft, b.accentSoft, t)!,
      );
}
