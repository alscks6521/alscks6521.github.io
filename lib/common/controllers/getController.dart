import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;

class WaveController extends GetxController with GetTickerProviderStateMixin {
  final scrollProgress = 0.0.obs;
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
    // 현재 페이지의 소수점 부분을 progress로 사용
    double fractionalPart = currentPage - currentPage.floor();

    // 페이지 2(인덱스 1)에 도달했을 때 progress를 1로 설정
    if (currentPage >= 1) {
      scrollProgress.value = 1.0;
    } else {
      // 첫 페이지에서 두 번째 페이지로 이동하는 동안의 progress
      scrollProgress.value = currentPage;
    }
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

  OvalWavePainter({
    required this.progress,
    required this.isTopLeft,
    required this.color,
    required this.aspectRatio,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 그림자를 위한 Paint 객체
    final shadowPaint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

    // 메인 Paint 객체
    final paint = Paint()..style = PaintingStyle.fill;

    // 중앙으로 모일 때 흰색 변경
    Color currentColor;
    if (progress < 0.8) {
      currentColor = Color.lerp(color, Colors.transparent, progress * 4) ?? color;
    } else {
      currentColor = Colors.transparent;
    }
    paint.color = currentColor;

    const ovalRatio = 1.2;
    double baseSize = math.min(size.width, size.height);
    double initialSize = baseSize * 0.3;

    // 시작 위치 계산 (약간의 움직임 추가)
    double wobble = math.sin(animationValue * math.pi * 2) * baseSize * 0.01;
    double startX = isTopLeft ? baseSize * 0.2 + wobble : size.width - baseSize * 0.2 + wobble;
    double startY = isTopLeft ? baseSize * 0.2 + wobble : size.height - baseSize * 0.2 + wobble;

    double targetX = size.width / 2;
    double targetY = size.height / 2;

    double currentX = startX + (targetX - startX) * progress;
    double currentY = startY + (targetY - startY) * progress;

    double currentSize = initialSize + (baseSize * 0.4) * progress;
    double radiusX = currentSize * ovalRatio;
    double radiusY = currentSize;

    // 여러 레이어의 웨이브 효과 생성
    void drawWaveLayer(double phaseOffset, double amplitudeMultiplier) {
      final path = Path();

      for (double theta = 0; theta <= 2 * math.pi; theta += 0.1) {
        double waveAmplitude = baseSize * 0.05 * (1 - progress * 0.7);
        double wave1 = math.sin(theta * 1 + animationValue * math.pi * 4 + phaseOffset) *
            waveAmplitude *
            amplitudeMultiplier;
        double wave2 = math.sin(theta * 3 + animationValue * math.pi * 6 + phaseOffset) *
            waveAmplitude *
            amplitudeMultiplier *
            0.5;
        double wave3 = math.sin(theta * 1 + animationValue * math.pi * 8 + phaseOffset) *
            waveAmplitude *
            amplitudeMultiplier *
            0.3;
        double pulse = math.sin(animationValue * math.pi * 4) * waveAmplitude * 0.2;

        double combinedWave = wave1 + wave2 + wave3 + pulse;

        double x = currentX + (radiusX + combinedWave) * math.cos(theta);
        double y = currentY + (radiusY + combinedWave) * math.sin(theta);

        if (theta == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }

      path.close();

      // 그림자 그리기
      canvas.drawPath(path, shadowPaint);
      // 메인 도형 그리기
      canvas.drawPath(path, paint);
    }

    drawWaveLayer(0, 1.0);
    drawWaveLayer(math.pi / 3, 0.8);
    drawWaveLayer(math.pi / 2, 0.6);
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
      final fadeOutProgress = (progress - 0.8).clamp(0.0, 0.2) * 5; // 0.8~1.0 구간에서 페이드아웃
      final opacity = 1.0 - fadeOutProgress;

      if (progress >= 1.0) {
        return const SizedBox(); // 완전히 사라졌을 때는 렌더링하지 않음
      }

      return Opacity(
        opacity: opacity,
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
      );
    });
  }
}
