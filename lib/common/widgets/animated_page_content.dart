import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:github_portfolio/common/controllers/get_controller.dart';
import 'package:github_portfolio/common/interfaces/animatble_content.dart';

enum AnimationType {
  fade, // 페이드 인/아웃
  slideRight, // 오른쪽으로 슬라이드
  slideUp, // 위로 슬라이드
  curvedSlideRight // 곡선으로 오른쪽 이동
}

class AnimatedPageContent extends StatelessWidget {
  final int pageIndex;
  final AnimatableContent content;
  final AnimationType? primaryAnimation;
  final AnimationType? secondaryAnimation;

  const AnimatedPageContent({
    super.key,
    required this.pageIndex,
    required this.content,
    this.primaryAnimation,
    this.secondaryAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WaveController>();

    return Obx(() {
      final progress = controller.scrollProgress.value;

      return Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 메인 위젯 애니메이션
                _animateWidget(
                  context,
                  content.buildPrimaryWidget(context),
                  progress,
                  primaryAnimation,
                ),
                // 보조 위젯들 애니메이션
                ...content.buildSecondaryWidgets(context).map(
                      (widget) => _animateWidget(
                        context,
                        widget,
                        progress,
                        secondaryAnimation,
                      ),
                    ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _animateWidget(
    BuildContext context,
    Widget widget,
    double progress,
    AnimationType? animation,
  ) {
    if (animation == null) return widget;

    final controller = Get.find<WaveController>();
    // 현재 페이지의 실제 진행도를 계산
    final currentProgress = controller.currentPageProgress.value - pageIndex;
    // 현재 페이지에서의 애니메이션 진행도 (0.0 ~ 1.0 사이 값으로 변환)
    final normalizedProgress = currentProgress.clamp(0.0, 1.0);

    switch (animation) {
      case AnimationType.fade:
        return Opacity(
          // 현재 페이지에 들어올 때는 opacity가 0->1로, 나갈 때는 1->0로
          opacity: currentProgress < 0 ? 1.0 : (1.0 - normalizedProgress),
          child: widget,
        );

      case AnimationType.slideRight:
        return Transform.translate(
          offset: Offset(
              currentProgress < 0
                  ? 0
                  : normalizedProgress * MediaQuery.of(context).size.width * 0.5,
              0),
          child: Opacity(
            opacity: currentProgress < 0 ? 1.0 : (1.0 - normalizedProgress),
            child: widget,
          ),
        );

      case AnimationType.slideUp:
        return Transform.translate(
          offset: Offset(
              0,
              currentProgress < 0
                  ? 0
                  : -normalizedProgress * MediaQuery.of(context).size.height * 0.3),
          child: Opacity(
            opacity: currentProgress < 0 ? 1.0 : (1.0 - normalizedProgress),
            child: widget,
          ),
        );

      case AnimationType.curvedSlideRight:
        return Transform.translate(
          offset: Offset(
            currentProgress < 0 ? 0 : normalizedProgress * MediaQuery.of(context).size.width * 0.5,
            currentProgress < 0 ? 0 : normalizedProgress * -50,
          ),
          child: Transform.rotate(
            angle: currentProgress < 0 ? 0 : normalizedProgress * 0.5,
            child: widget,
          ),
        );
    }
  }
}
