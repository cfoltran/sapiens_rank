import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'package:sapiens_rank/common/helpers/guild_visuals.dart';
import 'package:sapiens_rank/models/guild_models.dart';
import 'package:sapiens_rank/screens/map/game/hex_geometry.dart';

/// Animated siege overlay drawn on a territory while an attack is active:
/// a countdown arc (now -> endsAt) plus pulsing clash rings, tinted with the
/// attacker guild's color.
class SiegeRing extends PositionComponent {
  SiegeRing({
    required Vector2 center,
    required this.startsAt,
    required this.endsAt,
    required this.metric,
    required this.color,
    this.boosted = false,
  }) : super(
         position: center,
         size: Vector2.all(hexSize * 2),
         anchor: Anchor.center,
         priority: 1000,
       );

  final DateTime startsAt;
  final DateTime endsAt;
  final AttackMetric metric;
  final Color color;
  final bool boosted;
  double _t = 0;

  @override
  void update(double dt) => _t += dt;

  @override
  void render(Canvas canvas) {
    final c = Offset(size.x / 2, size.y / 2);
    final radius = hexSize - tileGap + 4;

    final total = endsAt.difference(startsAt).inMilliseconds;
    final elapsed = DateTime.now().difference(startsAt).inMilliseconds;
    final remaining = total <= 0 ? 0.0 : (1 - elapsed / total).clamp(0.0, 1.0);

    canvas.drawCircle(
      c,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = Colors.black.withAlpha(70),
    );
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: radius),
      -math.pi / 2,
      2 * math.pi * remaining,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..color = color,
    );

    for (final phase in [_t % 1.0, (_t + 0.5) % 1.0]) {
      final e = Curves.easeOut.transform(phase);
      canvas.drawCircle(
        c,
        radius + e * 9,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..color = color.withAlpha(((1 - e) * 200).round()),
      );
    }

    final tp = TextPainter(
      text: TextSpan(
        text: metric.emoji,
        style: TextStyle(fontSize: hexSize * 0.5),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, c - Offset(tp.width / 2, tp.height / 2));

    if (boosted) {
      final badgeCenter = c + Offset(hexSize * 0.52, -hexSize * 0.52);
      final badge = TextPainter(
        text: const TextSpan(text: '⚡️', style: TextStyle(fontSize: 11)),
        textDirection: TextDirection.ltr,
      )..layout();
      badge.paint(
        canvas,
        badgeCenter - Offset(badge.width - 4, badge.height - 14),
      );
    }
  }
}

/// One-shot radial particle burst played when a territory is captured.
class CaptureBurst extends ParticleSystemComponent {
  CaptureBurst({required Vector2 center, required Color color})
    : super(
        position: center,
        priority: 2000,
        particle: Particle.generate(
          count: 22,
          lifespan: 0.8,
          generator: (i) {
            final rnd = math.Random();
            final angle = (i / 22) * 2 * math.pi + rnd.nextDouble() * 0.4;
            final speed = 60 + rnd.nextDouble() * 90;
            return AcceleratedParticle(
              acceleration: Vector2(0, 40),
              speed: Vector2(math.cos(angle), math.sin(angle)) * speed,
              child: CircleParticle(
                radius: 1.5 + rnd.nextDouble() * 2.5,
                paint: Paint()..color = color,
              ),
            );
          },
        ),
      );
}
