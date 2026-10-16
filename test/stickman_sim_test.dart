import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:github_portfolio/features/stickman/domain/stickman_sim.dart';

void main() {
  const h = 1 / 120;
  const plats = [
    Plat(#a, Rect.fromLTWH(40, 300, 300, 60)),
    Plat(#b, Rect.fromLTWH(200, 520, 400, 40)),
    Plat(#c, Rect.fromLTWH(60, 900, 500, 80)),
  ];

  World world(double top, double step) => World(
      plats: plats,
      width: 800,
      top: top,
      bottom: top + 700,
      wallStep: step,
      dt: h);

  void run(StickmanSim sim, double seconds, double Function(int) topAt) {
    final n = (seconds / h).round();
    var prevTop = topAt(0);
    for (var i = 0; i < n; i++) {
      final top = topAt(i);
      sim.followPlatforms(plats);
      sim.step(world(top, top - prevTop));
      prevTop = top;
      for (final p in sim.pts) {
        expect(p.dx.isFinite && p.dy.isFinite, isTrue);
        expect(p.dx, inInclusiveRange(-1, 801));
        expect(p.dy, inInclusiveRange(top - 1, top + 701));
      }
    }
  }

  test('spawns, settles, and comes alive standing on something', () {
    final sim = StickmanSim()..spawn(world(0, 0));
    run(sim, 8, (_) => 0);
    expect(sim.mode, isNot(Mode.ragdoll));
  });

  test('scrolling down drags it along and it stays inside the viewport', () {
    final sim = StickmanSim()..spawn(world(0, 0));
    run(sim, 6, (_) => 0);
    // 2초 동안 0 → 600 스크롤 후 멈춤
    run(sim, 2, (i) => (i * h / 2).clamp(0, 1) * 600);
    run(sim, 8, (_) => 600);
    expect(sim.mode, isNot(Mode.ragdoll));
  });

  for (final dir in [-1.0, 1.0]) {
    test('fast scroll ${dir < 0 ? 'up' : 'down'} does not fling it', () {
      final start = dir < 0 ? 600.0 : 0.0;
      final sim = StickmanSim()..spawn(world(start, 0));
      run(sim, 6, (_) => start);
      // 0.3초 동안 1800px/s로 스크롤
      final n = (0.3 / h).round();
      run(sim, 0.3,
          (i) => (start + dir * math.min(i + 1, n) * 15.0).clamp(0, 600));
      final end = (start + dir * n * 15.0).clamp(0.0, 600.0);
      // 스크롤이 멈춘 뒤 위로 솟구치지 않아야 한다
      final headAtStop = sim.pts[0].dy;
      var highest = headAtStop;
      final m = (1.0 / h).round();
      for (var i = 0; i < m; i++) {
        sim.followPlatforms(plats);
        sim.step(world(end, 0));
        highest = math.min(highest, sim.pts[0].dy);
      }
      expect(headAtStop - highest, lessThan(40));
    });
  }
}
