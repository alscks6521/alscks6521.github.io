import 'package:flutter/material.dart';
import 'package:github_portfolio/features/stickman/presentation/stickman_arena.dart';
import 'package:github_portfolio/features/home/presentation/theme/home_palette.dart';
import 'package:github_portfolio/features/home/presentation/widgets/section_label.dart';

class AboutSection extends StatelessWidget {
  final HomePalette palette;
  const AboutSection({super.key, required this.palette});

  @override
  Widget build(BuildContext context) {
    final body = TextStyle(fontSize: 17, height: 1.7, color: palette.muted);
    final strong = TextStyle(fontWeight: FontWeight.w600, color: palette.text);

    return ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionLabel('About', palette),
            StickmanSolid(
                child: Text.rich(TextSpan(style: body, children: [
              TextSpan(text: 'Flutter', style: strong),
              const TextSpan(text: '를 중심으로 모바일 앱과 웹 서비스를 만드는 개발자입니다.'),
            ]))),
            const SizedBox(height: 18),
            StickmanSolid(
                child: Text.rich(TextSpan(style: body, children: [
              const TextSpan(text: '실무에서 모바일 앱과 웹을 개발해 '),
              TextSpan(text: 'App Store · Google Play에 출시', style: strong),
              const TextSpan(text: '했고, 서버 API 개발에도 함께 참여했습니다.'),
            ]))),
            const SizedBox(height: 18),
            StickmanSolid(
                child: Text.rich(TextSpan(style: body, children: [
              const TextSpan(text: '텍스트 임베딩 기반 의도 분류와 '),
              TextSpan(text: 'RAG(AWS Bedrock)', style: strong),
              const TextSpan(
                  text: '로 누적된 치료 데이터를 분석해 평가서를 생성하는 AI 기능을 실제 서비스에 적용했습니다.'),
            ]))),
            const SizedBox(height: 28),
            for (final (label, value) in const [
              ('Education', '컴퓨터공학 학사'),
              ('Training', '한국소프트웨어 3년 교육과정 수료'),
            ])
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: StickmanSolid(
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      SizedBox(
                        width: 96,
                        child: Text(label,
                            style: TextStyle(
                                fontSize: 14,
                                height: 1.9,
                                color: palette.muted)),
                      ),
                      Expanded(
                        child: Text(value,
                            style: TextStyle(
                                fontSize: 16,
                                height: 1.7,
                                fontWeight: FontWeight.w600,
                                color: palette.text)),
                      ),
                    ])),
              ),
          ],
        ));
  }
}
