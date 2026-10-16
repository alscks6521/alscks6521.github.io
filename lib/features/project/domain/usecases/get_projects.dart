import 'package:github_portfolio/features/project/domain/entities/project.dart';
import 'package:github_portfolio/features/project/domain/repositories/project_repository.dart';

class GetProjects {
  final ProjectRepository _repository;
  const GetProjects(this._repository);

  List<ProjectItem> call(ProjectScope scope) => _repository.getProjects(scope);
}
