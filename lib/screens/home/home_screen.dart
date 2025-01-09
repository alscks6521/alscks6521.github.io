import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:github_portfolio/common/controllers/getController.dart';
import 'package:github_portfolio/common/controllers/themeController.dart';
import 'package:github_portfolio/screens/home/widgets/profile_card_widget.dart';
import 'package:github_portfolio/screens/home/widgets/slide_box_widget.dart';

// 각 페이지의 기본 구조를 정의하는 위젯
class PageSection extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;

  const PageSection({
    super.key,
    required this.child,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: backgroundColor ?? Colors.transparent,
      child: child,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  double _targetPage = 0;
  double _currentPage = 0;
  late AnimationController _smoothScrollController;

  @override
  void initState() {
    super.initState();
    Get.put(WaveController());

    // 부드러운 스크롤을 위한 애니메이션 컨트롤러
    _smoothScrollController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16), // 60fps
    )..addListener(_updateScroll);

    _smoothScrollController.repeat();
  }

  @override
  void dispose() {
    _smoothScrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // 부드러운 스크롤 업데이트
  void _updateScroll() {
    const lerpFactor = 0.04; // 보간 계수 (값이 작을수록 더 부드러움)

    if (_currentPage != _targetPage) {
      _currentPage = lerpDouble(_currentPage, _targetPage, lerpFactor) ?? _currentPage;

      // 페이지 위치 및 진행도 업데이트
      if (mounted && context.mounted) {
        _pageController.jumpTo(_currentPage * MediaQuery.of(context).size.height);
      }

      // WaveController에 현재 페이지 값 전달
      final controller = Get.find<WaveController>();
      controller.updateProgress(_currentPage);
    }
  }

  void _handleScroll(PointerScrollEvent event) {
    const scrollSensitivity = 0.001; // 스크롤 감도 (값이 작을수록 부드러움)
    const maxPage = 6.0; // 전체 페이지 수 - 1

    // 목표 페이지 업데이트
    _targetPage += event.scrollDelta.dy * scrollSensitivity;
    _targetPage = _targetPage.clamp(0.0, maxPage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          Positioned.fill(
            child: Stack(
              children: [
                Obx(() => WaveAnimation(
                      isTopLeft: false,
                      color: Get.find<ThemeController>().waveColor1,
                    )),
                Obx(() => WaveAnimation(
                      isTopLeft: true,
                      color: Get.find<ThemeController>().waveColor2,
                    )),
              ],
            ),
          ),
          MouseRegion(
            child: Listener(
              onPointerSignal: (signal) {
                if (signal is PointerScrollEvent) {
                  _targetPage += signal.scrollDelta.dy * 0.001;
                  _targetPage = _targetPage.clamp(0.0, 6.0);
                }
              },
              onPointerPanZoomUpdate: (event) {
                // 모바일에서의 스크롤 처리
                _targetPage += event.panDelta.dy * 0.001;
                _targetPage = _targetPage.clamp(0.0, 6.0);
              },
              child: PageView(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  // 첫 번째 페이지 - 인트로/메인
                  PageSection(
                    child: AnimatedPageContent(
                      pageIndex: 0,
                      content: MainIntroContent(
                        primaryWidget: const ResponsiveCard(),
                        secondaryWidgets: [],
                      ),
                      primaryAnimation: AnimationType.curvedSlideRight,
                      secondaryAnimation: AnimationType.fade,
                    ),
                  ),

                  // 두 번째 페이지 - 소개 또는 주요 섹션
                  const PageSection(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('2', style: TextStyle(fontSize: 30)),
                        ],
                      ),
                    ),
                  ),

                  // 세 번째 페이지
                  const PageSection(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('3', style: TextStyle(fontSize: 30)),
                        ],
                      ),
                    ),
                  ),

                  // 네 번째 페이지
                  const PageSection(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 네 번째 페이지 내용
                        ],
                      ),
                    ),
                  ),

                  // 다섯 번째 페이지
                  const PageSection(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 다섯 번째 페이지 내용
                        ],
                      ),
                    ),
                  ),

                  // 여섯 번째 페이지
                  const PageSection(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 여섯 번째 페이지 내용
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon:
                  Icon(Get.find<ThemeController>().isDarkMode ? Icons.light_mode : Icons.dark_mode),
              onPressed: () => Get.find<ThemeController>().toggleTheme(),
            ),
          ),
        ],
      ),
    );
  }
}
