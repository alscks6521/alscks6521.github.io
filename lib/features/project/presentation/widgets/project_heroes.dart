import 'package:flutter/material.dart';
import 'package:github_portfolio/features/project/domain/entities/project.dart';
import 'package:github_portfolio/features/project/presentation/theme/project_style.dart';

/// 카드 ↔ 상세 화면 사이를 날아가는 아이콘.
class ProjectIconHero extends StatelessWidget {
  final ProjectItem item;
  final double size, radius;
  const ProjectIconHero(
      {super.key,
      required this.item,
      required this.size,
      required this.radius});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'project-icon-${item.title}',
      createRectTween: (a, b) => MaterialRectCenterArcTween(begin: a, end: b),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Image(
            image: projectIconImage(item.icon),
            width: size,
            height: size,
            fit: BoxFit.cover),
      ),
    );
  }
}

/// 카드 ↔ 상세 화면 사이를 날아가는 제목. 비행 중 글자 크기도 자연스럽게 바뀐다.
class ProjectTitleHero extends StatelessWidget {
  final ProjectItem item;
  final TextStyle style;
  final int? maxLines;
  const ProjectTitleHero(
      {super.key, required this.item, required this.style, this.maxLines});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'project-title-${item.title}',
      flightShuttleBuilder: (context, animation, direction, fromCtx, toCtx) {
        final from = direction == HeroFlightDirection.push
            ? cardTitleStyle
            : detailTitleStyle;
        final to = direction == HeroFlightDirection.push
            ? detailTitleStyle
            : cardTitleStyle;
        return AnimatedBuilder(
          animation: animation,
          builder: (context, _) {
            final v = direction == HeroFlightDirection.push
                ? animation.value
                : 1 - animation.value;
            return Material(
              type: MaterialType.transparency,
              child: Text(item.title,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.visible,
                  style: TextStyle.lerp(from, to, v)),
            );
          },
        );
      },
      child: Material(
        type: MaterialType.transparency,
        child: Text(item.title,
            maxLines: maxLines,
            overflow: maxLines == null ? null : TextOverflow.ellipsis,
            style: style),
      ),
    );
  }
}

/// 아이콘 원본(1024px 이상)을 그대로 디코딩하지 않도록 고정 크기로 줄인다.
/// 카드·상세·히어로 비행이 같은 키를 써서 한 번만 디코딩된다.
ImageProvider projectIconImage(String asset) =>
    ResizeImage(AssetImage(asset), width: 192);
