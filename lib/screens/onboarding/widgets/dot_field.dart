import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sapiens_rank/common/theme/sr_theme.dart';

class DotField extends StatelessWidget {
  const DotField({super.key});

  @override
  Widget build(BuildContext context) {
    final limeColor = context.srLime;
    return Opacity(
      opacity: 0.7,
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _DotsPainter(limeColor: limeColor),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _DotsPainter extends CustomPainter {
  _DotsPainter({required this.limeColor}) {
    final rng = Random(42);
    _dots = List.generate(
      60,
      (_) => _Dot(
        x: rng.nextDouble(),
        y: rng.nextDouble(),
        size: rng.nextDouble() * 2 + 1,
        opacity: rng.nextDouble() * 0.5 + 0.1,
      ),
    );
  }

  final Color limeColor;
  late final List<_Dot> _dots;

  @override
  void paint(Canvas canvas, Size size) {
    for (final dot in _dots) {
      final center = Offset(dot.x * size.width, dot.y * size.height);
      final radius = dot.size / 2;

      canvas.drawCircle(
        center,
        radius * 4,
        Paint()
          ..color = limeColor.withAlpha((dot.opacity * 0.25 * 255).round()),
      );

      canvas.drawCircle(
        center,
        radius,
        Paint()..color = limeColor.withAlpha((dot.opacity * 255).round()),
      );
    }
  }

  @override
  bool shouldRepaint(_DotsPainter old) => old.limeColor != limeColor;
}

class _Dot {
  const _Dot({
    required this.x,
    required this.y,
    required this.size,
    required this.opacity,
  });

  final double x;
  final double y;
  final double size;
  final double opacity;
}
