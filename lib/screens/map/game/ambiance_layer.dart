import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:sapiens_rank/screens/map/game/hex_geometry.dart';

/// Slow drifting motes across the whole board for atmosphere.
class AmbianceLayer extends Component {
  AmbianceLayer({required this.color, this.count = 40}) {
    priority = 500;
  }

  final Color color;
  final int count;
  final _rnd = math.Random(7);
  final List<_Mote> _motes = [];

  @override
  Future<void> onLoad() async {
    for (var i = 0; i < count; i++) {
      _motes.add(_spawn(initial: true));
    }
  }

  _Mote _spawn({bool initial = false}) {
    return _Mote(
      x: _rnd.nextDouble() * canvasWidth,
      y: initial ? _rnd.nextDouble() * canvasHeight : canvasHeight + 8,
      speed: 5 + _rnd.nextDouble() * 12,
      radius: 0.8 + _rnd.nextDouble() * 1.8,
      alpha: 12 + _rnd.nextInt(40),
      drift: _rnd.nextDouble() * 2 * math.pi,
    );
  }

  @override
  void update(double dt) {
    for (var i = 0; i < _motes.length; i++) {
      final m = _motes[i];
      m.y -= m.speed * dt;
      m.x += math.sin(m.y * 0.02 + m.drift) * 0.25;
      if (m.y < -8) _motes[i] = _spawn();
    }
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint();
    for (final m in _motes) {
      paint.color = color.withAlpha(m.alpha);
      canvas.drawCircle(Offset(m.x, m.y), m.radius, paint);
    }
  }
}

class _Mote {
  _Mote({
    required this.x,
    required this.y,
    required this.speed,
    required this.radius,
    required this.alpha,
    required this.drift,
  });

  double x;
  double y;
  final double speed;
  final double radius;
  final int alpha;
  final double drift;
}
