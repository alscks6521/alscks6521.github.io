import 'package:flutter/widgets.dart';
import 'package:github_portfolio/app/di/app_dependencies.dart';

/// 위젯 트리 어디서든 `DependencyScope.of(context)`로 유스케이스를 꺼내 쓴다.
class DependencyScope extends InheritedWidget {
  final AppDependencies dependencies;
  const DependencyScope(
      {super.key, required this.dependencies, required super.child});

  static AppDependencies of(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<DependencyScope>();
    assert(scope != null, 'DependencyScope가 위젯 트리 위에 없습니다.');
    return scope!.dependencies;
  }

  @override
  bool updateShouldNotify(DependencyScope oldWidget) =>
      dependencies != oldWidget.dependencies;
}
