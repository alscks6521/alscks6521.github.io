import 'package:flutter/material.dart';
import 'package:github_portfolio/features/stickman/presentation/stickman_arena.dart';
import 'package:github_portfolio/features/home/presentation/theme/home_palette.dart';

class SectionLabel extends StatelessWidget {
  final String text;
  final HomePalette palette;
  const SectionLabel(this.text, this.palette, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: StickmanSolid(
          child: Text(
            text.toUpperCase(),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
              color: palette.accent,
            ),
          ),
        ),
      );
}
