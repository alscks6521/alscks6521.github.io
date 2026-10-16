import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:github_portfolio/features/home/domain/entities/featured_project.dart';

double netInterval(double t, double a, double b,
        [Curve curve = Curves.easeOutCubic]) =>
    curve.transform(((t - a) / (b - a)).clamp(0.0, 1.0));

/// 크기별로 한 번 계산해 두는 신경망 배치.
class NetGeometry {
  final Size size;
  final Offset center;
  final double coreR, nodeD;
  final List<Offset> nodes;
  final List<List<Offset>> sats; // 프로젝트 노드 기준 상대 위치
  final List<Offset> ambient;
  final List<int> ambientLink;
  final List<double> ambientPhase, ambientR;

  NetGeometry._(
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

  factory NetGeometry.of(Size s, bool narrow, List<FeaturedProject> projects) {
    final center = s.center(Offset.zero);
    final coreR = narrow ? 48.0 : 58.0;
    final nodeD = narrow ? 72.0 : 96.0;
    final n = projects.length;
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
      final k = projects[i].skills.length;
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

    return NetGeometry._(
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
