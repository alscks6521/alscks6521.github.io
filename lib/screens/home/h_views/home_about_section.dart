import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
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

class _HomeAboutSectionState extends State<HomeAboutSection> with AutomaticKeepAliveClientMixin {
  double _pageProgress = 0.0;
  double _scrollOffset = 0.0;
  bool _isPageAnimating = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    widget.pageController.addListener(_onPageChanged);
    widget.scrollController.addListener(_onScrollOffsetChanged);
  }

  @override
  void dispose() {
    widget.pageController.removeListener(_onPageChanged);
    widget.scrollController.removeListener(_onScrollOffsetChanged);
    super.dispose();
  }

  void _onPageChanged() {
    if (!mounted) return;
    final page = widget.pageController.page ?? 0.0;
    setState(() {
      _pageProgress = page.clamp(0.0, 1.0);
    });
  }

  void _onScrollOffsetChanged() {
    if (!mounted) return;
    setState(() {
      _scrollOffset = widget.scrollController.offset;
    });
  }

  Future<void> _goToPage(int index) async {
    if (_isPageAnimating) return;
    _isPageAnimating = true;
    try {
      await widget.pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
      );
    } finally {
      _isPageAnimating = false;
    }
  }

  void _onPointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) return;
    if (!widget.scrollController.hasClients) return;

    final max = widget.scrollController.position.maxScrollExtent;
    const edge = 8.0;

    final isAtTop = widget.scrollController.offset <= edge;
    final isAtBottom = widget.scrollController.offset >= max - edge;

    final isScrollingUp = event.scrollDelta.dy < 0;
    final isScrollingDown = event.scrollDelta.dy > 0;

    if (isAtTop && isScrollingUp) {
      _goToPage(widget.prevPageIndex);
      return;
    }

    if (isAtBottom && isScrollingDown) {
      _goToPage(widget.nextPageIndex);
      return;
    }

    final newOffset = (widget.scrollController.offset + event.scrollDelta.dy * 0.6).clamp(0.0, max);

    widget.scrollController.jumpTo(newOffset);
  }

  double _calcProgress(double offset, double start, double end) {
    return ((offset - start) / (end - start)).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final r = ResponsiveScope.of(context);
    final isMobile = r.isMobile;
    final isDesktop = r.isDesktop;

    final double offsetY = (1.0 - _pageProgress) * 60.0;
    final double pageOpacity = _pageProgress.clamp(0.0, 1.0);
    final double introOffsetX = (1.0 - _pageProgress) * 80.0;

    final double textFadeOut = 1.0 - _calcProgress(_scrollOffset, 2000, 2500);
    final double fixedTextOpacity = (pageOpacity * textFadeOut).clamp(0.0, 1.0);

    return Listener(
      onPointerSignal: _onPointerSignal,
      child: Stack(
        children: [
          SingleChildScrollView(
            controller: widget.scrollController,
            physics: const NeverScrollableScrollPhysics(),
            child: Container(
              width: r.width,
              height: 3400,
              color: Colors.white,
            ),
          ),
          Positioned(
            top: (isMobile ? 800 : 1100) - _scrollOffset,
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
          Positioned(
            top: isMobile ? 16 : 70,
            left: isMobile ? 20 : 80,
            right: isMobile ? null : 80,
            child: Transform.translate(
              offset: Offset(0, offsetY),
              child: Opacity(
                opacity: fixedTextOpacity,
                child: Text(
                  "About Me",
                  style: context.textTheme.titleLarge,
                  textAlign: isMobile ? TextAlign.center : TextAlign.left,
                ),
              ),
            ),
          ),
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
                    "Hello! My name is Kim Min-seong\n"
                    "and I develop web and apps.\n\n"
                    "At a startup, I specialized in Flutter,\n"
                    "designing and developing apps from start to finish.\n\n"
                    "I improved distribution to the Play Store and App Store,\n"
                    "and then worked on feature development and improvements.",
                    style: isMobile
                        ? context.textTheme.bodyMedium
                        : isDesktop
                            ? context.textTheme.titleMedium
                            : context.textTheme.bodyLarge,
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 1500 - _scrollOffset,
            right: isMobile ? 24 : r.width * 0.1,
            child: Opacity(
              opacity: pageOpacity,
              child: _shadowImage(
                assetPath: AppAssets.aboutImg2,
                width: isMobile ? 140 : r.width * 0.2,
              ),
            ),
          ),
          Positioned(
            top: 2200 - _scrollOffset,
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

  Widget _shadowImage({
    required String assetPath,
    required double width,
  }) {
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
        child: Image.asset(
          assetPath,
          width: width,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
