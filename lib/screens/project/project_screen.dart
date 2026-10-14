import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const _bg = Color(0xFF0B0D10);
const _card = Color(0xFF14181D);
const _line = Color(0xFF242A31);
const _text = Color(0xFFEEF1F4);
const _muted = Color(0xFF9AA5B1);
const _accent = Color(0xFF4CC2FF);

/// 그리드 한 칸에 들어가는 프로젝트 정보.
/// 상세 화면은 처음 보는 사람도 읽을 수 있도록 고정된 규격(섹션 순서)으로 보여준다.
/// 비어 있는 항목은 '작성 예정'으로 표시된다.
class ProjectItem {
  final String title, summary, description, icon;
  final List<String> skills, screens;

  // 한눈에 보기
  final String period; // 개발 기간 예) 2024.03 ~ 2024.12
  final String team; // 참여 인원 예) 4명 (FE 1, BE 2, 디자인 1)
  final String role; // 담당 역할 예) Flutter 앱 개발 전체
  final String status; // 상태 예) App Store · Google Play 출시

  final String problem; // 왜 만들었나 (배경 / 해결하려던 문제)
  final List<String> features; // 주요 기능
  final List<String> contributions; // 내가 한 일 (구체적으로)
  final List<ProjectIssue> issues; // 기술적 문제와 해결
  final List<String> results; // 성과 / 배운 점
  final Map<String, String> links; // 링크 (이름 → URL)

  const ProjectItem({
    required this.title,
    required this.summary,
    required this.description,
    required this.icon,
    this.skills = const [],
    this.screens = const [],
    this.period = '',
    this.team = '',
    this.role = '',
    this.status = '',
    this.problem = '',
    this.features = const [],
    this.contributions = const [],
    this.issues = const [],
    this.results = const [],
    this.links = const {},
  });
}

/// 기술적 문제 → 해결 → 결과 한 묶음.
class ProjectIssue {
  final String problem, solution, result;
  const ProjectIssue({required this.problem, required this.solution, this.result = ''});
}

/// 프로젝트를 한눈에 보여주는 그리드. 비어 있는 칸은 빈 그리드로 채운다.
class ProjectScreen extends StatelessWidget {
  final String title;
  final String description;
  final List<ProjectItem> items;
  final int minSlots;
  const ProjectScreen(
      {super.key,
      required this.title,
      required this.description,
      this.items = const [],
      this.minSlots = 6});

  @override
  Widget build(BuildContext context) {
    for (final it in items) {
      precacheImage(_iconImage(it.icon), context);
    }
    final slots = items.length > minSlots ? items.length : minSlots;
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1080),
            child: CustomScrollView(slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
                sliver: SliverToBoxAdapter(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    TextButton(
                      onPressed: () => context.go('/home'),
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      child: const Text('← 홈으로',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600, color: _accent)),
                    ),
                    const SizedBox(height: 20),
                    Text(title,
                        style: const TextStyle(
                            fontSize: 32, fontWeight: FontWeight.w800, color: _text)),
                    const SizedBox(height: 8),
                    Text(description,
                        style: const TextStyle(fontSize: 16, height: 1.7, color: _muted)),
                  ]),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
                sliver: SliverLayoutBuilder(builder: (context, box) {
                  final w = box.crossAxisExtent;
                  final cols = w < 520 ? 1 : (w < 820 ? 2 : 3);
                  return SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cols,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      // 비율 대신 카드 내용 높이로 고정해 어떤 폭·글자 배율에서도 넘치지 않게 한다.
                      mainAxisExtent: _ProjectCard.extent(MediaQuery.textScalerOf(context)),
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => i < items.length
                          ? _ProjectCard(item: items[i], index: i + 1)
                          : const _EmptyCard(),
                      childCount: slots,
                    ),
                  );
                }),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class _ProjectCard extends StatefulWidget {
  final ProjectItem item;
  final int index;
  const _ProjectCard({required this.item, required this.index});

  static const _pad = 20.0, _icon = 48.0, _gap = 16.0, _titleGap = 6.0, _linkGap = 12.0;
  static const _summary = TextStyle(fontSize: 14, height: 1.5, color: _muted);
  static const _link =
      TextStyle(fontSize: 13, height: 1.4, fontWeight: FontWeight.w600, color: _accent);

  /// 카드에 필요한 높이: 패딩·테두리 + 아이콘 + 간격 + 글자 줄(글자 배율 반영) + 여유.
  static double extent(TextScaler scaler) {
    double line(TextStyle s) => scaler.scale(s.fontSize!) * s.height!;
    return _pad * 2 + 2 + _icon + _gap + _titleGap + _linkGap +
        line(_cardTitle) + line(_summary) * 2 + line(_link) + 8;
  }

  @override
  State<_ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<_ProjectCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: () => _openDetail(context, item),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.translationValues(0, _hover ? -4 : 0, 0),
          padding: const EdgeInsets.all(_ProjectCard._pad),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _hover ? _accent : _line),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              _IconHero(item: item, size: _ProjectCard._icon, radius: 12),
              const Spacer(),
              Text('0${widget.index}', style: const TextStyle(fontSize: 13, color: _muted)),
            ]),
            const SizedBox(height: _ProjectCard._gap),
            const Spacer(),
            _TitleHero(item: item, style: _cardTitle, maxLines: 1),
            const SizedBox(height: _ProjectCard._titleGap),
            Text(item.summary,
                maxLines: 2, overflow: TextOverflow.ellipsis, style: _ProjectCard._summary),
            const SizedBox(height: _ProjectCard._linkGap),
            const Text('자세히 보기 →',
                maxLines: 1, overflow: TextOverflow.ellipsis, style: _ProjectCard._link),
          ]),
        ),
      ),
    );
  }
}

/// 아직 채워지지 않은 빈 칸.
class _EmptyCard extends StatelessWidget {
  const _EmptyCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _line),
      ),
      child: const FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.add_rounded, size: 28, color: _line),
          SizedBox(height: 6),
          Text('준비 중', style: TextStyle(fontSize: 13, color: _muted)),
        ]),
      ),
    );
  }
}

/// 카드 위치에서 퍼지며 전체 화면으로 상세를 연다 (모바일 포함).
void _openDetail(BuildContext context, ProjectItem item) {
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
            clipper: _RectClipper(Rect.lerp(from, full, t.value)!, 16 * (1 - t.value)),
            child: ColoredBox(
              color: Color.lerp(_card, _bg, t.value)!,
              child: FadeTransition(
                opacity: fade,
                child: SlideTransition(
                  position: Tween(begin: const Offset(0, 0.02), end: Offset.zero).animate(fade),
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
  RRect getClip(Size size) => RRect.fromRectAndRadius(rect, Radius.circular(radius));

  @override
  bool shouldReclip(_RectClipper old) => old.rect != rect || old.radius != radius;
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
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  child: const Text('← 목록으로',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _accent)),
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
        _IconHero(item: item, size: 56, radius: 14),
        const SizedBox(width: 16),
        Expanded(
          child: _TitleHero(item: item, style: _detailTitle),
        ),
      ]),
      const SizedBox(height: 18),
      Text(item.description, style: const TextStyle(fontSize: 16, height: 1.7, color: _muted)),
      const SizedBox(height: 24),
      LayoutBuilder(builder: (context, box) {
        final info = _DetailInfo(item: item);
        if (item.screens.isEmpty) return info;
        if (box.maxWidth < 760) {
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
            color: _bg, borderRadius: BorderRadius.circular(14), border: Border.all(color: _line)),
        child: Wrap(spacing: 32, runSpacing: 14, children: [
          _Fact('기간', item.period),
          _Fact('인원', item.team),
          _Fact('역할', item.role),
          _Fact('상태', item.status),
        ]),
      ),
      _Section('왜 만들었나', item.problem.isEmpty ? null : _Body(item.problem)),
      _Section('주요 기능', item.features.isEmpty ? null : _Bullets(item.features)),
      _Section('내가 한 일', item.contributions.isEmpty ? null : _Bullets(item.contributions)),
      _Section(
          '문제 해결',
          item.issues.isEmpty
              ? null
              : Column(children: [for (final e in item.issues) _IssueCard(e)])),
      _Section('성과 · 배운 점', item.results.isEmpty ? null : _Bullets(item.results)),
      _Section(
          '링크',
          item.links.isEmpty
              ? null
              : _Bullets([for (final e in item.links.entries) '${e.key}  ${e.value}'])),
      _Section(
          '기술 스택',
          item.skills.isEmpty
              ? null
              : Wrap(spacing: 8, runSpacing: 8, children: [
                  for (final s in item.skills)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                          color: _accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999)),
                      child: Text(s,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w500, color: _accent)),
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
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: _text)),
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
        style: TextStyle(fontSize: 15, fontStyle: FontStyle.italic, color: _line));
  }
}

class _Body extends StatelessWidget {
  final String text;
  const _Body(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(fontSize: 15, height: 1.7, color: _muted));
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
            const Text('•  ', style: TextStyle(fontSize: 15, height: 1.7, color: _accent)),
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
    return Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
      Text(label, style: const TextStyle(fontSize: 12, color: _muted)),
      const SizedBox(height: 4),
      Text(value.isEmpty ? '작성 예정' : value,
          style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: value.isEmpty ? _line : _text)),
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
                        fontSize: 13, height: 1.9, fontWeight: FontWeight.w700, color: _accent))),
            Expanded(child: _Body(text)),
          ]),
        );
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      decoration: BoxDecoration(
          color: _bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: _line)),
      child: Column(children: [
        row('문제', issue.problem),
        row('해결', issue.solution),
        if (issue.result.isNotEmpty) row('결과', issue.result),
      ]),
    );
  }
}

const _cardTitle = TextStyle(fontSize: 18, height: 1.4, fontWeight: FontWeight.w700, color: _text);
const _detailTitle = TextStyle(fontSize: 22, height: 1.4, fontWeight: FontWeight.w800, color: _text);

/// 카드 ↔ 상세 화면 사이를 날아가는 아이콘.
class _IconHero extends StatelessWidget {
  final ProjectItem item;
  final double size, radius;
  const _IconHero({required this.item, required this.size, required this.radius});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'project-icon-${item.title}',
      createRectTween: (a, b) => MaterialRectCenterArcTween(begin: a, end: b),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Image(image: _iconImage(item.icon), width: size, height: size, fit: BoxFit.cover),
      ),
    );
  }
}

/// 카드 ↔ 상세 화면 사이를 날아가는 제목. 비행 중 글자 크기도 자연스럽게 바뀐다.
class _TitleHero extends StatelessWidget {
  final ProjectItem item;
  final TextStyle style;
  final int? maxLines;
  const _TitleHero({required this.item, required this.style, this.maxLines});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'project-title-${item.title}',
      flightShuttleBuilder: (context, animation, direction, fromCtx, toCtx) {
        final from = direction == HeroFlightDirection.push ? _cardTitle : _detailTitle;
        final to = direction == HeroFlightDirection.push ? _detailTitle : _cardTitle;
        return AnimatedBuilder(
          animation: animation,
          builder: (context, _) {
            final v = direction == HeroFlightDirection.push ? animation.value : 1 - animation.value;
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
ImageProvider _iconImage(String asset) => ResizeImage(AssetImage(asset), width: 192);
