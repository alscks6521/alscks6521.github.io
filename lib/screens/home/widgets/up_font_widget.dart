import 'package:flutter/material.dart';

class WaveText extends StatefulWidget {
  final String text;
  const WaveText(this.text, {super.key});

  @override
  State<WaveText> createState() => _WaveTextState();
}

class _WaveTextState extends State<WaveText> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<Offset>> _animations;
  late List<Animation<double>> _opacityAnimations; // 불투명도 애니메이션 추가

  @override
  void initState() {
    super.initState();

    _controllers = List.generate(
      widget.text.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 800),
        vsync: this,
      ),
    );

    _animations = List.generate(
      widget.text.length,
      (index) => Tween<Offset>(
        begin: const Offset(0, 1.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _controllers[index],
        curve: Curves.easeOutCubic,
      )),
    );

    // 불투명도 애니메이션 설정
    _opacityAnimations = List.generate(
      widget.text.length,
      (index) => Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _controllers[index],
        curve: Curves.easeIn,
      )),
    );

    for (var i = 0; i < widget.text.length; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        _controllers[i].forward();
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        widget.text.length,
        (index) => SlideTransition(
          position: _animations[index],
          child: FadeTransition(
            opacity: _opacityAnimations[index],
            child: Text(
              widget.text[index],
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
