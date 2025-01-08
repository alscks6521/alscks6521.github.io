import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:github_portfolio/common/controllers/getController.dart';
import 'package:github_portfolio/common/controllers/themeController.dart';

enum AnimationType {
  fade, // 페이드 인/아웃
  slideRight, // 오른쪽으로 슬라이드
  slideUp, // 위로 슬라이드
  curvedSlideRight // 곡선으로 오른쪽 이동
}

// 애니메이션될 컨텐츠 인터페이스
abstract class AnimatableContent {
  Widget buildPrimaryWidget(BuildContext context);
  List<Widget> buildSecondaryWidgets(BuildContext context);
}

// 메인 인트로 컨텐츠
class MainIntroContent implements AnimatableContent {
  final Widget primaryWidget;
  final List<Widget> secondaryWidgets;

  MainIntroContent({
    required this.primaryWidget,
    required this.secondaryWidgets,
  });

  @override
  Widget buildPrimaryWidget(BuildContext context) => primaryWidget;

  @override
  List<Widget> buildSecondaryWidgets(BuildContext context) => secondaryWidgets;
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

    switch (animation) {
      case AnimationType.fade:
        return Opacity(
          opacity: pageIndex == 0 ? 1.0 - progress : progress,
          child: widget,
        );

      case AnimationType.slideRight:
        return Transform.translate(
          offset: Offset(progress * MediaQuery.of(context).size.width * 0.5, 0),
          child: Opacity(
            opacity: 1.0 - progress,
            child: widget,
          ),
        );

      case AnimationType.slideUp:
        return Transform.translate(
          offset: Offset(0, -progress * MediaQuery.of(context).size.height * 0.3),
          child: Opacity(
            opacity: 1.0 - progress,
            child: widget,
          ),
        );

      case AnimationType.curvedSlideRight:
        return Transform.translate(
          offset: Offset(
            progress * MediaQuery.of(context).size.width * 0.5,
            progress * -50,
          ),
          child: Transform.rotate(
            angle: progress * 0.5,
            child: Opacity(
              opacity: 1.0 - progress,
              child: widget,
            ),
          ),
        );
    }
  }
}
