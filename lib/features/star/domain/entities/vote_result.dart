enum VoteStatus { ok, already, error }

class VoteResult {
  final VoteStatus status;
  final int? count; // 서버가 알려준 최신 합계 (모르면 null)
  const VoteResult(this.status, [this.count]);

  static const error = VoteResult(VoteStatus.error);
}
