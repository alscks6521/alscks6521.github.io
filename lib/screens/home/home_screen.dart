import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:github_portfolio/common/app_assets.dart';
import 'package:github_portfolio/common/extensions/context_extensions.dart';
import 'package:github_portfolio/common/responsive/responsive_scope.dart';
import 'package:github_portfolio/screens/home/h_views/home_about_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late final AnimationController _titleController;
  late final AnimationController _imageController;
  late final Animation<double> _titleFade;
  late final Animation<double> _imageFade;

  late final PageController _pageController;
  double _pageProgress = 0.0;

  final ScrollController _aboutScrollController = ScrollController();

  // 마우스휠 전용
  bool _wheelSnapping = false;

  // Home => About 터치전용
  bool _touchActive = false;
  bool _touchConsumed = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(_onPageChanged);

    _titleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _imageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _titleFade = CurvedAnimation(parent: _titleController, curve: Curves.easeIn);
    _imageFade = CurvedAnimation(parent: _imageController, curve: Curves.easeIn);

    _titleController.forward();
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _imageController.forward();
    });
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageChanged);
    _titleController.dispose();
    _imageController.dispose();
    _pageController.dispose();
    _aboutScrollController.dispose();
    super.dispose();
  }

  void _onPageChanged() {
    if (!mounted) return;
    final page = _pageController.page ?? 0.0;
    setState(() => _pageProgress = page.clamp(0.0, 1.0));
  }

  Future<void> _wheelSnapToPage(int page) async {
    if (_wheelSnapping) return;
    _wheelSnapping = true;
    try {
      await _pageController.animateToPage(
        page,
        duration: const Duration(milliseconds: 480),
        curve: Curves.easeOutCubic,
      );
    } finally {
      _wheelSnapping = false;
    }
  }

  Future<void> _wheelSnapToOffset(double offset) async {
    if (_wheelSnapping) return;
    _wheelSnapping = true;
    try {
      await _pageController.animateTo(
        offset,
        duration: const Duration(milliseconds: 480),
        curve: Curves.easeOutCubic,
      );
    } finally {
      _wheelSnapping = false;
    }
  }

  Future<void> _snapToPage(int page) async {
    await _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 480),
      curve: Curves.easeOutCubic,
    );
  }

  void _onPointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) return;
    if (!_pageController.hasClients) return;

    final dy = event.scrollDelta.dy;
    final isTrackpad = dy.abs() < 180;
    final page = _pageController.page ?? 0.0;

    if (page >= 0.99) {
      _handleAboutScroll(dy, isTrackpad);
      return;
    }

    // Home 페이지
    final viewport = _pageController.position.viewportDimension;
    final maxOffset = viewport;
    final midOffset = viewport * 0.5;

    if (isTrackpad) {
      final newOffset = (_pageController.offset + dy * 0.4).clamp(0.0, maxOffset);
      _pageController.jumpTo(newOffset);
      if (newOffset >= maxOffset) {
        _snapToPage(1);
      }
    } else {
      if (_wheelSnapping) return;
      if (dy > 0) {
        if (page < 0.5) {
          _wheelSnapToOffset(midOffset);
        } else {
          _wheelSnapToPage(1);
        }
      } else {
        _wheelSnapToOffset(0.0);
      }
    }
  }

  void _handleAboutScroll(double dy, bool isTrackpad) {
    if (!_aboutScrollController.hasClients) return;

    final max = _aboutScrollController.position.maxScrollExtent;
    const edge = 8.0;
    final offset = _aboutScrollController.offset;
    final isAtTop = offset <= edge;

    // about -> home
    if (isAtTop && dy < 0) {
      if (isTrackpad) {
        _snapToPage(0);
      } else {
        _wheelSnapToOffset(0.0);
      }
      return;
    }

    _scrollAbout(dy, isTrackpad, max);
  }

  void _scrollAbout(double dy, bool isTrackpad, double max) {
    if (isTrackpad) {
      final newOffset = (_aboutScrollController.offset + dy * 0.8).clamp(0.0, max);
      _aboutScrollController.jumpTo(newOffset);
    } else {
      final newOffset = (_aboutScrollController.offset + dy * 3.0).clamp(0.0, max);
      _aboutScrollController.animateTo(
        newOffset,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _onVerticalDragStart(DragStartDetails details) {
    final page = _pageController.page ?? 0.0;
    _touchActive = page <= 0.05;
    _touchConsumed = false;
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    if (!_touchActive || _touchConsumed) return;
    if (!_pageController.hasClients) return;

    final dy = details.delta.dy;
    if (dy >= 0) return;

    final viewport = _pageController.position.viewportDimension;
    final newOffset = (_pageController.offset - dy * 0.8).clamp(0.0, viewport);
    _pageController.jumpTo(newOffset);
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    if (!_touchActive || _touchConsumed) return;
    if (!_pageController.hasClients) return;

    _touchConsumed = true;
    _touchActive = false;

    final page = _pageController.page ?? 0.0;
    final velocity = details.velocity.pixelsPerSecond.dy;

    if (page > 0.02 || velocity < -100) {
      _snapToPage(1);
    } else {
      _pageController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Listener(
        onPointerSignal: _onPointerSignal,
        child: GestureDetector(
          behavior: HitTestBehavior.deferToChild,
          onVerticalDragStart: _onVerticalDragStart,
          onVerticalDragUpdate: _onVerticalDragUpdate,
          onVerticalDragEnd: _onVerticalDragEnd,
          child: PageView(
            controller: _pageController,
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            pageSnapping: false,
            children: [
              _buildHero(context),
              HomeAboutSection(
                pageController: _pageController,
                scrollController: _aboutScrollController,
                prevPageIndex: 0,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    final r = ResponsiveScope.of(context);
    final isMobile = r.isMobile;
    final isDesktop = r.isDesktop;

    return SizedBox(
      width: r.width,
      height: r.height,
      child: Stack(
        children: [
          FadeTransition(
            opacity: _imageFade,
            child: Transform.translate(
              offset: Offset(-_pageProgress * r.width * 0.1, 0),
              child: Opacity(
                opacity: (1.0 - _pageProgress * 1.4).clamp(0.0, 1.0),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    width: isDesktop ? r.width * 0.8 : r.width * 0.9,
                    height: isMobile ? r.height * 0.4 : null,
                    constraints: BoxConstraints(maxHeight: r.height * 0.5),
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular((isMobile ? 150 : 300) * (1.0 - _pageProgress)),
                        topRight: Radius.circular(_pageProgress * 400),
                      ),
                      child: Image.asset(
                        AppAssets.hImg2,
                        fit: BoxFit.cover,
                        alignment: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 20,
            left: isMobile ? 20 : 60,
            right: isMobile ? 20 : 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Text("Home", style: context.textTheme.bodySmall),
                  SizedBox(width: isMobile ? 20 : 50),
                  Text("About", style: context.textTheme.bodySmall),
                ]),
                Row(children: [
                  Text("Projects", style: context.textTheme.bodySmall),
                  SizedBox(width: isMobile ? 20 : 50),
                  Text("Skills", style: context.textTheme.bodySmall),
                ]),
              ],
            ),
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: r.height * 0.3),
              child: FadeTransition(
                opacity: _titleFade,
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(children: [
                    TextSpan(text: "Hi, ", style: context.textTheme.titleLarge),
                    TextSpan(text: "I'm Minsung Kim. ", style: context.textTheme.titleMedium),
                    TextSpan(
                      text: "Web App Frontend Developer.",
                      style: context.textTheme.titleSmall,
                    ),
                  ]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
