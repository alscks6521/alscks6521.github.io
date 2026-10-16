import 'package:github_portfolio/features/project/domain/entities/project.dart';

/// 프로젝트 목록을 어디서 가져오는지(로컬 상수, 원격 CMS 등) 숨기는 경계.
abstract interface class ProjectRepository {
  List<ProjectItem> getProjects(ProjectScope scope);
}
