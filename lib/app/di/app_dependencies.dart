import 'package:github_portfolio/features/home/data/datasources/home_local_data_source.dart';
import 'package:github_portfolio/features/home/data/repositories/home_repository_impl.dart';
import 'package:github_portfolio/features/home/domain/repositories/home_repository.dart';
import 'package:github_portfolio/features/home/domain/usecases/get_home_content.dart';
import 'package:github_portfolio/features/project/data/datasources/project_local_data_source.dart';
import 'package:github_portfolio/features/project/data/repositories/project_repository_impl.dart';
import 'package:github_portfolio/features/project/domain/repositories/project_repository.dart';
import 'package:github_portfolio/features/project/domain/usecases/get_projects.dart';
import 'package:github_portfolio/features/star/data/datasources/star_local_data_source.dart';
import 'package:github_portfolio/features/star/data/datasources/star_remote_data_source.dart';
import 'package:github_portfolio/features/star/data/repositories/star_repository_impl.dart';
import 'package:github_portfolio/features/star/domain/repositories/star_repository.dart';
import 'package:github_portfolio/features/star/domain/usecases/star_usecases.dart';

/// 컴포지션 루트: 데이터 소스 → 리포지토리 → 유스케이스를 한곳에서 조립한다.
/// 테스트에서는 리포지토리만 가짜로 바꿔 끼우면 된다.
class AppDependencies {
  final GetProjects getProjects;
  final GetFeaturedProjects getFeaturedProjects;
  final GetSkills getSkills;
  final GetStarCount getStarCount;
  final HasVotedStar hasVotedStar;
  final VoteStar voteStar;

  AppDependencies._({
    required ProjectRepository projects,
    required HomeRepository home,
    required StarRepository star,
  })  : getProjects = GetProjects(projects),
        getFeaturedProjects = GetFeaturedProjects(home),
        getSkills = GetSkills(home),
        getStarCount = GetStarCount(star),
        hasVotedStar = HasVotedStar(star),
        voteStar = VoteStar(star);

  factory AppDependencies.production() => AppDependencies._(
        projects: const ProjectRepositoryImpl(ProjectLocalDataSource()),
        home: const HomeRepositoryImpl(HomeLocalDataSource()),
        star: StarRepositoryImpl(
            StarRemoteDataSource(), const StarLocalDataSource()),
      );

  factory AppDependencies.withRepositories({
    ProjectRepository? projects,
    HomeRepository? home,
    required StarRepository star,
  }) =>
      AppDependencies._(
        projects:
            projects ?? const ProjectRepositoryImpl(ProjectLocalDataSource()),
        home: home ?? const HomeRepositoryImpl(HomeLocalDataSource()),
        star: star,
      );
}
