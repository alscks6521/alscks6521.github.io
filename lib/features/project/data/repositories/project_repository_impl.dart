import 'package:github_portfolio/features/project/data/datasources/project_local_data_source.dart';
import 'package:github_portfolio/features/project/domain/entities/project.dart';
import 'package:github_portfolio/features/project/domain/repositories/project_repository.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  final ProjectLocalDataSource _local;
  const ProjectRepositoryImpl(this._local);

  @override
  List<ProjectItem> getProjects(ProjectScope scope) => switch (scope) {
        ProjectScope.app => _local.appProjects,
        ProjectScope.web => _local.webProjects,
        ProjectScope.all => [..._local.appProjects, ..._local.webProjects],
      };
}
