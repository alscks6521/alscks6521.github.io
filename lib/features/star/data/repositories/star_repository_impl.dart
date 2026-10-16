import 'package:github_portfolio/features/star/data/datasources/star_local_data_source.dart';
import 'package:github_portfolio/features/star/data/datasources/star_remote_data_source.dart';
import 'package:github_portfolio/features/star/domain/entities/vote_result.dart';
import 'package:github_portfolio/features/star/domain/repositories/star_repository.dart';

class StarRepositoryImpl implements StarRepository {
  final StarRemoteDataSource _remote;
  final StarLocalDataSource _local;
  const StarRepositoryImpl(this._remote, this._local);

  @override
  bool get isRemoteEnabled => _remote.enabled;

  @override
  Future<int?> fetchCount() => _remote.fetch();

  @override
  Future<VoteResult> vote() => _remote.vote();

  @override
  Future<bool> hasVoted() => _local.hasVoted();

  @override
  Future<void> markVoted() => _local.markVoted();
}
