import 'package:flutter/material.dart';
import 'package:github_portfolio/core/widgets/circle_reveal.dart';

class DeviceLink extends StatefulWidget {
  final String asset, tooltip, route;
  final Color color;
  final double hoverScale, radius;
  const DeviceLink({
    super.key,
    required this.asset,
    required this.tooltip,
    required this.route,
    required this.color,
    this.hoverScale = 1.12,
    this.radius = 0,
  });

  @override
  State<DeviceLink> createState() => _DeviceLinkState();
}

class _DeviceLinkState extends State<DeviceLink> {
  bool _hover = false;
  bool _busy = false;

  void _go() {
    if (_busy) return;
    setState(() => _busy = true);

    final box = context.findRenderObject() as RenderBox;
    revealTo(context, box.localToGlobal(box.size.center(Offset.zero)),
        widget.color, widget.route);

    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) setState(() => _busy = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final active = _hover || _busy;
    return Tooltip(
      message: widget.tooltip,
      waitDuration: Duration.zero,
      preferBelow: false,
      textStyle: const TextStyle(
          fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
      decoration: BoxDecoration(
        color: const Color(0xFF14181C),
        borderRadius: BorderRadius.circular(8),
      ),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _go,
          child: AnimatedScale(
            scale: active ? widget.hoverScale : 1.0,
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutBack,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(widget.radius),
              child: Image.asset(widget.asset),
            ),
          ),
        ),
      ),
    );
  }
}
