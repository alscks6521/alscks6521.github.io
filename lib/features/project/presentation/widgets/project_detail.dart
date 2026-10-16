import 'package:flutter/material.dart';
import 'package:github_portfolio/features/project/domain/entities/project.dart';
import 'package:github_portfolio/features/project/presentation/theme/project_style.dart';
import 'package:github_portfolio/features/project/presentation/widgets/project_heroes.dart';
import 'package:github_portfolio/features/project/presentation/widgets/store_badges.dart';

/// 카드 위치에서 퍼지며 전체 화면으로 상세를 연다 (모바일 포함).
void openProjectDetail(BuildContext context, ProjectItem item) {
  final box = context.findRenderObject() as RenderBox;
  final from = box.localToGlobal(Offset.zero) & box.size;
  Navigator.of(context).push(PageRouteBuilder(
    opaque: false, // 퍼지는 동안 뒤의 그리드가 보이도록
    transitionDuration: const Duration(milliseconds: 700),
    reverseTransitionDuration: const Duration(milliseconds: 550),
    pageBuilder: (context, _, __) => _DetailPage(item: item),
    transitionsBuilder: (context, animation, _, child) {
      final t = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOutCubicEmphasized,
          reverseCurve: Curves.easeInOutCubicEmphasized.flipped);
      // 내용은 영역이 거의 펼쳐진 뒤 살짝 떠오르며 나타난다 (닫을 땐 먼저 사라짐).
      final fade = CurvedAnimation(
          parent: animation,
          curve: const Interval(0.45, 1, curve: Curves.easeOut),
          reverseCurve: const Interval(0.6, 1, curve: Curves.easeIn));
      return AnimatedBuilder(
        animation: t,
        builder: (context, _) {
          final full = Offset.zero & MediaQuery.sizeOf(context);
          return ClipRRect(
            clipper: _RectClipper(
                Rect.lerp(from, full, t.value)!, 16 * (1 - t.value)),
            child: ColoredBox(
              color: Color.lerp(ProjectColors.card, ProjectColors.bg, t.value)!,
              child: FadeTransition(
                opacity: fade,
                child: SlideTransition(
                  position:
                      Tween(begin: const Offset(0, 0.02), end: Offset.zero)
                          .animate(fade),
                  // 상세 페이지는 한 번만 그리고, 매 프레임엔 클립·투명도·이동 레이어만 바뀐다.
                  child: RepaintBoundary(child: child),
                ),
              ),
            ),
          );
        },
      );
    },
  ));
}

class _RectClipper extends CustomClipper<RRect> {
  final Rect rect;
  final double radius;
  _RectClipper(this.rect, this.radius);

  @override
  RRect getClip(Size size) =>
      RRect.fromRectAndRadius(rect, Radius.circular(radius));

  @override
  bool shouldReclip(_RectClipper old) =>
      old.rect != rect || old.radius != radius;
}

/// 넓은 화면용 상세 페이지. 왼쪽 위 '목록으로'로 그리드에 돌아간다.
class _DetailPage extends StatelessWidget {
  final ProjectItem item;
  const _DetailPage({required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      child: const Text('← 목록으로',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: ProjectColors.accent)),
                    ),
                    const SizedBox(height: 20),
                    _DetailBody(item: item),
                  ]),
            ),
          ),
        ),
      ),
    );
  }
}

/// 상세 내용: 헤더 + (넓은 화면: 왼쪽 내용 | 오른쪽 이미지, 좁은 화면: 내용 아래 이미지)
class _DetailBody extends StatelessWidget {
  final ProjectItem item;
  const _DetailBody({required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        ProjectIconHero(item: item, size: 56, radius: 14),
        const SizedBox(width: 16),
        Expanded(
          child: ProjectTitleHero(item: item, style: detailTitleStyle),
        ),
        if (item.released) ...[const SizedBox(width: 12), const StoreBadges()],
      ]),
      const SizedBox(height: 18),
      Text(item.description,
          style: const TextStyle(
              fontSize: 16, height: 1.7, color: ProjectColors.muted)),
      const SizedBox(height: 24),
      LayoutBuilder(builder: (context, box) {
        final info = _DetailInfo(item: item);
        if (item.screens.isEmpty) return info;
        if (box.maxWidth < 760) {
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                info,
                const _SectionTitle('화면'),
                _Screens(screens: item.screens, cols: 2),
              ]);
        }
        return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(flex: 3, child: info),
          const SizedBox(width: 32),
          Expanded(flex: 2, child: _Screens(screens: item.screens, cols: 2)),
        ]);
      }),
    ]);
  }
}

/// 상세 화면 왼쪽(또는 위쪽)의 글 영역.
class _DetailInfo extends StatelessWidget {
  final ProjectItem item;
  const _DetailInfo({required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // 1. 한눈에 보기
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
            color: ProjectColors.bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: ProjectColors.line)),
        child: Wrap(spacing: 32, runSpacing: 14, children: [
          _Fact('구분', item.category),
          _Fact('기간', item.period),
          _Fact('인원', item.team),
          _Fact('역할', item.role),
        ]),
      ),
      _Section('주요 기능', item.features.isEmpty ? null : _Bullets(item.features)),
      _Section('내가 한 일',
          item.contributions.isEmpty ? null : _Bullets(item.contributions)),
      _Section(
          '문제 해결',
          item.issues.isEmpty
              ? null
              : Column(children: [for (final e in item.issues) _IssueCard(e)])),
      _Section(
          '성과 · 배운 점', item.results.isEmpty ? null : _Bullets(item.results)),
      _Section(
          '기술 스택',
          item.skills.isEmpty
              ? null
              : Wrap(spacing: 8, runSpacing: 8, children: [
                  for (final s in item.skills)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                          color: ProjectColors.accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999)),
                      child: Text(s,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: ProjectColors.accent)),
                    ),
                ])),
    ]);
  }
}

/// 프로젝트 스크린샷 나열.
/// 페이지 전환 애니메이션이 끝난 뒤에 디코딩을 시작하고(전환 중 프레임 드랍 방지),
/// 표시 크기에 맞춰 줄여서 디코딩한 뒤 부드럽게 나타난다.
class _Screens extends StatefulWidget {
  final List<String> screens;
  final int cols;
  const _Screens({required this.screens, required this.cols});

  @override
  State<_Screens> createState() => _ScreensState();
}

class _ScreensState extends State<_Screens> {
  Animation<double>? _route;
  bool _ready = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context)?.animation;
    if (route == _route) return;
    _route?.removeStatusListener(_onStatus);
    _route = route;
    _ready = route == null || route.status == AnimationStatus.completed;
    if (!_ready) route!.addStatusListener(_onStatus);
  }

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && mounted) {
      _route?.removeStatusListener(_onStatus);
      setState(() => _ready = true);
    }
  }

  @override
  void dispose() {
    _route?.removeStatusListener(_onStatus);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) return const SizedBox(width: double.infinity, height: 240);
    final dpr = MediaQuery.devicePixelRatioOf(context);
    return LayoutBuilder(builder: (context, box) {
      const gap = 12.0;
      final cols = widget.cols;
      final w = (box.maxWidth - gap * (cols - 1)) / cols;
      return Wrap(spacing: gap, runSpacing: gap, children: [
        for (final s in widget.screens)
          SizedBox(
            width: w,
            child: RepaintBoundary(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  s,
                  fit: BoxFit.fitWidth,
                  cacheWidth: (w * dpr).round(),
                  frameBuilder: (context, child, frame, sync) => sync
                      ? child
                      : AnimatedOpacity(
                          opacity: frame == null ? 0 : 1,
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeOut,
                          child: child,
                        ),
                ),
              ),
            ),
          ),
      ]);
    });
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 28, bottom: 10),
      child: Text(text,
          style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: ProjectColors.text)),
    );
  }
}

/// 제목 + 내용. 내용이 없으면 '작성 예정'을 보여준다.
class _Section extends StatelessWidget {
  final String title;
  final Widget? child;
  const _Section(this.title, this.child);

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _SectionTitle(title),
      child ?? const _Placeholder(),
    ]);
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) {
    return const Text('작성 예정',
        style: TextStyle(
            fontSize: 15,
            fontStyle: FontStyle.italic,
            color: ProjectColors.line));
  }
}

class _Body extends StatelessWidget {
  final String text;
  const _Body(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(
            fontSize: 15, height: 1.7, color: ProjectColors.muted));
  }
}

class _Bullets extends StatelessWidget {
  final List<String> lines;
  const _Bullets(this.lines);

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      for (final l in lines)
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('•  ',
                style: TextStyle(
                    fontSize: 15, height: 1.7, color: ProjectColors.accent)),
            Expanded(child: _Body(l)),
          ]),
        ),
    ]);
  }
}

/// 한눈에 보기의 한 칸 (라벨 + 값).
class _Fact extends StatelessWidget {
  final String label, value;
  const _Fact(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 12, color: ProjectColors.muted)),
          const SizedBox(height: 4),
          Text(value.isEmpty ? '작성 예정' : value,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color:
                      value.isEmpty ? ProjectColors.line : ProjectColors.text)),
        ]);
  }
}

/// 문제 → 해결 → 결과 카드.
class _IssueCard extends StatelessWidget {
  final ProjectIssue issue;
  const _IssueCard(this.issue);

  @override
  Widget build(BuildContext context) {
    Widget row(String label, String text) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(
                width: 44,
                child: Text(label,
                    style: const TextStyle(
                        fontSize: 13,
                        height: 1.9,
                        fontWeight: FontWeight.w700,
                        color: ProjectColors.accent))),
            Expanded(child: _Body(text)),
          ]),
        );
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      decoration: BoxDecoration(
          color: ProjectColors.bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ProjectColors.line)),
      child: Column(children: [
        row('문제', issue.problem),
        row('해결', issue.solution),
        if (issue.result.isNotEmpty) row('결과', issue.result),
      ]),
    );
  }
}
