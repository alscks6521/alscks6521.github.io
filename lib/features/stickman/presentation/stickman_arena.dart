import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:github_portfolio/features/stickman/domain/stickman_sim.dart';

/// 스크롤 영역 위에 혼자 돌아다니는 졸라맨을 올린다.
/// 하위의 [StickmanSolid]로 감싼 위젯들이 발판(가구·지형)이 되고,
/// 화면(뷰포트) 테두리는 스크롤과 함께 움직이는 벽이 된다.
class StickmanArena extends StatefulWidget {
  final ScrollController controller;
  final Color ink, paper, accent;
  final Widget child;
  const StickmanArena({
    super.key,
    required this.controller,
    required this.ink,
    required this.paper,
    required this.accent,
    required this.child,
  });

  @override
  State<StickmanArena> createState() => StickmanArenaState();
}

class StickmanArenaState extends State<StickmanArena>
    with SingleTickerProviderStateMixin {
  static const _subStep = 1 / 120;

  final _solids = <_StickmanSolidState>{};
  final _sim = StickmanSim();
  final _frame = ValueNotifier(0);
  late final Ticker _ticker = createTicker(_tick);

  Duration _last = Duration.zero;
  double _lastOffset = 0, _offset = 0;
  bool _enabled = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _enabled = !MediaQuery.disableAnimationsOf(context);
    if (_enabled && !_ticker.isActive) {
      _last = Duration.zero;
      _ticker.start();
    } else if (!_enabled && _ticker.isActive) {
      _ticker.stop();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _frame.dispose();
    super.dispose();
  }

  double get _scrollOffset {
    final c = widget.controller;
    return c.hasClients ? c.position.pixels : 0;
  }

  List<Plat> _collectPlats(RenderBox arena, double offset) {
    final out = <Plat>[];
    for (final s in _solids) {
      final ro = s.context.findRenderObject();
      if (ro is! RenderBox || !ro.attached || !ro.hasSize) continue;
      final size = ro.size;
      if (size.width < 16 || size.height < 4) continue;
      final tl = ro.localToGlobal(Offset.zero, ancestor: arena);
      out.add(Plat(s, (tl & size).shift(Offset(0, offset))));
    }
    return out;
  }

  void _tick(Duration elapsed) {
    final dt = _last == Duration.zero
        ? 1 / 60
        : ((elapsed - _last).inMicroseconds / 1e6).clamp(0.0, 1 / 20);
    _last = elapsed;

    final arena = context.findRenderObject();
    if (arena is! RenderBox || !arena.hasSize || arena.size.isEmpty) return;
    final size = arena.size;

    final offset = _scrollOffset;
    final plats = _collectPlats(arena, offset);
    if (!_sim.spawned) {
      _lastOffset = offset;
      _sim.spawn(World(
          plats: plats,
          width: size.width,
          top: offset,
          bottom: offset + size.height,
          wallStep: 0,
          dt: _subStep));
    }

    _sim.followPlatforms(plats);

    // 고정 스텝으로 쪼개서, 그 사이 벽(스크롤)도 보간해 움직인다
    final n = (dt / _subStep).ceil().clamp(1, 6);
    final h = dt / n;
    final dOff = offset - _lastOffset;
    for (var k = 0; k < n; k++) {
      final top = _lastOffset + dOff * (k + 1) / n;
      _sim.step(World(
        plats: plats,
        width: size.width,
        top: top,
        bottom: top + size.height,
        wallStep: dOff / n,
        dt: h,
      ));
    }
    _lastOffset = offset;
    _offset = offset;
    _frame.value++;
  }

  void _onDown(PointerDownEvent e) {
    final p = e.localPosition.translate(0, _scrollOffset);
    if (_enabled && _sim.hit(p)) _sim.poke(p, _subStep);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _onDown,
      child: Stack(
        fit: StackFit.expand,
        children: [
          widget.child,
          if (_enabled)
            IgnorePointer(
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: _StickmanPainter(
                    sim: _sim,
                    offset: () => _offset,
                    ink: widget.ink,
                    paper: widget.paper,
                    accent: widget.accent,
                    repaint: _frame,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 감싼 위젯의 윗면을 졸라맨이 밟을 수 있는 발판으로 만든다.
class StickmanSolid extends StatefulWidget {
  final Widget child;
  const StickmanSolid({super.key, required this.child});

  @override
  State<StickmanSolid> createState() => _StickmanSolidState();
}

class _StickmanSolidState extends State<StickmanSolid> {
  StickmanArenaState? _arena;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final a = context.findAncestorStateOfType<StickmanArenaState>();
    if (a != _arena) {
      _arena?._solids.remove(this);
      _arena = a?.._solids.add(this);
    }
  }

  @override
  void dispose() {
    _arena?._solids.remove(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _StickmanPainter extends CustomPainter {
  final StickmanSim sim;
  final double Function() offset;
  final Color ink, paper, accent;

  _StickmanPainter({
    required this.sim,
    required this.offset,
    required this.ink,
    required this.paper,
    required this.accent,
    required Listenable repaint,
  }) : super(repaint: repaint);

  @override
  void paint(Canvas canvas, Size size) {
    if (!sim.spawned) return;
    final dy = -offset();
    final p = [for (final q in sim.pts) q.translate(0, dy)];

    final line = Paint()
      ..color = ink
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final body = Path()
      ..moveTo(p[8].dx, p[8].dy)
      ..lineTo(p[7].dx, p[7].dy)
      ..lineTo(p[2].dx, p[2].dy)
      ..lineTo(p[9].dx, p[9].dy)
      ..lineTo(p[10].dx, p[10].dy)
      ..moveTo(p[2].dx, p[2].dy)
      ..lineTo(p[1].dx, p[1].dy)
      ..moveTo(p[4].dx, p[4].dy)
      ..lineTo(p[3].dx, p[3].dy)
      ..lineTo(p[1].dx, p[1].dy)
      ..lineTo(p[5].dx, p[5].dy)
      ..lineTo(p[6].dx, p[6].dy);
    canvas.drawPath(body, line);

    final head = p[0];
    canvas.drawCircle(head, headR, Paint()..color = paper);
    canvas.drawCircle(head, headR, line);

    // 어지러움 별
    if (sim.dizzy) {
      final star = Paint()..color = accent;
      for (var i = 0; i < 3; i++) {
        final a = sim.t * 5 + i * math.pi * 2 / 3;
        final c = head + Offset(math.cos(a) * 13, -10 + math.sin(a) * 4);
        _drawStar(canvas, c, 3.2, star);
      }
    }

    // 말풍선
    final text = sim.bubble;
    if (text != null) {
      final tp = TextPainter(
        text: TextSpan(
            text: text,
            style: TextStyle(
                color: accent, fontSize: 14, fontWeight: FontWeight.w800)),
        textDirection: TextDirection.ltr,
      )..layout();
      final pop = (sim.bubbleT * 6).clamp(0.0, 1.0);
      final at = head + Offset(-tp.width / 2, -headR - 8 - tp.height * pop);
      tp.paint(canvas, at);
    }
  }

  void _drawStar(Canvas canvas, Offset c, double r, Paint paint) {
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final rr = i.isEven ? r : r * 0.45;
      final a = -math.pi / 2 + i * math.pi / 5;
      final pt = c + Offset(math.cos(a) * rr, math.sin(a) * rr);
      i == 0 ? path.moveTo(pt.dx, pt.dy) : path.lineTo(pt.dx, pt.dy);
    }
    canvas.drawPath(path..close(), paint);
  }

  @override
  bool shouldRepaint(_StickmanPainter old) =>
      old.ink != ink || old.paper != paper || old.accent != accent;
}
