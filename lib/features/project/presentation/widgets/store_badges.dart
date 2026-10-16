import 'package:flutter/material.dart';
import 'package:github_portfolio/features/project/presentation/theme/project_style.dart';

/// App Store · Google Play 출시 인증용 작은 원형 뱃지 두 개.
class StoreBadges extends StatelessWidget {
  const StoreBadges({super.key});

  @override
  Widget build(BuildContext context) {
    Widget badge(IconData icon, String tip) => Tooltip(
          message: tip,
          child: Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: ProjectColors.accent.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(color: ProjectColors.accent, width: 1.2),
            ),
            child: Icon(icon, size: 15, color: ProjectColors.accent),
          ),
        );
    return Row(mainAxisSize: MainAxisSize.min, children: [
      badge(Icons.apple, 'App Store 출시'),
      const SizedBox(width: 6),
      badge(Icons.android, 'Google Play 출시'),
    ]);
  }
}
