import 'dart:math' as math;

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
                physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
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
                          SizedBox(key: _skillsKey, height: narrow ? 72 : 96),
                          _Reveal(child: _Skills(palette: c)),
                          SizedBox(key: _projectsKey, height: narrow ? 72 : 96),
                          _Reveal(child: _Projects(palette: c)),
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
  Widget buildOverscrollIndicator(
          BuildContext context, Widget child, ScrollableDetails details) =>
      child;

  @override
  Widget buildScrollbar(
          BuildContext context, Widget child, ScrollableDetails details) =>
      child;
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
                            fontWeight: FontWeight.w700,
                            fontSize: 17,
                            color: palette.text)),
                  ),
                ),
                Row(children: [
                  link('About', onAbout),
                  const SizedBox(width: 20),
                  link('Skills', onSkills),
                  const SizedBox(width: 20),
                  link('Projects', onProjects),
                  const SizedBox(width: 16),
                  _ThemeToggle(
                      palette: palette, isLight: isLight, onTap: onToggleTheme),
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
  const _ThemeToggle(
      {required this.palette, required this.isLight, required this.onTap});

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
                decoration: BoxDecoration(
                    color: palette.accent, shape: BoxShape.circle),
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
  final double hoverScale, radius;
  const _DeviceLink({
    required this.asset,
    required this.tooltip,
    required this.route,
    required this.color,
    this.hoverScale = 1.12,
    this.radius = 0,
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
    _revealTo(context, box.localToGlobal(box.size.center(Offset.zero)),
        widget.color, widget.route);

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
      textStyle: const TextStyle(
          fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(widget.radius),
              child: Image.asset(widget.asset),
            ),
          ),
        ),
      ),
    );
  }
}

/// [center]에서 원이 화면을 덮으며 [route]로 이동한다.
void _revealTo(BuildContext context, Offset center, Color color, String route) {
  final overlay = Overlay.of(context, rootOverlay: true);
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _CircleReveal(
      center: center,
      color: color,
      onCovered: () => router.go(route),
      onDone: entry.remove,
    ),
  );
  overlay.insert(entry);
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

class _CircleRevealState extends State<_CircleReveal>
    with SingleTickerProviderStateMixin {
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

    final grow = CurvedAnimation(
        parent: _c, curve: const Interval(0.0, 0.5, curve: Curves.easeInCubic));
    final fade = CurvedAnimation(
        parent: _c, curve: const Interval(0.7, 1.0, curve: Curves.easeOut));

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
  const _CirclePainter(
      {required this.center, required this.radius, required this.color});

  @override
  void paint(Canvas canvas, Size size) =>
      canvas.drawCircle(center, radius, Paint()..color = color);

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
                  _voted ? '눌러주셔서 고마워요! 👍' : '별 눌러주세요!',
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
  const _PuffText(
      {required this.text, required this.size, required this.onDone});

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
  const _Hero(
      {required this.palette, required this.narrow, required this.onProjects});

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
            style: TextStyle(
                fontSize: narrow ? 16 : 19, height: 1.7, color: palette.muted),
          ),
        ),
        const SizedBox(height: 36),
        Wrap(spacing: 12, runSpacing: 12, children: [
          _Pill(
              label: '프로젝트 보기',
              primary: true,
              palette: palette,
              onTap: onProjects),
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
                  amplitude: 6,
                  seconds: 3.0,
                  phase: 0.7,
                  child: _StarBadge(starSize: w * 0.16)),
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
      {required this.child,
      required this.amplitude,
      required this.seconds,
      this.phase = 0});

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
              const TextSpan(text: '를 중심으로 모바일 앱과 웹 서비스를 만드는 개발자입니다.'),
            ])),
            const SizedBox(height: 18),
            Text.rich(TextSpan(style: body, children: [
              const TextSpan(text: '실무에서 모바일 앱과 웹을 개발해 '),
              TextSpan(text: 'App Store · Google Play에 출시', style: strong),
              const TextSpan(text: '했고, 서버 API 개발에도 함께 참여했습니다.'),
            ])),
            const SizedBox(height: 18),
            Text.rich(TextSpan(style: body, children: [
              const TextSpan(text: '텍스트 임베딩 기반 의도 분류와 '),
              TextSpan(text: 'RAG(AWS Bedrock)', style: strong),
              const TextSpan(
                  text: '로 누적된 치료 데이터를 분석해 평가서를 생성하는 AI 기능을 실제 서비스에 적용했습니다.'),
            ])),
            const SizedBox(height: 28),
            for (final (label, value) in const [
              ('Education', '컴퓨터공학 학사'),
              ('Training', '한국소프트웨어 3년 교육과정 수료'),
            ])
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 96,
                        child: Text(label,
                            style: TextStyle(
                                fontSize: 14,
                                height: 1.9,
                                color: palette.muted)),
                      ),
                      Expanded(
                        child: Text(value,
                            style: TextStyle(
                                fontSize: 16,
                                height: 1.7,
                                fontWeight: FontWeight.w600,
                                color: palette.text)),
                      ),
                    ]),
              ),
          ],
        ));
  }
}

class _ProjectData {
  final String title, tag, description, role, image, tooltip;
  final String route;
  final List<String> skills, screens;
  final double imageRadius;
  final int screenCols;
  final bool released; // App Store · Google Play 출시 여부
  const _ProjectData(this.title, this.tag, this.description, this.role,
      this.image, this.tooltip, this.route, this.skills,
      {this.screens = const [],
      this.imageRadius = 0,
      this.screenCols = 4,
      this.released = false});
}

const _projects = [
  _ProjectData(
    ' 치료 관리 모바일 애플리케이션',
    'ISay App',
    ' 치료가 필요한 아동과 보호자, 그리고 치료사를 연결하여 치료 일정 관리와 상담을 지원하는 모바일 애플리케이션입니다.',
    'Flutter 기반 모바일 앱 개발 전체 담당',
    AppAssets.isayIcon,
    '앱 프로젝트 보러가기',
    '${AppScreen.appPro}?p=isay-app',
    [
      'Flutter',
      'Riverpod',
      'AWS Bedrock',
      'RAG',
      'LLM',
      'WebSocket',
      'Firebase Cloud Messaging'
    ],
    screens: AppAssets.isayScreens,
    imageRadius: 16,
    released: true,
  ),
  _ProjectData(
    ' 치료 관리 웹 플랫폼',
    'ISay Web',
    ' 치료 서비스 이용자와 치료사를 위한 관리 플랫폼으로, 치료 일정 관리, 상담, 사용자 관리 기능을 제공하는 웹 서비스입니다.',
    'Flutter Web 개발 전체 담당',
    AppAssets.isayWebIcon,
    '웹 프로젝트 보러가기',
    '${AppScreen.webPro}?p=isay-web',
    [
      'Flutter Web',
      'WebSocket',
      'Firebase Cloud Messaging',
      'PortOne 구독 결제',
      '역할 기반 권한'
    ],
    screens: AppAssets.isayWebScreens,
    imageRadius: 16,
    screenCols: 2,
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
        _ProjectNetwork(palette: palette),
        const SizedBox(height: 24),
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

class _ProjectTile extends StatefulWidget {
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
  State<_ProjectTile> createState() => _ProjectTileState();
}

class _ProjectTileState extends State<_ProjectTile> {
  final _id = UniqueKey();
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.palette;
    final data = widget.data;
    final index = widget.index;
    final last = widget.last;
    return VisibilityDetector(
      key: _id,
      onVisibilityChanged: (info) {
        if (!_open &&
            data.screens.isNotEmpty &&
            info.visibleFraction > 0.5 &&
            mounted) {
          setState(() => _open = true);
        }
      },
      child: _tile(context, c, data, index, last),
    );
  }

  Widget _tile(BuildContext context, _Palette c, _ProjectData data, int index,
      bool last) {
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
                  tooltip: data.tooltip,
                  route: data.route,
                  color: c.accent,
                  hoverScale: 1.25,
                  radius: data.imageRadius *
                      (MediaQuery.sizeOf(context).width < 520 ? 48 : 72) /
                      72,
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
                  text: MediaQuery.sizeOf(context).width < 520
                      ? '\n${data.tag}'
                      : '  · ${data.tag}',
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
          Text.rich(TextSpan(
            style: TextStyle(fontSize: 17, height: 1.7, color: c.text),
            children: [
              TextSpan(text: data.role),
              if (data.released) ...[
                const TextSpan(text: '  '),
                WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: _StoreBadge(
                        icon: Icons.apple,
                        tooltip: 'App Store 출시',
                        palette: c)),
                const TextSpan(text: ' '),
                WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: _StoreBadge(
                        icon: Icons.android,
                        tooltip: 'Google Play 출시',
                        palette: c)),
              ],
            ],
          )),
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
          if (data.screens.isNotEmpty)
            _ScreenGallery(
                screens: data.screens, cols: data.screenCols, open: _open),
        ],
      ),
    );
  }
}

/// 스토어 출시 인증용 작은 원형 뱃지.
class _StoreBadge extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final _Palette palette;
  final double size;
  final Color? bg, fg; // 지정하면 브랜드 색 솔리드 뱃지
  const _StoreBadge(
      {required this.icon,
      required this.tooltip,
      required this.palette,
      this.size = 26,
      this.bg,
      this.fg});

  @override
  Widget build(BuildContext context) {
    final solid = bg != null;
    return Tooltip(
      message: tooltip,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: bg ?? palette.accentSoft,
          shape: BoxShape.circle,
          border: Border.all(
              color: solid ? palette.bg : palette.accent,
              width: solid ? 2 : 1.2),
        ),
        child: Icon(icon, size: size * 0.58, color: fg ?? palette.accent),
      ),
    );
  }
}

double _iv(double t, double a, double b, [Curve curve = Curves.easeOutCubic]) =>
    curve.transform(((t - a) / (b - a)).clamp(0.0, 1.0));

/// 프로젝트 섹션 인트로: 가운데 코어가 스윽 생기고, 시냅스를 따라
/// 프로젝트 아이콘과 기술 스택 뉴런이 사방으로 퍼지는 신경망 연출.
class _ProjectNetwork extends StatefulWidget {
  final _Palette palette;
  const _ProjectNetwork({required this.palette});

  @override
  State<_ProjectNetwork> createState() => _ProjectNetworkState();
}

class _ProjectNetworkState extends State<_ProjectNetwork>
    with TickerProviderStateMixin {
  final _id = UniqueKey();
  late final AnimationController _intro = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2800));
  late final AnimationController _loop =
      AnimationController(vsync: this, duration: const Duration(seconds: 6));
  bool _started = false;
  bool _coreHover = false;
  final _coreKey = GlobalKey();
  _NetGeometry? _geo;

  /// 가운데 코어 클릭 → 작은 팝업 → 코어에서 원이 퍼지며 전체 프로젝트로 이동.
  Future<void> _openAll() async {
    final c = widget.palette;
    final go = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: '닫기',
      barrierColor: Colors.black.withValues(alpha: 0.35),
      transitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (_, __, ___) => _AllProjectsPopup(palette: c),
      transitionBuilder: (_, a, __, child) => FadeTransition(
        opacity: a,
        child: ScaleTransition(
          scale: Tween(begin: 0.9, end: 1.0).animate(CurvedAnimation(
              parent: a,
              curve: Curves.easeOutBack,
              reverseCurve: Curves.easeIn)),
          child: child,
        ),
      ),
    );
    if (go != true || !mounted) return;
    final box = _coreKey.currentContext?.findRenderObject() as RenderBox?;
    final center = box != null && box.attached
        ? box.localToGlobal(box.size.center(Offset.zero))
        : MediaQuery.sizeOf(context).center(Offset.zero);
    _revealTo(context, center, c.accent, AppScreen.projects);
  }

  @override
  void dispose() {
    _intro.dispose();
    _loop.dispose();
    super.dispose();
  }

  void _onVisible(VisibilityInfo info) {
    if (!mounted) return;
    final still = MediaQuery.of(context).disableAnimations;
    if (info.visibleFraction > 0.3) {
      if (!_started) {
        _started = true;
        still ? _intro.value = 1 : _intro.forward();
      }
      if (!still && !_loop.isAnimating) _loop.repeat();
    } else if (info.visibleFraction == 0) {
      _loop.stop(); // 화면 밖에서는 루프를 멈춘다.
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.palette;
    return VisibilityDetector(
      key: _id,
      onVisibilityChanged: _onVisible,
      child: LayoutBuilder(builder: (context, box) {
        final w = box.maxWidth;
        final narrow = w < 560;
        final size = Size(w, narrow ? 460.0 : 520.0);
        final g = _geo != null && _geo!.size == size
            ? _geo!
            : (_geo = _NetGeometry.of(size, narrow));

        return SizedBox.fromSize(
          size: size,
          child: AnimatedBuilder(
            animation: Listenable.merge([_intro, _loop]),
            builder: (context, _) {
              final t = _intro.value, l = _loop.value;
              final nodes = [
                for (var i = 0; i < g.nodes.length; i++)
                  g.nodes[i] + g.float(i, l)
              ];
              final coreIn = _iv(t, 0, 0.34);
              final breath = 0.5 + 0.5 * math.sin(2 * math.pi * l * 2);

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: CustomPaint(painter: _NetPainter(g, nodes, t, l, c)),
                  ),
                  // 기술 스택 뉴런 툴팁 영역
                  for (var i = 0; i < nodes.length; i++)
                    for (var j = 0; j < g.sats[i].length; j++)
                      if (_iv(t, g.satStart(i, j), g.satStart(i, j) + 0.2) >= 1)
                        Positioned(
                          left: (nodes[i] + g.sats[i][j]).dx - 11,
                          top: (nodes[i] + g.sats[i][j]).dy - 11,
                          width: 22,
                          height: 22,
                          child: Tooltip(
                            message: _projects[i].skills[j],
                            waitDuration: Duration.zero,
                            child: const MouseRegion(child: SizedBox.expand()),
                          ),
                        ),
                  // 가운데 코어
                  Positioned(
                    left: g.center.dx - g.coreR,
                    top: g.center.dy - g.coreR,
                    width: g.coreR * 2,
                    height: g.coreR * 2,
                    child: Opacity(
                      opacity: coreIn,
                      child: Transform.scale(
                        scale: 0.45 + 0.55 * coreIn,
                        child: Tooltip(
                          message: '전체 프로젝트 보기',
                          waitDuration: const Duration(milliseconds: 300),
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            onEnter: (_) => setState(() => _coreHover = true),
                            onExit: (_) => setState(() => _coreHover = false),
                            child: GestureDetector(
                              onTap: _openAll,
                              child: AnimatedScale(
                                key: _coreKey,
                                scale: _coreHover ? 1.08 : 1.0,
                                duration: const Duration(milliseconds: 240),
                                curve: Curves.easeOutBack,
                                child: _NetCore(
                                  palette: c,
                                  narrow: narrow,
                                  glow: (_coreHover ? 0.34 : 0.18) +
                                      0.14 * breath * _iv(t, 0.6, 1),
                                  textIn: _iv(t, 0.14, 0.42),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // 프로젝트 노드
                  for (var i = 0; i < nodes.length; i++)
                    ..._node(i, nodes[i], g, t, narrow, c),
                ],
              );
            },
          ),
        );
      }),
    );
  }

  List<Widget> _node(
      int i, Offset p, _NetGeometry g, double t, bool narrow, _Palette c) {
    final data = _projects[i];
    final a = 0.46 + i * 0.08;
    final pop = _iv(t, a, a + 0.26, Curves.easeOutBack);
    final fade = _iv(t, a, a + 0.14);
    final badge = _iv(t, a + 0.22, a + 0.42, Curves.easeOutBack);
    final d = g.nodeD;
    return [
      Positioned(
        left: p.dx - d / 2,
        top: p.dy - d / 2,
        width: d,
        height: d,
        child: IgnorePointer(
          ignoring: fade < 1,
          child: Opacity(
            opacity: fade,
            child: Transform.scale(
              scale: pop,
              child: _NetNode(data: data, palette: c, size: d, badgeIn: badge),
            ),
          ),
        ),
      ),
      Positioned(
        left: p.dx - 90,
        top: p.dy + d / 2 + 10,
        width: 180,
        child: IgnorePointer(
          child: Opacity(
            opacity: _iv(t, a + 0.12, a + 0.32),
            child: Column(
              children: [
                Text(data.tag,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: c.text)),
                if (!narrow)
                  Text(data.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: c.muted)),
              ],
            ),
          ),
        ),
      ),
    ];
  }
}

class _NetCore extends StatelessWidget {
  final _Palette palette;
  final bool narrow;
  final double glow, textIn;
  const _NetCore(
      {required this.palette,
      required this.narrow,
      required this.glow,
      required this.textIn});

  @override
  Widget build(BuildContext context) {
    final c = palette;
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [c.accentSoft, c.bg]),
        border: Border.all(color: c.accent.withValues(alpha: 0.55), width: 1.5),
        boxShadow: [
          BoxShadow(
              color: c.accent.withValues(alpha: glow),
              blurRadius: 48,
              spreadRadius: 2),
        ],
      ),
      child: Opacity(
        opacity: textIn,
        child: Transform.translate(
          offset: Offset(0, (1 - textIn) * 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('PROJECTS',
                  style: TextStyle(
                      fontSize: narrow ? 9 : 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                      color: c.accent)),
              const SizedBox(height: 4),
              Text('App\nWeb\nLLM',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: narrow ? 13 : 15,
                      height: 1.25,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                      color: c.text)),
            ],
          ),
        ),
      ),
    );
  }
}

class _AllProjectsPopup extends StatelessWidget {
  final _Palette palette;
  const _AllProjectsPopup({required this.palette});

  @override
  Widget build(BuildContext context) {
    final c = palette;
    void close(bool go) => Navigator.of(context).pop(go);
    return Center(
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          width: 300,
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: c.line),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25), blurRadius: 30)
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration:
                    BoxDecoration(color: c.accentSoft, shape: BoxShape.circle),
                child: Icon(Icons.grid_view_rounded, size: 19, color: c.accent),
              ),
              const SizedBox(height: 14),
              Text('전체 프로젝트',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: c.text)),
              const SizedBox(height: 6),
              Text('App · Web 구분 없이 모든 프로젝트를 한곳에서 볼 수 있어요.',
                  style: TextStyle(fontSize: 14, height: 1.6, color: c.muted)),
              const SizedBox(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                _Pill(label: '닫기', palette: c, onTap: () => close(false)),
                const SizedBox(width: 8),
                _Pill(
                    label: '보러 가기',
                    primary: true,
                    palette: c,
                    onTap: () => close(true)),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

class _NetNode extends StatelessWidget {
  final _ProjectData data;
  final _Palette palette;
  final double size, badgeIn;
  const _NetNode(
      {required this.data,
      required this.palette,
      required this.size,
      required this.badgeIn});

  @override
  Widget build(BuildContext context) {
    final c = palette;
    final b = size < 80 ? 20.0 : 24.0;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: c.surface,
              border:
                  Border.all(color: c.accent.withValues(alpha: 0.6), width: 2),
              boxShadow: [
                BoxShadow(
                    color: c.accent.withValues(alpha: 0.28), blurRadius: 24)
              ],
            ),
          ),
        ),
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: _DeviceLink(
              asset: data.image,
              tooltip: data.tooltip,
              route: data.route,
              color: c.accent,
              hoverScale: 1.1,
              radius: size,
            ),
          ),
        ),
        // 상단 우측 스토어 출시 뱃지
        if (data.released && badgeIn > 0)
          Positioned(
            top: -b * 0.2,
            right: -b * 0.7,
            child: Transform.scale(
              scale: badgeIn,
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                _StoreBadge(
                    icon: Icons.apple,
                    tooltip: 'App Store 출시',
                    palette: c,
                    size: b,
                    bg: c.text,
                    fg: c.bg),
                const SizedBox(width: 2),
                _StoreBadge(
                    icon: Icons.android,
                    tooltip: 'Google Play 출시',
                    palette: c,
                    size: b,
                    bg: const Color(0xFF3DDC84),
                    fg: const Color(0xFF073042)),
              ]),
            ),
          ),
      ],
    );
  }
}

/// 크기별로 한 번 계산해 두는 신경망 배치.
class _NetGeometry {
  final Size size;
  final Offset center;
  final double coreR, nodeD;
  final List<Offset> nodes;
  final List<List<Offset>> sats; // 프로젝트 노드 기준 상대 위치
  final List<Offset> ambient;
  final List<int> ambientLink;
  final List<double> ambientPhase, ambientR;

  _NetGeometry._(
      this.size,
      this.center,
      this.coreR,
      this.nodeD,
      this.nodes,
      this.sats,
      this.ambient,
      this.ambientLink,
      this.ambientPhase,
      this.ambientR);

  factory _NetGeometry.of(Size s, bool narrow) {
    final center = s.center(Offset.zero);
    final coreR = narrow ? 48.0 : 58.0;
    final nodeD = narrow ? 72.0 : 96.0;
    final n = _projects.length;
    // 좁은 화면은 위아래로, 넓은 화면은 좌우로 퍼진다.
    final base = narrow ? -math.pi / 2 : math.pi;
    final rx = narrow ? s.width * 0.30 : math.min(s.width * 0.30, 290.0);
    final ry = s.height * (narrow ? 0.31 : 0.27);
    final edge = Rect.fromLTWH(10, 10, s.width - 20, s.height - 20);

    final nodes = <Offset>[];
    final sats = <List<Offset>>[];
    for (var i = 0; i < n; i++) {
      final a = base + 2 * math.pi * i / n + math.pi / 9;
      final p = center + Offset(math.cos(a) * rx, math.sin(a) * ry);
      nodes.add(p);

      final dir = (p - center).direction;
      final k = _projects[i].skills.length;
      final spread = math.min(math.pi * 0.85, 0.36 * (k - 1));
      sats.add([
        for (var j = 0; j < k; j++)
          () {
            final aj = dir + (k == 1 ? 0 : (j / (k - 1) - 0.5) * spread);
            final dist = nodeD / 2 + (narrow ? 24 : 34) + (j.isOdd ? 16 : 0);
            final q = p + Offset(math.cos(aj), math.sin(aj)) * dist;
            return Offset(q.dx.clamp(edge.left, edge.right),
                    q.dy.clamp(edge.top, edge.bottom)) -
                p;
          }(),
      ]);
    }

    // 배경 뉴런: 코어·노드와 겹치지 않는 자리에 흩뿌리고 가장 가까운 이웃과 잇는다.
    final rnd = math.Random(11);
    final ambient = <Offset>[];
    for (var tries = 0;
        ambient.length < (narrow ? 16 : 26) && tries < 400;
        tries++) {
      final q = Offset(edge.left + rnd.nextDouble() * edge.width,
          edge.top + rnd.nextDouble() * edge.height);
      if ((q - center).distance < coreR * 1.5) continue;
      if (nodes.any((p) => (q - p).distance < nodeD * 1.1)) continue;
      ambient.add(q);
    }
    final link = [
      for (var i = 0; i < ambient.length; i++)
        () {
          var best = i == 0 ? 1 : 0;
          for (var j = 0; j < ambient.length; j++) {
            if (j != i &&
                (ambient[j] - ambient[i]).distance <
                    (ambient[best] - ambient[i]).distance) {
              best = j;
            }
          }
          return best;
        }(),
    ];

    return _NetGeometry._(
      s,
      center,
      coreR,
      nodeD,
      nodes,
      sats,
      ambient,
      link,
      [for (var i = 0; i < ambient.length; i++) rnd.nextDouble()],
      [for (var i = 0; i < ambient.length; i++) 1.2 + rnd.nextDouble() * 1.6],
    );
  }

  Offset float(int i, double loop) =>
      Offset(0, math.sin(2 * math.pi * (loop + i * 0.37)) * 4);

  double satStart(int i, int j) => math.min(0.62 + i * 0.06 + j * 0.02, 0.8);

  /// 코어에서 노드로 휘어 나가는 시냅스 곡선.
  Path synapse(int i, Offset to) {
    final d = to - center;
    final normal = Offset(-d.dy, d.dx) / d.distance;
    final ctrl =
        center + d / 2 + normal * d.distance * 0.18 * (i.isEven ? 1 : -1);
    return Path()
      ..moveTo(center.dx, center.dy)
      ..quadraticBezierTo(ctrl.dx, ctrl.dy, to.dx, to.dy);
  }
}

class _NetPainter extends CustomPainter {
  final _NetGeometry g;
  final List<Offset> nodes;
  final double t, loop;
  final _Palette c;
  const _NetPainter(this.g, this.nodes, this.t, this.loop, this.c);

  @override
  void paint(Canvas canvas, Size size) {
    final glow = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    // 배경 뉴런
    final amb = _iv(t, 0.35, 1);
    if (amb > 0) {
      final line = Paint()
        ..color = c.muted.withValues(alpha: 0.12 * amb)
        ..strokeWidth = 1;
      for (var i = 0; i < g.ambient.length; i++) {
        canvas.drawLine(g.ambient[i], g.ambient[g.ambientLink[i]], line);
      }
      for (var i = 0; i < g.ambient.length; i++) {
        final tw =
            0.5 + 0.5 * math.sin(2 * math.pi * (loop * 2 + g.ambientPhase[i]));
        canvas.drawCircle(
            g.ambient[i],
            g.ambientR[i],
            Paint()
              ..color = c.muted.withValues(alpha: (0.18 + 0.3 * tw) * amb));
      }
    }

    // 코어 파문: 등장 시 한 번 크게, 이후 루프마다 잔잔하게
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final rp = _iv(t, 0.04, 0.6, Curves.easeOut);
    if (rp > 0 && rp < 1) {
      canvas.drawCircle(g.center, g.coreR * (1 + 1.5 * rp),
          ring..color = c.accent.withValues(alpha: 0.4 * (1 - rp)));
    }
    final settled = _iv(t, 0.7, 1);
    if (settled > 0) {
      final lr = (loop * 2) % 1;
      canvas.drawCircle(g.center, g.coreR * (1 + 0.6 * lr),
          ring..color = c.accent.withValues(alpha: 0.2 * (1 - lr) * settled));
    }

    for (var i = 0; i < nodes.length; i++) {
      final p = nodes[i];

      // 코어 → 프로젝트 시냅스
      final metric = g.synapse(i, p).computeMetrics().first;
      final grow =
          _iv(t, 0.22 + i * 0.08, 0.56 + i * 0.08, Curves.easeInOutCubic);
      if (grow > 0) {
        canvas.drawPath(
          metric.extractPath(0, metric.length * grow),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.6
            ..strokeCap = StrokeCap.round
            ..shader = LinearGradient(colors: [
              c.accent.withValues(alpha: 0.75),
              c.accent.withValues(alpha: 0.3),
            ]).createShader(Rect.fromPoints(g.center, p)),
        );
        // 뻗어 나가는 끝의 빛
        if (grow < 1) {
          final tip =
              metric.getTangentForOffset(metric.length * grow)!.position;
          canvas.drawCircle(
              tip, 7, glow..color = c.accent.withValues(alpha: 0.6));
          canvas.drawCircle(tip, 2.5, Paint()..color = c.accent);
        }
      }
      // 시냅스를 따라 흐르는 신호
      if (settled > 0) {
        for (final off in const [0.0, 0.5]) {
          final f = (loop * 1.5 + i * 0.3 + off) % 1;
          final pos = metric.getTangentForOffset(metric.length * f)!.position;
          final a = math.sin(math.pi * f) * settled;
          canvas.drawCircle(
              pos, 6, glow..color = c.accent.withValues(alpha: 0.45 * a));
          canvas.drawCircle(
              pos, 2.2, Paint()..color = c.accent.withValues(alpha: a));
        }
      }

      // 프로젝트 → 기술 스택 뉴런
      for (var j = 0; j < g.sats[i].length; j++) {
        final s0 = g.satStart(i, j);
        final sp = _iv(t, s0, s0 + 0.2);
        if (sp <= 0) continue;
        final to = p + g.sats[i][j];
        canvas.drawLine(
            p,
            Offset.lerp(p, to, sp)!,
            Paint()
              ..color = c.accent.withValues(alpha: 0.28)
              ..strokeWidth = 1);
        final dot = _iv(t, s0 + 0.12, s0 + 0.2, Curves.easeOutBack);
        if (dot > 0) {
          canvas.drawCircle(
              to, 7 * dot, glow..color = c.accent.withValues(alpha: 0.25));
          canvas.drawCircle(
              to, 3.6 * dot, Paint()..color = c.accent.withValues(alpha: 0.85));
        }
        if (settled > 0) {
          final f = (loop * 2 + j * 0.23 + i * 0.5) % 1;
          final a = math.sin(math.pi * f) * settled * 0.8;
          canvas.drawCircle(Offset.lerp(p, to, f)!, 1.8,
              Paint()..color = c.accent.withValues(alpha: a));
        }
      }
    }
  }

  @override
  bool shouldRepaint(_NetPainter old) => true;
}

/// 타일이 화면에 들어오면 한 번만 아래로 부드럽게 펼쳐지며 스크린샷을 보여준다.
class _ScreenGallery extends StatelessWidget {
  final List<String> screens;
  final int cols;
  final bool open;
  const _ScreenGallery(
      {required this.screens, required this.cols, required this.open});

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeInOutCubic,
      alignment: Alignment.topCenter,
      child: open
          ? _grid(context)
          : const SizedBox(width: double.infinity, height: 0),
    );
  }

  Widget _grid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 28),
      child: LayoutBuilder(builder: (context, box) {
        const gap = 12.0;
        final cols = box.maxWidth < 520 ? (this.cols + 1) ~/ 2 : this.cols;
        final w = (box.maxWidth - gap * (cols - 1)) / cols / 2;
        final dpr = MediaQuery.devicePixelRatioOf(context);
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            // 한 줄만 보여준다.
            for (var i = 0; i < screens.length && i < cols; i++)
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: Duration(milliseconds: 600 + i * 120),
                curve: Curves.easeOut,
                builder: (context, t, child) => Opacity(
                  opacity: t,
                  child: Transform.translate(
                      offset: Offset(0, (1 - t) * 24), child: child),
                ),
                child: SizedBox(
                  width: w,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(screens[i],
                        cacheWidth: (w * dpr).round(), fit: BoxFit.fitWidth),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }
}

class _Skills extends StatelessWidget {
  final _Palette palette;
  const _Skills({required this.palette});

  static const _rows = [
    ('Framework', 'Flutter · Flutter Web · Riverpod'),
    (
      'AI',
      'AWS Bedrock (Serverless) · RAG · Text Embedding · Vector Search · LLM Intent Classification'
    ),
    ('Realtime', 'WebSocket 채팅 · Firebase Cloud Messaging'),
    ('Backend', 'REST API 설계·개발 · 역할 기반 권한'),
    ('Payment', 'PortOne 구독 결제'),
    ('Release', 'App Store · Google Play 출시'),
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
