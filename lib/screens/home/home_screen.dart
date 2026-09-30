import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// 세로 스크롤 단일 페이지 포트폴리오 (docs/index.html 디자인과 동일).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scroll = ScrollController();
  final _topKey = GlobalKey();
  final _aboutKey = GlobalKey();
  final _projectsKey = GlobalKey();
  final _skillsKey = GlobalKey();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  double _target = 0;
  DateTime _lastWheel = DateTime.fromMillisecondsSinceEpoch(0);

  // 마우스 휠 입력을 누적해서 easeOut으로 부드럽게 스크롤
  void _onPointer(PointerSignalEvent e) {
    if (e is! PointerScrollEvent || !_scroll.hasClients) return;
    final pos = _scroll.position;
    final now = DateTime.now();
    final animating =
        now.difference(_lastWheel) < const Duration(milliseconds: 600);
    _lastWheel = now;
    final base = animating ? _target : _scroll.offset;
    _target = (base + e.scrollDelta.dy).clamp(0.0, pos.maxScrollExtent);
    _scroll.animateTo(
      _target,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
    );
  }

  void _goTo(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      alignment: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = _Palette.of(context);
    final narrow = MediaQuery.sizeOf(context).width < 520;
    final hPad = narrow ? 20.0 : 24.0;

    return Scaffold(
      backgroundColor: c.bg,
      body: Column(
        children: [
          _Nav(
            palette: c,
            hPad: hPad,
            onLogo: () => _goTo(_topKey),
            onAbout: () => _goTo(_aboutKey),
            onProjects: () => _goTo(_projectsKey),
            onSkills: () => _goTo(_skillsKey),
          ),
          Expanded(
            child: ScrollConfiguration(
              behavior: const _BounceBehavior(),
              child: SingleChildScrollView(
                controller: _scroll,
                physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                child: Listener(
                  // 스크롤뷰보다 안쪽에서 먼저 등록해야 기본 휠 스크롤(점프)을 대체할 수 있음
                  onPointerSignal: (e) {
                    if (e is PointerScrollEvent) {
                      GestureBinding.instance.pointerSignalResolver
                          .register(e, _onPointer);
                    }
                  },
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720 + 48),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: hPad),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(key: _topKey, height: narrow ? 88 : 128),
                            _Reveal(
                                child: _Hero(
                                    palette: c,
                                    narrow: narrow,
                                    onProjects: () => _goTo(_projectsKey))),
                            SizedBox(key: _aboutKey, height: narrow ? 72 : 96),
                            _Reveal(child: _About(palette: c)),
                            SizedBox(
                                key: _projectsKey, height: narrow ? 72 : 96),
                            _Reveal(child: _Projects(palette: c)),
                            SizedBox(key: _skillsKey, height: narrow ? 72 : 96),
                            _Reveal(child: _Skills(palette: c)),
                            const SizedBox(height: 120),
                            Divider(height: 1, color: c.line),
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 32, bottom: 48),
                              child: Text(
                                '© 2026 Minsung Kim · 방문해주셔서 감사합니다.',
                                style: TextStyle(fontSize: 14, color: c.muted),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BounceBehavior extends MaterialScrollBehavior {
  const _BounceBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };

  @override
  Widget buildOverscrollIndicator(
          BuildContext context, Widget child, ScrollableDetails details) =>
      child;

  @override
  Widget buildScrollbar(
          BuildContext context, Widget child, ScrollableDetails details) =>
      child;
}

// ── Palette ────────────────────────────────────────────────────────────────

class _Palette {
  final Color bg, surface, text, muted, line, accent, accentSoft;
  const _Palette({
    required this.bg,
    required this.surface,
    required this.text,
    required this.muted,
    required this.line,
    required this.accent,
    required this.accentSoft,
  });

  static const _dark = _Palette(
    bg: Color(0xFF0B0D10),
    surface: Color(0xFF161A1E),
    text: Color(0xFFEEF1F4),
    muted: Color(0xFF9AA5B1),
    line: Color(0xFF262C32),
    accent: Color(0xFF4CC2FF),
    accentSoft: Color(0xFF12232D),
  );

  static _Palette of(BuildContext context) => _dark;
}

// ── Common ─────────────────────────────────────────────────────────────────

Future<void> _open(String url) =>
    launchUrl(Uri.parse(url), webOnlyWindowName: '_blank');

class _Reveal extends StatefulWidget {
  final Widget child;
  const _Reveal({required this.child});

  @override
  State<_Reveal> createState() => _RevealState();
}

class _RevealState extends State<_Reveal> {
  final _id = UniqueKey();
  bool _shown = false;

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: _id,
      onVisibilityChanged: (info) {
        if (!_shown && info.visibleFraction > 0.05 && mounted) {
          setState(() => _shown = true);
        }
      },
      child: AnimatedOpacity(
        opacity: _shown ? 1 : 0,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOut,
        child: AnimatedSlide(
          offset: _shown ? Offset.zero : const Offset(0, 0.02),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOut,
          child: widget.child,
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  final _Palette palette;
  const _Label(this.text, this.palette);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Text(
          text.toUpperCase(),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
            color: palette.accent,
          ),
        ),
      );
}

class _Pill extends StatefulWidget {
  final String label;
  final bool primary;
  final VoidCallback onTap;
  final _Palette palette;
  const _Pill(
      {required this.label,
      required this.onTap,
      required this.palette,
      this.primary = false});

  @override
  State<_Pill> createState() => _PillState();
}

class _PillState extends State<_Pill> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.palette;
    final bg =
        widget.primary ? c.text : (_hover ? c.surface : Colors.transparent);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: widget.primary ? c.text : c.line),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: widget.primary ? c.bg : c.text,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Nav ────────────────────────────────────────────────────────────────────

class _Nav extends StatelessWidget {
  final _Palette palette;
  final double hPad;
  final VoidCallback onLogo, onAbout, onProjects, onSkills;
  const _Nav({
    required this.palette,
    required this.hPad,
    required this.onLogo,
    required this.onAbout,
    required this.onProjects,
    required this.onSkills,
  });

  @override
  Widget build(BuildContext context) {
    Widget link(String t, VoidCallback f) => MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: f,
            child:
                Text(t, style: TextStyle(fontSize: 14, color: palette.muted)),
          ),
        );

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: palette.bg,
        border: Border(bottom: BorderSide(color: palette.line)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720 + 48),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: hPad),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: onLogo,
                    child: Text('김민성',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 17,
                            color: palette.text)),
                  ),
                ),
                Row(children: [
                  link('About', onAbout),
                  const SizedBox(width: 20),
                  link('Projects', onProjects),
                  const SizedBox(width: 20),
                  link('Skills', onSkills),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Hero ───────────────────────────────────────────────────────────────────

class _Hero extends StatelessWidget {
  final _Palette palette;
  final bool narrow;
  final VoidCallback onProjects;
  const _Hero(
      {required this.palette, required this.narrow, required this.onProjects});

  @override
  Widget build(BuildContext context) {
    final size = narrow ? 36.0 : 56.0;
    final base = TextStyle(
        fontSize: size,
        height: 1.2,
        fontWeight: FontWeight.w800,
        letterSpacing: -size * 0.03,
        color: palette.text);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(TextSpan(style: base, children: [
          const TextSpan(text: '안녕하세요,\n'),
          TextSpan(text: '김민성', style: TextStyle(color: palette.accent)),
          const TextSpan(text: '입니다.\n웹·앱 개발자.'),
        ])),
        const SizedBox(height: 24),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Text(
            'Flutter를 중심으로 웹과 모바일 서비스를 만듭니다. 설계부터 개발, 스토어 배포까지 직접 경험했습니다.',
            style: TextStyle(
                fontSize: narrow ? 17 : 19, height: 1.7, color: palette.muted),
          ),
        ),
        const SizedBox(height: 36),
        Wrap(spacing: 12, runSpacing: 12, children: [
          _Pill(
              label: '프로젝트 보기',
              primary: true,
              palette: palette,
              onTap: onProjects),
          _Pill(
              label: 'GitHub',
              palette: palette,
              onTap: () => _open('https://github.com/alscks6521')),
        ]),
      ],
    );
  }
}

// ── About ──────────────────────────────────────────────────────────────────

class _About extends StatelessWidget {
  final _Palette palette;
  const _About({required this.palette});

  @override
  Widget build(BuildContext context) {
    final body = TextStyle(fontSize: 17, height: 1.7, color: palette.muted);
    final strong = TextStyle(fontWeight: FontWeight.w600, color: palette.text);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label('About', palette),
        Text.rich(TextSpan(style: body, children: [
          TextSpan(text: 'Flutter', style: strong),
          const TextSpan(text: '를 중심으로 웹과 모바일 서비스를 개발하고 있습니다.'),
        ])),
        const SizedBox(height: 18),
        Text.rich(TextSpan(style: body, children: [
          const TextSpan(text: '스타트업에서 앱의 설계부터 개발, 배포까지 전 과정을 담당하며 '),
          TextSpan(text: 'Android와 iOS 스토어에 서비스를 직접 출시', style: strong),
          const TextSpan(text: '한 경험이 있습니다.'),
        ])),
        const SizedBox(height: 18),
        Text('사용자가 실제로 사용할 수 있는 서비스를 만드는 것을 목표로, 공부를 하며 지속적인 개선에 집중하고 있습니다.',
            style: body),
      ],
    );
  }
}

// ── Projects ───────────────────────────────────────────────────────────────

class _ProjectData {
  final String title, tag, description, role;
  final List<String> skills;
  const _ProjectData(
      this.title, this.tag, this.description, this.role, this.skills);
}

const _projects = [
  _ProjectData(
    '언어 치료 관리 모바일 애플리케이션',
    'ISay App',
    '언어 치료가 필요한 아동과 보호자, 그리고 치료사를 연결하여 치료 일정 관리와 상담을 지원하는 모바일 애플리케이션입니다.',
    'Flutter 기반 모바일 앱 개발 전체 담당',
    [
      'Flutter',
      'Riverpod',
      'Kakao Auth & Map',
      'iOS Auth',
      'Firebase Cloud Messaging',
      'PortOne API',
      'WebSocket'
    ],
  ),
  _ProjectData(
    '언어 치료 관리 웹 플랫폼',
    'ISay Web',
    '언어 치료 서비스 이용자와 치료사를 위한 관리 플랫폼으로, 치료 일정 관리, 상담, 사용자 관리 기능을 제공하는 웹 서비스입니다.',
    'Flutter Web 개발 전체 담당',
    [
      'Flutter Web',
      'Dio',
      'Firebase Cloud Messaging',
      'PortOne JS SDK',
      'WebSocket'
    ],
  ),
];

class _Projects extends StatelessWidget {
  final _Palette palette;
  const _Projects({required this.palette});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label('Projects', palette),
        for (var i = 0; i < _projects.length; i++)
          _ProjectTile(
              index: i + 1,
              data: _projects[i],
              palette: palette,
              last: i == _projects.length - 1),
      ],
    );
  }
}

class _ProjectTile extends StatelessWidget {
  final int index;
  final _ProjectData data;
  final _Palette palette;
  final bool last;
  const _ProjectTile(
      {required this.index,
      required this.data,
      required this.palette,
      required this.last});

  @override
  Widget build(BuildContext context) {
    final c = palette;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: c.line),
          bottom: last ? BorderSide(color: c.line) : BorderSide.none,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('0$index', style: TextStyle(fontSize: 13, color: c.muted)),
          const SizedBox(height: 6),
          Text.rich(TextSpan(
            style: TextStyle(
                fontSize: 22,
                height: 1.4,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.4,
                color: c.text),
            children: [
              TextSpan(text: data.title),
              TextSpan(
                  text: '  · ${data.tag}',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: c.muted)),
            ],
          )),
          const SizedBox(height: 12),
          Text(data.description,
              style: TextStyle(fontSize: 17, height: 1.7, color: c.muted)),
          const SizedBox(height: 10),
          Text(data.role,
              style: TextStyle(fontSize: 17, height: 1.7, color: c.text)),
          const SizedBox(height: 18),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final s in data.skills)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                    color: c.accentSoft,
                    borderRadius: BorderRadius.circular(999)),
                child: Text(s,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: c.accent)),
              ),
          ]),
        ],
      ),
    );
  }
}

// ── Skills ─────────────────────────────────────────────────────────────────

class _Skills extends StatelessWidget {
  final _Palette palette;
  const _Skills({required this.palette});

  static const _rows = [
    ('Framework', 'Flutter · Flutter Web'),
    ('State & Network', 'Riverpod · Dio · WebSocket'),
    (
      'Integration',
      'Firebase Cloud Messaging · Kakao Auth & Map · PortOne · iOS Auth'
    ),
    ('Release', 'Google Play · App Store 출시'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label('Skills', palette),
        for (final r in _rows)
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r.$1,
                    style: TextStyle(fontSize: 14, color: palette.muted)),
                const SizedBox(height: 6),
                Text(r.$2,
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: palette.text)),
              ],
            ),
          ),
      ],
    );
  }
}
