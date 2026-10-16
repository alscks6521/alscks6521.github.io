import 'package:github_portfolio/features/home/data/datasources/home_local_data_source.dart';
import 'package:github_portfolio/features/home/domain/entities/featured_project.dart';
import 'package:github_portfolio/features/home/domain/entities/skill_group.dart';
import 'package:github_portfolio/features/home/domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeLocalDataSource _local;
  const HomeRepositoryImpl(this._local);

  @override
  List<FeaturedProject> getFeaturedProjects() => _local.featuredProjects;

  @override
  List<SkillGroup> getSkills() => _local.skills;
}
