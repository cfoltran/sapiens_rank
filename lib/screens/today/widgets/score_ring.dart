import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sapiens_rank/common/theme/colors.dart';

/// Animated Sapiens Score ring.
class ScoreRing extends StatefulWidget {
  const ScoreRing({super.key, required this.score, this.size = 272.0});

  final double score;
  final double size;

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
                    colors: [SrColors.lime.withAlpha(28), Colors.transparent],
                    stops: const [0.0, 0.65],
                  ),
                ),
              ),
            ),
            // Ring arc
            RepaintBoundary(
              child: CustomPaint(
                size: Size(size, size),
                painter: _RingPainter(progress: _anim.value / 100.0),
              ),
            ),
            // Center label
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'SAPIENS SCORE',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: SrColors.textMuted,
                    letterSpacing: 10 * 0.18,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _anim.value.round().toString(),
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 88,
                    fontWeight: FontWeight.w600,
                    color: SrColors.text,
                    height: 1.0,
                    letterSpacing: 88 * -0.04,
                  ),
                ),
                Text(
                  '/ 100',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: SrColors.textDim,
                    letterSpacing: 10 * 0.1,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({required this.progress});

  final double progress;

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
        ..color = SrColors.tintSm,
    );

    // Tick marks at 25 / 50 / 75 %
    final tickPaint = Paint()
      ..color = Colors.white.withAlpha(38)
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

    // Glow halo (wider, transparent, blurred)
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
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}
