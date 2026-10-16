import 'package:flutter/material.dart';
import 'package:github_portfolio/features/home/presentation/theme/home_palette.dart';

class HomeNavBar extends StatelessWidget {
  final HomePalette palette;
  final double hPad;
  final VoidCallback onLogo, onAbout, onProjects, onSkills, onToggleTheme;
  final bool isLight;
  const HomeNavBar({
    super.key,
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
  final HomePalette palette;
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
