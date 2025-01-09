import 'package:flutter/material.dart';
import 'package:github_portfolio/common/app_assets.dart';
import 'package:github_portfolio/screens/home/widgets/link_widget.dart';

class ResponsiveCard extends StatelessWidget {
  const ResponsiveCard({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    const maxWidth = 600.0;
    const minWidth = 300.0;
    final cardWidth = (size.width * 0.3).clamp(minWidth, maxWidth);

    const fontSize = 16.0;
    const iconSize = 22.0;
    const padding = 12.0;

    // 이미지를 표시할 최소 높이 설정
    const minHeightForImage = 370.0;
    final shouldShowImage = size.height >= minHeightForImage;
    const minHeightIcons = 600.0;
    final shouldShowIcons = size.height >= minHeightIcons;

    return Align(
      alignment: Alignment.center,
      child: Container(
        width: cardWidth,
        constraints: BoxConstraints(
          maxWidth: maxWidth,
          minWidth: minWidth,
          maxHeight: size.height * 0.8,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black.withOpacity(0.3)
                  : Colors.black.withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 고정된 헤더
            _buildHeader(padding, iconSize, fontSize),

            // 스크롤 가능한 컨텐츠 영역
            Expanded(
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  scrollbars: false,
                ),
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 조건부로 이미지 표시
                      if (size.height >= minHeightForImage)
                        SizedBox(
                          width: cardWidth, // 가로 크기는 카드 너비로 고정
                          height: shouldShowImage
                              ? (size.height / 1000) * 300 // 화면 높이에 비례하여 세로 크기 조절
                              : 0, // 완전히 사라질 때
                          child: Image.asset(
                            AppAssets.myPicture,
                            fit: BoxFit.cover,
                          ),
                        ),
                      if (shouldShowIcons) _buildActions(padding, iconSize),
                      if (shouldShowIcons) _buildLikes(padding, fontSize),
                      _buildContent(context, padding, fontSize),
                      _buildDateTime(context, fontSize),
                      const SocialLinks(
                        githubUrl: 'https://github.com/your-username',
                        notionUrl: 'https://notion.so/your-workspace',
                        instagramUrl: 'https://instagram.com/your-username',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(double padding, double iconSize, double fontSize) {
    return Padding(
      padding: EdgeInsets.all(padding),
      child: Row(
        children: [
          CircleAvatar(
            radius: iconSize * 0.8,
            backgroundImage: const AssetImage(AppAssets.myPicture),
          ),
          SizedBox(width: padding / 2),
          Text(
            'alscks6521',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
            ),
          ),
          const Spacer(),
          Icon(Icons.more_horiz, size: iconSize),
        ],
      ),
    );
  }

  Widget _buildActions(double padding, double iconSize) {
    return Padding(
      padding: EdgeInsets.all(padding),
      child: Row(
        children: [
          Icon(Icons.favorite_border, size: iconSize),
          SizedBox(width: padding),
          Icon(Icons.chat_bubble_outline, size: iconSize),
          SizedBox(width: padding),
          Icon(Icons.send, size: iconSize),
          const Spacer(),
          Icon(Icons.bookmark_border, size: iconSize),
        ],
      ),
    );
  }

  Widget _buildLikes(double padding, double fontSize) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: Text(
        '좋아요 3개',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: fontSize,
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, double padding, double fontSize) {
    return Padding(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: TextStyle(
                // 테마에 따른 텍스트 색상
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontSize: fontSize,
              ),
              children: const [
                TextSpan(
                  text: 'alscks6521 ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: '#유연한 #개발 #화이팅',
                ),
              ],
            ),
          ),
          SizedBox(height: padding),
          Text(
            "Let's live with a flexible mind!",
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
              // 테마 색상 적용
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTime(BuildContext context, double fontSize) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Text(
        '1시간 전',
        style: TextStyle(
          // 테마에 따른 색상 적용
          color:
              Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[600],
          fontSize: fontSize * 0.9,
        ),
      ),
    );
  }
}
