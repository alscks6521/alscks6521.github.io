import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

class Reveal extends StatefulWidget {
  final Widget child;
  const Reveal({super.key, required this.child});

  @override
  State<Reveal> createState() => _RevealState();
}

class _RevealState extends State<Reveal> {
  final _id = UniqueKey();
  bool _shown = false;

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: _id,
      onVisibilityChanged: (info) {
        if (!_shown && info.visibleFraction > 0.05 && mounted) {
          setState(() => _shown = true);
        }
      },
      child: AnimatedOpacity(
        opacity: _shown ? 1 : 0,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOut,
        child: AnimatedSlide(
          offset: _shown ? Offset.zero : const Offset(0, 0.02),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOut,
          child: widget.child,
        ),
      ),
    );
  }
}
