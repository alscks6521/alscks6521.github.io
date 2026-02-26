import 'package:flutter/material.dart';
import 'breakpoints.dart';

enum DeviceType { mobile, tablet, desktop }

@immutable
class ResponsiveSpec {
  final double width;
  final double height;
  final DeviceType device;

  // 공통 규격 (너 프로젝트에 맞게 고정)
  final double maxStageHeight; // tablet/desktop에서 전체 높이 제한
  final double contentMaxWidth; // 데스크탑에서 본문 폭 제한 같은 것

  const ResponsiveSpec({
    required this.width,
    required this.height,
    required this.device,
    required this.maxStageHeight,
    required this.contentMaxWidth,
  });

  bool get isMobile => device == DeviceType.mobile;
  bool get isTablet => device == DeviceType.tablet;
  bool get isDesktop => device == DeviceType.desktop;

  bool get homeScreenHeight => height < 400;
}

class ResponsiveScope extends InheritedWidget {
  final ResponsiveSpec spec;

  const ResponsiveScope({
    super.key,
    required this.spec,
    required super.child,
  });

  static ResponsiveSpec of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ResponsiveScope>();
    assert(scope != null, 'ResponsiveScope가 트리에 없습니다.');
    return scope!.spec;
  }

  @override
  bool updateShouldNotify(ResponsiveScope oldWidget) => spec != oldWidget.spec;
}

class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext, ResponsiveSpec) builder;
  const ResponsiveBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final h = c.maxHeight;

        final device = (w < Breakpoints.mobile)
            ? DeviceType.mobile
            : (w < Breakpoints.tablet)
                ? DeviceType.tablet
                : DeviceType.desktop;

        // “브라우저 전체 높이 제한” 공통 정책을 여기서 통일
        final maxStageHeight = switch (device) {
          DeviceType.mobile => double.infinity,
          DeviceType.tablet => 900,
          DeviceType.desktop => 1000,
        };

        // 데스크탑 본문 폭 같은 공통 제한도 여기서 관리 가능
        final contentMaxWidth = (device == DeviceType.desktop) ? w * 0.9 : w;

        final spec = ResponsiveSpec(
          width: w,
          height: h,
          device: device,
          maxStageHeight: maxStageHeight.toDouble(),
          contentMaxWidth: contentMaxWidth,
        );

        return ResponsiveScope(
          spec: spec,
          child: builder(context, spec),
        );
      },
    );
  }
}
