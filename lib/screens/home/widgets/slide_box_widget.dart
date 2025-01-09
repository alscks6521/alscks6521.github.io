import 'package:flutter/material.dart';
import 'package:github_portfolio/common/interfaces/animatble_content.dart';

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
