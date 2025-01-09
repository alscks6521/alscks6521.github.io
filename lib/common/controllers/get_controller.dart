import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;

class WaveController extends GetxController with GetTickerProviderStateMixin {
  final scrollProgress = 0.0.obs;
  final currentPageProgress = 0.0.obs; // 현재 페이지의 진행도를 추적하기 위한 새로운 변수
  late AnimationController animationController;
  final animationValue = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    animationController.addListener(() {
      animationValue.value = animationController.value;
    });
  }

  void updateProgress(double currentPage) {
    // Wave 애니메이션을 위한 progress 업데이트
    if (currentPage < 1.0) {
      scrollProgress.value = currentPage;
    } else if (currentPage >= 1.0) {
      scrollProgress.value = 1.0;
    }

    // 현재 페이지의 진행도 계산
    currentPageProgress.value = currentPage;
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }
}

class OvalWavePainter extends CustomPainter {
  final double progress;
  final bool isTopLeft;
  final Color color;
  final double aspectRatio;
  final double animationValue;

  // 캐시용 변수들
  late final double baseSize;
  late final double initialSize;
  late final Paint gradientPaint;

  // 캐시 변수
  static final List<double> _sineCache = List.generate(360, (i) => math.sin(i * math.pi / 180));

  double getCachedSine(double angle) {
    int index = ((angle * 180 / math.pi) % 360).floor();
    return _sineCache[index];
  }

  // 최적화를 위한 미리 계산된 상수들
  static const ovalRatio = 1.2;
  static const steps = 60; // 포인트 수를 약간 줄임
  static const stepSize = (2 * math.pi) / steps;

  OvalWavePainter({
    required this.progress,
    required this.isTopLeft,
    required this.color,
    required this.aspectRatio,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 초기화 계산을 한 번만 수행
    baseSize = math.min(size.width, size.height);
    initialSize = baseSize * 0.26;

    gradientPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = RadialGradient(
        colors: [
          color.withOpacity(0.8),
          color.withOpacity(0.5),
          color.withOpacity(0.2),
        ],
        stops: const [0.0, 0.5, 1.0],
        center: Alignment.center,
      ).createShader(Rect.fromCircle(
        center: Offset(size.width / 2, size.height / 2),
        radius: math.max(size.width, size.height) / 2,
      ));

    double targetX = size.width / 2;
    double targetY = size.height / 2;

    // Path 객체를 재사용
    final path = Path();

    void drawWaveLayer(int layerIndex, double amplitudeMultiplier) {
      // 각 레이어별 독립적인 현재 위치
      double startX = getLayerPosition(true, layerIndex, size);
      double startY = getLayerPosition(false, layerIndex, size);
      double currentX = startX + (targetX - startX) * progress;
      double currentY = startY + (targetY - startY) * progress;

      // 레이어별 크기 차별화
      double layerSizeMultiplier = 1.0 + (layerIndex * 0.1);
      double currentSize = (initialSize + (baseSize * 0.4) * progress) * layerSizeMultiplier;
      double radiusX = currentSize * ovalRatio;
      double radiusY = currentSize;

      path.reset(); // Path 재사용

      double previousX = 0;
      double previousY = 0;

      for (double i = 0; i <= steps; i++) {
        double theta = i * stepSize;
        double waveAmplitude = baseSize * 0.03 * (1 - progress * 0.7);

        // 웨이브 패턴 최적화
        double wave;
        if (layerIndex == 0) {
          wave = getFirstLayerWave(theta, waveAmplitude);
        } else {
          wave = getSecondLayerWave(theta, waveAmplitude);
        }

        wave += getPulse(layerIndex, waveAmplitude);

        double x = currentX + (radiusX + wave) * math.cos(theta);
        double y = currentY + (radiusY + wave) * math.sin(theta);

        // 급격한 변화 방지
        if (i == 0) {
          path.moveTo(x, y);
          previousX = x;
          previousY = y;
        } else {
          // 이전 점과의 거리가 너무 멀면 보간
          double distance = (x - previousX).abs() + (y - previousY).abs();
          if (distance > baseSize * 0.1) {
            x = (x + previousX) / 2;
            y = (y + previousY) / 2;
          }
          path.lineTo(x, y);
          previousX = x;
          previousY = y;
        }
      }

      path.close();
      canvas.drawPath(path, gradientPaint);
    }

    // 레이어 2개만 그리도록 수정
    drawWaveLayer(1, 0.85);
    drawWaveLayer(0, 1.0);
  }

  // 각 레이어의 웨이브 패턴을 별도 메소드로 분리
  double getFirstLayerWave(double theta, double waveAmplitude) {
    return math.sin(theta * 3 + animationValue * math.pi * 5) * waveAmplitude +
        math.cos(theta * 2 + animationValue * math.pi * 3) * waveAmplitude * 0.5;
  }

  double getSecondLayerWave(double theta, double waveAmplitude) {
    return math.sin(theta * 2 - animationValue * math.pi * 3) * waveAmplitude * 1.2 +
        math.sin(theta * 4 - animationValue * math.pi * 2) * waveAmplitude * 0.2;
  }

  double getPulse(int layerIndex, double waveAmplitude) {
    return math.sin((animationValue + layerIndex * 0.7) * math.pi * 3) * waveAmplitude * 0.3;
  }

  double getLayerPosition(bool isStart, int layerIndex, Size size) {
    double offset = math.sin((animationValue + layerIndex * 0.3) * math.pi * 2) *
        baseSize *
        0.015 *
        (3 - layerIndex);

    if (isStart) {
      return isTopLeft ? baseSize * 0.1 + offset : size.width - baseSize * 0.1 + offset;
    } else {
      return isTopLeft ? baseSize * 0.1 + offset : size.height - baseSize * 0.1 + offset;
    }
  }

  @override
  bool shouldRepaint(OvalWavePainter oldDelegate) =>
      progress != oldDelegate.progress || animationValue != oldDelegate.animationValue;
}

class WaveAnimation extends StatelessWidget {
  final bool isTopLeft;
  final Color color;

  const WaveAnimation({
    super.key,
    required this.isTopLeft,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WaveController>();
    final size = MediaQuery.of(context).size;
    final aspectRatio = size.width / size.height;

    return Obx(() {
      final progress = controller.scrollProgress.value;

      // 두 번째에서 세 번째 페이지로 넘어갈 때 서서히 사라지게 함
      final fadeOutProgress = (progress - 0.6).clamp(0.0, 0.2) * 5; // 0.~1.0 구간에서 페이드아웃
      final opacity = 1.0 - fadeOutProgress;

      if (progress >= 0.9) {
        return const SizedBox(); // 완전히 사라졌을 때는 렌더링하지 않음
      }

      return Opacity(
        opacity: opacity,
        child: RepaintBoundary(
          child: CustomPaint(
            painter: OvalWavePainter(
              progress: progress.clamp(0.0, 1.0),
              isTopLeft: isTopLeft,
              color: color,
              aspectRatio: aspectRatio,
              animationValue: controller.animationValue.value,
            ),
            child: Container(),
          ),
        ),
      );
    });
  }
}
