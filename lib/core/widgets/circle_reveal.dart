import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// [center]에서 원이 화면을 덮으며 [route]로 이동한다.
void revealTo(BuildContext context, Offset center, Color color, String route) {
  final overlay = Overlay.of(context, rootOverlay: true);
  final router = GoRouter.of(context);
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _CircleReveal(
      center: center,
      color: color,
      onCovered: () => router.go(route),
      onDone: entry.remove,
    ),
  );
  overlay.insert(entry);
}

class _CircleReveal extends StatefulWidget {
  final Offset center;
  final Color color;
  final VoidCallback onCovered, onDone;
  const _CircleReveal({
    required this.center,
    required this.color,
    required this.onCovered,
    required this.onDone,
  });

  @override
  State<_CircleReveal> createState() => _CircleRevealState();
}

class _CircleRevealState extends State<_CircleReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  );
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _c.addListener(() {
      if (!_navigated && _c.value >= 0.5) {
        _navigated = true;
        widget.onCovered();
      }
    });
    _c.addStatusListener((st) {
      if (st == AnimationStatus.completed) widget.onDone();
    });
    _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final c = widget.center;
    final maxR = [
      Offset.zero,
      Offset(size.width, 0),
      Offset(0, size.height),
      Offset(size.width, size.height),
    ].map((p) => (p - c).distance).reduce((a, b) => a > b ? a : b);

    final grow = CurvedAnimation(
        parent: _c, curve: const Interval(0.0, 0.5, curve: Curves.easeInCubic));
    final fade = CurvedAnimation(
        parent: _c, curve: const Interval(0.7, 1.0, curve: Curves.easeOut));

    return AbsorbPointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, __) => CustomPaint(
          size: size,
          painter: _CirclePainter(
            center: c,
            radius: maxR * grow.value,
            color: widget.color.withValues(alpha: 1 - fade.value),
          ),
        ),
      ),
    );
  }
}

class _CirclePainter extends CustomPainter {
  final Offset center;
  final double radius;
  final Color color;
  const _CirclePainter(
      {required this.center, required this.radius, required this.color});

  @override
  void paint(Canvas canvas, Size size) =>
      canvas.drawCircle(center, radius, Paint()..color = color);

  @override
  bool shouldRepaint(_CirclePainter old) =>
      old.radius != radius || old.color != color || old.center != center;
}
