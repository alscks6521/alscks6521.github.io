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
  final ScrollController _aboutScrollController = ScrollController();

  double _pageProgress = 0.0;
  bool _wheelSnapping = false;
  bool _touchActive = false;
  bool _touchConsumed = false;

  static const double _trackpadDyThreshold = 40.0;

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
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeOutCubic,
    );
  }

  bool _isLikelyTrackpad(PointerScrollEvent event) {
    final dy = event.scrollDelta.dy.abs();
    final dx = event.scrollDelta.dx.abs();
    return dx > 0 || (dy > 0 && dy < _trackpadDyThreshold);
  }

  void _onPointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) return;
    if (!_pageController.hasClients) return;

    final dy = event.scrollDelta.dy;
    final page = _pageController.page ?? 0.0;

    if (page >= 0.99) {
      _handleAboutScroll(dy, _isLikelyTrackpad(event));
      return;
    }

    if (_wheelSnapping) return;

    final viewport = _pageController.position.viewportDimension;
    final midOffset = viewport * 0.5;
    final currentOffset = _pageController.offset;
    const tolerance = 8.0;

    if (dy > 0) {
      if (currentOffset < midOffset - tolerance) {
        _wheelSnapToOffset(midOffset);
      } else {
        _wheelSnapToPage(1);
      }
    } else if (dy < 0) {
      if (currentOffset > midOffset + tolerance) {
        _wheelSnapToOffset(midOffset);
      } else {
        _wheelSnapToOffset(0.0);
      }
    }
  }

  void _handleAboutScroll(double dy, bool isTrackpad) {
    if (!_aboutScrollController.hasClients) return;

    final max = _aboutScrollController.position.maxScrollExtent;
    const edge = 8.0;

    if (_aboutScrollController.offset <= edge && dy < 0) {
      if (isTrackpad) {
        _snapToPage(0);
      } else {
        _wheelSnapToOffset(0.0);
      }
      return;
    }

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

  Future<void> _navigateToAbout() async {
    await _snapToPage(1);
    if (_aboutScrollController.hasClients) {
      _aboutScrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Future<void> _navigateToProject() async {
    final r = ResponsiveScope.of(context);
    final isMobile = r.isMobile;
    final aboutH =
        isMobile ? HomeAboutSection.aboutHMobile + 320 : HomeAboutSection.aboutHDesktop + 700;
    final projectOffset = aboutH - (isMobile ? 500.0 : 1000.0);

    await _snapToPage(1);
    if (_aboutScrollController.hasClients) {
      _aboutScrollController.animateTo(
        projectOffset,
        duration: const Duration(milliseconds: 600),
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
              _HeroPage(
                pageProgress: _pageProgress,
                titleFade: _titleFade,
                imageFade: _imageFade,
                onNavigateToAbout: _navigateToAbout,
                onNavigateToProject: _navigateToProject,
              ),
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
}

class _HeroPage extends StatelessWidget {
  final double pageProgress;
  final Animation<double> titleFade;
  final Animation<double> imageFade;
  final VoidCallback onNavigateToAbout;
  final VoidCallback onNavigateToProject;

  const _HeroPage({
    required this.pageProgress,
    required this.titleFade,
    required this.imageFade,
    required this.onNavigateToAbout,
    required this.onNavigateToProject,
  });

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveScope.of(context);
    final isMobile = r.isMobile;
    final isDesktop = r.isDesktop;

    final navStyle = context.textTheme.bodySmall?.copyWith(
      fontSize: isMobile ? 14 : null,
    );

    return SizedBox(
      width: r.width,
      height: r.height,
      child: Stack(
        children: [
          FadeTransition(
            opacity: imageFade,
            child: Transform.translate(
              offset: Offset(-pageProgress * r.width * 0.1, 0),
              child: Opacity(
                opacity: (1.0 - pageProgress * 1.4).clamp(0.0, 1.0),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    width: isDesktop ? r.width * 0.8 : r.width * 0.9,
                    height: isMobile ? r.height * 0.4 : null,
                    constraints: BoxConstraints(maxHeight: r.height * 0.5),
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular((isMobile ? 150 : 300) * (1.0 - pageProgress)),
                        topRight: Radius.circular(pageProgress * 400),
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
                  Text("Home", style: navStyle),
                  SizedBox(width: isMobile ? 20 : 50),
                  GestureDetector(
                    onTap: onNavigateToAbout,
                    child: Text("About", style: navStyle),
                  ),
                ]),
                Row(children: [
                  GestureDetector(
                    onTap: onNavigateToProject,
                    child: Text("Projects", style: navStyle),
                  ),
                  SizedBox(width: isMobile ? 20 : 50),
                  Text("Skills", style: navStyle),
                ]),
              ],
            ),
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: r.height * 0.3),
              child: FadeTransition(
                opacity: titleFade,
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(children: [
                    TextSpan(
                      text: "Hi, ",
                      style: context.textTheme.titleLarge?.copyWith(fontSize: isMobile ? 26 : null),
                    ),
                    TextSpan(
                      text: "I'm Minsung Kim.${isMobile ? "\n" : " "}",
                      style:
                          context.textTheme.titleMedium?.copyWith(fontSize: isMobile ? 20 : null),
                    ),
                    TextSpan(
                      text: "Web App Frontend Developer.",
                      style: context.textTheme.titleSmall?.copyWith(fontSize: isMobile ? 20 : null),
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
