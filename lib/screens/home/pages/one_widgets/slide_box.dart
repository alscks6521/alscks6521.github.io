import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:github_portfolio/common/app_assets.dart';
import 'package:github_portfolio/common/controllers/get_controller.dart';

class SlideBox extends StatelessWidget {
  const SlideBox({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WaveController>();
    final Size screenSize = MediaQuery.of(context).size;

    // 박스 크기를 화면보다 더 크게 설정하여 여유 공간 확보
    final boxWidth = screenSize.width * 1.2; // 20% 더 크게
    final boxHeight = screenSize.height; // 20% 더 크게

    const fontBigSize = 20.0;
    const fontSize = 16.0;
    const iconSize = 22.0;

    return Obx(
      () {
        final currentPage = controller.currentPageProgress.value;

        // 진입 애니메이션 (0.84 ~ 1.24 구간)
        final slideProgress = ((currentPage - 0.84) / 0.4).clamp(0.0, 1.0);

        // 퇴장 애니메이션 (1.6 ~ 2.0 구간)
        final fadeOutProgress = ((currentPage - 1.6) / 0.4).clamp(0.0, 1.0);

        // 두 애니메이션을 결합
        final opacity = (slideProgress * 4).clamp(0.0, 1.0) * (1 - fadeOutProgress);

        return Opacity(
          opacity: opacity,
          child: Container(
            width: boxWidth,
            height: boxHeight,
            decoration: const BoxDecoration(),
            clipBehavior: Clip.none,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Divider(),
                // 상단 텍스트나 설명 추가
                Positioned(
                  top: screenSize.height * 0.2, // 상단에서 20% 위치
                  left: screenSize.width * 0.1,
                  child: SizedBox(
                    width: screenSize.width * 0.8,
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '-----',
                          style: TextStyle(
                            fontSize: fontBigSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          '----------- -----',
                          style: TextStyle(
                            fontSize: fontSize,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 이미지를 더 아래로 위치시키고 크기 조정
                Positioned(
                  bottom: -screenSize.height * 0.1, // 화면 아래로 10% 더 내림
                  left: -boxWidth * 0.04,
                  right: -boxWidth * 0.04,
                  child: Transform.scale(
                    scale: 1.2, // 이미지를 20% 더 크게
                    child: Image.asset(
                      AppAssets.oneFlo,
                      fit: BoxFit.cover,
                      width: boxWidth,
                    ),
                  ),
                ),
                const Divider(),
              ],
            ),
          ),
        );
      },
    );
  }
}
