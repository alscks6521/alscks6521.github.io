import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:github_portfolio/common/app_assets.dart';
import 'package:github_portfolio/common/extensions/context_extensions.dart';
import 'package:github_portfolio/common/responsive/responsive_scope.dart';

class HomeAboutSection extends StatefulWidget {
  final PageController pageController;
  final ScrollController scrollController;
  final int nextPageIndex;
  final int prevPageIndex;

  const HomeAboutSection({
    super.key,
    required this.pageController,
    required this.scrollController,
    this.nextPageIndex = 2,
    this.prevPageIndex = 0,
  });

  @override
  State<HomeAboutSection> createState() => _HomeAboutSectionState();
}

class _HomeAboutSectionState extends State<HomeAboutSection>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  double _pageProgress = 0.0;
  double _scrollOffset = 0.0;

  // 페럴 지연 오프셋 값 = _scrollOffset을 즉시 안따라가게
  double _parallaxOffset = 0.0;
  late final Ticker _ticker;

  static const double _factor1 = 0.55; // 1이미지
  static const double _factor2 = 0.65; // 2이미지
  static const double _factor3 = 0.75; // 3이미지

  // 터치
  double? _touchStartY;
  double _touchStartScrollOffset = 0.0;
  bool _isPageAnimating = false;
  static const double _touchThreshold = 60.0;

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
    setState(() => _pageProgress = page.clamp(0.0, 2.0));
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

  // 터치 이벤트
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
      return;
    }
    if (newOffset >= max - edge && delta > _touchThreshold) {
      _touchStartY = null;
      _goToPage(widget.nextPageIndex);
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

    final double pageArrival = _pageProgress.clamp(0.0, 1.0);
    final double offsetY = (1.0 - pageArrival) * 60.0;
    final double pageOpacity = pageArrival.clamp(0.0, 1.0);
    final double introOffsetX = (1.0 - pageArrival) * 80.0;

    final double textFadeOut = 1.0 - _calcProgress(_scrollOffset, 2500, 3400);
    final double fixedTextOpacity = (pageOpacity * textFadeOut).clamp(0.0, 1.0);

    // 이미지 기본 Y 위치
    final double img1BaseY = isMobile ? 800 : 600;
    const double img2BaseY = 1200;
    const double img3BaseY = 1700;

    return Listener(
      onPointerDown: _onPointerDown,
      onPointerMove: _onPointerMove,
      onPointerUp: _onPointerUp,
      child: Stack(
        children: [
          // 스크롤 영역
          SingleChildScrollView(
            controller: widget.scrollController,
            physics: const NeverScrollableScrollPhysics(),
            child: Container(
              width: r.width,
              height: 4200,
              color: Colors.white,
            ),
          ),

          // 1 이미지
          Positioned(
            top: _parallaxTop(img1BaseY, _factor1),
            left: isMobile ? null : r.width * 0.1,
            right: isMobile ? 24 : null,
            child: Opacity(
              opacity: pageOpacity,
              child: _shadowImage(
                assetPath: AppAssets.aboutImg1,
                width: isMobile ? 140 : r.width * 0.2,
              ),
            ),
          ),

          // about me 텍스트
          Positioned(
            top: isMobile ? 16 : 70,
            left: isMobile ? 20 : 80,
            right: isMobile ? null : 80,
            child: Transform.translate(
              offset: Offset(0, offsetY),
              child: Opacity(
                opacity: fixedTextOpacity,
                child: Text(
                  "About",
                  style: context.textTheme.titleLarge,
                  textAlign: isMobile ? TextAlign.center : TextAlign.left,
                ),
              ),
            ),
          ),

          // 소개 텍스트 고정
          Positioned(
            top: isMobile ? r.height * 0.3 : 140,
            left: isMobile ? 24 : 10,
            right: isMobile ? 24 : 0,
            child: Center(
              child: Transform.translate(
                offset: Offset(introOffsetX, 0),
                child: Opacity(
                  opacity: fixedTextOpacity,
                  child: Text(
                    """
안녕하세요. 웹·앱 개발자 김민성입니다.
Flutter를 중심으로 웹과 모바일 서비스를 개발하고 있습니다.

스타트업에서 앱의 설계부터 개발, 배포까지 전 과정을 담당하며
Android와 iOS 스토어에 서비스를 직접 출시한 경험이 있습니다.

사용자가 실제로 사용할 수 있는 서비스를 만드는 것을 목표로
공부를 하며 지속적인 개선에 집중하고 있습니다.

방문해주셔서 감사합니다.
""",
                    style: isMobile
                        ? context.textTheme.bodyMedium
                        : isDesktop
                            ? context.textTheme.titleMedium
                                ?.copyWith(height: 1.8, letterSpacing: -0.2, fontSize: 22)
                            : context.textTheme.bodyLarge,
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
            ),
          ),

          // 2 이미지
          Positioned(
            top: _parallaxTop(img2BaseY, _factor2),
            right: isMobile ? 24 : r.width * 0.1,
            child: Opacity(
              opacity: pageOpacity,
              child: _shadowImage(
                assetPath: AppAssets.aboutImg2,
                width: isMobile ? 140 : r.width * 0.2,
              ),
            ),
          ),

          // 3 이미지
          Positioned(
            top: _parallaxTop(img3BaseY, _factor3),
            left: isMobile ? null : r.width * 0.14,
            right: isMobile ? 24 : null,
            child: Opacity(
              opacity: pageOpacity,
              child: _shadowImage(
                assetPath: AppAssets.aboutImg3,
                width: isMobile ? 130 : r.width * 0.2,
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
