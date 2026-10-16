import 'package:github_portfolio/features/project/domain/entities/project.dart';

/// 앱의 모든 경로. 문자열 경로는 여기서만 만든다.
class AppRoutes {
  static const home = '/home';
  static const appPro = '/app-pro';
  static const webPro = '/web-pro';
  static const projects = '/projects';

  static String ofScope(ProjectScope scope) => switch (scope) {
        ProjectScope.app => appPro,
        ProjectScope.web => webPro,
        ProjectScope.all => projects,
      };

  /// 프로젝트 페이지에 들어가자마자 [slug] 상세를 펼치는 주소.
  static String projectDetail(ProjectScope scope, String slug) =>
      '${ofScope(scope)}?p=$slug';
}
