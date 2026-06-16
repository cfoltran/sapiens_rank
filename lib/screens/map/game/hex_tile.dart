import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sapiens_rank/models/guild_models.dart';
import 'package:sapiens_rank/screens/map/game/attack_fx.dart';
import 'package:sapiens_rank/screens/map/game/hex_geometry.dart';
import 'package:sapiens_rank/screens/map/game/map_game.dart';

class HexTileComponent extends PositionComponent
    with HasGameReference<MapGame>, TapCallbacks {
  HexTileComponent({
    required this.col,
    required this.row,
    required this.entranceDelay,
    required Territory territory,
    required Color faceColor,
    required this.isMine,
    required this.attackable,
  }) : _territory = territory,
       _faceColor = faceColor,
       _targetColor = faceColor,
       super(
         position: hexCenter(col, row).toVector2(),
         size: Vector2.all(hexSize * 2),
         anchor: Anchor.center,
         priority: row,
       );

  final int col;
  final int row;
  final double entranceDelay;

  Territory _territory;
  Color _faceColor;
  Color _targetColor;
  bool isMine;
  bool attackable;

  Territory get territory => _territory;

  double _entranceElapsed = 0;
  double _bounce = -1;
  double _capture = -1;
  Color _captureFrom = Colors.transparent;

  late final List<Offset> _grain = _buildGrain();

  List<Offset> _buildGrain() {
    final rnd = math.Random(col * 31 + row * 7);
    return List.generate(7, (_) {
      final a = rnd.nextDouble() * 2 * math.pi;
      final d = rnd.nextDouble() * (hexSize - tileGap) * 0.7;
      return Offset(math.cos(a) * d, math.sin(a) * d);
    });
  }

  void syncState(
    Territory territory,
    Color faceColor,
    bool mine,
    bool canAttack,
  ) {
    final ownerChanged = territory.ownerGuildId != _territory.ownerGuildId;
    _territory = territory;
    isMine = mine;
    attackable = canAttack;
    if (ownerChanged) {
      playCapture(faceColor);
    } else {
      _faceColor = faceColor;
      _targetColor = faceColor;
    }
  }

  void playCapture(Color to) {
    _captureFrom = _faceColor;
    _targetColor = to;
    _capture = 0;
    game.world.add(CaptureBurst(center: position.clone(), color: to));
  }

  void bounce() => _bounce = 0;

  @override
  bool containsLocalPoint(Vector2 point) {
    final dx = point.x - size.x / 2;
    final dy = point.y - size.y / 2;
    return dx * dx + dy * dy <= hexSize * hexSize;
  }

  @override
  void onTapUp(TapUpEvent event) {
    HapticFeedback.lightImpact();
    bounce();
    game.onTerritoryTap(_territory);
  }

  @override
  void update(double dt) {
    if (_entranceElapsed < entranceDelay + 0.45) _entranceElapsed += dt;
    if (_bounce >= 0) {
      _bounce += dt / 0.28;
      if (_bounce >= 1) _bounce = -1;
    }
    if (_capture >= 0) {
      _capture += dt / 0.5;
      if (_capture >= 1) {
        _capture = -1;
        _faceColor = _targetColor;
      }
    }
  }

  double get _entranceScale {
    final t = ((_entranceElapsed - entranceDelay) / 0.45).clamp(0.0, 1.0);
    return Curves.easeOutBack.transform(t);
  }

  @override
  void render(Canvas canvas) {
    final scale = _entranceScale;
    if (scale <= 0.01) return;

    var pop = 1.0;
    if (_bounce >= 0) pop *= 1 - 0.14 * math.sin(_bounce * math.pi);
    if (_capture >= 0) pop *= 1 + 0.12 * math.sin(_capture * math.pi);

    final color = _capture >= 0
        ? Color.lerp(_captureFrom, _targetColor, _capture)!
        : _faceColor;

    final c = Offset(size.x / 2, size.y / 2);
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.scale(scale * pop);
    canvas.translate(-c.dx, -c.dy);

    final faceSize = hexSize - tileGap;
    final face = hexPath(c, faceSize);

    if (isMine) {
      canvas.drawPath(
        hexPath(c, faceSize + 2),
        Paint()
          ..color = color.withAlpha(110)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
    }

    canvas.drawPath(
      hexPath(c + const Offset(0, tileDepth), faceSize),
      Paint()..color = Color.lerp(color, Colors.black, 0.45)!,
    );

    final bounds = face.getBounds();
    canvas.drawPath(
      face,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(color, Colors.white, 0.18)!,
            color,
            Color.lerp(color, Colors.black, 0.12)!,
          ],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(bounds),
    );

    canvas.save();
    canvas.clipPath(face);
    final grainPaint = Paint()..color = Colors.white.withAlpha(14);
    for (final g in _grain) {
      canvas.drawCircle(c + g, 1.3, grainPaint);
    }
    canvas.restore();

    if (attackable) {
      final breath = game.breath;
      canvas.drawPath(
        hexPath(c, faceSize + 2 + breath * 2.5),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6)
          ..color = game.colors.highlight.withAlpha(
            (70 + 130 * breath).round(),
          ),
      );
      canvas.drawPath(
        face,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = game.colors.highlight.withAlpha(
            (160 + 95 * breath).round(),
          ),
      );
    } else if (!_territory.isNeutral) {
      canvas.drawPath(
        face,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..color = Color.lerp(color, Colors.white, 0.35)!,
      );
    } else {
      canvas.drawPath(
        face,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = game.colors.border.withAlpha(120),
      );
    }

    canvas.restore();
  }
}
