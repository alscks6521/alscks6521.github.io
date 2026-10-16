import 'package:github_portfolio/features/home/domain/entities/featured_project.dart';
import 'package:github_portfolio/features/home/domain/entities/skill_group.dart';

abstract interface class HomeRepository {
  List<FeaturedProject> getFeaturedProjects();
  List<SkillGroup> getSkills();
}
