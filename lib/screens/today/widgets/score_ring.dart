import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sapiens_rank/common/theme/colors.dart';
import 'package:sapiens_rank/common/theme/sr_theme.dart';

/// Animated Sapiens Score ring. When [coinFill] is provided the inner disc
/// fills with gold Sapie coins (the day's harvestable crop).
class ScoreRing extends StatefulWidget {
  const ScoreRing({
    super.key,
    required this.score,
    this.size = 220.0,
    this.coinFill,
  });

  final double score;
  final double size;

  /// 0..1 fraction of the inner disc filled with coins. Null = plain ring.
  final double? coinFill;

  @override
  State<ScoreRing> createState() => _ScoreRingState();
}

class _ScoreRingState extends State<ScoreRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _anim = Tween<double>(
      begin: 0,
      end: widget.score,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    WidgetsBinding.instance.addPostFrameCallback((_) => _ctrl.forward());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    final hasCoins = widget.coinFill != null;
    return SizedBox(
      width: size,
      height: size,
      child: AnimatedBuilder(
        animation: _anim,
        builder: (context, _) => Stack(
          alignment: Alignment.center,
          children: [
            // Outer radial glow
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      SrColors.lime.withAlpha(context.isDark ? 28 : 18),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.65],
                  ),
                ),
              ),
            ),
            // Inner coin reservoir
            if (hasCoins)
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: widget.coinFill!.clamp(0.0, 1.0)),
                duration: const Duration(milliseconds: 1150),
                curve: const Cubic(.34, 1.06, .36, 1),
                builder: (context, fill, _) => RepaintBoundary(
                  child: CustomPaint(
                    size: Size(size, size),
                    painter: _CoinFillPainter(fill: fill),
                  ),
                ),
              ),
            // Ring arc
            RepaintBoundary(
              child: CustomPaint(
                size: Size(size, size),
                painter: _RingPainter(
                  progress: _anim.value / 100.0,
                  trackColor: context.srTrack,
                  tickColor: context.srTick,
                ),
              ),
            ),
            // Score number — floats centered in the empty space above the
            // coin pile, shrinking to stay clear of the rising fill line.
            if (hasCoins)
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: widget.coinFill!.clamp(0.0, 1.0)),
                duration: const Duration(milliseconds: 1150),
                curve: const Cubic(.34, 1.06, .36, 1),
                builder: (context, fill, _) {
                  // inner radius / (size/2): the disc edge in alignment units
                  final r = 1 - 32 / size;
                  final emptyHeight = (size - 32) * (1 - fill);
                  final fontSize = (emptyHeight * 0.58).clamp(20.0, 76.0);
                  return Align(
                    alignment: Alignment(0, -r * fill),
                    child: _ScoreNumber(
                      value: _anim.value.round(),
                      fontSize: fontSize,
                      shadow: true,
                    ),
                  );
                },
              )
            else
              _ScoreNumber(value: _anim.value.round(), fontSize: 70),
          ],
        ),
      ),
    );
  }
}

class _ScoreNumber extends StatelessWidget {
  const _ScoreNumber({
    required this.value,
    required this.fontSize,
    this.shadow = false,
  });

  final int value;
  final double fontSize;
  final bool shadow;

  static const _shadow = [
    Shadow(color: Color(0x8C281A04), blurRadius: 6, offset: Offset(0, 2)),
  ];

  @override
  Widget build(BuildContext context) {
    return Text(
      '$value',
      style: GoogleFonts.spaceGrotesk(
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
        color: context.srText,
        height: 1.0,
        letterSpacing: fontSize * -0.04,
        shadows: shadow ? _shadow : null,
      ),
    );
  }
}

/// Fills the inner disc with packed gold coins from the bottom up to [fill].
class _CoinFillPainter extends CustomPainter {
  const _CoinFillPainter({required this.fill});

  final double fill;

  static const double _stroke = 14.0;
  static const double _coinR = 10.5;

  @override
  void paint(Canvas canvas, Size size) {
    if (fill <= 0) return;
    final center = Offset(size.width / 2, size.height / 2);
    final innerR = size.width / 2 - _stroke - 2;

    canvas.save();
    canvas.clipPath(
      Path()..addOval(Rect.fromCircle(center: center, radius: innerR)),
    );

    // Recessed reservoir backdrop
    canvas.drawCircle(
      center,
      innerR,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, -0.36),
          colors: [Colors.white.withAlpha(13), Colors.black.withAlpha(36)],
        ).createShader(Rect.fromCircle(center: center, radius: innerR)),
    );

    final fillTopY = center.dy + innerR - fill.clamp(0.0, 1.0) * (2 * innerR);

    final coinPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.3, -0.44),
        radius: 0.95,
        colors: [
          Color(0xFFFFE9A8),
          Color(0xFFF1C14E),
          Color(0xFFCF9626),
          Color(0xFFA9741A),
        ],
        stops: [0.0, 0.4, 0.74, 1.0],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: _coinR));
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = SrColors.coinLight.withAlpha(150);
    final shadePaint = Paint()..color = SrColors.coinDeep.withAlpha(70);

    // The same α glyph as SapieCoin, laid out once and stamped on each coin.
    final glyph = TextPainter(
      text: TextSpan(
        text: 'α',
        style: GoogleFonts.notoSerif(
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.w700,
          fontSize: _coinR * 1.2,
          height: 1.0,
          color: const Color(0xFF7C5512),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final glyphOffset = Offset(
      -glyph.width / 2 - _coinR * 0.04,
      -glyph.height / 2 - _coinR * 0.1,
    );

    final stepX = _coinR * 2 + 1.5;
    final stepY = _coinR * 1.55;
    final maxR = innerR - _coinR * 0.35;
    // A coin pops in as the rising fill line clears it, over this band of
    // travel — giving a coin-by-coin cascade rather than a flat reveal.
    const popBand = _coinR * 2.6;

    var row = 0;
    for (
      var y = center.dy + innerR - _coinR;
      y > center.dy - innerR;
      y -= stepY
    ) {
      final xOffset = row.isEven ? 0.0 : _coinR;
      for (
        var x = center.dx - innerR + _coinR + xOffset;
        x < center.dx + innerR - _coinR + 1;
        x += stepX
      ) {
        final dx = x - center.dx;
        final dy = y - center.dy;
        if (dx * dx + dy * dy > maxR * maxR) continue;
        if (y < fillTopY) continue;

        final appear = ((y - fillTopY) / popBand).clamp(0.0, 1.0);
        final scale = Curves.easeOutBack.transform(appear);
        if (scale <= 0.02) continue;

        final rnd = Random((x * 7 + y * 13).round());
        final jx = (rnd.nextDouble() - 0.5) * 2.2;
        final jy = (rnd.nextDouble() - 0.5) * 2.2;
        final rot = (rnd.nextDouble() - 0.5) * 1.4;

        canvas.save();
        canvas.translate(x + jx, y + jy);
        canvas.scale(scale);
        canvas.rotate(rot);
        canvas.drawCircle(const Offset(0, 1.2), _coinR, shadePaint);
        canvas.drawCircle(Offset.zero, _coinR, coinPaint);
        canvas.drawCircle(Offset.zero, _coinR - 0.5, ringPaint);
        glyph.paint(canvas, glyphOffset);
        canvas.restore();
      }
      row++;
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_CoinFillPainter old) => old.fill != fill;
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.progress,
    required this.trackColor,
    required this.tickColor,
  });

  final double progress;
  final Color trackColor;
  final Color tickColor;

  static const double _strokeWidth = 14.0;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - _strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _strokeWidth
        ..color = trackColor,
    );

    // Tick marks at 25 / 50 / 75 %
    final tickPaint = Paint()
      ..color = tickColor
      ..strokeWidth = 1.0;
    for (final pct in [0.25, 0.5, 0.75]) {
      final angle = pct * 2 * pi - pi / 2;
      final inner = Offset(
        center.dx + cos(angle) * (radius - _strokeWidth / 2 - 4),
        center.dy + sin(angle) * (radius - _strokeWidth / 2 - 4),
      );
      final outer = Offset(
        center.dx + cos(angle) * (radius + _strokeWidth / 2 + 4),
        center.dy + sin(angle) * (radius + _strokeWidth / 2 + 4),
      );
      canvas.drawLine(inner, outer, tickPaint);
    }

    if (progress <= 0) return;

    final sweepAngle = progress * 2 * pi;

    // Glow halo
    canvas.drawArc(
      rect,
      -pi / 2,
      sweepAngle,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _strokeWidth + 8
        ..strokeCap = StrokeCap.round
        ..color = SrColors.lime.withAlpha(45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // Progress arc with lime→amber gradient
    canvas.drawArc(
      rect,
      -pi / 2,
      sweepAngle,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _strokeWidth
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          startAngle: -pi / 2,
          endAngle: -pi / 2 + sweepAngle,
          colors: const [SrColors.lime, SrColors.lime, SrColors.amber],
          stops: const [0.0, 0.6, 1.0],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress ||
      old.trackColor != trackColor ||
      old.tickColor != tickColor;
}
