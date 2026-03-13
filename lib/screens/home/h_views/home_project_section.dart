import 'package:flutter/material.dart';
import 'package:github_portfolio/common/app_assets.dart';
import 'package:github_portfolio/common/extensions/context_extensions.dart';
import 'package:github_portfolio/common/responsive/responsive_scope.dart';
import 'package:github_portfolio/common/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class ProjectItem {
  final String title;
  final String subtitle;
  final List<String> useSkill;
  final String imagePath;
  final String contentImagePath;
  final String? url;

  const ProjectItem({
    required this.title,
    required this.subtitle,
    required this.useSkill,
    required this.imagePath,
    required this.contentImagePath,
    this.url,
  });
}

const List<ProjectItem> projects = [
  ProjectItem(
    title: '언어 치료 관리 모바일 애플리케이션',
    subtitle: 'ISay App은 언어 치료가 필요한 아동과 보호자, 그리고 치료사를 연결하여 치료 일정 관리와 상담을 지원하는 모바일 애플리케이션입니다.\n\n'
        'Flutter 기반 모바일 애플리케이션 개발을 전체적으로 담당했습니다.',
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
  ProjectItem(
    title: '언어 치료 관리 웹 플랫폼',
    subtitle:
        'ISay Web은 언어 치료 서비스 이용자와 치료사를 위한 관리 플랫폼으로, 치료 일정 관리, 상담 기능, 사용자 관리 기능 등을 제공하는 웹 서비스입니다.\n\n'
        'Flutter Web 프론트엔드 개발을 전체적으로 담당했습니다.',
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
  ProjectItem(
    title: 'Dialogflow 음성일정 관리 앱',
    subtitle: '음성을 인식하여 음성 데이터를 Dialogflow에서 자연어 해석 처리\n\n'
        '개인 스터디',
    useSkill: [
      'Flutter',
      'Dialogflow',
      'Firebase',
      'Speech To Text',
    ],
    imagePath: AppAssets.sImg3,
    contentImagePath: AppAssets.scImg3,
    url: 'https://github.com/alscks6521/flutter-voice-recognition-calendar',
  ),
  ProjectItem(
    title: 'OCare - AI Chat 헬스케어 추적 앱',
    subtitle:
        'OCare는 헬스케어 추적 앱으로, OpenAI API를 활용하여 사용자의 누적된 건강정보와 AI 챗봇 간의 상호작용을 통해 건강 관리 및 피드백을 제공합니다.\n\n'
        '스터디그룹 프로젝트로, OpenAI API 연동을 담당했습니다. \n건강기능식품 품목제조신고 API와 Kakao Login, Firebase Auth 등을 활용하여 사용자 인증과 건강 정보 관리를 합니다.',
    useSkill: [
      'Flutter',
      'Open AI API',
      '건강기능식품 품목제조신고(원재료) API',
      'Kakao Login',
      'Firebase Auth',
    ],
    imagePath: AppAssets.scImg4,
    contentImagePath: AppAssets.scImg4,
    url: 'https://github.com/alscks6521/oc-ai-chat',
  ),
  ProjectItem(
    title: 'Naver 웹툰 API 연동 - 클론코딩',
    subtitle: 'Api Naver 웹툰 정보 사용한 앱\n\n'
        '클론코딩 프로젝트로, Naver 웹툰 API를 활용하여 웹툰 정보를 제공하는 앱을 개발했습니다. \n웹툰 목록, 상세 정보, 이미지 등을 API로부터 받아와 Flutter 앱에서 표시하는 기능을 구현했습니다.',
    useSkill: [
      'Flutter',
      'HTTP',
      'Naver Webtoon API',
    ],
    imagePath: AppAssets.scImg5,
    contentImagePath: AppAssets.scImg5,
    url: 'https://github.com/alscks6521/flutter-toonix-review',
  ),
  ProjectItem(
    title: '픽셀 동물 키우기 모바일',
    subtitle: 'React Native을 활용한 동물 레벨업 시키는 앱 입니다\n\n'
        'Firebase를 통해 회원의 정보와 동물의 정보를 저장하여, 레벨업에 따라 동물의 외형이 변하는 것이 특징입니다.',
    useSkill: [
      'React Native',
      'Firebase',
      'React Hook',
    ],
    imagePath: AppAssets.sImg6,
    contentImagePath: AppAssets.scImg6,
    url: 'https://github.com/alscks6521/RN-animal-games',
  ),
];

class HomeProjectSection extends StatefulWidget {
  final double scrollOffset;
  final double sectionStartOffset;

  const HomeProjectSection({
    super.key,
    required this.scrollOffset,
    required this.sectionStartOffset,
  });

  @override
  State<HomeProjectSection> createState() => _HomeProjectSectionState();
}

class _HomeProjectSectionState extends State<HomeProjectSection> with TickerProviderStateMixin {
  static const double _rowTriggerInterval = 140.0;
  static const int _projectCount = 6;

  late final List<AnimationController> _cardControllers;
  late final List<Animation<double>> _fadeAnims;
  late final List<Animation<Offset>> _slideAnims;

  @override
  void initState() {
    super.initState();
    _cardControllers = List.generate(
      _projectCount,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
        reverseDuration: const Duration(milliseconds: 300),
      ),
    );
    _fadeAnims = List.generate(
      _projectCount,
      (i) => CurvedAnimation(parent: _cardControllers[i], curve: Curves.easeOut),
    );
    _slideAnims = List.generate(
      _projectCount,
      (i) => Tween<Offset>(
        begin: const Offset(0, 0.1),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: _cardControllers[i], curve: Curves.easeOutCubic)),
    );
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
    if (oldWidget.scrollOffset != widget.scrollOffset) {
      _checkTriggers();
    }
  }

  void _checkTriggers() {
    for (int i = 0; i < _projectCount; i++) {
      final triggerAt = widget.sectionStartOffset + i * _rowTriggerInterval;
      final ctrl = _cardControllers[i];

      if (widget.scrollOffset >= triggerAt) {
        if (!ctrl.isCompleted && !ctrl.isAnimating) ctrl.forward();
      } else {
        if (ctrl.value > 0 && !ctrl.isAnimating) ctrl.reverse();
      }
    }
  }

  // 오버레이 뜨우기
  void _openDetail(BuildContext context, int index) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: false,
        transitionDuration: const Duration(milliseconds: 420),
        reverseTransitionDuration: const Duration(milliseconds: 320),
        pageBuilder: (_, animation, __) =>
            _ProjectDetailOverlay(project: projects[index], index: index, animation: animation),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveScope.of(context);
    final isMobile = r.isMobile;
    final isDesktop = r.isDesktop;

    final int crossCount = isDesktop ? 3 : 2;
    final double hPad = isMobile ? 20.0 : 40.0;
    final double gap = isMobile ? 12.0 : 20.0;

    final double cardW = (r.width - hPad * 2 - gap * (crossCount - 1)) / crossCount;
    final double cardH = cardW * 1.4;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: gap,
            runSpacing: gap,
            children: List.generate(_projectCount, (i) {
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
                      onTap: () => _openDetail(context, i),
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

class _ProjectCard extends StatefulWidget {
  final ProjectItem project;
  final int index;
  final bool isMobile;
  final VoidCallback onTap;

  const _ProjectCard({
    required this.project,
    required this.index,
    required this.isMobile,
    required this.onTap,
  });

  @override
  State<_ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<_ProjectCard> with SingleTickerProviderStateMixin {
  late final AnimationController _hoverCtrl;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _glowAnim;
  late final Animation<Color?> _borderColorAnim;

  @override
  void initState() {
    super.initState();
    _hoverCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 220));

    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 1.035,
    ).animate(CurvedAnimation(parent: _hoverCtrl, curve: Curves.easeOutCubic));
    _glowAnim = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _hoverCtrl, curve: Curves.easeOut));
    _borderColorAnim = ColorTween(
      begin: const Color(0x1AFFFFFF),
      end: const Color(0x66FFFFFF),
    ).animate(CurvedAnimation(parent: _hoverCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _hoverCtrl.dispose();
    super.dispose();
  }

  void _onEnter(_) {
    _hoverCtrl.forward();
  }

  void _onExit(_) {
    _hoverCtrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: _onEnter,
      onExit: _onExit,
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedBuilder(
          animation: _hoverCtrl,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnim.value,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0x01000000),
                  border: Border.all(
                    color: _borderColorAnim.value ?? const Color(0x1AFFFFFF),
                    width: 1.0 + _glowAnim.value * 0.5,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.06 * _glowAnim.value),
                      blurRadius: 24 * _glowAnim.value,
                      spreadRadius: 2 * _glowAnim.value,
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3 * _glowAnim.value),
                      blurRadius: 20 * _glowAnim.value,
                      offset: Offset(0, 8 * _glowAnim.value),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: child,
              ),
            );
          },
          child: _CardContent(
            project: widget.project,
            index: widget.index,
            isMobile: widget.isMobile,
            hoverAnim: _glowAnim,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
class _CardContent extends StatelessWidget {
  final ProjectItem project;
  final int index;
  final bool isMobile;
  final Animation<double> hoverAnim;

  static const _badgeBgColor = Color(0x1AFFFFFF);
  static const _skillBorderColor = Color(0x33FFFFFF);

  const _CardContent({
    required this.project,
    required this.index,
    required this.isMobile,
    required this.hoverAnim,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── 이미지 영역 ─────────────────────────
        Expanded(
          flex: 5,
          child: AnimatedBuilder(
            animation: hoverAnim,
            builder: (_, child) => Stack(
              fit: StackFit.expand,
              children: [
                child!,
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: Image.asset(
                project.imagePath,
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
          ),
        ),

        Expanded(
          flex: 6,
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 12 : 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _badgeBgColor,
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
                Wrap(
                  spacing: 5,
                  runSpacing: 5,
                  children: project.useSkill
                      .take(2)
                      .map(
                        (skill) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            border: Border.all(color: _skillBorderColor),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            skill,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: Colors.white70,
                              fontSize: isMobile ? 10 : 11,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ProjectDetailOverlay extends StatefulWidget {
  final ProjectItem project;
  final int index;
  final Animation<double> animation;

  const _ProjectDetailOverlay({
    required this.project,
    required this.index,
    required this.animation,
  });

  @override
  State<_ProjectDetailOverlay> createState() => _ProjectDetailOverlayState();
}

class _ProjectDetailOverlayState extends State<_ProjectDetailOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _innerCtrl;
  late final Animation<double> _contentFade;
  late final Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();
    _innerCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 380));

    _contentFade = CurvedAnimation(
      parent: _innerCtrl,
      curve: const Interval(0.35, 1.0, curve: Curves.easeOut),
    );
    _contentSlide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _innerCtrl,
        curve: const Interval(0.35, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    // 배경 애니메이션이 시작되면 내부 콘텐츠 연출
    widget.animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _innerCtrl.forward();
      }
    });
  }

  @override
  void dispose() {
    _innerCtrl.dispose();
    super.dispose();
  }

  void _close() {
    _innerCtrl.reverse().then((_) => Navigator.of(context).pop());
  }

  Future<void> launchURL(String url) async {
    final Uri uri = Uri.parse(url);

    if (!await canLaunchUrl(uri)) {
      throw Exception('URL을 열 수 없습니다: $url');
    }

    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bgScale = Tween<double>(
      begin: 0.92,
      end: 1.0,
    ).animate(CurvedAnimation(parent: widget.animation, curve: Curves.easeOutCubic));
    final bgFade = CurvedAnimation(parent: widget.animation, curve: Curves.easeOut);

    return AnimatedBuilder(
      animation: widget.animation,
      builder: (context, _) {
        return FadeTransition(
          opacity: bgFade,
          child: ScaleTransition(
            scale: bgScale,
            child: Scaffold(
              backgroundColor: const Color(0xFF0A0A0F),
              body: Stack(
                children: [
                  // 배경 이미지 흐림
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.18,
                      child: Image.asset(widget.project.contentImagePath, fit: BoxFit.cover),
                    ),
                  ),

                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0x99000000), Color(0xDD0A0A0F)],
                          stops: [0.0, 0.55],
                        ),
                      ),
                    ),
                  ),

                  // 콘텐츠
                  FadeTransition(
                    opacity: _contentFade,
                    child: SlideTransition(
                      position: _contentSlide,
                      child: SafeArea(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(32, 64, 32, 48),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 프로젝트 번호
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0x1AFFFFFF),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: const Color(0x33FFFFFF)),
                                ),
                                child: Text(
                                  '0${widget.index + 1}',
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              // 타이틀
                              Text(
                                widget.project.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  height: 1.3,
                                ),
                              ),

                              const SizedBox(height: 24),

                              // 프로젝트 이미지
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.asset(
                                  widget.project.contentImagePath,
                                  width: double.infinity,
                                  height: 240,
                                  fit: BoxFit.contain,
                                ),
                              ),

                              const SizedBox(height: 32),

                              // 설명
                              Text(
                                widget.project.subtitle,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 15,
                                  height: 1.8,
                                ),
                              ),
                              const SizedBox(height: 18),
                              if (widget.project.url != null)
                                ElevatedButton(
                                  onPressed: () => launchURL(widget.project.url!),
                                  child: const Text('GitHub Repository'),
                                ),
                              const SizedBox(height: 32),

                              // 구분선
                              const Divider(color: AppColors.line, thickness: 1),

                              const SizedBox(height: 24),

                              // 스킬 섹션
                              const Text(
                                'Tech Stack',
                                style: TextStyle(
                                  color: Colors.white38,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 2,
                                ),
                              ),

                              const SizedBox(height: 16),

                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: widget.project.useSkill
                                    .map(
                                      (skill) => Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 7,
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: const Color(0x44FFFFFF)),
                                          borderRadius: BorderRadius.circular(24),
                                          color: const Color(0x0DFFFFFF),
                                        ),
                                        child: Text(
                                          skill,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 닫기 버튼
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 16,
                    right: 16,
                    child: FadeTransition(
                      opacity: bgFade,
                      child: _CloseButton(onTap: _close),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CloseButton extends StatefulWidget {
  final VoidCallback onTap;
  const _CloseButton({required this.onTap});

  @override
  State<_CloseButton> createState() => _CloseButtonState();
}

class _CloseButtonState extends State<_CloseButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _hovered ? const Color(0x33FFFFFF) : const Color(0x1AFFFFFF),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: _hovered ? const Color(0x66FFFFFF) : const Color(0x33FFFFFF)),
          ),
          child: Icon(
            Icons.close_rounded,
            color: _hovered ? Colors.white : Colors.white70,
            size: 20,
          ),
        ),
      ),
    );
  }
}
