import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:github_portfolio/router/app_router.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late Animation<double> _logoRotation;
  late Animation<double> _logoScale;
  late Animation<double> _textOpacity;
  late List<Particle> particles;

  @override
  void initState() {
    super.initState();

    // 로고 애니메이션 컨트롤러
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1600),
      vsync: this,
    );

    // 텍스트 ''
    _textController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // 로고 회전 ''
    _logoRotation = Tween<double>(
      begin: 0,
      end: 1 * math.pi,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeInOutBack,
    ));

    // 로고 크기 ''
    _logoScale = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    // 텍스트 페이드 인 ''
    _textOpacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeInOut,
    ));

    // 파티클 초기화
    particles = List.generate(50, (index) => Particle());

    // 애니메이션 Go
    _logoController.forward();

    // 텍스트 Go
    Future.delayed(const Duration(milliseconds: 200), () {
      _textController.forward();
    });

    // 홈 화면으로 이동하기 전에 페이드아웃 효과 추가
    Future.delayed(const Duration(milliseconds: 1600), () async {
      // 기존 컨텐츠 페이드아웃 텍스트 => 로고
      await _textController.reverse();
      await _logoController.reverse();

      // 홈 화면으로 전환
      if (mounted) {
        context.go(AppScreen.home);
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor 테마
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // 파티클
          ...particles.map((particle) => ParticleWidget(
                particle: particle,
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.blue,
              )),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 회전하는 로고
                AnimatedBuilder(
                  animation: _logoController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _logoScale.value,
                      child: Transform.rotate(
                        angle: _logoRotation.value,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.code,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),

                // 페이드인되는 텍스트
                FadeTransition(
                  opacity: _textOpacity,
                  child: Column(
                    children: [
                      Text(
                        '반가워요',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 8,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        '치료사',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 파티클 클래스
class Particle {
  double x = math.Random().nextDouble() * 400;
  double y = math.Random().nextDouble() * 800;
  double size = math.Random().nextDouble() * 4 + 2;
  double speed = math.Random().nextDouble() * 2 + 1;
  double opacity = math.Random().nextDouble();
}

// 파티클 위젯
class ParticleWidget extends StatefulWidget {
  final Particle particle;
  final Color? color; // 색상 파라미터 추가

  const ParticleWidget({
    super.key,
    required this.particle,
    this.color, // 선택적 색상 파라미터
  });

  @override
  State<ParticleWidget> createState() => _ParticleWidgetState();
}

class _ParticleWidgetState extends State<ParticleWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 테마에 따른 기본 색상 설정
    final defaultColor =
        Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.blue;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        widget.particle.y -= widget.particle.speed;
        if (widget.particle.y < 0) {
          widget.particle.y = 800;
        }

        return Positioned(
          left: widget.particle.x,
          top: widget.particle.y,
          child: Container(
            width: widget.particle.size,
            height: widget.particle.size,
            decoration: BoxDecoration(
              // 제공된 색상이 있으면 사용하고, 없으면 테마 기반 기본 색상 사용
              color: (widget.color ?? defaultColor).withOpacity(widget.particle.opacity * 0.5),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}
