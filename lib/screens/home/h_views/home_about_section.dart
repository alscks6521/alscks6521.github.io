import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:github_portfolio/common/app_assets.dart';
import 'package:github_portfolio/common/extensions/context_extensions.dart';
import 'package:github_portfolio/common/responsive/responsive_scope.dart';
import 'package:github_portfolio/common/theme/app_colors.dart';
import 'package:github_portfolio/screens/home/h_views/home_project_section.dart';

class HomeAboutSection extends StatefulWidget {
  final PageController pageController;
  final ScrollController scrollController;
  final int prevPageIndex;

  const HomeAboutSection({
    super.key,
    required this.pageController,
    required this.scrollController,
    this.prevPageIndex = 0,
  });

  @override
  State<HomeAboutSection> createState() => _HomeAboutSectionState();
}

class _HomeAboutSectionState extends State<HomeAboutSection>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  final _introTexts = [
    '안녕하세요. 웹·앱 개발자 김민성입니다.\n'
        'Flutter를 중심으로 웹과 모바일 서비스를 개발하고 있습니다.',
    '스타트업에서 앱의 설계부터 개발, 배포까지 전 과정을 담당하며\n'
        'Android와 iOS 스토어에 서비스를 직접 출시한 경험이 있습니다.',
    '사용자가 실제로 사용할 수 있는 서비스를 만드는 것을 목표로\n'
        '공부를 하며 지속적인 개선에 집중하고 있습니다.\n\n'
        '방문해주셔서 감사합니다.',
  ];

  double _pageProgress = 0.0;
  double _scrollOffset = 0.0;
  double _parallaxOffset = 0.0;
  late final Ticker _ticker;

  static const double _factor1 = 0.55;
  static const double _factor2 = 0.65;
  static const double _factor3 = 0.75;

  double? _touchStartY;
  double _touchStartScrollOffset = 0.0;
  bool _isPageAnimating = false;
  static const double _touchThreshold = 60.0;

  // 스크롤 섹션 높이
  static const double _aboutHDesktop = 4000.0;
  static const double _aboutHMobile = 2000.0;
  static const double _projectSectionH = 1800.0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    widget.pageController.addListener(_onPageChanged);
    widget.scrollController.addListener(_onScrollOffsetChanged);
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void dispose() {
    widget.pageController.removeListener(_onPageChanged);
    widget.scrollController.removeListener(_onScrollOffsetChanged);
    _ticker.dispose();
    super.dispose();
  }

  void _onPageChanged() {
    if (!mounted) return;
    final page = widget.pageController.page ?? 0.0;
    setState(() => _pageProgress = page.clamp(0.0, 1.0));
  }

  void _onScrollOffsetChanged() {
    if (!mounted) return;
    setState(() => _scrollOffset = widget.scrollController.offset);
  }

  void _onTick(Duration elapsed) {
    if (!mounted) return;
    const lerpFactor = 0.08;
    final next = _parallaxOffset + (_scrollOffset - _parallaxOffset) * lerpFactor;
    if ((next - _parallaxOffset).abs() > 0.1) {
      setState(() => _parallaxOffset = next);
    }
  }

  Future<void> _goToPage(int index) async {
    if (_isPageAnimating) return;
    _isPageAnimating = true;
    try {
      await widget.pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 480),
        curve: Curves.easeOutCubic,
      );
    } finally {
      _isPageAnimating = false;
    }
  }

  void _onPointerDown(PointerDownEvent event) {
    if (event.kind == PointerDeviceKind.mouse) return;
    _touchStartY = event.position.dy;
    _touchStartScrollOffset =
        widget.scrollController.hasClients ? widget.scrollController.offset : 0.0;
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (event.kind == PointerDeviceKind.mouse) return;
    if (_touchStartY == null) return;
    if (!widget.scrollController.hasClients) return;

    final delta = _touchStartY! - event.position.dy;
    final max = widget.scrollController.position.maxScrollExtent;
    const edge = 8.0;

    final newOffset = (_touchStartScrollOffset + delta).clamp(0.0, max);
    widget.scrollController.jumpTo(newOffset);

    if (newOffset <= edge && delta < -_touchThreshold) {
      _touchStartY = null;
      _goToPage(widget.prevPageIndex);
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    if (event.kind == PointerDeviceKind.mouse) return;
    _touchStartY = null;
  }

  double _calcProgress(double offset, double start, double end) {
    return ((offset - start) / (end - start)).clamp(0.0, 1.0);
  }

  double _parallaxTop(double baseY, double factor) {
    return baseY - _parallaxOffset * factor;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final r = ResponsiveScope.of(context);
    final isMobile = r.isMobile;
    final isDesktop = r.isDesktop;

    // ── 텍스트 블록별 등장 트리거 구간 ──
    final List<double> textTriggers = isDesktop ? [0, 900, 1800] : [0, 400, 700];

    double blockOpacity(int index) {
      final start = textTriggers[index];
      final end = start + 300.0;
      return _calcProgress(_scrollOffset, start, end);
    }

    final double aboutH = isDesktop ? _aboutHDesktop : _aboutHMobile;
    final double totalH = aboutH + _projectSectionH;

    final double pageArrival = _pageProgress.clamp(0.0, 1.0);
    final double offsetY = (1.0 - pageArrival) * 60.0;
    final double pageOpacity = pageArrival.clamp(0.0, 1.0);
    final double introOffsetX = (1.0 - pageArrival) * 80.0;

    // 이미지 퇴장
    final double imgExitStart = isDesktop ? 2400.0 : 1100.0;
    final double imgExitEnd = isDesktop ? 3200.0 : 1700.0;
    final double imgExitProgress = _calcProgress(_scrollOffset, imgExitStart, imgExitEnd);
    final double imgExitOffsetY = -imgExitProgress * 200.0;
    final double imgExitOpacity =
        imgExitProgress < 0.4 ? 1.0 : 1.0 - ((imgExitProgress - 0.4) / 0.6);

    // About 타이틀 퇴장
    final double titleExitStart = isDesktop ? 2200.0 : 1000.0;
    final double titleExitEnd = isDesktop ? 2800.0 : 1400.0;
    final double titleExitProgress = _calcProgress(_scrollOffset, titleExitStart, titleExitEnd);
    final double titleExitOffsetY = -titleExitProgress * 120.0;
    final double titleExitOpacity =
        titleExitProgress < 0.4 ? 1.0 : 1.0 - ((titleExitProgress - 0.4) / 0.6);
    final double titleOpacity = (pageOpacity * titleExitOpacity).clamp(0.0, 1.0);

    // 이미지 y값
    final double img1BaseY = isDesktop ? 600 : 400;
    final double img2BaseY = isDesktop ? 1200 : 800;
    final double img3BaseY = isDesktop ? 2200 : 1200;

    // Project 카드 트리거 시작점
    final double projectTriggerStart = aboutH - (isMobile ? 500 : 1000);
    final Color bgColor = Color.lerp(
      Colors.white,
      AppColors.black,
      _calcProgress(_scrollOffset, projectTriggerStart, projectTriggerStart + 10),
    )!;

    return Listener(
      onPointerDown: _onPointerDown,
      onPointerMove: _onPointerMove,
      onPointerUp: _onPointerUp,
      child: Stack(
        children: [
          // 배경
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeInOut,
              color: bgColor,
            ),
          ),
          // 전체 스크롤 영역
          SingleChildScrollView(
            controller: widget.scrollController,
            physics: const NeverScrollableScrollPhysics(),
            child: SizedBox(
              width: r.width,
              height: totalH,
              child: Stack(
                children: [
                  // Project 섹션
                  Positioned(
                    top: aboutH + 0,
                    left: 0,
                    right: 0,
                    child: HomeProjectSection(
                      scrollOffset: _scrollOffset,
                      sectionStartOffset: projectTriggerStart,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 패럴랙스 이미지 1
          Positioned(
            top: _parallaxTop(img1BaseY, _factor1) + imgExitOffsetY,
            left: isMobile ? null : r.width * 0.09,
            right: isMobile ? 24 : null,
            child: Opacity(
              opacity: (pageOpacity * imgExitOpacity).clamp(0.0, 1.0),
              child: _shadowImage(
                assetPath: AppAssets.aboutImg1,
                width: isMobile ? 140 : r.width * 0.2,
              ),
            ),
          ),

          // 이미지 2
          if (isMobile)
            Positioned(
              top: _parallaxTop(img2BaseY, _factor2) + imgExitOffsetY,
              left: 20,
              child: Opacity(
                opacity: (pageOpacity * imgExitOpacity).clamp(0.0, 1.0),
                child: _shadowImage(assetPath: AppAssets.aboutImg2, width: 140),
              ),
            )
          else
            Positioned(
              top: _parallaxTop(img2BaseY, _factor2) + imgExitOffsetY,
              right: r.width * 0.1,
              child: Opacity(
                opacity: (pageOpacity * imgExitOpacity).clamp(0.0, 1.0),
                child: _shadowImage(
                  assetPath: AppAssets.aboutImg2,
                  width: r.width * 0.2,
                ),
              ),
            ),

          // 이미지 3
          Positioned(
            top: _parallaxTop(img3BaseY, _factor3) + imgExitOffsetY,
            left: isMobile ? null : r.width * 0.14,
            right: isMobile ? 24 : null,
            child: Opacity(
              opacity: (pageOpacity * imgExitOpacity).clamp(0.0, 1.0),
              child: _shadowImage(
                assetPath: AppAssets.aboutImg3,
                width: isMobile ? 130 : r.width * 0.2,
              ),
            ),
          ),

          // About 타이틀
          Positioned(
            top: isMobile ? 16 : 70,
            left: isMobile ? 20 : 80,
            child: Transform.translate(
              offset: Offset(0, offsetY + titleExitOffsetY),
              child: Opacity(
                opacity: titleOpacity,
                child: Text(
                  'About',
                  style: context.textTheme.titleLarge?.copyWith(fontSize: isMobile ? 20 : 30),
                ),
              ),
            ),
          ),

          // 소개 텍스트 카드
          Positioned(
            top: isMobile ? r.height * 0.16 : 120,
            left: isMobile ? 24 : 10,
            right: isMobile ? 24 : 0,
            child: Center(
              child: Transform.translate(
                offset: Offset(introOffsetX, 0),
                child: Opacity(
                  opacity: pageOpacity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(_introTexts.length, (i) {
                      // 등장
                      final appearOpacity = (blockOpacity(i) * pageOpacity).clamp(0.0, 1.0);
                      final slideY = (1.0 - blockOpacity(i)) * 24.0;

                      // 퇴장
                      final combinedOpacity = (appearOpacity * imgExitOpacity).clamp(0.0, 1.0);
                      final combinedOffsetY = slideY + imgExitOffsetY;

                      return Transform.translate(
                        offset: Offset(0, combinedOffsetY),
                        child: Opacity(
                          opacity: combinedOpacity,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: isMobile ? 40 : 80, vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 10,
                                    offset: const Offset(1, 3),
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Text(
                                _introTexts[i],
                                style: isMobile
                                    ? context.textTheme.bodyMedium
                                    : isDesktop
                                        ? context.textTheme.titleMedium?.copyWith(
                                            height: 1.8,
                                            letterSpacing: 0.2,
                                            fontSize: 20,
                                          )
                                        : context.textTheme.bodyLarge,
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),

          // Project 툴바
          if (_scrollOffset >= projectTriggerStart)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AnimatedOpacity(
                opacity:
                    _calcProgress(_scrollOffset, projectTriggerStart, projectTriggerStart + 200),
                duration: const Duration(milliseconds: 1200),
                child: Container(
                  color: AppColors.black,
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16 : 40,
                    vertical: 16,
                  ),
                  child: Text(
                    'Projects',
                    style: context.textTheme.titleLarge
                        ?.copyWith(color: Colors.white, fontSize: isMobile ? 20 : 30),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _shadowImage({required String assetPath, required double width}) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(1, 3),
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(assetPath, width: width, fit: BoxFit.cover),
      ),
    );
  }
}
