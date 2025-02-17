import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:github_portfolio/common/controllers/get_controller.dart';
import 'package:github_portfolio/common/controllers/theme_controller.dart';
import 'package:github_portfolio/common/widgets/animated_page_content.dart';
import 'package:github_portfolio/screens/home/pages/one_widgets/slide_box.dart';
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
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.transparent,
        // border: Border.all(color: Colors.red, width: 2),
      ),
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
      duration: const Duration(milliseconds: 33), // 60fps
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
    const lerpFactor = 0.06; // 보간 계수 (값이 작을수록 더 부드러움)

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
    const scrollSensitivity = 0.0003; // 스크롤 감도 (값이 작을수록 부드러움)
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
          Listener(
            onPointerSignal: (signal) {
              if (signal is PointerScrollEvent) {
                _handleScroll(signal);
              }
            },
            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                _targetPage -= details.delta.dy * 0.004; // 스크롤 감도 조절
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
                    child: SlideBox(),
                  ),

                  // 세 번째 페이지
                  const PageSection(
                    child: Text('3', style: TextStyle(fontSize: 30)),
                  ),

                  // 네 번째 페이지
                  const PageSection(
                    child: Text('4', style: TextStyle(fontSize: 30)),
                  ),

                  // 다섯 번째 페이지
                  const PageSection(
                    child: Text('5', style: TextStyle(fontSize: 30)),
                  ),

                  // 여섯 번째 페이지
                  const PageSection(
                    child: Text('6', style: TextStyle(fontSize: 30)),
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
