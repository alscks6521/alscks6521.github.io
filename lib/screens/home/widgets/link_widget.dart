import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SocialLinks extends StatelessWidget {
  final String githubUrl;
  final String notionUrl;
  final String instagramUrl;

  const SocialLinks({
    super.key,
    required this.githubUrl,
    required this.notionUrl,
    required this.instagramUrl,
  });

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // 카드 너비에 따른 아이콘 크기 계산
    final cardWidth = (size.width * 0.3).clamp(300.0, 600.0);
    final iconSize = (cardWidth * 0.08).clamp(26.0, 52.0);

    // 패딩 계산
    final padding = (cardWidth * 0.06).clamp(6.0, 18.0);

    return Padding(
      padding: EdgeInsets.all(padding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildSocialIcon(
            icon: FontAwesomeIcons.github,
            url: githubUrl,
            tooltip: 'GitHub',
            iconSize: iconSize,
          ),
          _buildSocialIcon(
            icon: FontAwesomeIcons.n,
            url: notionUrl,
            tooltip: 'Notion',
            iconSize: iconSize,
          ),
          _buildSocialIcon(
            icon: FontAwesomeIcons.instagram,
            url: instagramUrl,
            tooltip: 'Instagram',
            iconSize: iconSize,
          ),
        ],
      ),
    );
  }

  Widget _buildSocialIcon({
    required IconData icon,
    required String url,
    required String tooltip,
    required double iconSize,
  }) {
    return IconButton(
      onPressed: () => _launchUrl(url),
      icon: FaIcon(
        icon,
        size: iconSize,
      ),
      tooltip: tooltip,
      iconSize: iconSize,
      padding: const EdgeInsets.all(8),
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
    );
  }
}
