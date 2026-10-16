import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:github_portfolio/app/router/app_routes.dart';
import 'package:github_portfolio/core/widgets/circle_reveal.dart';
import 'package:github_portfolio/features/home/domain/entities/featured_project.dart';
import 'package:github_portfolio/features/home/presentation/theme/home_palette.dart';
import 'package:github_portfolio/features/home/presentation/widgets/device_link.dart';
import 'package:github_portfolio/features/home/presentation/widgets/pill_button.dart';
import 'package:github_portfolio/features/home/presentation/widgets/project_network/net_geometry.dart';
import 'package:github_portfolio/features/home/presentation/widgets/project_network/net_painter.dart';
import 'package:github_portfolio/features/home/presentation/widgets/store_badge.dart';

/// 프로젝트 섹션 인트로: 가운데 코어가 스윽 생기고, 시냅스를 따라
/// 프로젝트 아이콘과 기술 스택 뉴런이 사방으로 퍼지는 신경망 연출.
class ProjectNetwork extends StatefulWidget {
  final HomePalette palette;
  final List<FeaturedProject> projects;
  const ProjectNetwork(
      {super.key, required this.palette, required this.projects});

  @override
  State<ProjectNetwork> createState() => _ProjectNetworkState();
}

class _ProjectNetworkState extends State<ProjectNetwork>
    with TickerProviderStateMixin {
  final _id = UniqueKey();
  late final AnimationController _intro = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2800));
  late final AnimationController _loop =
      AnimationController(vsync: this, duration: const Duration(seconds: 6));
  bool _started = false;
  bool _coreHover = false;
  final _coreKey = GlobalKey();
  NetGeometry? _geo;

  /// 가운데 코어 클릭 → 작은 팝업 → 코어에서 원이 퍼지며 전체 프로젝트로 이동.
  Future<void> _openAll() async {
    final c = widget.palette;
    final go = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: '닫기',
      barrierColor: Colors.black.withValues(alpha: 0.35),
      transitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (_, __, ___) => _AllProjectsPopup(palette: c),
      transitionBuilder: (_, a, __, child) => FadeTransition(
        opacity: a,
        child: ScaleTransition(
          scale: Tween(begin: 0.9, end: 1.0).animate(CurvedAnimation(
              parent: a,
              curve: Curves.easeOutBack,
              reverseCurve: Curves.easeIn)),
          child: child,
        ),
      ),
    );
    if (go != true || !mounted) return;
    final box = _coreKey.currentContext?.findRenderObject() as RenderBox?;
    final center = box != null && box.attached
        ? box.localToGlobal(box.size.center(Offset.zero))
        : MediaQuery.sizeOf(context).center(Offset.zero);
    revealTo(context, center, c.accent, AppRoutes.projects);
  }

  @override
  void dispose() {
    _intro.dispose();
    _loop.dispose();
    super.dispose();
  }

  void _onVisible(VisibilityInfo info) {
    if (!mounted) return;
    final still = MediaQuery.of(context).disableAnimations;
    if (info.visibleFraction > 0.3) {
      if (!_started) {
        _started = true;
        still ? _intro.value = 1 : _intro.forward();
      }
      if (!still && !_loop.isAnimating) _loop.repeat();
    } else if (info.visibleFraction == 0) {
      _loop.stop(); // 화면 밖에서는 루프를 멈춘다.
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.palette;
    return VisibilityDetector(
      key: _id,
      onVisibilityChanged: _onVisible,
      child: LayoutBuilder(builder: (context, box) {
        final w = box.maxWidth;
        final narrow = w < 560;
        final size = Size(w, narrow ? 460.0 : 520.0);
        final g = _geo != null && _geo!.size == size
            ? _geo!
            : (_geo = NetGeometry.of(size, narrow, widget.projects));

        return SizedBox.fromSize(
          size: size,
          child: AnimatedBuilder(
            animation: Listenable.merge([_intro, _loop]),
            builder: (context, _) {
              final t = _intro.value, l = _loop.value;
              final nodes = [
                for (var i = 0; i < g.nodes.length; i++)
                  g.nodes[i] + g.float(i, l)
              ];
              final coreIn = netInterval(t, 0, 0.34);
              final breath = 0.5 + 0.5 * math.sin(2 * math.pi * l * 2);

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: CustomPaint(painter: NetPainter(g, nodes, t, l, c)),
                  ),
                  // 기술 스택 뉴런 툴팁 영역
                  for (var i = 0; i < nodes.length; i++)
                    for (var j = 0; j < g.sats[i].length; j++)
                      if (netInterval(
                              t, g.satStart(i, j), g.satStart(i, j) + 0.2) >=
                          1)
                        Positioned(
                          left: (nodes[i] + g.sats[i][j]).dx - 11,
                          top: (nodes[i] + g.sats[i][j]).dy - 11,
                          width: 22,
                          height: 22,
                          child: Tooltip(
                            message: widget.projects[i].skills[j],
                            waitDuration: Duration.zero,
                            child: const MouseRegion(child: SizedBox.expand()),
                          ),
                        ),
                  // 가운데 코어
                  Positioned(
                    left: g.center.dx - g.coreR,
                    top: g.center.dy - g.coreR,
                    width: g.coreR * 2,
                    height: g.coreR * 2,
                    child: Opacity(
                      opacity: coreIn,
                      child: Transform.scale(
                        scale: 0.45 + 0.55 * coreIn,
                        child: Tooltip(
                          message: '전체 프로젝트 보기',
                          waitDuration: const Duration(milliseconds: 300),
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            onEnter: (_) => setState(() => _coreHover = true),
                            onExit: (_) => setState(() => _coreHover = false),
                            child: GestureDetector(
                              onTap: _openAll,
                              child: AnimatedScale(
                                key: _coreKey,
                                scale: _coreHover ? 1.08 : 1.0,
                                duration: const Duration(milliseconds: 240),
                                curve: Curves.easeOutBack,
                                child: _NetCore(
                                  palette: c,
                                  narrow: narrow,
                                  glow: (_coreHover ? 0.34 : 0.18) +
                                      0.14 * breath * netInterval(t, 0.6, 1),
                                  textIn: netInterval(t, 0.14, 0.42),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // 프로젝트 노드
                  for (var i = 0; i < nodes.length; i++)
                    ..._node(i, nodes[i], g, t, narrow, c),
                ],
              );
            },
          ),
        );
      }),
    );
  }

  List<Widget> _node(
      int i, Offset p, NetGeometry g, double t, bool narrow, HomePalette c) {
    final data = widget.projects[i];
    final a = 0.46 + i * 0.08;
    final pop = netInterval(t, a, a + 0.26, Curves.easeOutBack);
    final fade = netInterval(t, a, a + 0.14);
    final badge = netInterval(t, a + 0.22, a + 0.42, Curves.easeOutBack);
    final d = g.nodeD;
    return [
      Positioned(
        left: p.dx - d / 2,
        top: p.dy - d / 2,
        width: d,
        height: d,
        child: IgnorePointer(
          ignoring: fade < 1,
          child: Opacity(
            opacity: fade,
            child: Transform.scale(
              scale: pop,
              child: _NetNode(data: data, palette: c, size: d, badgeIn: badge),
            ),
          ),
        ),
      ),
      Positioned(
        left: p.dx - 90,
        top: p.dy + d / 2 + 10,
        width: 180,
        child: IgnorePointer(
          child: Opacity(
            opacity: netInterval(t, a + 0.12, a + 0.32),
            child: Column(
              children: [
                Text(data.tag,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: c.text)),
                if (!narrow)
                  Text(data.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: c.muted)),
              ],
            ),
          ),
        ),
      ),
    ];
  }
}

class _NetCore extends StatelessWidget {
  final HomePalette palette;
  final bool narrow;
  final double glow, textIn;
  const _NetCore(
      {required this.palette,
      required this.narrow,
      required this.glow,
      required this.textIn});

  @override
  Widget build(BuildContext context) {
    final c = palette;
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [c.accentSoft, c.bg]),
        border: Border.all(color: c.accent.withValues(alpha: 0.55), width: 1.5),
        boxShadow: [
          BoxShadow(
              color: c.accent.withValues(alpha: glow),
              blurRadius: 48,
              spreadRadius: 2),
        ],
      ),
      child: Opacity(
        opacity: textIn,
        child: Transform.translate(
          offset: Offset(0, (1 - textIn) * 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('PROJECTS',
                  style: TextStyle(
                      fontSize: narrow ? 9 : 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                      color: c.accent)),
              const SizedBox(height: 4),
              Text('App\nWeb\nLLM',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: narrow ? 13 : 15,
                      height: 1.25,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                      color: c.text)),
            ],
          ),
        ),
      ),
    );
  }
}

class _AllProjectsPopup extends StatelessWidget {
  final HomePalette palette;
  const _AllProjectsPopup({required this.palette});

  @override
  Widget build(BuildContext context) {
    final c = palette;
    void close(bool go) => Navigator.of(context).pop(go);
    return Center(
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          width: 300,
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: c.line),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25), blurRadius: 30)
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration:
                    BoxDecoration(color: c.accentSoft, shape: BoxShape.circle),
                child: Icon(Icons.grid_view_rounded, size: 19, color: c.accent),
              ),
              const SizedBox(height: 14),
              Text('전체 프로젝트',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: c.text)),
              const SizedBox(height: 6),
              Text('App · Web 구분 없이 모든 프로젝트를 한곳에서 볼 수 있어요.',
                  style: TextStyle(fontSize: 14, height: 1.6, color: c.muted)),
              const SizedBox(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                PillButton(label: '닫기', palette: c, onTap: () => close(false)),
                const SizedBox(width: 8),
                PillButton(
                    label: '보러 가기',
                    primary: true,
                    palette: c,
                    onTap: () => close(true)),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

class _NetNode extends StatelessWidget {
  final FeaturedProject data;
  final HomePalette palette;
  final double size, badgeIn;
  const _NetNode(
      {required this.data,
      required this.palette,
      required this.size,
      required this.badgeIn});

  @override
  Widget build(BuildContext context) {
    final c = palette;
    final b = size < 80 ? 20.0 : 24.0;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: c.surface,
              border:
                  Border.all(color: c.accent.withValues(alpha: 0.6), width: 2),
              boxShadow: [
                BoxShadow(
                    color: c.accent.withValues(alpha: 0.28), blurRadius: 24)
              ],
            ),
          ),
        ),
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: DeviceLink(
              asset: data.image,
              tooltip: data.tooltip,
              route: AppRoutes.projectDetail(data.scope, data.slug),
              color: c.accent,
              hoverScale: 1.1,
              radius: size,
            ),
          ),
        ),
        // 상단 우측 스토어 출시 뱃지
        if (data.released && badgeIn > 0)
          Positioned(
            top: -b * 0.2,
            right: -b * 0.7,
            child: Transform.scale(
              scale: badgeIn,
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                StoreBadge(
                    icon: Icons.apple,
                    tooltip: 'App Store 출시',
                    palette: c,
                    size: b,
                    bg: c.text,
                    fg: c.bg),
                const SizedBox(width: 2),
                StoreBadge(
                    icon: Icons.android,
                    tooltip: 'Google Play 출시',
                    palette: c,
                    size: b,
                    bg: const Color(0xFF3DDC84),
                    fg: const Color(0xFF073042)),
              ]),
            ),
          ),
      ],
    );
  }
}
