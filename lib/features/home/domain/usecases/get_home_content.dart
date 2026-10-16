import 'package:github_portfolio/features/home/domain/entities/featured_project.dart';
import 'package:github_portfolio/features/home/domain/entities/skill_group.dart';
import 'package:github_portfolio/features/home/domain/repositories/home_repository.dart';

class GetFeaturedProjects {
  final HomeRepository _repository;
  const GetFeaturedProjects(this._repository);

  List<FeaturedProject> call() => _repository.getFeaturedProjects();
}

class GetSkills {
  final HomeRepository _repository;
  const GetSkills(this._repository);

  List<SkillGroup> call() => _repository.getSkills();
}
