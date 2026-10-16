import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:github_portfolio/app/di/app_dependencies.dart';
import 'package:github_portfolio/app/di/dependency_scope.dart';
import 'package:github_portfolio/core/constants/app_assets.dart';
import 'package:github_portfolio/features/star/domain/entities/vote_result.dart';

class StarBadge extends StatefulWidget {
  final double starSize;
  const StarBadge({super.key, required this.starSize});

  @override
  State<StarBadge> createState() => _StarBadgeState();
}

class _Puff {
  final int id;
  final String text;
  const _Puff(this.id, this.text);
}

class _StarBadgeState extends State<StarBadge> {
  late final AppDependencies _deps = DependencyScope.of(context);

  int? _total;
  bool _voted = false;
  bool _busy = false;
  bool _squish = false;
  bool _loaded = false;
  int _puffId = 0;
  DateTime _lastTap = DateTime.fromMillisecondsSinceEpoch(0);
  final _puffs = <_Puff>[];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    _deps.hasVotedStar().then((v) {
      if (mounted) setState(() => _voted = v);
    });
    _deps.getStarCount().then((v) {
      if (mounted && v != null) setState(() => _total = v);
    });
  }

  void _puff(String text) => setState(() => _puffs.add(_Puff(_puffId++, text)));

  void _bounce() {
    setState(() => _squish = true);
    Future.delayed(const Duration(milliseconds: 110), () {
      if (mounted) setState(() => _squish = false);
    });
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

    // 화면은 먼저 +1 해 두고(낙관적 업데이트), 실패하면 되돌린다.
    final r = await _deps.voteStar();
    _busy = false;
    if (!mounted) return;
    if (r.status == VoteStatus.ok) {
      setState(() => _total = r.count ?? before + 1);
    } else {
      setState(() {
        _total = before;
        _voted = false;
      });
    }
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
