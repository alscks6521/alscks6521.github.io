import 'package:flutter/material.dart';
import 'package:github_portfolio/features/home/presentation/theme/home_palette.dart';

/// 스토어 출시 인증용 작은 원형 뱃지.
class StoreBadge extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final HomePalette palette;
  final double size;
  final Color? bg, fg; // 지정하면 브랜드 색 솔리드 뱃지
  const StoreBadge(
      {super.key,
      required this.icon,
      required this.tooltip,
      required this.palette,
      this.size = 26,
      this.bg,
      this.fg});

  @override
  Widget build(BuildContext context) {
    final solid = bg != null;
    return Tooltip(
      message: tooltip,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: bg ?? palette.accentSoft,
          shape: BoxShape.circle,
          border: Border.all(
              color: solid ? palette.bg : palette.accent,
              width: solid ? 2 : 1.2),
        ),
        child: Icon(icon, size: size * 0.58, color: fg ?? palette.accent),
      ),
    );
  }
}
