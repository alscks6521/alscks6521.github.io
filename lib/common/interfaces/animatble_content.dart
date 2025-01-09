// 애니메이션될 컨텐츠 인터페이스
import 'package:flutter/material.dart';

abstract class AnimatableContent {
  Widget buildPrimaryWidget(BuildContext context);
  List<Widget> buildSecondaryWidgets(BuildContext context);
}
