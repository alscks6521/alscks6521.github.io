import 'package:flutter/material.dart';
import 'package:github_portfolio/common/app_assets.dart';
import 'package:github_portfolio/common/extensions/context_extensions.dart';
import 'package:github_portfolio/common/responsive/responsive_scope.dart';

// 데이터 모델
class ProjectItem {
  final String title;
  final String subtitle;
  final List<String> useSkill;
  final String imagePath;
  final String contentImagePath;

  const ProjectItem({
    required this.title,
    required this.subtitle,
    required this.useSkill,
    required this.imagePath,
    required this.contentImagePath,
  });
}

final projects = [
  const ProjectItem(
    title: '언어 치료 관리 모바일 애플리케이션',
    subtitle: 'ISay App은 언어 치료가 필요한 아동과 보호자, 그리고 치료사를 연결하여 치료 일정 관리와 상담을 지원하는 모바일 애플리케이션입니다.\n\n'
        '프로젝트에서는 Flutter 기반 모바일 애플리케이션 개발을 전체적으로 담당했습니다.',
    useSkill: [
      'Flutter',
      'Riverpod Provider',
      'Kakao Auth & Map',
      'IOS Auth',
      'Firebase Cloud Messaging',
      'PortOne API',
      'WebSocket',
    ],
    imagePath: AppAssets.sImg1,
    contentImagePath: AppAssets.scImg1,
  ),
  const ProjectItem(
    title: '언어 치료 관리 웹 플랫폼',
    subtitle:
        'ISay Web은 언어 치료 서비스 이용자와 치료사를 위한 관리 플랫폼으로, 치료 일정 관리, 상담 기능, 사용자 관리 기능 등을 제공하는 웹 서비스입니다.\n\n'
        '프로젝트에서는 Flutter Web 프론트엔드 개발을 전체적으로 담당했습니다.',
    useSkill: [
      'Flutter',
      'Dio',
      'Firebase Cloud Messaging',
      'JavaScript PortOne API SDK',
      'WebSocket',
    ],
    imagePath: AppAssets.sImg2,
    contentImagePath: AppAssets.scImg2,
  ),
  const ProjectItem(
    title: 'Project Gamma',
    subtitle: 'Flutter · Firebase',
    useSkill: [
      'Flutter',
      'Dio',
      'Firebase Cloud Messaging',
      'JavaScript PortOne API SDK',
      'WebSocket'
    ],
    imagePath: AppAssets.sImg3,
    contentImagePath: AppAssets.scImg1,
  ),
  const ProjectItem(
    title: 'Project Delta',
    subtitle: 'Flutter · BLE',
    useSkill: [
      'Flutter',
      'Dio',
      'Firebase Cloud Messaging',
      'JavaScript PortOne API SDK',
      'WebSocket'
    ],
    imagePath: AppAssets.sImg4,
    contentImagePath: AppAssets.scImg1,
  ),
  const ProjectItem(
    title: 'Project Epsilon',
    subtitle: 'Flutter · WebRTC',
    useSkill: [
      'Flutter',
      'Dio',
      'Firebase Cloud Messaging',
      'JavaScript PortOne API SDK',
      'WebSocket'
    ],
    imagePath: AppAssets.sImg5,
    contentImagePath: AppAssets.scImg2,
  ),
];

class HomeProjectSection extends StatefulWidget {
  final double scrollOffset;
  final double sectionStartOffset; // 카드 애니메이션 트리거 기준점

  const HomeProjectSection({
    super.key,
    required this.scrollOffset,
    required this.sectionStartOffset,
  });

  @override
  State<HomeProjectSection> createState() => _HomeProjectSectionState();
}

class _HomeProjectSectionState extends State<HomeProjectSection> with TickerProviderStateMixin {
  late final List<AnimationController> _cardControllers;
  late final List<Animation<double>> _fadeAnims;
  late final List<Animation<Offset>> _slideAnims;

  static const double _rowTriggerInterval = 140.0;

  @override
  void initState() {
    super.initState();
    _cardControllers = List.generate(
      projects.length,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
        reverseDuration: const Duration(milliseconds: 300),
      ),
    );
    _fadeAnims = _cardControllers
        .map((c) => CurvedAnimation(parent: c, curve: Curves.easeOut) as Animation<double>)
        .toList();
    _slideAnims = _cardControllers
        .map((c) => Tween<Offset>(
              begin: const Offset(0, 0.1),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: c, curve: Curves.easeOutCubic)))
        .toList();
  }

  @override
  void dispose() {
    for (final c in _cardControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(HomeProjectSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    _checkTriggers();
  }

  void _checkTriggers() {
    for (int i = 0; i < projects.length; i++) {
      final triggerAt = widget.sectionStartOffset + i * _rowTriggerInterval;

      // 등장 트기러 기준
      if (widget.scrollOffset >= triggerAt &&
          !_cardControllers[i].isCompleted &&
          !_cardControllers[i].isAnimating) {
        _cardControllers[i].forward();
      }

      // 퇴장 트리거
      if (widget.scrollOffset < triggerAt &&
          _cardControllers[i].value > 0 &&
          !_cardControllers[i].isAnimating) {
        _cardControllers[i].reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveScope.of(context);
    final isMobile = r.isMobile;

    final int crossCount = isMobile ? 2 : 3;
    final double hPad = isMobile ? 20.0 : 40.0;
    final double gap = isMobile ? 12.0 : 20.0;

    // 카드 높이: 너비에 비례 계산
    final double availW = r.width - hPad * 2 - gap * (crossCount - 1);
    final double cardW = availW / crossCount;
    final double cardH = cardW * 1.4;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: gap,
            runSpacing: gap,
            children: List.generate(projects.length, (i) {
              return FadeTransition(
                opacity: _fadeAnims[i],
                child: SlideTransition(
                  position: _slideAnims[i],
                  child: SizedBox(
                    width: cardW,
                    height: cardH,
                    child: _ProjectCard(
                      project: projects[i],
                      index: i,
                      isMobile: isMobile,
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

// 카드
class _ProjectCard extends StatelessWidget {
  final ProjectItem project;
  final int index;
  final bool isMobile;

  const _ProjectCard({
    required this.project,
    required this.index,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 이미지
          Expanded(
            flex: 5,
            child: SizedBox(
              width: double.infinity,
              child: Image.asset(
                project.contentImagePath,
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
          ),

          // 텍스트
          Expanded(
            flex: 6,
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 12 : 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 번호 뱃지
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '0${index + 1}',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: Colors.white60,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // 제목
                  Text(
                    project.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.headlineLarge?.copyWith(
                      color: Colors.white,
                      fontSize: isMobile ? 13 : 15,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // 설명
                  Expanded(
                    child: Text(
                      project.subtitle,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodyLarge?.copyWith(
                        color: Colors.white54,
                        fontSize: isMobile ? 11 : 12,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // 스킬 태그
                  Wrap(
                    spacing: 5,
                    runSpacing: 5,
                    children: project.useSkill
                        .take(2)
                        .map((skill) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                skill,
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: Colors.white70,
                                  fontSize: isMobile ? 10 : 11,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
