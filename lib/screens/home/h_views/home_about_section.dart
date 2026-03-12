import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:github_portfolio/common/app_assets.dart';
import 'package:github_portfolio/common/extensions/context_extensions.dart';
import 'package:github_portfolio/common/responsive/responsive_scope.dart';
import 'package:github_portfolio/common/theme/app_colors.dart';
import 'package:github_portfolio/screens/home/h_views/home_project_section.dart';

double _calcProgress(double offset, double start, double end) {
  return ((offset - start) / (end - start)).clamp(0.0, 1.0);
}

const _shadowDecoration = BoxDecoration(
  borderRadius: BorderRadius.all(Radius.circular(12)),
  boxShadow: [
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 20,
      offset: Offset(1, 3),
      spreadRadius: 5,
    ),
  ],
);

class HomeAboutSection extends StatefulWidget {
  static const double aboutHDesktop = 3800.0;
  static const double aboutHMobile = 2000.0;

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
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  static const _introTexts = [
    '안녕하세요. 웹·앱 개발자 김민성입니다.\n'
        'Flutter를 중심으로 웹과 모바일 서비스를 개발하고 있습니다.',
    '스타트업에서 앱의 설계부터 개발, 배포까지 전 과정을 담당하며\n'
        'Android와 iOS 스토어에 서비스를 직접 출시한 경험이 있습니다.',
    '사용자가 실제로 사용할 수 있는 서비스를 만드는 것을 목표로\n'
        '공부를 하며 지속적인 개선에 집중하고 있습니다.\n\n'
        '방문해주셔서 감사합니다.',
  ];

  static const double _factor1 = 0.55;
  static const double _factor2 = 0.65;
  static const double _factor3 = 0.75;
  static const double _touchThreshold = 60.0;
  static const double _projectSectionH = 1800.0;

  static const _cardShadow = BoxShadow(
    color: Color(0x0D000000),
    blurRadius: 10,
    offset: Offset(1, 3),
    spreadRadius: 5,
  );

  double _pageProgress = 0.0;
  double _scrollOffset = 0.0;
  double _parallaxOffset = 0.0;
  late final Ticker _ticker;
  late final AnimationController _helloMarqueeController;

  double? _touchStartY;
  double _touchStartScrollOffset = 0.0;
  bool _isPageAnimating = false;

  double? _cachedTextWidth;
  TextStyle? _cachedTextStyle;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    widget.pageController.addListener(_onPageChanged);
    widget.scrollController.addListener(_onScrollOffsetChanged);
    _ticker = createTicker(_onTick)..start();
    _helloMarqueeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    widget.pageController.removeListener(_onPageChanged);
    widget.scrollController.removeListener(_onScrollOffsetChanged);
    _ticker.dispose();
    _helloMarqueeController.dispose();
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

  double _parallaxTop(double baseY, double factor) {
    return baseY - _parallaxOffset * factor;
  }

  double _measureTextWidth(String text, TextStyle style) {
    if (_cachedTextStyle == style && _cachedTextWidth != null) {
      return _cachedTextWidth!;
    }
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    _cachedTextStyle = style;
    _cachedTextWidth = painter.width;
    painter.dispose();
    return _cachedTextWidth!;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final r = ResponsiveScope.of(context);
    final isMobile = r.isMobile;
    final isDesktop = r.isDesktop;

    final List<double> textTriggers = isDesktop ? [0, 900, 1800] : [0, 400, 700];

    double blockVisible(int index) => _scrollOffset >= textTriggers[index] ? 1.0 : 0.0;

    final double aboutH =
        isDesktop ? HomeAboutSection.aboutHDesktop : HomeAboutSection.aboutHMobile;
    final double totalH = aboutH + _projectSectionH;

    final double pageArrival = _pageProgress.clamp(0.0, 1.0);
    final double offsetY = (1.0 - pageArrival) * 100.0;
    final double pageOpacity = pageArrival;
    final double introOffsetX = (1.0 - pageArrival) * 80.0;

    final double imgExitStart = isDesktop ? 2400.0 : 1100.0;
    final double imgExitEnd = isDesktop ? 3200.0 : 1700.0;
    final double imgExitProgress = _calcProgress(_scrollOffset, imgExitStart, imgExitEnd);
    final double imgExitOffsetY = -imgExitProgress * 200.0;
    final double imgExitOpacity =
        imgExitProgress < 0.4 ? 1.0 : 1.0 - ((imgExitProgress - 0.4) / 0.6);

    final double textExitStart = isDesktop ? 2200.0 : 900.0;
    final double textExitEnd = isDesktop ? 2600.0 : 1140.0;
    final double textExitOpacity = 1.0 - _calcProgress(_scrollOffset, textExitStart, textExitEnd);

    final double titleExitStart = isDesktop ? 200.0 : 1000.0;
    final double titleExitEnd = isDesktop ? 2400.0 : 1400.0;
    final double titleExitProgress = _calcProgress(_scrollOffset, titleExitStart, titleExitEnd);
    final double titleExitOffsetY = -titleExitProgress * 10.0;
    final double titleExitOpacity =
        titleExitProgress < 0.4 ? 1.0 : 1.0 - ((titleExitProgress - 0.4) / 0.6);
    final double titleOpacity = (pageOpacity * titleExitOpacity).clamp(0.0, 1.0);

    final double img1BaseY = isDesktop ? 600 : 400;
    final double img2BaseY = isDesktop ? 1200 : 800;
    final double img3BaseY = isDesktop ? 1800 : 1100;
    final double helloY = isDesktop ? 3550 : 1880;

    final double projectTriggerStart = aboutH - (isMobile ? 500 : 1000);
    final Color bgColor = Color.lerp(
      Colors.white,
      AppColors.black,
      _calcProgress(_scrollOffset, projectTriggerStart, projectTriggerStart + 10),
    )!;

    final double textGroupOpacity = (pageOpacity * textExitOpacity).clamp(0.0, 1.0);
    final double imageOpacity = (pageOpacity * imgExitOpacity).clamp(0.0, 1.0);

    return Listener(
      onPointerDown: _onPointerDown,
      onPointerMove: _onPointerMove,
      onPointerUp: _onPointerUp,
      child: Stack(
        children: [
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeInOut,
              color: bgColor,
            ),
          ),
          SingleChildScrollView(
            controller: widget.scrollController,
            physics: const NeverScrollableScrollPhysics(),
            child: SizedBox(
              width: r.width,
              height: totalH,
              child: Stack(
                children: [
                  Positioned(
                    top: helloY,
                    left: 0,
                    right: 0,
                    child: SizedBox(
                      height: isMobile ? 100 : 200,
                      child: ClipRect(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final textStyle = context.textTheme.displayLarge?.copyWith(
                              color: Colors.black,
                              fontSize: isMobile ? 100 : 180,
                              height: 1.0,
                            );

                            if (textStyle == null) return const SizedBox.shrink();

                            const itemText = 'Hello, World!';
                            final gap = isMobile ? 32.0 : 80.0;
                            final textWidth = _measureTextWidth(itemText, textStyle);
                            final itemWidth = textWidth + gap;
                            final repeatCount = ((constraints.maxWidth / itemWidth).ceil()) + 3;

                            return AnimatedBuilder(
                              animation: _helloMarqueeController,
                              builder: (context, _) {
                                return Transform.translate(
                                  offset: Offset(-itemWidth * _helloMarqueeController.value, 0),
                                  child: OverflowBox(
                                    maxWidth: double.infinity,
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: List.generate(
                                        repeatCount,
                                        (_) => Padding(
                                          padding: EdgeInsets.only(right: gap),
                                          child: Text(
                                            itemText,
                                            maxLines: 1,
                                            softWrap: false,
                                            overflow: TextOverflow.visible,
                                            style: textStyle,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: aboutH,
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
          Positioned(
            top: _parallaxTop(img1BaseY, _factor1) + imgExitOffsetY,
            left: isMobile ? null : r.width * 0.09,
            right: isMobile ? 24 : null,
            child: Opacity(
              opacity: imageOpacity,
              child: _ShadowImage(
                assetPath: AppAssets.aboutImg1,
                width: isMobile ? 140 : r.width * 0.2,
              ),
            ),
          ),
          Positioned(
            top: _parallaxTop(img2BaseY, _factor2) + imgExitOffsetY,
            left: isMobile ? 20 : null,
            right: isMobile ? null : r.width * 0.1,
            child: Opacity(
              opacity: imageOpacity,
              child: _ShadowImage(
                assetPath: AppAssets.aboutImg2,
                width: isMobile ? 140 : r.width * 0.2,
              ),
            ),
          ),
          Positioned(
            top: _parallaxTop(img3BaseY, _factor3) + imgExitOffsetY,
            left: isMobile ? null : r.width * 0.14,
            right: isMobile ? 24 : null,
            child: Opacity(
              opacity: imageOpacity,
              child: _ShadowImage(
                assetPath: AppAssets.aboutImg3,
                width: isMobile ? 130 : r.width * 0.2,
              ),
            ),
          ),
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
                      final visible = blockVisible(i);
                      return AnimatedOpacity(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOut,
                        opacity: (visible * textGroupOpacity).clamp(0.0, 1.0),
                        child: AnimatedSlide(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOut,
                          offset: visible == 1.0 ? Offset.zero : const Offset(0, 0.04),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: isMobile ? 40 : 80, vertical: 14),
                              decoration: BoxDecoration(
                                color: const Color(0xE6FFFFFF),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: const [_cardShadow],
                              ),
                              child: Text(
                                _introTexts[i],
                                style: isMobile
                                    ? context.textTheme.bodyMedium
                                    : context.textTheme.titleMedium?.copyWith(
                                        height: 1.8,
                                        letterSpacing: 0.2,
                                        fontSize: 16,
                                      ),
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
}

class _ShadowImage extends StatelessWidget {
  final String assetPath;
  final double width;

  const _ShadowImage({required this.assetPath, required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: _shadowDecoration,
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        child: Image.asset(assetPath, width: width, fit: BoxFit.cover),
      ),
    );
  }
}
