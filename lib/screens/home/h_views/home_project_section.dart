import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:github_portfolio/common/app_assets.dart';
import 'package:github_portfolio/common/extensions/context_extensions.dart';
import 'package:github_portfolio/common/responsive/responsive_scope.dart';
import 'package:github_portfolio/common/theme/app_colors.dart';

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

final _projects = [
  const ProjectItem(
    title: '언어 치료 관리 모바일 애플리케이션',
    subtitle: """
ISay App은 언어 치료가 필요한 아동과 보호자, 그리고 치료사를 연결하여 치료 일정 관리와 상담을 지원하는 모바일 애플리케이션입니다.

프로젝트에서는 Flutter 기반 모바일 애플리케이션 개발을 전체적으로 담당했습니다.

- Firebase Cloud Messaging을 활용한 푸시 알림 기능을 구현하여 사용자에게 일정 및 서비스 관련 알림을 전달하도록 하였으며, 실제 서비스 운영을 위해 Android Play Store와 Apple App Store에 앱을 직접 배포했습니다.
""",
    useSkill: [
      'Flutter',
      'Riverpod Provider',
      'Kakao Auth & Map',
      'IOS Auth',
      'Firebase Cloud Messaging',
      'PortOne API',
      'WebSocket'
    ],
    imagePath: AppAssets.sImg1,
    contentImagePath: AppAssets.scImg1,
  ),
  const ProjectItem(
    title: '언어 치료 관리 웹 플랫폼',
    subtitle: """
ISay Web은 언어 치료 서비스 이용자와 치료사를 위한 관리 플랫폼으로, 치료 일정 관리, 상담 기능, 사용자 관리 기능 등을 제공하는 웹 서비스입니다.

프로젝트에서는 Flutter Web 프론트엔드 개발을 전체적으로 담당했습니다.

- WebSocket 기반 실시간 채팅 기능을 구현하여 사용자 간 상담이 가능하도록 했으며, Firebase Cloud Messaging을 활용하여 웹 환경에서도 푸시 알림을 받을 수 있도록 구성했습니다.
""",
    useSkill: [
      'Flutter',
      'Dio',
      'Firebase Cloud Messaging',
      'JavaScript PortOne API SDK',
      'WebSocket'
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
  final PageController pageController;
  final ScrollController projectScrollController;
  final ScrollController aboutScrollController;
  final int prevPageIndex;
  final VoidCallback? onArrivedAtAboutFromProject;

  const HomeProjectSection({
    super.key,
    required this.pageController,
    required this.projectScrollController,
    required this.aboutScrollController,
    this.prevPageIndex = 1,
    this.onArrivedAtAboutFromProject,
  });

  @override
  State<HomeProjectSection> createState() => _HomeProjectSectionState();
}

class _HomeProjectSectionState extends State<HomeProjectSection>
    with AutomaticKeepAliveClientMixin {
  int _focusedIndex = 0;
  bool _isPageAnimating = false;
  double _trackpadAccum = 0.0;
  bool _wheelCooldown = false;

  // 태블릿/모바일 스크롤 컨트롤러
  final ScrollController _tabletScrollController = ScrollController();

  // 데스크탑 터치 전용
  double? _touchStartY;
  double? _touchStartX;
  int _touchStartIndex = 0;

  static const double _itemHeight = 130.0;
  static const double _thumbFixedW = 240.0;
  static const double _thumbFixedH = 200.0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabletScrollController.addListener(_onTabletScroll);
  }

  @override
  void dispose() {
    _tabletScrollController.removeListener(_onTabletScroll);
    _tabletScrollController.dispose();
    super.dispose();
  }

  // 맨 위에서 추가 스크롤 시도 감지 → About 복귀
  void _onTabletScroll() {
    if (_tabletScrollController.offset <= 0 &&
        _tabletScrollController.position.userScrollDirection.name == 'forward') {
      _goBackToAbout();
    }
  }

  Future<void> _goBackToAbout() async {
    if (_isPageAnimating) return;
    _isPageAnimating = true;
    try {
      await _setAboutToBottom();
      await widget.pageController.animateToPage(
        widget.prevPageIndex,
        duration: const Duration(milliseconds: 480),
        curve: Curves.easeOutCubic,
      );
      widget.onArrivedAtAboutFromProject?.call();
    } finally {
      _isPageAnimating = false;
    }
  }

  Future<void> _setAboutToBottom() async {
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
    await Future.delayed(const Duration(milliseconds: 32));
  }

  void _setIndex(int i) {
    final clamped = i.clamp(0, _projects.length - 1);
    if (clamped == _focusedIndex) return;
    setState(() => _focusedIndex = clamped);
  }

  // 데스크탑 전용 휠/트랙패드
  void _onPointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) return;
    if (_isPageAnimating) return;

    final dy = event.scrollDelta.dy;
    final isTrackpad = dy.abs() < 50;

    if (isTrackpad) {
      _trackpadAccum += dy;
      if (_trackpadAccum.abs() >= _itemHeight * 0.8) {
        if (_trackpadAccum < 0) {
          if (_focusedIndex == 0) {
            _trackpadAccum = 0;
            _goBackToAbout();
            return;
          }
          _setIndex(_focusedIndex - 1);
        } else {
          _setIndex(_focusedIndex + 1);
        }
        _trackpadAccum = 0;
      }
    } else {
      if (_wheelCooldown) return;
      _wheelCooldown = true;
      Future.delayed(const Duration(milliseconds: 100), () => _wheelCooldown = false);
      if (dy < 0) {
        if (_focusedIndex == 0) {
          _goBackToAbout();
          return;
        }
        _setIndex(_focusedIndex - 1);
      } else {
        _setIndex(_focusedIndex + 1);
      }
    }
  }

  // 데스크탑 전용 터치 세로 드래그
  void _onPointerDown(PointerDownEvent event) {
    if (event.kind == PointerDeviceKind.mouse) return;
    _touchStartY = event.position.dy;
    _touchStartX = event.position.dx;
    _touchStartIndex = _focusedIndex;
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (event.kind == PointerDeviceKind.mouse) return;
    if (_touchStartY == null) return;
    final deltaY = _touchStartY! - event.position.dy;
    final steps = (deltaY / _itemHeight).round();
    final newIndex = (_touchStartIndex + steps).clamp(0, _projects.length - 1);
    setState(() => _focusedIndex = newIndex);
    if (_focusedIndex == 0 && deltaY < -80) {
      _touchStartY = null;
      _goBackToAbout();
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    if (event.kind == PointerDeviceKind.mouse) return;
    _touchStartY = null;
    _touchStartX = null;
  }

  double _thumbOffsetY(int i) {
    final diff = i - _focusedIndex;
    if (diff == 0) return 0;
    return diff * (_thumbFixedH + 12.0);
  }

  double _thumbOffsetX(int i, double thumbW) {
    final diff = i - _focusedIndex;
    if (diff == 0) return 0;
    return diff * (thumbW + 10.0);
  }

  double _thumbScale(int i) {
    final diff = (i - _focusedIndex).abs();
    if (diff == 0) return 1.0;
    if (diff == 1) return 0.78;
    if (diff == 2) return 0.60;
    return 0.46;
  }

  double _thumbOpacity(int i) {
    final diff = (i - _focusedIndex).abs();
    if (diff == 0) return 1.0;
    if (diff == 1) return 0.45;
    if (diff == 2) return 0.22;
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final r = ResponsiveScope.of(context);
    final isDesktop = r.isDesktop;
    final double fixedH = r.isMobile ? 700.0 : r.maxStageHeight;

    final body = SizedBox(
      width: r.width,
      height: r.height,
      child: OverflowBox(
        maxHeight: double.infinity,
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: r.width,
          height: fixedH,
          child: isDesktop
              ? _buildDesktopLayout(r.width, fixedH)
              : _buildTabletMobileLayout(r.width, r.isMobile, r.isTablet, fixedH),
        ),
      ),
    );

    // 데스크탑: 휠/트랙패드 + 터치 세로 드래그
    // 태블릿/모바일: Listener 없음 → 드럼롤은 onTap으로만 이동
    if (isDesktop) {
      return Listener(
        onPointerSignal: _onPointerSignal,
        onPointerDown: _onPointerDown,
        onPointerMove: _onPointerMove,
        onPointerUp: _onPointerUp,
        child: body,
      );
    }
    return body;
  }

  Widget _buildDesktopLayout(double width, double fixedH) {
    final double contentW = width * 0.64;
    final double thumbAreaW = width * 0.22;
    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          Positioned(top: 50, width: contentW, height: 1000, child: _buildContent(false, false)),
          Positioned(
              right: width * 0.04,
              top: 0,
              height: fixedH,
              width: thumbAreaW,
              child: _buildVerticalPicker(thumbAreaW, fixedH)),
        ],
      ),
    );
  }

  Widget _buildTabletMobileLayout(double width, bool isMobile, bool isTablet, double fixedH) {
    final double thumbW = isMobile ? 100.0 : 140.0;
    final double thumbH = isMobile ? 80.0 : 110.0;
    final double contentW = isMobile ? width - 40 : width - 80;
    final double hPickerH = thumbH + 24;

    return Container(
        color: Colors.white,
        child: SingleChildScrollView(
          controller: _tabletScrollController,
          physics: const ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              SizedBox(width: contentW, child: _buildContent(isMobile, isTablet)),
              const SizedBox(height: 40),
              SizedBox(height: hPickerH, child: _buildHorizontalPicker(width, thumbW, thumbH)),
              SizedBox(height: thumbH),
            ],
          ),
        ));
  }

  Widget _buildVerticalPicker(double thumbAreaW, double screenH) {
    final centerY = screenH / 2;
    return Stack(
      clipBehavior: Clip.none,
      children: List.generate(_projects.length, (i) {
        final diff = (i - _focusedIndex).abs();
        if (diff > 2) return const SizedBox.shrink();
        return AnimatedPositioned(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
          top: centerY - _thumbFixedH / 2 + _thumbOffsetY(i),
          right: 0,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 250),
            opacity: _thumbOpacity(i),
            child: AnimatedScale(
              scale: _thumbScale(i),
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeOutCubic,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _setIndex(i),
                child: _thumbContainer(
                    project: _projects[i],
                    w: _thumbFixedW,
                    h: _thumbFixedH,
                    isFocused: i == _focusedIndex),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildHorizontalPicker(double screenW, double thumbW, double thumbH) {
    final centerX = screenW / 2;
    return ClipRect(
      child: SizedBox(
        width: screenW,
        height: thumbH,
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: List.generate(_projects.length, (i) {
            final diff = (i - _focusedIndex).abs();
            if (diff > 2) return const SizedBox.shrink();

            final scale = _thumbScale(i);
            final opacity = _thumbOpacity(i);
            final w = thumbW * scale;
            final h = thumbH * scale;
            final offsetX = _thumbOffsetX(i, thumbW);

            return AnimatedPositioned(
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeOutCubic,
              left: centerX - w / 2 + offsetX,
              top: (thumbH - h) / 2,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 250),
                opacity: opacity,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _setIndex(i),
                  child: _thumbContainer(
                    project: _projects[i],
                    w: w,
                    h: h,
                    isFocused: i == _focusedIndex,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _thumbContainer(
      {required ProjectItem project,
      required double w,
      required double h,
      required bool isFocused}) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade100,
        boxShadow: isFocused
            ? [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 20,
                    offset: const Offset(0, 6))
              ]
            : [],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(project.imagePath, width: w, height: h, fit: BoxFit.contain),
      ),
    );
  }

  Widget _buildContent(bool isMobile, bool isTablet) {
    bool deskTop = !isMobile && !isTablet;
    final project = _projects[_focusedIndex];
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero).animate(anim),
          child: child,
        ),
      ),
      child: Column(
        key: ValueKey(_focusedIndex),
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(isMobile ? 18 : 40, 8, isMobile ? 40 : 80, 8),
            decoration: BoxDecoration(
              color: AppColors.glay20.withValues(alpha: 0.8),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(100),
                bottomRight: Radius.circular(100),
              ),
            ),
            child: Text(project.title,
                style: context.textTheme.headlineLarge?.copyWith(
                    fontSize: isMobile
                        ? 18
                        : isTablet
                            ? 20
                            : null)),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.only(left: deskTop ? 60 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: isMobile ? 200 : 300,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(project.contentImagePath),
                      fit: BoxFit.contain,
                      alignment: isMobile || isTablet ? Alignment.center : Alignment.centerLeft,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text('Description',
                    style:
                        context.textTheme.headlineMedium?.copyWith(fontSize: isMobile ? 18 : null)),
                const SizedBox(height: 8),
                Text(project.subtitle,
                    style: context.textTheme.bodyLarge?.copyWith(fontSize: isMobile ? 14 : null)),
                const SizedBox(height: 20),
                Text('Use Skill',
                    style:
                        context.textTheme.headlineMedium?.copyWith(fontSize: isMobile ? 18 : null)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: project.useSkill
                      .map((skill) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.glay20),
                              borderRadius: BorderRadius.circular(20),
                              color: AppColors.glay20.withValues(alpha: 0.1),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                        color: Colors.black54, shape: BoxShape.circle)),
                                const SizedBox(width: 6),
                                Text(skill,
                                    style: context.textTheme.headlineSmall
                                        ?.copyWith(fontSize: isMobile ? 13 : null)),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
