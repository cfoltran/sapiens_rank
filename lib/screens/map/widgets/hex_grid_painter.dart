import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:sapiens_rank/models/guild_models.dart';

const double hexSize = 34.0;
const int gridCols = 12;
const int gridRows = 18;

const double _tileGap = 3.5;
const double _tileDepth = 4.0;
const double _cornerRadius = 7.0;

double get canvasWidth => gridCols * 1.5 * hexSize + 0.5 * hexSize;
double get canvasHeight =>
    gridRows * math.sqrt(3) * hexSize + math.sqrt(3) / 2 * hexSize;

Offset hexCenter(int col, int row) {
  final cx = col * 1.5 * hexSize + hexSize;
  final cy =
      row * math.sqrt(3) * hexSize +
      (col % 2 == 1 ? math.sqrt(3) / 2 * hexSize : 0) +
      math.sqrt(3) / 2 * hexSize;
  return Offset(cx, cy);
}

Path _hexPath(Offset center, double size, {double corner = _cornerRadius}) {
  final pts = List.generate(6, (i) {
    final angle = math.pi / 180 * (60 * i);
    return center + Offset(size * math.cos(angle), size * math.sin(angle));
  });

  final path = Path();
  for (int i = 0; i < 6; i++) {
    final vertex = pts[i];
    final prev = pts[(i + 5) % 6];
    final next = pts[(i + 1) % 6];
    final inDir = vertex - prev;
    final outDir = next - vertex;
    final r = math.min(corner, math.min(inDir.distance, outDir.distance) / 2);
    final start = vertex - inDir / inDir.distance * r;
    final end = vertex + outDir / outDir.distance * r;
    i == 0 ? path.moveTo(start.dx, start.dy) : path.lineTo(start.dx, start.dy);
    path.quadraticBezierTo(vertex.dx, vertex.dy, end.dx, end.dy);
  }
  return path..close();
}

Color _parseGuildColor(String hex) {
  final h = hex.replaceAll('#', '');
  return Color(int.parse('FF$h', radix: 16));
}

String? _hitTest(Offset canvasPoint) {
  double minDist = double.infinity;
  String? result;
  for (int c = 0; c < gridCols; c++) {
    for (int r = 0; r < gridRows; r++) {
      final center = hexCenter(c, r);
      final dist = (canvasPoint - center).distance;
      if (dist < minDist) {
        minDist = dist;
        result = '$c,$r';
      }
    }
  }
  return minDist <= hexSize ? result : null;
}

/// Converts a canvas point to (col, row) if inside a hex.
(int, int)? canvasPointToHex(Offset canvasPoint) {
  final key = _hitTest(canvasPoint);
  if (key == null) return null;
  final parts = key.split(',');
  return (int.parse(parts[0]), int.parse(parts[1]));
}

class HexGridPainter extends CustomPainter {
  HexGridPainter({
    required this.territories,
    required this.attackableTerritoryIds,
    required this.activeAttacks,
    required this.myGuildId,
    required this.animationValue,
    required this.entranceValue,
    required this.bounceValue,
    required this.bounceHex,
    required this.neutralColor,
    required this.borderColor,
    required this.attackableHighlight,
    required this.textColor,
  });

  final List<Territory> territories;
  final Set<String> attackableTerritoryIds;
  final List<Attack> activeAttacks;
  final String? myGuildId;
  final double animationValue;
  final double entranceValue;
  final double bounceValue;
  final (int, int)? bounceHex;
  final Color neutralColor;
  final Color borderColor;
  final Color attackableHighlight;
  final Color textColor;

  double _tileEntrance(int c, int r) {
    if (entranceValue >= 1) return 1.0;
    final dc = c - gridCols / 2;
    final dr = r - gridRows / 2;
    final dist = math.sqrt(dc * dc + dr * dr);
    final maxDist = math.sqrt(
      gridCols * gridCols / 4.0 + gridRows * gridRows / 4.0,
    );
    final delay = dist / maxDist * 0.55;
    final t = ((entranceValue - delay) / 0.45).clamp(0.0, 1.0);
    return Curves.easeOutBack.transform(t);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final byPos = {for (final t in territories) '${t.gridX},${t.gridY}': t};
    final underAttackIds = {for (final a in activeAttacks) a.territoryId};
    final breath = 0.5 - 0.5 * math.cos(2 * math.pi * animationValue);

    final glowPaint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    final sidePaint = Paint()..style = PaintingStyle.fill;
    final fillPaint = Paint()..style = PaintingStyle.fill;
    final borderPaint = Paint()..style = PaintingStyle.stroke;
    final haloPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    final ripplePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    // Pass 1 — tiles (glow, 3D side, face, border)
    for (int c = 0; c < gridCols; c++) {
      for (int r = 0; r < gridRows; r++) {
        final territory = byPos['$c,$r'];
        if (territory == null) continue;

        double scale = _tileEntrance(c, r);
        if (scale <= 0.01) continue;
        if (bounceHex == (c, r)) {
          scale *= 1 - 0.14 * math.sin(bounceValue * math.pi);
        }

        final center = hexCenter(c, r);
        final faceSize = (hexSize - _tileGap) * scale;
        final isAttackable = attackableTerritoryIds.contains(territory.id);
        final isMine = territory.ownerGuildId == myGuildId && myGuildId != null;

        final Color faceColor;
        if (territory.isNeutral) {
          faceColor = neutralColor;
        } else {
          final raw = territory.guilds?.color ?? '#888888';
          faceColor = _parseGuildColor(raw).withAlpha(isMine ? 230 : 180);
        }

        final facePath = _hexPath(center, faceSize);

        if (isMine) {
          glowPaint.color = faceColor.withAlpha(110);
          canvas.drawPath(_hexPath(center, faceSize + 2), glowPaint);
        }

        sidePaint.color = Color.lerp(faceColor, Colors.black, 0.45)!;
        canvas.drawPath(
          _hexPath(center + Offset(0, _tileDepth * scale), faceSize),
          sidePaint,
        );

        fillPaint.color = faceColor;
        canvas.drawPath(facePath, fillPaint);

        if (isAttackable) {
          haloPaint.color = attackableHighlight.withAlpha(
            (70 + 130 * breath).round(),
          );
          canvas.drawPath(
            _hexPath(center, faceSize + 2 + breath * 2.5),
            haloPaint,
          );
          borderPaint
            ..color = attackableHighlight.withAlpha((160 + 95 * breath).round())
            ..strokeWidth = 2.0;
        } else {
          borderPaint
            ..color = borderColor.withAlpha(120)
            ..strokeWidth = 1.0;
        }
        canvas.drawPath(facePath, borderPaint);
      }
    }

    // Pass 2 — attack ripples (always on top)
    for (int c = 0; c < gridCols; c++) {
      for (int r = 0; r < gridRows; r++) {
        final territory = byPos['$c,$r'];
        if (territory == null) continue;
        if (!underAttackIds.contains(territory.id)) continue;

        final center = hexCenter(c, r);
        final faceSize = hexSize - _tileGap;
        for (final phase in [animationValue, (animationValue + 0.5) % 1.0]) {
          final e = Curves.easeOut.transform(phase);
          ripplePaint.color = Colors.orange.withAlpha(((1 - e) * 200).round());
          canvas.drawPath(_hexPath(center, faceSize + 2 + e * 8), ripplePaint);
        }
      }
    }

    // Pass 3 — text (always on top)
    for (int c = 0; c < gridCols; c++) {
      for (int r = 0; r < gridRows; r++) {
        final territory = byPos['$c,$r'];
        if (territory == null || territory.guilds == null) continue;

        final scale = _tileEntrance(c, r);
        if (scale <= 0.5) continue;
        final alpha = ((scale - 0.5) * 2).clamp(0.0, 1.0);

        final center = hexCenter(c, r);
        final initials = territory.guilds!.name
            .trim()
            .split(' ')
            .take(2)
            .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
            .join();

        final tp = TextPainter(
          text: TextSpan(
            text: initials,
            style: TextStyle(
              color: Color.lerp(textColor.withAlpha(0), textColor, alpha),
              fontSize: hexSize * 0.35,
              fontWeight: FontWeight.w600,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
      }
    }
  }

  @override
  bool shouldRepaint(HexGridPainter old) =>
      old.territories != territories ||
      old.attackableTerritoryIds != attackableTerritoryIds ||
      old.activeAttacks != activeAttacks ||
      old.animationValue != animationValue ||
      old.entranceValue != entranceValue ||
      old.bounceValue != bounceValue ||
      old.bounceHex != bounceHex;
}
