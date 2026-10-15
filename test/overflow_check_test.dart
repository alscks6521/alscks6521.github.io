import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:github_portfolio/common/app_assets.dart';
import 'package:github_portfolio/screens/project/project_screen.dart';

void main() {
  final items = [
    ProjectItem(
      title: 'ISay App 아주 긴 제목이 들어가도 넘치지 않는지 확인하는 테스트용 제목',
      summary: '언어 치료 아동·보호자·치료사를 연결하는 모바일 앱 요약이 길게 들어가는 경우를 확인합니다',
      description: '설명 ' * 40,
      icon: AppAssets.isayIcon,
      skills: ['Flutter', 'Riverpod', 'Kakao Auth & Map', 'iOS Auth', 'Firebase Cloud Messaging'],
      screens: AppAssets.isayScreens,
      released: true,
      highlights: ['Flutter', 'Riverpod', 'AWS Bedrock', 'RAG', 'LLM', 'Text Embedding', 'WebSocket'],
      period: '2024.03 ~ 2024.12 (아주 긴 기간 설명 텍스트)',
      team: '4명 (FE 1, BE 2, 디자인 1)',
      role: 'Flutter 앱 개발 전체 담당 및 배포',
      issues: [ProjectIssue(problem: '문제 ' * 20, solution: '해결 ' * 20, result: '결과 ' * 10)],
      features: ['기능 하나', '기능 둘'],
    ),
    ProjectItem(
      title: 'ISay Web',
      summary: '짧은 요약',
      description: '설명',
      icon: AppAssets.isayWebIcon,
      screens: AppAssets.isayWebScreens,
    ),
  ];

  for (final width in [320.0, 375.0, 430.0, 600.0, 768.0, 900.0, 1280.0, 1920.0]) {
    for (final scale in [1.0, 1.3, 2.0]) {
      testWidgets('w=$width scale=$scale', (tester) async {
        tester.view.physicalSize = Size(width, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
            child: child!,
          ),
          home: ProjectScreen(title: '앱 프로젝트', description: '설명', items: items),
        ));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        for (final title in [items[0].title, items[1].title]) {
          // 카드 열기 (애니메이션 프레임마다 검사)
          await tester.ensureVisible(find.text(title).first);
          await tester.pumpAndSettle();
          await tester.tap(find.text(title).first);
          for (var i = 0; i < 50; i++) {
            await tester.pump(const Duration(milliseconds: 16));
            expect(tester.takeException(), isNull);
          }
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          // 상세 화면 끝까지 스크롤
          await tester.drag(find.byType(SingleChildScrollView).last, const Offset(0, -5000));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          await tester.drag(find.byType(SingleChildScrollView).last, const Offset(0, 5000));
          await tester.pumpAndSettle();
          // 목록으로
          await tester.tap(find.text('← 목록으로'));
          for (var i = 0; i < 40; i++) {
            await tester.pump(const Duration(milliseconds: 16));
            expect(tester.takeException(), isNull);
          }
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }
      });
    }
  }
}




