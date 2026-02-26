import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:github_portfolio/common/extensions/context_extensions.dart';
import 'package:github_portfolio/common/responsive/responsive_scope.dart';

class HomeProjectSection extends StatefulWidget {
  final PageController pageController;
  final ScrollController projectScrollController;
  final ScrollController aboutScrollController;
  final int prevPageIndex;

  const HomeProjectSection({
    super.key,
    required this.pageController,
    required this.projectScrollController,
    required this.aboutScrollController,
    this.prevPageIndex = 1,
  });

  @override
  State<HomeProjectSection> createState() => _HomeProjectSectionState();
}

class _HomeProjectSectionState extends State<HomeProjectSection>
    with AutomaticKeepAliveClientMixin {
  bool _isPageAnimating = false;

  @override
  bool get wantKeepAlive => true;

  Future<void> _goBackToAboutAndStickToBottom() async {
    if (_isPageAnimating) return;
    _isPageAnimating = true;
    try {
      await widget.pageController.animateToPage(
        widget.prevPageIndex,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
      );
      await _jumpAboutToBottomSafely();
    } finally {
      _isPageAnimating = false;
    }
  }

  Future<void> _jumpAboutToBottomSafely() async {
    final c = widget.aboutScrollController;

    for (int i = 0; i < 30; i++) {
      if (c.hasClients) break;
      await Future.delayed(const Duration(milliseconds: 16));
    }
    if (!c.hasClients) return;

    for (int i = 0; i < 30; i++) {
      final pos = c.position;
      if (pos.hasContentDimensions && pos.maxScrollExtent > 0) break;
      await Future.delayed(const Duration(milliseconds: 16));
    }

    final max = c.position.maxScrollExtent;
    if (max <= 0) return;

    c.jumpTo(max);
  }

  void _onPointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) return;
    if (!widget.projectScrollController.hasClients) return;

    const edge = 8.0;
    final isAtTop = widget.projectScrollController.offset <= edge;
    final isScrollingUp = event.scrollDelta.dy < 0;

    if (isAtTop && isScrollingUp) {
      _goBackToAboutAndStickToBottom();
      return;
    }

    final max = widget.projectScrollController.position.maxScrollExtent;
    final newOffset =
        (widget.projectScrollController.offset + event.scrollDelta.dy * 0.8).clamp(0.0, max);

    widget.projectScrollController.jumpTo(newOffset);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final r = ResponsiveScope.of(context);
    final isMobile = r.isMobile;

    return Listener(
      onPointerSignal: _onPointerSignal,
      child: SingleChildScrollView(
        controller: widget.projectScrollController,
        physics: const NeverScrollableScrollPhysics(),
        child: Container(
          width: r.width,
          height: 3000,
          color: Colors.black,
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 20 : 80,
            vertical: isMobile ? 24 : 60,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Projects",
                style: context.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Project content here",
                style: context.textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(height: 2000),
              Text(
                "End",
                style: context.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
