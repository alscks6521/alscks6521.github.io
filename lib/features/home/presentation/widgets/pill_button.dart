import 'package:flutter/material.dart';
import 'package:github_portfolio/features/stickman/presentation/stickman_arena.dart';
import 'package:github_portfolio/features/home/presentation/theme/home_palette.dart';

class PillButton extends StatefulWidget {
  final String label;
  final bool primary;
  final VoidCallback onTap;
  final HomePalette palette;
  const PillButton(
      {super.key,
      required this.label,
      required this.onTap,
      required this.palette,
      this.primary = false});

  @override
  State<PillButton> createState() => _PillState();
}

class _PillState extends State<PillButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.palette;
    final bg =
        widget.primary ? c.text : (_hover ? c.surface : Colors.transparent);
    return StickmanSolid(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: widget.primary ? c.text : c.line),
            ),
            child: Text(
              widget.label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: widget.primary ? c.bg : c.text,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
