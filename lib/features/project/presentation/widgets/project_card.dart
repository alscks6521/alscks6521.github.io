import 'package:flutter/material.dart';
import 'package:github_portfolio/features/project/domain/entities/project.dart';
import 'package:github_portfolio/features/project/presentation/theme/project_style.dart';
import 'package:github_portfolio/features/project/presentation/widgets/project_detail.dart';
import 'package:github_portfolio/features/project/presentation/widgets/project_heroes.dart';
import 'package:github_portfolio/features/project/presentation/widgets/store_badges.dart';

class ProjectCard extends StatefulWidget {
  final ProjectItem item;
  final int index;
  const ProjectCard({super.key, required this.item, required this.index});

  static const _pad = 20.0,
      _icon = 48.0,
      _gap = 16.0,
      _titleGap = 6.0,
      _linkGap = 12.0;
  static const _summary =
      TextStyle(fontSize: 14, height: 1.5, color: ProjectColors.muted);
  static const _link = TextStyle(
      fontSize: 13,
      height: 1.4,
      fontWeight: FontWeight.w600,
      color: ProjectColors.accent);
  static const _chip = TextStyle(
      fontSize: 12,
      height: 1.4,
      fontWeight: FontWeight.w500,
      color: ProjectColors.accent);
  static const _chipGap = 10.0, _chipPadV = 3.0;

  static double _chipHeight(TextScaler scaler) =>
      scaler.scale(_chip.fontSize!) * _chip.height! + _chipPadV * 2;

  /// 카드에 필요한 높이: 패딩·테두리 + 아이콘 + 간격 + 글자 줄 + 기술 칩 한 줄(글자 배율 반영) + 여유.
  static double extent(TextScaler scaler) {
    double line(TextStyle s) => scaler.scale(s.fontSize!) * s.height!;
    return _pad * 2 +
        2 +
        _icon +
        _gap +
        _titleGap +
        _linkGap +
        line(cardTitleStyle) +
        line(_summary) * 2 +
        line(_link) +
        _chipGap +
        _chipHeight(scaler) +
        8;
  }

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: () => openProjectDetail(context, item),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.translationValues(0, _hover ? -4 : 0, 0),
          padding: const EdgeInsets.all(ProjectCard._pad),
          decoration: BoxDecoration(
            color: ProjectColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: _hover ? ProjectColors.accent : ProjectColors.line),
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              ProjectIconHero(item: item, size: ProjectCard._icon, radius: 12),
              const Spacer(),
              if (item.released) ...[
                const StoreBadges(),
                const SizedBox(width: 12)
              ],
              Text('0${widget.index}',
                  style: const TextStyle(
                      fontSize: 13, color: ProjectColors.muted)),
            ]),
            const SizedBox(height: ProjectCard._gap),
            const Spacer(),
            ProjectTitleHero(item: item, style: cardTitleStyle, maxLines: 1),
            const SizedBox(height: ProjectCard._titleGap),
            Text(item.summary,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: ProjectCard._summary),
            const SizedBox(height: ProjectCard._chipGap),
            // 핵심 기술은 한 줄만 (넘치는 칩은 잘라서 카드 높이를 고정)
            SizedBox(
              height: ProjectCard._chipHeight(MediaQuery.textScalerOf(context)),
              child: ClipRect(
                child: Wrap(spacing: 6, runSpacing: 6, children: [
                  for (final h in item.highlights)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: ProjectCard._chipPadV),
                      decoration: BoxDecoration(
                          color: ProjectColors.accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999)),
                      child: Text(h, maxLines: 1, style: ProjectCard._chip),
                    ),
                ]),
              ),
            ),
            const SizedBox(height: ProjectCard._linkGap),
            const Text('자세히 보기 →',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: ProjectCard._link),
          ]),
        ),
      ),
    );
  }
}

/// 아직 채워지지 않은 빈 칸.
class EmptyProjectCard extends StatelessWidget {
  const EmptyProjectCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ProjectColors.line),
      ),
      child: const FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.add_rounded, size: 28, color: ProjectColors.line),
          SizedBox(height: 6),
          Text('준비 중',
              style: TextStyle(fontSize: 13, color: ProjectColors.muted)),
        ]),
      ),
    );
  }
}
