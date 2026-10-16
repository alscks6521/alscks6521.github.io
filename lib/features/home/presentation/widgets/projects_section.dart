import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:github_portfolio/app/router/app_routes.dart';
import 'package:github_portfolio/features/stickman/presentation/stickman_arena.dart';
import 'package:github_portfolio/features/home/domain/entities/featured_project.dart';
import 'package:github_portfolio/features/home/presentation/theme/home_palette.dart';
import 'package:github_portfolio/features/home/presentation/widgets/device_link.dart';
import 'package:github_portfolio/features/home/presentation/widgets/project_network/project_network.dart';
import 'package:github_portfolio/features/home/presentation/widgets/section_label.dart';
import 'package:github_portfolio/features/home/presentation/widgets/store_badge.dart';

class ProjectsSection extends StatelessWidget {
  final HomePalette palette;
  final List<FeaturedProject> projects;
  const ProjectsSection(
      {super.key, required this.palette, required this.projects});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel('Projects', palette),
        StickmanSolid(
            child: ProjectNetwork(palette: palette, projects: projects)),
        const SizedBox(height: 24),
        for (var i = 0; i < projects.length; i++)
          _ProjectTile(
              index: i + 1,
              data: projects[i],
              palette: palette,
              last: i == projects.length - 1),
      ],
    );
  }
}

class _ProjectTile extends StatefulWidget {
  final int index;
  final FeaturedProject data;
  final HomePalette palette;
  final bool last;
  const _ProjectTile(
      {required this.index,
      required this.data,
      required this.palette,
      required this.last});

  @override
  State<_ProjectTile> createState() => _ProjectTileState();
}

class _ProjectTileState extends State<_ProjectTile> {
  final _id = UniqueKey();
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.palette;
    final data = widget.data;
    final index = widget.index;
    final last = widget.last;
    return VisibilityDetector(
      key: _id,
      onVisibilityChanged: (info) {
        if (!_open &&
            data.screens.isNotEmpty &&
            info.visibleFraction > 0.5 &&
            mounted) {
          setState(() => _open = true);
        }
      },
      child: _tile(context, c, data, index, last),
    );
  }

  Widget _tile(BuildContext context, HomePalette c, FeaturedProject data,
      int index, bool last) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: c.line),
          bottom: last ? BorderSide(color: c.line) : BorderSide.none,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('0$index', style: TextStyle(fontSize: 13, color: c.muted)),
              const Spacer(),
              SizedBox(
                height: MediaQuery.sizeOf(context).width < 520 ? 48 : 72,
                child: StickmanSolid(
                    child: DeviceLink(
                  asset: data.image,
                  tooltip: data.tooltip,
                  route: AppRoutes.projectDetail(data.scope, data.slug),
                  color: c.accent,
                  hoverScale: 1.25,
                  radius: data.imageRadius *
                      (MediaQuery.sizeOf(context).width < 520 ? 48 : 72) /
                      72,
                )),
              ),
            ],
          ),
          const SizedBox(height: 6),
          StickmanSolid(
              child: Text.rich(TextSpan(
            style: TextStyle(
                fontSize: 22,
                height: 1.4,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.4,
                color: c.text),
            children: [
              TextSpan(text: data.title),
              TextSpan(
                  text: MediaQuery.sizeOf(context).width < 520
                      ? '\n${data.tag}'
                      : '  · ${data.tag}',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: c.muted)),
            ],
          ))),
          const SizedBox(height: 12),
          StickmanSolid(
              child: Text(data.description,
                  style: TextStyle(fontSize: 17, height: 1.7, color: c.muted))),
          const SizedBox(height: 10),
          StickmanSolid(
              child: Text.rich(TextSpan(
            style: TextStyle(fontSize: 17, height: 1.7, color: c.text),
            children: [
              TextSpan(text: data.role),
              if (data.released) ...[
                const TextSpan(text: '  '),
                WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: StoreBadge(
                        icon: Icons.apple,
                        tooltip: 'App Store 출시',
                        palette: c)),
                const TextSpan(text: ' '),
                WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: StoreBadge(
                        icon: Icons.android,
                        tooltip: 'Google Play 출시',
                        palette: c)),
              ],
            ],
          ))),
          const SizedBox(height: 18),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final s in data.skills)
              StickmanSolid(
                  child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                    color: c.accentSoft,
                    borderRadius: BorderRadius.circular(999)),
                child: Text(s,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: c.accent)),
              )),
          ]),
          if (data.screens.isNotEmpty)
            _ScreenGallery(
                screens: data.screens, cols: data.screenCols, open: _open),
        ],
      ),
    );
  }
}

/// 타일이 화면에 들어오면 한 번만 아래로 부드럽게 펼쳐지며 스크린샷을 보여준다.
class _ScreenGallery extends StatelessWidget {
  final List<String> screens;
  final int cols;
  final bool open;
  const _ScreenGallery(
      {required this.screens, required this.cols, required this.open});

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeInOutCubic,
      alignment: Alignment.topCenter,
      child: open
          ? _grid(context)
          : const SizedBox(width: double.infinity, height: 0),
    );
  }

  Widget _grid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 28),
      child: LayoutBuilder(builder: (context, box) {
        const gap = 12.0;
        final cols = box.maxWidth < 520 ? (this.cols + 1) ~/ 2 : this.cols;
        final w = (box.maxWidth - gap * (cols - 1)) / cols / 2;
        final dpr = MediaQuery.devicePixelRatioOf(context);
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            // 한 줄만 보여준다.
            for (var i = 0; i < screens.length && i < cols; i++)
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: Duration(milliseconds: 600 + i * 120),
                curve: Curves.easeOut,
                builder: (context, t, child) => Opacity(
                  opacity: t,
                  child: Transform.translate(
                      offset: Offset(0, (1 - t) * 24), child: child),
                ),
                child: SizedBox(
                  width: w,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(screens[i],
                        cacheWidth: (w * dpr).round(), fit: BoxFit.fitWidth),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }
}
