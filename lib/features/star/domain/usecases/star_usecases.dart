import 'package:github_portfolio/features/star/domain/entities/vote_result.dart';
import 'package:github_portfolio/features/star/domain/repositories/star_repository.dart';

/// 현재 별 개수. 원격 카운터가 꺼져 있으면 0부터 시작한다.
class GetStarCount {
  final StarRepository _repository;
  const GetStarCount(this._repository);

  Future<int?> call() async =>
      _repository.isRemoteEnabled ? _repository.fetchCount() : 0;
}

class HasVotedStar {
  final StarRepository _repository;
  const HasVotedStar(this._repository);

  Future<bool> call() => _repository.hasVoted();
}

/// 별 누르기: 서버에 반영되면(또는 원격이 꺼져 있으면) 이 기기에서 눌렀다고 기억한다.
class VoteStar {
  final StarRepository _repository;
  const VoteStar(this._repository);

  Future<VoteResult> call() async {
    if (!_repository.isRemoteEnabled) {
      await _repository.markVoted();
      return const VoteResult(VoteStatus.ok);
    }
    final result = await _repository.vote();
    if (result.status == VoteStatus.ok) await _repository.markVoted();
    return result;
  }
}
