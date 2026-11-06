import 'package:flutter/material.dart';
import 'package:github_portfolio/features/project/presentation/theme/project_style.dart';
import 'package:url_launcher/url_launcher.dart';

/// App Store · Google Play 출시 인증용 작은 원형 뱃지 두 개.
/// 스토어 주소가 주어지면 뱃지를 눌러 해당 스토어 페이지를 새 탭으로 연다.
class StoreBadges extends StatelessWidget {
  final String appStoreUrl, playStoreUrl;
  final String webUrl; // 비어 있지 않으면 웹 버전 뱃지를 하나 더 붙인다
  const StoreBadges(
      {super.key,
      this.appStoreUrl = '',
      this.playStoreUrl = '',
      this.webUrl = ''});

  @override
  Widget build(BuildContext context) {
    Widget badge(IconData icon, String tip, String url) {
      final circle = Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: ProjectColors.accent.withValues(alpha: 0.12),
          shape: BoxShape.circle,
          border: Border.all(color: ProjectColors.accent, width: 1.2),
        ),
        child: Icon(icon, size: 15, color: ProjectColors.accent),
      );
      if (url.isEmpty) return Tooltip(message: tip, child: circle);
      return Tooltip(
        message: icon == Icons.language ? tip : '$tip · 스토어에서 보기',
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => launchUrl(Uri.parse(url), webOnlyWindowName: '_blank'),
            child: circle,
          ),
        ),
      );
    }

    return Row(mainAxisSize: MainAxisSize.min, children: [
      badge(Icons.apple, 'App Store 출시', appStoreUrl),
      const SizedBox(width: 6),
      badge(Icons.android, 'Google Play 출시', playStoreUrl),
      if (webUrl.isNotEmpty) ...[
        const SizedBox(width: 6),
        badge(Icons.language, '웹에서 사용하기', webUrl),
      ],
    ]);
  }
}
