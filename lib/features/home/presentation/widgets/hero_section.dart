import 'package:flutter/material.dart';
import 'package:github_portfolio/app/router/app_routes.dart';
import 'package:github_portfolio/core/constants/app_assets.dart';
import 'package:github_portfolio/features/stickman/presentation/stickman_arena.dart';
import 'package:github_portfolio/core/widgets/floating.dart';
import 'package:github_portfolio/features/home/presentation/theme/home_palette.dart';
import 'package:github_portfolio/features/home/presentation/widgets/device_link.dart';
import 'package:github_portfolio/features/home/presentation/widgets/pill_button.dart';
import 'package:github_portfolio/features/star/presentation/widgets/star_badge.dart';

class HeroSection extends StatelessWidget {
  final HomePalette palette;
  final bool narrow;
  final VoidCallback onProjects;
  const HeroSection(
      {super.key,
      required this.palette,
      required this.narrow,
      required this.onProjects});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final wide = width >= 860;
    final size = wide ? 56.0 : (width < 360 ? 30.0 : (narrow ? 36.0 : 48.0));
    final base = TextStyle(
        fontSize: size,
        height: 1.2,
        fontWeight: FontWeight.w800,
        letterSpacing: -size * 0.03,
        color: palette.text);

    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StickmanSolid(
          child: Text.rich(TextSpan(style: base, children: [
            const TextSpan(text: '안녕하세요,\n'),
            TextSpan(text: '김민성', style: TextStyle(color: palette.accent)),
            const TextSpan(text: '입니다.\n웹·앱 개발자'),
          ])),
        ),
        const SizedBox(height: 24),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: StickmanSolid(
            child: Text(
              'Flutter를 중심으로 웹과 모바일 서비스를 만듭니다. 설계부터 개발, 스토어 배포까지 직접 경험했습니다.',
              style: TextStyle(
                  fontSize: narrow ? 16 : 19,
                  height: 1.7,
                  color: palette.muted),
            ),
          ),
        ),
        const SizedBox(height: 36),
        Wrap(spacing: 12, runSpacing: 12, children: [
          PillButton(
              label: '프로젝트 보기',
              primary: true,
              palette: palette,
              onTap: onProjects),
          // PillButton(
          //     label: 'GitHub',
          //     palette: palette,
          //     onTap: () => _open('https://github.com/alscks6521')),
        ]),
      ],
    );

    if (wide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(flex: 11, child: text),
          const SizedBox(width: 24),
          Expanded(flex: 10, child: _HeroArt(maxSize: 440, palette: palette)),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        text,
        const SizedBox(height: 40),
        Center(child: _HeroArt(maxSize: 360, palette: palette)),
      ],
    );
  }
}

class _HeroArt extends StatelessWidget {
  final double maxSize;
  final HomePalette palette;
  const _HeroArt({required this.maxSize, required this.palette});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final w = c.maxWidth.isFinite ? c.maxWidth.clamp(0.0, maxSize) : maxSize;
      return SizedBox(
        width: w,
        height: w * 0.92,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              right: 0,
              top: w * 0.06,
              width: w * 0.86,
              child: Floating(
                  amplitude: 8,
                  seconds: 4.2,
                  child: StickmanSolid(
                      child: DeviceLink(
                    asset: AppAssets.laptop,
                    tooltip: '웹 프로젝트 보러가기',
                    route: AppRoutes.webPro,
                    color: palette.accent,
                  ))),
            ),
            Positioned(
              left: 0,
              bottom: 0,
              width: w * 0.30,
              child: Floating(
                  amplitude: 10,
                  seconds: 3.6,
                  phase: 0.4,
                  child: StickmanSolid(
                      child: DeviceLink(
                    asset: AppAssets.phone,
                    tooltip: '앱 프로젝트 보러가기',
                    route: AppRoutes.appPro,
                    color: palette.accent,
                  ))),
            ),
            Positioned(
              right: w * 0.02,
              top: -w * 0.02 - 22,
              child: Floating(
                  amplitude: 6,
                  seconds: 3.0,
                  phase: 0.7,
                  child: StickmanSolid(child: StarBadge(starSize: w * 0.16))),
            ),
          ],
        ),
      );
    });
  }
}
