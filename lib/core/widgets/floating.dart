import 'package:flutter/material.dart';

class Floating extends StatefulWidget {
  final Widget child;
  final double amplitude, seconds, phase;
  const Floating(
      {super.key,
      required this.child,
      required this.amplitude,
      required this.seconds,
      this.phase = 0});

  @override
  State<Floating> createState() => _FloatState();
}

class _FloatState extends State<Floating> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: (widget.seconds * 1000).round()),
    value: widget.phase,
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curve = CurvedAnimation(parent: _c, curve: Curves.easeInOut);
    return AnimatedBuilder(
      animation: curve,
      child: widget.child,
      builder: (_, child) => Transform.translate(
        offset: Offset(0, (curve.value - 0.5) * 2 * widget.amplitude),
        child: child,
      ),
    );
  }
}
