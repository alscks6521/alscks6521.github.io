import 'package:flutter/material.dart';
import 'package:github_portfolio/features/home/domain/entities/skill_group.dart';
import 'package:github_portfolio/features/stickman/presentation/stickman_arena.dart';
import 'package:github_portfolio/features/home/presentation/theme/home_palette.dart';
import 'package:github_portfolio/features/home/presentation/widgets/section_label.dart';

class SkillsSection extends StatelessWidget {
  final HomePalette palette;
  final List<SkillGroup> skills;
  const SkillsSection({super.key, required this.palette, required this.skills});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel('Skills', palette),
        for (final r in skills)
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: StickmanSolid(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r.label,
                    style: TextStyle(fontSize: 14, color: palette.muted)),
                const SizedBox(height: 6),
                Text(r.value,
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: palette.text)),
              ],
            )),
          ),
      ],
    );
  }
}
