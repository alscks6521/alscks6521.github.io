import 'dart:math' as math;
import 'dart:ui';

/// 졸라맨이 올라설 수 있는 발판 (콘텐츠 좌표계). [key]로 같은 위젯을 프레임 간 추적한다.
class Plat {
  final Object key;
  final Rect rect;
  const Plat(this.key, this.rect);
}

/// 한 스텝 동안의 세계 상태. 모든 좌표는 스크롤 콘텐츠 기준.
/// 브라우저(뷰포트)는 [top]~[bottom] 사이의 움직이는 상자다.
class World {
  final List<Plat> plats;
  final double width, top, bottom;
  final double wallStep; // 이번 서브스텝에서 벽이 움직인 거리 (+ 아래)
  final double dt;
  const World({
    required this.plats,
    required this.width,
    required this.top,
    required this.bottom,
    required this.wallStep,
    required this.dt,
  });
}

enum Mode { alive, ragdoll, getUp }

enum Act { idle, walk, crouch, air, land, sit, dance, look, dizzy, dust }

// 관절 인덱스
const _head = 0, _neck = 1, _pelvis = 2;
const _lElbow = 3, _lHand = 4, _rElbow = 5, _rHand = 6;
const _lKnee = 7, _lFoot = 8, _rKnee = 9, _rFoot = 10;

/// 뼈대 (a, b, 길이)
const bones = [
  (_head, _neck, 11.0),
  (_neck, _pelvis, 20.0),
  (_neck, _lElbow, 12.0),
  (_lElbow, _lHand, 11.0),
  (_neck, _rElbow, 12.0),
  (_rElbow, _rHand, 11.0),
  (_pelvis, _lKnee, 14.0),
  (_lKnee, _lFoot, 14.0),
  (_pelvis, _rKnee, 14.0),
  (_rKnee, _rFoot, 14.0),
];

// 래그돌이 너무 접히지 않게 잡아주는 보조 제약 (느슨하게)
const _braces = [
  (_head, _pelvis, 30.0),
  (_lFoot, _rFoot, 6.0),
];

const headR = 8.0;
const _height = 67.0; // 발끝~머리끝
const _g = 2200.0;
const _floorKey = #floor;

class StickmanSim {
  final _rng = math.Random();

  Mode mode = Mode.ragdoll;
  Act act = Act.air;
  double actT = 0, actDur = 0;

  /// 살아있을 때 기준점 = 두 발 사이 바닥
  Offset pos = Offset.zero;
  Offset vel = Offset.zero;
  double facing = 1;
  Object? ground;
  Rect? _groundRect;

  double _walkTo = 0, _walkSpeed = 70;
  bool _walkThenSit = false;
  Offset _jumpVel = Offset.zero;
  double _phase = 0, t = 0;
  double _ghost = 0; // >0 이면 발판을 통과 (벽에 밀려 끌려가는 중)
  double _settle = 0, _ragT = 0, _maxImpact = 0;

  List<Offset> pts = List.filled(11, Offset.zero);
  List<Offset> _prev = List.filled(11, Offset.zero);
  List<Offset> _snap = const [];

  String? bubble;
  double bubbleT = 0;
  bool spawned = false;

  bool get dizzy => act == Act.dizzy && mode == Mode.alive;

  void spawn(World w) {
    spawned = true;
    pos = Offset(w.width * (0.6 + _rng.nextDouble() * 0.25), w.top + 90);
    pts = [for (final p in _pose(Act.air, 0)) p + pos];
    _toRagdoll(Offset(-120 - _rng.nextDouble() * 120, -200), spin: 5, dt: w.dt);
  }

  // ───────────────────────────── 공개 입력

  /// 프레임마다 한 번: 서 있는 발판이 움직였으면 (리사이즈·둥실 애니메이션) 같이 이동.
  void followPlatforms(List<Plat> plats) {
    if (ground == null || ground == _floorKey) return;
    final p = _find(plats, ground!);
    if (p == null) {
      _becomeAirborne();
      return;
    }
    final old = _groundRect;
    _groundRect = p.rect;
    if (old == null || mode == Mode.ragdoll) return;
    final d = p.rect.topLeft - old.topLeft;
    if (d.distanceSquared < 40 * 40) pos += d;
  }

  bool hit(Offset p) {
    for (final q in pts) {
      if ((q - p).distance < 16) return true;
    }
    return false;
  }

  void poke(Offset from, double dt) {
    final c = pts[_neck];
    var d = c - from;
    if (d.distance < 1) d = const Offset(0, -1);
    d = d / d.distance;
    final v = Offset(d.dx * 520, math.min(-380.0, d.dy * 520));
    if (mode != Mode.ragdoll) {
      _toRagdoll(v, spin: (_rng.nextDouble() - 0.5) * 16, dt: dt);
    } else {
      for (var i = 0; i < pts.length; i++) {
        _prev[i] = pts[i] - v * dt;
      }
    }
    _say('!', 0.8);
  }

  // ───────────────────────────── 스텝

  void step(World w) {
    t += w.dt;
    if (_ghost > 0) _ghost -= w.dt;
    if (bubbleT > 0) {
      bubbleT -= w.dt;
      if (bubbleT <= 0) bubble = null;
    }
    switch (mode) {
      case Mode.alive:
        _stepAlive(w);
        if (mode == Mode.alive) {
          pts = [for (final p in _pose(act, actT)) p + pos];
        }
      case Mode.ragdoll:
        _stepRagdoll(w);
      case Mode.getUp:
        _stepGetUp(w);
    }
  }

  // ───────────────────────────── 살아있는 상태

  void _stepAlive(World w) {
    final dt = w.dt;
    actT += dt;
    final grounded = ground != null;

    if (grounded) {
      // 발판 지지 확인
      if (ground == _floorKey) {
        // 바닥이 올라오거나 천천히 내려가면 엘리베이터처럼 따라간다
        if (w.wallStep < 6) pos = Offset(pos.dx, w.bottom);
        if (pos.dy < w.bottom - 2) _becomeAirborne();
      } else {
        final r = _groundRect;
        if (r == null || pos.dx < r.left - 4 || pos.dx > r.right + 4) {
          _becomeAirborne();
        } else {
          pos = Offset(pos.dx, r.top);
        }
      }
    }

    if (ground != null) {
      _think(w);
    } else {
      // 공중
      final prevY = pos.dy;
      vel = Offset(vel.dx, vel.dy + _g * dt);
      pos += vel * dt;
      if (act != Act.air) _setAct(Act.air, 0);
      if (vel.dy > 0 && _ghost <= 0) {
        Plat? best;
        for (final p in w.plats) {
          final r = p.rect;
          if (prevY <= r.top + 0.5 &&
              pos.dy >= r.top &&
              pos.dx >= r.left &&
              pos.dx <= r.right &&
              (best == null || r.top < best.rect.top)) {
            best = p;
          }
        }
        if (best != null) _land(best.key, best.rect, w);
      }
    }

    // 좌우 벽
    if (pos.dx < 6 || pos.dx > w.width - 6) {
      pos = Offset(pos.dx.clamp(6, w.width - 6), pos.dy);
      if (ground == null) vel = Offset(-vel.dx * 0.4, vel.dy);
      if (act == Act.walk) _setAct(Act.idle, 0.6);
    }

    // 위쪽 벽: 아래로 스크롤하면 내려와서 머리를 밀고, 발판을 통과해 끌려 내려간다.
    // 벽의 속도는 물려받지 않는다 (날아가지 않게).
    // 팔을 들어 올린 자세면 손끝이 머리보다 높을 수 있다
    var reach = -_height;
    for (final p in _pose(act, actT)) {
      reach = math.min(reach, p.dy - 2);
    }
    final headTop = pos.dy + reach;
    if (headTop < w.top) {
      pos = Offset(pos.dx, pos.dy + (w.top - headTop));
      _becomeAirborne();
      _ghost = 0.25;
      vel = Offset(vel.dx, math.max(vel.dy, 0));
    }

    // 아래쪽 벽(바닥): 위로 스크롤하면 바닥을 타고 같이 올라간다
    if (pos.dy > w.bottom) {
      pos = Offset(pos.dx, w.bottom);
      if (ground == null) {
        _land(_floorKey, null, w);
      } else {
        ground = _floorKey;
        _groundRect = null;
      }
    }
  }

  void _land(Object key, Rect? r, World w) {
    final impact = vel.dy;
    ground = key;
    _groundRect = r;
    if (r != null) pos = Offset(pos.dx, r.top);
    if (impact > 1150) {
      // 너무 세게 떨어지면 그 자리에서 털썩 넘어진다 (튀어오르지 않음)
      _toRagdoll(Offset(vel.dx * 0.5, -math.min(impact * 0.08, 120.0)),
          spin: (_rng.nextDouble() - 0.5) * 12, dt: w.dt);
      return;
    }
    vel = Offset.zero;
    _setAct(Act.land, 0.14);
  }

  void _becomeAirborne() {
    ground = null;
    _groundRect = null;
    if (mode == Mode.alive && act != Act.air) {
      vel = Offset(act == Act.walk ? facing * _walkSpeed : 0, 0);
      _setAct(Act.air, 0);
    }
  }

  void _setAct(Act a, double dur) {
    act = a;
    actT = 0;
    actDur = dur;
  }

  void _say(String s, double secs) {
    bubble = s;
    bubbleT = secs;
  }

  // ───────────────────────────── 자아 (상태 머신)

  void _think(World w) {
    final dt = w.dt;

    switch (act) {
      case Act.walk:
        final d = _walkTo - pos.dx;
        if (d.abs() < 2) {
          if (_walkThenSit) {
            _walkThenSit = false;
            // 모서리 바깥쪽을 보고 앉아서 다리를 늘어뜨린다
            final r = _groundRect;
            if (r != null) facing = pos.dx < r.center.dx ? -1 : 1;
            _setAct(Act.sit, 3 + _rng.nextDouble() * 5);
            if (_rng.nextDouble() < 0.4) _say('~', 1.4);
          } else {
            _setAct(Act.idle, 0.6 + _rng.nextDouble() * 1.4);
          }
          return;
        }
        facing = d.sign;
        _phase += dt * _walkSpeed * 0.105;
        pos = Offset(
            pos.dx + facing * math.min(_walkSpeed * dt, d.abs()), pos.dy);
        return;
      case Act.crouch:
        if (actT > 0.17) {
          vel = _jumpVel;
          ground = null;
          _groundRect = null;
          _setAct(Act.air, 0);
        }
        return;
      case Act.look:
        // 두리번두리번
        facing = (actT * 1.25).floor().isOdd ? -1 : 1;
      default:
    }

    if (actT < actDur) return;
    _decide(w);
  }

  void _decide(World w) {
    final options = <(double, void Function())>[];
    final onFloor = ground == _floorKey;
    final r = _groundRect;
    final minX = r == null ? 20.0 : r.left + 6;
    final maxX = r == null ? w.width - 20 : r.right - 6;

    options.add((1.6, () => _setAct(Act.idle, 0.8 + _rng.nextDouble() * 2)));
    options.add((1.0, () => _setAct(Act.look, 1.6 + _rng.nextDouble())));
    if (maxX - minX > 30) {
      options.add((
        3.0,
        () {
          _walkTo = minX + _rng.nextDouble() * (maxX - minX);
          _walkSpeed = 55 + _rng.nextDouble() * 50;
          _walkThenSit = false;
          _setAct(Act.walk, 0);
        }
      ));
    }
    if (r != null && r.width > 50) {
      options.add((
        1.1,
        () {
          // 화면 안에 있는 모서리로 걸어가서 걸터앉기
          final left = _rng.nextBool();
          var edge = left ? r.left + 5 : r.right - 5;
          if (edge < 20 || edge > w.width - 20) {
            edge = left ? r.right - 5 : r.left + 5;
          }
          _walkTo = edge;
          _walkSpeed = 70;
          _walkThenSit = true;
          _setAct(Act.walk, 0);
        }
      ));
    }
    final jump = _pickJump(w);
    if (jump != null) options.add((onFloor ? 4.0 : 2.6, jump));
    options.add((0.35, () => _setAct(Act.dance, 2.4)));

    final total = options.fold<double>(0, (s, o) => s + o.$1);
    var roll = _rng.nextDouble() * total;
    for (final o in options) {
      roll -= o.$1;
      if (roll <= 0) {
        o.$2();
        return;
      }
    }
  }

  void Function()? _pickJump(World w) {
    final cands = <(Plat, double)>[];
    for (final p in w.plats) {
      if (p.key == ground) continue;
      final r = p.rect;
      if (r.width < 24) continue;
      // 착지했을 때 머리까지 화면 안에 들어와야 함
      if (r.top - _height < w.top + 8 || r.top > w.bottom - 4) continue;
      final lx = (pos.dx).clamp(r.left + 12, r.right - 12);
      final dx = (lx - pos.dx).abs();
      final up = pos.dy - r.top;
      if (dx > 230 || up > 170) continue;
      cands.add((p, lx));
    }
    if (cands.isEmpty) return null;
    final (p, lx0) = cands[_rng.nextInt(cands.length)];
    return () {
      final r = p.rect;
      final lx = (lx0 + (_rng.nextDouble() - 0.5) * 60)
          .clamp(r.left + 10, r.right - 10)
          .toDouble();
      final apex = math.min(pos.dy, r.top) - 30 - _rng.nextDouble() * 40;
      final h1 = pos.dy - apex, h2 = r.top - apex;
      final t1 = math.sqrt(2 * h1 / _g), t2 = math.sqrt(2 * h2 / _g);
      final vx = ((lx - pos.dx) / (t1 + t2)).clamp(-420.0, 420.0);
      _jumpVel = Offset(vx, -math.sqrt(2 * _g * h1));
      if (vx.abs() > 5) facing = vx.sign;
      _setAct(Act.crouch, 0);
    };
  }

  // ───────────────────────────── 래그돌 (Verlet)

  void _toRagdoll(Offset v, {double spin = 0, required double dt}) {
    mode = Mode.ragdoll;
    ground = null;
    _groundRect = null;
    _settle = 0;
    _ragT = 0;
    _maxImpact = v.distance;
    final c = pts[_pelvis];
    _prev = [
      for (final p in pts)
        p - (v + Offset(-(p.dy - c.dy), p.dx - c.dx) * spin) * dt,
    ];
  }

  void _stepRagdoll(World w) {
    final dt = w.dt;
    _ragT += dt;
    final pre = <Offset>[];
    for (var i = 0; i < pts.length; i++) {
      final v = (pts[i] - _prev[i]) * 0.996;
      pre.add(v);
      _prev[i] = pts[i];
      pts[i] = pts[i] + v + Offset(0, _g * dt * dt);
    }

    var pushedByWall = false;
    for (var it = 0; it < 8; it++) {
      for (final (a, b, len) in bones) {
        _solve(a, b, len, 1);
      }
      for (final (a, b, len) in _braces) {
        _solve(a, b, len, 0.08, minOnly: b != _pelvis);
      }
      for (var i = 0; i < pts.length; i++) {
        if (_collide(i, w)) pushedByWall = true;
      }
    }
    if (pushedByWall) _ghost = 0.25;

    // 바닥/발판에서 튕김과 마찰
    var speed = 0.0;
    for (var i = 0; i < pts.length; i++) {
      final v = pts[i] - _prev[i];
      final r = i == _head ? headR : 2.0;
      final onFloor = pts[i].dy + r >= w.bottom - 0.5;
      final onPlat = !onFloor && _ghost <= 0 && _onPlatTop(pts[i], r, w);
      if (onFloor || onPlat) {
        final into = pre[i].dy;
        final bounceY = into > 1.5 ? -into * 0.3 : 0.0;
        _prev[i] = Offset(pts[i].dx - v.dx * 0.8, pts[i].dy - bounceY);
      }
      speed += (pts[i] - _prev[i]).distance / dt;
    }
    speed /= pts.length;
    _maxImpact = math.max(_maxImpact, speed);

    if (speed < 28 && _ghost <= 0) {
      _settle += dt;
    } else {
      _settle = 0;
    }
    if (_settle > 0.45 || _ragT > 5) _startGetUp(w);
  }

  void _solve(int a, int b, double len, double k, {bool minOnly = false}) {
    final d = pts[b] - pts[a];
    final dist = d.distance;
    if (dist < 0.0001) return;
    if (minOnly && dist > len) return;
    final diff = (dist - len) / dist * 0.5 * k;
    pts[a] += d * diff;
    pts[b] -= d * diff;
  }

  /// 위치 충돌. 움직이는 위/아래 벽에 밀렸으면 true.
  bool _collide(int i, World w) {
    final r = i == _head ? headR : 2.0;
    var p = pts[i];
    var pushed = false;
    if (p.dx < r) p = Offset(r, p.dy);
    if (p.dx > w.width - r) p = Offset(w.width - r, p.dy);
    // 위/아래 벽에 밀리면 위치만 옮기고 세로 속도는 없앤다 (벽 속도로 날아가지 않게)
    if (p.dy - r < w.top) {
      p = Offset(p.dx, w.top + r);
      _prev[i] = Offset(_prev[i].dx, p.dy);
      if (w.wallStep > 0.5) pushed = true;
    }
    if (p.dy + r > w.bottom) {
      p = Offset(p.dx, w.bottom - r);
      if (w.wallStep < -0.5) {
        _prev[i] = Offset(_prev[i].dx, p.dy);
        pushed = true;
      }
    }
    if (_ghost <= 0 && !pushed) {
      final prevY = _prev[i].dy + r;
      for (final pl in w.plats) {
        final rc = pl.rect;
        if (prevY <= rc.top + 1 &&
            p.dy + r > rc.top &&
            p.dx >= rc.left &&
            p.dx <= rc.right) {
          p = Offset(p.dx, rc.top - r);
          break;
        }
      }
    }
    pts[i] = p;
    return pushed;
  }

  bool _onPlatTop(Offset p, double r, World w) {
    for (final pl in w.plats) {
      final rc = pl.rect;
      if ((p.dy + r - rc.top).abs() < 0.8 &&
          p.dx >= rc.left &&
          p.dx <= rc.right) {
        return true;
      }
    }
    return false;
  }

  void _startGetUp(World w) {
    var lowest = -double.infinity;
    for (var i = 0; i < pts.length; i++) {
      lowest = math.max(lowest, pts[i].dy + (i == _head ? headR : 2));
    }
    pos = Offset(pts[_pelvis].dx.clamp(8, w.width - 8), lowest);
    final side = pts[_head].dx - pts[_pelvis].dx;
    if (side.abs() > 2) facing = side.sign;
    vel = Offset.zero;

    ground = null;
    _groundRect = null;
    if ((lowest - w.bottom).abs() < 3) {
      ground = _floorKey;
      pos = Offset(pos.dx, w.bottom);
    } else {
      for (final p in w.plats) {
        if ((p.rect.top - lowest).abs() < 3 &&
            pos.dx >= p.rect.left - 2 &&
            pos.dx <= p.rect.right + 2) {
          ground = p.key;
          _groundRect = p.rect;
          pos = Offset(pos.dx.clamp(p.rect.left, p.rect.right), p.rect.top);
          break;
        }
      }
    }
    _snap = List.of(pts);
    mode = Mode.getUp;
    actT = 0;
  }

  void _stepGetUp(World w) {
    actT += w.dt;
    final k = _easeInOut(math.min(1, actT / 0.55));
    final target = [for (final p in _pose(Act.idle, 0)) p + pos];
    pts = [
      for (var i = 0; i < pts.length; i++) Offset.lerp(_snap[i], target[i], k)!,
    ];
    if (actT >= 0.55) {
      mode = Mode.alive;
      if (_maxImpact > 700) {
        _setAct(Act.dizzy, 1.6);
        _say('@_@', 1.4);
      } else {
        _setAct(Act.dust, 0.8);
      }
      if (ground == null) _becomeAirborne();
    }
  }

  // ───────────────────────────── 포즈

  List<Offset> _pose(Act a, double at) {
    final tt = t;
    switch (a) {
      case Act.walk:
        final s = math.sin(_phase), c = math.cos(_phase);
        return _build(
          lean: 0.1,
          la: (-0.45 * s, 0.35),
          ra: (0.45 * s, 0.35),
          ll: (0.5 * s, -0.9 * math.max(0, c)),
          rl: (-0.5 * s, -0.9 * math.max(0, -c)),
        );
      case Act.crouch:
        return _build(
          lean: 0.35,
          la: (-0.9, 0.3),
          ra: (-0.8, 0.3),
          ll: (1.0, -1.9),
          rl: (0.9, -1.8),
        );
      case Act.land:
        return _build(
          lean: 0.25,
          la: (0.6, 0.4),
          ra: (-0.5, 0.4),
          ll: (0.7, -1.3),
          rl: (0.6, -1.2),
        );
      case Act.air:
        if (vel.dy < 0) {
          return _build(
            lean: 0.1,
            la: (2.6, 0.2),
            ra: (2.4, 0.3),
            ll: (0.9, -1.4),
            rl: (0.2, -0.6),
          );
        }
        return _build(
          lean: -0.1,
          la: (2.3 + 0.6 * math.sin(tt * 20), 0.4),
          ra: (2.0 + 0.6 * math.cos(tt * 18), 0.4),
          ll: (0.4 + 0.4 * math.sin(tt * 14), -0.5),
          rl: (-0.2 + 0.4 * math.cos(tt * 14), -0.6),
        );
      case Act.sit:
        return _build(
          align: false,
          py: -2,
          lean: -0.15,
          tilt: 0.15 * math.sin(tt * 0.9),
          la: (-0.7, 0.2),
          ra: (-0.5, 0.1),
          ll: (math.pi / 2 - 0.05, -math.pi / 2 + 0.3 * math.sin(tt * 3)),
          rl: (math.pi / 2 + 0.05, -math.pi / 2 + 0.3 * math.sin(tt * 3 + 1.6)),
        );
      case Act.dance:
        final s = math.sin(tt * 8);
        return _build(
          lean: 0.15 * math.sin(tt * 4),
          tilt: 0.2 * s,
          la: (2.8 + 0.3 * s, 0.6),
          ra: (2.8 - 0.3 * s, 0.6),
          ll: (0.3 * s, -0.4 - 0.3 * s),
          rl: (-0.3 * s, -0.4 + 0.3 * s),
        );
      case Act.dizzy:
        return _build(
          lean: 0.18 * math.sin(tt * 5),
          tilt: 0.3 * math.sin(tt * 5 + 1),
          la: (0.3 * math.sin(tt * 5), 0.2),
          ra: (-0.3 * math.sin(tt * 5), 0.2),
          ll: (0.15, -0.3),
          rl: (-0.1, -0.25),
        );
      case Act.dust:
        return _build(
          lean: 0.55,
          la: (0.9 + 0.35 * math.sin(tt * 20), 0.8),
          ra: (0.6 + 0.35 * math.sin(tt * 20 + 1), 0.6),
          ll: (0.35, -0.5),
          rl: (0.2, -0.4),
        );
      case Act.idle:
      case Act.look:
        final b = math.sin(tt * 2.2);
        return _build(
          lean: 0.02 * b,
          tilt: act == Act.look ? 0.15 : 0,
          la: (0.12 + 0.03 * b, 0.1),
          ra: (-0.12 - 0.03 * b, 0.1),
          ll: (0.06, -0.02 * b.abs()),
          rl: (-0.06, -0.02 * b.abs()),
        );
    }
  }

  /// 각도 기준: 0 = 아래, + = 바라보는 방향(앞). (상단, 하단) 관절 상대 각도.
  List<Offset> _build({
    double py = -28,
    double lean = 0,
    double tilt = 0,
    required (double, double) la,
    required (double, double) ra,
    required (double, double) ll,
    required (double, double) rl,
    bool align = true,
  }) {
    final f = facing;
    Offset dir(double a) => Offset(math.sin(a) * f, math.cos(a));
    final pelvis = Offset(0, py);
    final neck = pelvis + Offset(math.sin(lean) * f, -math.cos(lean)) * 20;
    final head =
        neck + Offset(math.sin(lean + tilt) * f, -math.cos(lean + tilt)) * 11;
    final le = neck + dir(la.$1) * 12, lh = le + dir(la.$1 + la.$2) * 11;
    final re = neck + dir(ra.$1) * 12, rh = re + dir(ra.$1 + ra.$2) * 11;
    final lk = pelvis + dir(ll.$1) * 14, lf = lk + dir(ll.$1 + ll.$2) * 14;
    final rk = pelvis + dir(rl.$1) * 14, rf = rk + dir(rl.$1 + rl.$2) * 14;
    final out = [head, neck, pelvis, le, lh, re, rh, lk, lf, rk, rf];
    if (!align) return out;
    final shift = -math.max(lf.dy, rf.dy);
    return [for (final p in out) p.translate(0, shift)];
  }

  static Plat? _find(List<Plat> plats, Object key) {
    for (final p in plats) {
      if (identical(p.key, key)) return p;
    }
    return null;
  }
}

double _easeInOut(double x) =>
    x < 0.5 ? 4 * x * x * x : 1 - math.pow(-2 * x + 2, 3) / 2;
