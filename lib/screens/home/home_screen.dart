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
  double _dragStartY = 0;
  double _dragAccumulator = 0;

  @override
  void initState() {
    super.initState();
    Get.put(WaveController());

    _smoothScrollController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..addListener(_updateScroll);

    _smoothScrollController.repeat();
  }

  @override
  void dispose() {
    _smoothScrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _updateScroll() {
    const lerpFactor = 0.04;

    if (_currentPage != _targetPage) {
      _currentPage = lerpDouble(_currentPage, _targetPage, lerpFactor) ?? _currentPage;

      if (mounted && context.mounted) {
        _pageController.jumpTo(_currentPage * MediaQuery.of(context).size.height);
      }

      final controller = Get.find<WaveController>();
      controller.updateProgress(_currentPage);
    }
  }

  void _handleScroll(PointerScrollEvent event) {
    const scrollSensitivity = 0.001;
    const maxPage = 6.0;

    _targetPage += event.scrollDelta.dy * scrollSensitivity;
    _targetPage = _targetPage.clamp(0.0, maxPage);
  }

  // 터치 시작 처리
  void _handleDragStart(DragStartDetails details) {
    _dragStartY = details.globalPosition.dy;
    _dragAccumulator = 0;
  }

  // 터치 드래그 처리
  void _handleDragUpdate(DragUpdateDetails details) {
    const sensitivity = 0.01;
    const maxPage = 6.0;

    _dragAccumulator += (details.globalPosition.dy - _dragStartY) * sensitivity;
    _dragStartY = details.globalPosition.dy;

    _targetPage -= _dragAccumulator;
    _targetPage = _targetPage.clamp(0.0, maxPage);
  }

  // 터치 종료 처리
  void _handleDragEnd(DragEndDetails details) {
    _dragAccumulator = 0;
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
          GestureDetector(
            onVerticalDragStart: _handleDragStart,
            onVerticalDragUpdate: _handleDragUpdate,
            onVerticalDragEnd: _handleDragEnd,
            child: Listener(
              onPointerSignal: (signal) {
                if (signal is PointerScrollEvent) {
                  _handleScroll(signal);
                }
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

                  // 나머지 페이지들...
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
