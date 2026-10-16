import 'package:github_portfolio/features/star/domain/entities/vote_result.dart';

abstract interface class StarRepository {
  /// 원격 카운터가 설정되어 있는지. 꺼져 있으면 로컬에서만 동작한다.
  bool get isRemoteEnabled;

  Future<int?> fetchCount();
  Future<VoteResult> vote();

  Future<bool> hasVoted();
  Future<void> markVoted();
}
