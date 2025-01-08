import 'package:flutter/material.dart';

// mouse_follower_wrapper.dart
class MouseFollowerWrapper extends StatefulWidget {
  final Widget child;

  const MouseFollowerWrapper({
    super.key,
    required this.child,
  });

  @override
  State<MouseFollowerWrapper> createState() => _MouseFollowerWrapperState();
}

class _MouseFollowerWrapperState extends State<MouseFollowerWrapper>
    with SingleTickerProviderStateMixin {
  Offset _position = Offset.zero;
  late AnimationController _controller;
  Animation<Offset>? _animation;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _animation = Tween<Offset>(
      begin: _position,
      end: _position,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updatePosition(PointerEvent details) {
    _animation = Tween<Offset>(
      begin: _position,
      end: details.position,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    setState(() {
      _position = details.position;
      _isVisible = true;
    });

    _controller.forward(from: 0);
  }

  void _onExit(PointerEvent details) {
    setState(() {
      _isVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      // Directionality 추가
      textDirection: TextDirection.ltr,
      child: Stack(
        alignment: Alignment.topLeft, // alignment 명시적 지정
        children: [
          widget.child,
          Positioned.fill(
            child: MouseRegion(
              opaque: false,
              onHover: _updatePosition,
              onExit: _onExit,
            ),
          ),
          if (_isVisible)
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final position = _animation?.value ?? _position;
                return Positioned(
                  left: position.dx - 8,
                  top: position.dy - 10,
                  child: IgnorePointer(
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.withOpacity(0.2),
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
