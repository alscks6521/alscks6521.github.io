import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:github_portfolio/app/di/dependency_scope.dart';
import 'package:github_portfolio/features/home/domain/entities/skill_group.dart';
import 'package:github_portfolio/features/stickman/presentation/stickman_arena.dart';
import 'package:github_portfolio/core/widgets/reveal.dart';
import 'package:github_portfolio/features/home/domain/entities/featured_project.dart';
import 'package:github_portfolio/features/home/presentation/theme/home_palette.dart';
import 'package:github_portfolio/features/home/presentation/widgets/about_section.dart';
import 'package:github_portfolio/features/home/presentation/widgets/hero_section.dart';
import 'package:github_portfolio/features/home/presentation/widgets/home_nav_bar.dart';
import 'package:github_portfolio/features/home/presentation/widgets/projects_section.dart';
import 'package:github_portfolio/features/home/presentation/widgets/skills_section.dart';

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
  late List<FeaturedProject> _projects;
  late List<SkillGroup> _skills;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final deps = DependencyScope.of(context);
    _projects = deps.getFeaturedProjects();
    _skills = deps.getSkills();
  }

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
        final c = HomePalette.lerp(HomePalette.dark, HomePalette.light, t);
        return _buildPage(c, narrow, hPad);
      },
    );
  }

  Widget _buildPage(HomePalette c, bool narrow, double hPad) {
    return Scaffold(
      backgroundColor: c.bg,
      body: Column(
        children: [
          HomeNavBar(
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
            child: StickmanArena(
              controller: _scroll,
              ink: c.text,
              paper: c.bg,
              accent: c.accent,
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
                            Reveal(
                                child: HeroSection(
                                    palette: c,
                                    narrow: narrow,
                                    onProjects: () => _goTo(_projectsKey))),
                            SizedBox(key: _aboutKey, height: narrow ? 72 : 96),
                            Reveal(child: AboutSection(palette: c)),
                            SizedBox(key: _skillsKey, height: narrow ? 72 : 96),
                            Reveal(
                                child:
                                    SkillsSection(palette: c, skills: _skills)),
                            SizedBox(
                                key: _projectsKey, height: narrow ? 72 : 96),
                            Reveal(
                                child: ProjectsSection(
                                    palette: c, projects: _projects)),
                            const SizedBox(height: 120),
                            Divider(height: 1, color: c.line),
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 32, bottom: 48),
                              child: StickmanSolid(
                                child: Text(
                                  '© 2026 Minsung Kim · 방문해주셔서 감사합니다.',
                                  style:
                                      TextStyle(fontSize: 14, color: c.muted),
                                ),
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
