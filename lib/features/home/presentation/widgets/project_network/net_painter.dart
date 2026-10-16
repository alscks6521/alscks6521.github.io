import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:github_portfolio/features/home/presentation/theme/home_palette.dart';
import 'package:github_portfolio/features/home/presentation/widgets/project_network/net_geometry.dart';

class NetPainter extends CustomPainter {
  final NetGeometry g;
  final List<Offset> nodes;
  final double t, loop;
  final HomePalette c;
  const NetPainter(this.g, this.nodes, this.t, this.loop, this.c);

  @override
  void paint(Canvas canvas, Size size) {
    final glow = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    // 배경 뉴런
    final amb = netInterval(t, 0.35, 1);
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
    final rp = netInterval(t, 0.04, 0.6, Curves.easeOut);
    if (rp > 0 && rp < 1) {
      canvas.drawCircle(g.center, g.coreR * (1 + 1.5 * rp),
          ring..color = c.accent.withValues(alpha: 0.4 * (1 - rp)));
    }
    final settled = netInterval(t, 0.7, 1);
    if (settled > 0) {
      final lr = (loop * 2) % 1;
      canvas.drawCircle(g.center, g.coreR * (1 + 0.6 * lr),
          ring..color = c.accent.withValues(alpha: 0.2 * (1 - lr) * settled));
    }

    for (var i = 0; i < nodes.length; i++) {
      final p = nodes[i];

      // 코어 → 프로젝트 시냅스
      final metric = g.synapse(i, p).computeMetrics().first;
      final grow = netInterval(
          t, 0.22 + i * 0.08, 0.56 + i * 0.08, Curves.easeInOutCubic);
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
        final sp = netInterval(t, s0, s0 + 0.2);
        if (sp <= 0) continue;
        final to = p + g.sats[i][j];
        canvas.drawLine(
            p,
            Offset.lerp(p, to, sp)!,
            Paint()
              ..color = c.accent.withValues(alpha: 0.28)
              ..strokeWidth = 1);
        final dot = netInterval(t, s0 + 0.12, s0 + 0.2, Curves.easeOutBack);
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
  bool shouldRepaint(NetPainter old) => true;
}
