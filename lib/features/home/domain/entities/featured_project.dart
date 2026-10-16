import 'package:github_portfolio/features/project/domain/entities/project.dart';

/// 홈 화면 Projects 섹션에 소개하는 대표 프로젝트.
/// 상세 페이지 주소는 [scope] + [slug]로 프레젠테이션 계층에서 만든다.
class FeaturedProject {
  final String title, tag, description, role, image, tooltip;
  final ProjectScope scope;
  final String slug;
  final List<String> skills, screens;
  final double imageRadius;
  final int screenCols;
  final bool released; // App Store · Google Play 출시 여부
  const FeaturedProject(this.title, this.tag, this.description, this.role,
      this.image, this.tooltip, this.scope, this.slug, this.skills,
      {this.screens = const [],
      this.imageRadius = 0,
      this.screenCols = 4,
      this.released = false});
}
