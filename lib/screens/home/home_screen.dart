import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:github_portfolio/common/app_assets.dart';
import 'package:github_portfolio/common/extensions/context_extensions.dart';
import 'package:github_portfolio/common/responsive/responsive_scope.dart';
import 'package:github_portfolio/screens/home/h_views/home_about_section.dart';
import 'package:github_portfolio/screens/home/h_views/home_project_section.dart';

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

  // 섹션별 스크롤 컨트롤러 제어용임!
  final ScrollController _aboutScrollController = ScrollController();
  final ScrollController _projectScrollController = ScrollController();

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
    _projectScrollController.dispose();

    super.dispose();
  }

  void _onPageChanged() {
    if (!mounted) return;
    setState(() {
      _pageProgress = (_pageController.page ?? 0.0).clamp(0.0, 1.0);
    });
  }

  // PageView제오ㅓ
  void _onScroll(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) return;
    if (!_pageController.hasClients) return;

    final currentPage = _pageController.page ?? 0.0;

    if (currentPage >= 0.9) return;

    final viewport = _pageController.position.viewportDimension;
    final aboutOffset = viewport * 1.0;
    const snapEps = 6.0; // 픽셀 단위 스냅 허용치

    final raw = _pageController.offset + event.scrollDelta.dy;

    final clamped = raw.clamp(0.0, aboutOffset);

    _pageController.jumpTo(clamped);

    // 도달
    if ((aboutOffset - clamped).abs() <= snapEps) {
      _pageController.jumpToPage(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          NotificationListener<ScrollEndNotification>(
            onNotification: (_) {
              final page = _pageController.page ?? 0.0;
              if (page >= 0.5 && page < 1.0) {
                _pageController.animateToPage(
                  1,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOut,
                );
              }
              return false;
            },
            child: Listener(
              onPointerSignal: _onScroll,
              child: PageView(
                controller: _pageController,
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                pageSnapping: false,
                children: [
                  _buildHero(context),
                  // About
                  HomeAboutSection(
                    pageController: _pageController,
                    scrollController: _aboutScrollController,
                    prevPageIndex: 0,
                    nextPageIndex: 2,
                  ),
                  // Project
                  HomeProjectSection(
                    pageController: _pageController,
                    projectScrollController: _projectScrollController,
                    aboutScrollController: _aboutScrollController,
                    prevPageIndex: 1, // About
                  ),
                ],
              ),
            ),
          ),
        ],
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
          /// 이미지
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
                        topLeft: Radius.circular(isMobile ? 150 : 300),
                      ),
                      child: Image.asset(
                        AppAssets.hImg,
                        fit: BoxFit.cover,
                        alignment: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          /// 상단 네비
          Positioned(
            top: 20,
            left: isMobile ? 20 : 60,
            right: isMobile ? 20 : 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text("Home", style: context.textTheme.bodySmall),
                    SizedBox(width: isMobile ? 20 : 50),
                    Text("About", style: context.textTheme.bodySmall),
                  ],
                ),
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        _pageController.jumpToPage(
                          2,
                        );
                      },
                      child: Text("Projects", style: context.textTheme.bodySmall),
                    ),
                    SizedBox(width: isMobile ? 20 : 50),
                    Text("Skills", style: context.textTheme.bodySmall),
                  ],
                ),
              ],
            ),
          ),

          /// 중앙 타이틀
          Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: r.height * 0.3),
              child: FadeTransition(
                opacity: _titleFade,
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Hi, ",
                        style: context.textTheme.titleLarge,
                      ),
                      TextSpan(
                        text: "I'm Minsung Kim. ",
                        style: context.textTheme.titleMedium,
                      ),
                      TextSpan(
                        text: "Web App Frontend Developer.",
                        style: context.textTheme.titleSmall,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
