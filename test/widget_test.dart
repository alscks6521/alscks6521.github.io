import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:github_portfolio/app/app.dart';
import 'package:github_portfolio/app/di/app_dependencies.dart';
import 'package:github_portfolio/features/star/domain/entities/vote_result.dart';
import 'package:github_portfolio/features/star/domain/repositories/star_repository.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// 네트워크·로컬 저장소 없이 동작하는 가짜 별 저장소.
class FakeStarRepository implements StarRepository {
  int count;
  bool voted;
  FakeStarRepository({this.count = 7, this.voted = false});

  @override
  bool get isRemoteEnabled => true;

  @override
  Future<int?> fetchCount() async => count;

  @override
  Future<VoteResult> vote() async => VoteResult(VoteStatus.ok, ++count);

  @override
  Future<bool> hasVoted() async => voted;

  @override
  Future<void> markVoted() async => voted = true;
}

void main() {
  setUp(() =>
      VisibilityDetectorController.instance.updateInterval = Duration.zero);

  testWidgets('home renders with injected dependencies', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final star = FakeStarRepository();
    await tester.pumpWidget(
        MyApp(dependencies: AppDependencies.withRepositories(star: star)));
    await tester.pump(const Duration(milliseconds: 600));

    // 홈 콘텐츠는 HomeRepository, 별 개수는 가짜 StarRepository에서 온다.
    expect(find.text('Projects'), findsOneWidget);
    expect(find.text('+7'), findsOneWidget);

    // 별을 누르면 VoteStar 유스케이스를 거쳐 저장소에 반영된다.
    await tester.tap(find.byTooltip('별을 눌러주세요 ⭐'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(star.voted, isTrue);
    expect(find.text('+8'), findsOneWidget);

    // 무한 애니메이션(졸라맨·둥실 효과)이 있으므로 트리를 내리고 끝낸다.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 3));
  });
}
