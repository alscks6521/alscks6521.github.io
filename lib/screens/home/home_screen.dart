import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:github_portfolio/common/controllers/getController.dart';
import 'package:github_portfolio/common/controllers/themeController.dart';
import 'package:github_portfolio/screens/home/widgets/profile_card_widget.dart';
import 'package:github_portfolio/screens/home/widgets/slide_box_widget.dart';

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
  double _accumulatedDelta = 0;
  DateTime _lastWheelTime = DateTime.now();
  late AnimationController _smoothScrollController;

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
    const lerpFactor = 0.02;

    if (_currentPage != _targetPage) {
      _currentPage = lerpDouble(_currentPage, _targetPage, lerpFactor) ?? _currentPage;

      if (mounted && context.mounted) {
        _pageController.jumpTo(_currentPage * MediaQuery.of(context).size.height);
      }

      final controller = Get.find<WaveController>();
      controller.updateProgress(_currentPage);
    }
  }

  void _handleWheelScroll(PointerScrollEvent event) {
    final now = DateTime.now();
    const threshold = 100.0; // 페이지 전환을 위한 임계값
    const cooldown = Duration(milliseconds: 50); // 휠 이벤트 쓰로틀링

    if (now.difference(_lastWheelTime) < cooldown) {
      return;
    }
    _lastWheelTime = now;

    _accumulatedDelta += event.scrollDelta.dy;

    if (_accumulatedDelta.abs() >= threshold) {
      if (_accumulatedDelta > 0) {
        _targetPage = (_targetPage + 1).clamp(0.0, 5.0);
      } else {
        _targetPage = (_targetPage - 1).clamp(0.0, 5.0);
      }
      _accumulatedDelta = 0; // 누적값 리셋
    }
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
                _handleWheelScroll(signal);
              }
            },
            child: PageView(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              physics: const NeverScrollableScrollPhysics(), // 드래그 스크롤 비활성화
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

                // 두 번째 페이지
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
                      children: [],
                    ),
                  ),
                ),

                // 다섯 번째 페이지
                const PageSection(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [],
                    ),
                  ),
                ),

                // 여섯 번째 페이지
                const PageSection(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [],
                    ),
                  ),
                ),
              ],
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
