import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:github_portfolio/common/app_assets.dart';
import 'package:github_portfolio/router/app_router.dart';
import 'package:github_portfolio/common/star_counter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visibility_detector/visibility_detector.dart';

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

  bool _light = false;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
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
    final narrow = MediaQuery.sizeOf(context).width < 520;
    final hPad = narrow ? 20.0 : 24.0;

    return TweenAnimationBuilder<double>(
      tween: Tween(end: _light ? 1.0 : 0.0),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOut,
      builder: (context, t, _) {
        final c = _Palette.lerp(_Palette.dark, _Palette.light, t);
        return _buildPage(c, narrow, hPad);
      },
    );
  }

  Widget _buildPage(_Palette c, bool narrow, double hPad) {
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
            isLight: _light,
            onToggleTheme: () => setState(() => _light = !_light),
          ),
          Expanded(
            child: ScrollConfiguration(
              behavior: const _BounceBehavior(),
              child: SingleChildScrollView(
                controller: _scroll,
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 960 + 48),
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
                          SizedBox(key: _projectsKey, height: narrow ? 72 : 96),
                          _Reveal(child: _Projects(palette: c)),
                          SizedBox(key: _skillsKey, height: narrow ? 72 : 96),
                          _Reveal(child: _Skills(palette: c)),
                          const SizedBox(height: 120),
                          Divider(height: 1, color: c.line),
                          Padding(
                            padding: const EdgeInsets.only(top: 32, bottom: 48),
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
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) =>
      child;

  @override
  Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) => child;
}

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

  static const dark = _Palette(
    bg: Color(0xFF0B0D10),
    surface: Color(0xFF161A1E),
    text: Color(0xFFEEF1F4),
    muted: Color(0xFF9AA5B1),
    line: Color(0xFF262C32),
    accent: Color(0xFF4CC2FF),
    accentSoft: Color(0xFF12232D),
  );

  static const light = _Palette(
    bg: Color(0xFFFFFFFF),
    surface: Color(0xFFF6F8FA),
    text: Color(0xFF14181C),
    muted: Color(0xFF5B6672),
    line: Color(0xFFE4E8EC),
    accent: Color(0xFF0A7FC2),
    accentSoft: Color(0xFFE6F4FC),
  );

  static _Palette lerp(_Palette a, _Palette b, double t) => _Palette(
        bg: Color.lerp(a.bg, b.bg, t)!,
        surface: Color.lerp(a.surface, b.surface, t)!,
        text: Color.lerp(a.text, b.text, t)!,
        muted: Color.lerp(a.muted, b.muted, t)!,
        line: Color.lerp(a.line, b.line, t)!,
        accent: Color.lerp(a.accent, b.accent, t)!,
        accentSoft: Color.lerp(a.accentSoft, b.accentSoft, t)!,
      );
}

Future<void> _open(String url) => launchUrl(Uri.parse(url), webOnlyWindowName: '_blank');

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
      {required this.label, required this.onTap, required this.palette, this.primary = false});

  @override
  State<_Pill> createState() => _PillState();
}

class _PillState extends State<_Pill> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.palette;
    final bg = widget.primary ? c.text : (_hover ? c.surface : Colors.transparent);
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

class _Nav extends StatelessWidget {
  final _Palette palette;
  final double hPad;
  final VoidCallback onLogo, onAbout, onProjects, onSkills, onToggleTheme;
  final bool isLight;
  const _Nav({
    required this.isLight,
    required this.onToggleTheme,
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
            child: Text(t, style: TextStyle(fontSize: 14, color: palette.muted)),
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
          constraints: const BoxConstraints(maxWidth: 960 + 48),
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
                            fontWeight: FontWeight.w700, fontSize: 17, color: palette.text)),
                  ),
                ),
                Row(children: [
                  link('About', onAbout),
                  const SizedBox(width: 20),
                  link('Projects', onProjects),
                  const SizedBox(width: 20),
                  link('Skills', onSkills),
                  const SizedBox(width: 16),
                  _ThemeToggle(palette: palette, isLight: isLight, onTap: onToggleTheme),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ThemeToggle extends StatelessWidget {
  final _Palette palette;
  final bool isLight;
  final VoidCallback onTap;
  const _ThemeToggle({required this.palette, required this.isLight, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const w = 48.0, h = 26.0, knob = 20.0;
    return Semantics(
      button: true,
      label: isLight ? '다크 테마로 전환' : '라이트 테마로 전환',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: w,
            height: h,
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: palette.line),
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              alignment: isLight ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: knob,
                height: knob,
                decoration: BoxDecoration(color: palette.accent, shape: BoxShape.circle),
                child: Icon(
                  isLight ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  size: 13,
                  color: palette.bg,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DeviceLink extends StatefulWidget {
  final String asset, tooltip, route;
  final Color color;
  final double hoverScale;
  const _DeviceLink({
    required this.asset,
    required this.tooltip,
    required this.route,
    required this.color,
    this.hoverScale = 1.12,
  });

  @override
  State<_DeviceLink> createState() => _DeviceLinkState();
}

class _DeviceLinkState extends State<_DeviceLink> {
  bool _hover = false;
  bool _busy = false;

  void _go() {
    if (_busy) return;
    setState(() => _busy = true);

    final box = context.findRenderObject() as RenderBox;
    final center = box.localToGlobal(box.size.center(Offset.zero));
    final overlay = Overlay.of(context, rootOverlay: true);
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _CircleReveal(
        center: center,
        color: widget.color,
        onCovered: () => router.go(widget.route),
        onDone: entry.remove,
      ),
    );
    overlay.insert(entry);

    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) setState(() => _busy = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final active = _hover || _busy;
    return Tooltip(
      message: widget.tooltip,
      waitDuration: Duration.zero,
      preferBelow: false,
      textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
      decoration: BoxDecoration(
        color: const Color(0xFF14181C),
        borderRadius: BorderRadius.circular(8),
      ),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _go,
          child: AnimatedScale(
            scale: active ? widget.hoverScale : 1.0,
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutBack,
            child: Image.asset(widget.asset),
          ),
        ),
      ),
    );
  }
}

class _CircleReveal extends StatefulWidget {
  final Offset center;
  final Color color;
  final VoidCallback onCovered, onDone;
  const _CircleReveal({
    required this.center,
    required this.color,
    required this.onCovered,
    required this.onDone,
  });

  @override
  State<_CircleReveal> createState() => _CircleRevealState();
}

class _CircleRevealState extends State<_CircleReveal> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  );
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _c.addListener(() {
      if (!_navigated && _c.value >= 0.5) {
        _navigated = true;
        widget.onCovered();
      }
    });
    _c.addStatusListener((st) {
      if (st == AnimationStatus.completed) widget.onDone();
    });
    _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final c = widget.center;
    final maxR = [
      Offset.zero,
      Offset(size.width, 0),
      Offset(0, size.height),
      Offset(size.width, size.height),
    ].map((p) => (p - c).distance).reduce((a, b) => a > b ? a : b);

    final grow =
        CurvedAnimation(parent: _c, curve: const Interval(0.0, 0.5, curve: Curves.easeInCubic));
    final fade =
        CurvedAnimation(parent: _c, curve: const Interval(0.7, 1.0, curve: Curves.easeOut));

    return AbsorbPointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, __) => CustomPaint(
          size: size,
          painter: _CirclePainter(
            center: c,
            radius: maxR * grow.value,
            color: widget.color.withValues(alpha: 1 - fade.value),
          ),
        ),
      ),
    );
  }
}

class _CirclePainter extends CustomPainter {
  final Offset center;
  final double radius;
  final Color color;
  const _CirclePainter({required this.center, required this.radius, required this.color});

  @override
  void paint(Canvas canvas, Size size) => canvas.drawCircle(center, radius, Paint()..color = color);

  @override
  bool shouldRepaint(_CirclePainter old) =>
      old.radius != radius || old.color != color || old.center != center;
}

class _StarBadge extends StatefulWidget {
  final double starSize;
  const _StarBadge({required this.starSize});

  @override
  State<_StarBadge> createState() => _StarBadgeState();
}

class _Puff {
  final int id;
  final String text;
  const _Puff(this.id, this.text);
}

class _StarBadgeState extends State<_StarBadge> {
  static const _prefKey = 'star_voted';

  int? _total;
  bool _voted = false;
  bool _busy = false;
  bool _squish = false;
  int _puffId = 0;
  DateTime _lastTap = DateTime.fromMillisecondsSinceEpoch(0);
  final _puffs = <_Puff>[];

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((p) {
      if (mounted) setState(() => _voted = p.getBool(_prefKey) ?? false);
    }).catchError((_) {});
    if (StarCounterConfig.enabled) {
      StarCounter.fetch().then((v) {
        if (mounted && v != null) setState(() => _total = v);
      });
    } else {
      _total = 0;
    }
  }

  void _puff(String text) => setState(() => _puffs.add(_Puff(_puffId++, text)));

  void _bounce() {
    setState(() => _squish = true);
    Future.delayed(const Duration(milliseconds: 110), () {
      if (mounted) setState(() => _squish = false);
    });
  }

  Future<void> _setVoted(bool v) async {
    try {
      final p = await SharedPreferences.getInstance();
      if (v) {
        await p.setBool(_prefKey, true);
      } else {
        await p.remove(_prefKey);
      }
    } catch (_) {}
  }

  Future<void> _tap() async {
    final now = DateTime.now();
    if (now.difference(_lastTap) < const Duration(milliseconds: 400)) return;
    _lastTap = now;

    if (_voted) {
      _bounce();
      _puff('♥');
      return;
    }
    if (_busy) return;
    _busy = true;

    final before = _total ?? 0;
    setState(() {
      _total = before + 1;
      _voted = true;
    });
    _bounce();
    _puff('+1');

    if (StarCounterConfig.enabled) {
      final r = await StarCounter.vote();
      if (!mounted) return;
      if (r.status == VoteStatus.ok) {
        setState(() => _total = r.count ?? before + 1);
        await _setVoted(true);
      } else {
        setState(() {
          _total = before;
          _voted = false;
        });
      }
    } else {
      await _setVoted(true);
    }
    _busy = false;
  }

  @override
  Widget build(BuildContext context) {
    final label = (widget.starSize * 0.32).clamp(14.0, 24.0);
    const amber = Color(0xFFE59500);

    final hintSize = (label * 0.6).clamp(12.0, 14.0);
    final row = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (_total != null)
          AnimatedScale(
            scale: _squish ? 1.18 : 1.0,
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOutBack,
            child: Text(
              '+${NumberFormat.decimalPattern().format(_total)}',
              style: TextStyle(
                fontSize: label,
                fontWeight: FontWeight.w900,
                color: amber,
              ),
            ),
          ),
        const SizedBox(width: 6),
        Tooltip(
          message: _voted ? '' : '별을 눌러주세요 ⭐',
          waitDuration: Duration.zero,
          preferBelow: false,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _tap,
              child: SizedBox(
                width: widget.starSize,
                height: widget.starSize,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    AnimatedScale(
                      scale: _squish ? 0.82 : 1.0,
                      duration: const Duration(milliseconds: 140),
                      curve: Curves.easeOutBack,
                      child: AnimatedRotation(
                        turns: _squish ? -0.02 : 0,
                        duration: const Duration(milliseconds: 140),
                        child: Image.asset(AppAssets.star),
                      ),
                    ),
                    for (final p in _puffs)
                      Positioned(
                        key: ValueKey(p.id),
                        top: -4,
                        child: _PuffText(
                          text: p.text,
                          size: label,
                          onDone: () {
                            if (mounted) setState(() => _puffs.remove(p));
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(
          height: hintSize + 8,
          child: Align(
            alignment: Alignment.bottomRight,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Padding(
                key: ValueKey(_voted),
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  _voted ? '눌러주셔서 고마워요! 💛' : '별 눌러주시면 최고!',
                  softWrap: false,
                  style: TextStyle(
                    fontSize: hintSize,
                    fontWeight: FontWeight.w800,
                    color: amber,
                  ),
                ),
              ),
            ),
          ),
        ),
        row,
      ],
    );
  }
}

class _PuffText extends StatelessWidget {
  final String text;
  final double size;
  final VoidCallback onDone;
  const _PuffText({required this.text, required this.size, required this.onDone});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOut,
        onEnd: onDone,
        builder: (_, t, child) => Opacity(
          opacity: (1 - t).clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, -46 * t),
            child: Transform.scale(scale: 0.9 + 0.35 * (1 - t), child: child),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: size * 0.9,
            fontWeight: FontWeight.w900,
            color: const Color(0xFFFFB400),
            shadows: const [Shadow(color: Color(0x66000000), blurRadius: 6)],
          ),
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  final _Palette palette;
  final bool narrow;
  final VoidCallback onProjects;
  const _Hero({required this.palette, required this.narrow, required this.onProjects});

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
        Text.rich(TextSpan(style: base, children: [
          const TextSpan(text: '안녕하세요,\n'),
          TextSpan(text: '김민성', style: TextStyle(color: palette.accent)),
          const TextSpan(text: '입니다.\n웹·앱 개발자'),
        ])),
        const SizedBox(height: 24),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Text(
            'Flutter를 중심으로 웹과 모바일 서비스를 만듭니다. 설계부터 개발, 스토어 배포까지 직접 경험했습니다.',
            style: TextStyle(fontSize: narrow ? 16 : 19, height: 1.7, color: palette.muted),
          ),
        ),
        const SizedBox(height: 36),
        Wrap(spacing: 12, runSpacing: 12, children: [
          _Pill(label: '프로젝트 보기', primary: true, palette: palette, onTap: onProjects),
          // _Pill(
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
  final _Palette palette;
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
              child: _Float(
                  amplitude: 8,
                  seconds: 4.2,
                  child: _DeviceLink(
                    asset: AppAssets.laptop,
                    tooltip: '웹 프로젝트 보러가기',
                    route: AppScreen.webPro,
                    color: palette.accent,
                  )),
            ),
            Positioned(
              left: 0,
              bottom: 0,
              width: w * 0.30,
              child: _Float(
                  amplitude: 10,
                  seconds: 3.6,
                  phase: 0.4,
                  child: _DeviceLink(
                    asset: AppAssets.phone,
                    tooltip: '앱 프로젝트 보러가기',
                    route: AppScreen.appPro,
                    color: palette.accent,
                  )),
            ),
            Positioned(
              right: w * 0.02,
              top: -w * 0.02 - 22,
              child: _Float(
                  amplitude: 6, seconds: 3.0, phase: 0.7, child: _StarBadge(starSize: w * 0.16)),
            ),
          ],
        ),
      );
    });
  }
}

class _Float extends StatefulWidget {
  final Widget child;
  final double amplitude, seconds, phase;
  const _Float(
      {required this.child, required this.amplitude, required this.seconds, this.phase = 0});

  @override
  State<_Float> createState() => _FloatState();
}

class _FloatState extends State<_Float> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: (widget.seconds * 1000).round()),
    value: widget.phase,
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curve = CurvedAnimation(parent: _c, curve: Curves.easeInOut);
    return AnimatedBuilder(
      animation: curve,
      child: widget.child,
      builder: (_, child) => Transform.translate(
        offset: Offset(0, (curve.value - 0.5) * 2 * widget.amplitude),
        child: child,
      ),
    );
  }
}

class _About extends StatelessWidget {
  final _Palette palette;
  const _About({required this.palette});

  @override
  Widget build(BuildContext context) {
    final body = TextStyle(fontSize: 17, height: 1.7, color: palette.muted);
    final strong = TextStyle(fontWeight: FontWeight.w600, color: palette.text);

    return ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: Column(
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
            Text('사용자가 실제로 사용할 수 있는 서비스를 만드는 것을 목표로, 공부를 하며 지속적인 개선에 집중하고 있습니다.', style: body),
          ],
        ));
  }
}

class _ProjectData {
  final String title, tag, description, role, image;
  final List<String> skills;
  const _ProjectData(this.title, this.tag, this.description, this.role, this.image, this.skills);
}

const _projects = [
  _ProjectData(
    '언어 치료 관리 모바일 애플리케이션',
    'ISay App',
    '언어 치료가 필요한 아동과 보호자, 그리고 치료사를 연결하여 치료 일정 관리와 상담을 지원하는 모바일 애플리케이션입니다.',
    'Flutter 기반 모바일 앱 개발 전체 담당',
    AppAssets.phone,
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
    AppAssets.laptop,
    ['Flutter Web', 'Dio', 'Firebase Cloud Messaging', 'PortOne JS SDK', 'WebSocket'],
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
              index: i + 1, data: _projects[i], palette: palette, last: i == _projects.length - 1),
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
      {required this.index, required this.data, required this.palette, required this.last});

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
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('0$index', style: TextStyle(fontSize: 13, color: c.muted)),
              const Spacer(),
              SizedBox(
                height: MediaQuery.sizeOf(context).width < 520 ? 48 : 72,
                child: _DeviceLink(
                  asset: data.image,
                  tooltip: data.image == AppAssets.phone ? '앱 프로젝트 보러가기' : '웹 프로젝트 보러가기',
                  route: data.image == AppAssets.phone ? AppScreen.appPro : AppScreen.webPro,
                  color: c.accent,
                  hoverScale: 1.25,
                ),
              ),
            ],
          ),
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
                  text:
                      MediaQuery.sizeOf(context).width < 520 ? '\n${data.tag}' : '  · ${data.tag}',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: c.muted)),
            ],
          )),
          const SizedBox(height: 12),
          Text(data.description, style: TextStyle(fontSize: 17, height: 1.7, color: c.muted)),
          const SizedBox(height: 10),
          Text(data.role, style: TextStyle(fontSize: 17, height: 1.7, color: c.text)),
          const SizedBox(height: 18),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final s in data.skills)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration:
                    BoxDecoration(color: c.accentSoft, borderRadius: BorderRadius.circular(999)),
                child: Text(s,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: c.accent)),
              ),
          ]),
        ],
      ),
    );
  }
}

class _Skills extends StatelessWidget {
  final _Palette palette;
  const _Skills({required this.palette});

  static const _rows = [
    ('Framework', 'Flutter · Flutter Web'),
    ('State & Network', 'Riverpod · Dio · WebSocket'),
    ('Integration', 'Firebase Cloud Messaging · Kakao Auth & Map · PortOne · iOS Auth'),
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
                Text(r.$1, style: TextStyle(fontSize: 14, color: palette.muted)),
                const SizedBox(height: 6),
                Text(r.$2,
                    style:
                        TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: palette.text)),
              ],
            ),
          ),
      ],
    );
  }
}
