import 'package:flutter/material.dart';
import 'package:sapiens_rank/common/theme/colors.dart';

class SparklineChart extends StatelessWidget {
  const SparklineChart({
    super.key,
    required this.data,
    this.width = 84.0,
    this.height = 20.0,
    this.color = SrColors.lime,
  });

  final List<int> data;
  final double width;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: Size(width, height),
        painter: _SparklinePainter(data: data, color: color),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  const _SparklinePainter({required this.data, required this.color});

  final List<int> data;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;

    final min = data.reduce((a, b) => a < b ? a : b).toDouble();
    final max = data.reduce((a, b) => a > b ? a : b).toDouble();
    final span = max - min == 0 ? 1.0 : max - min;

    final pts = List.generate(data.length, (i) {
      final x = (i / (data.length - 1)) * size.width;
      final y = size.height - ((data[i] - min) / span) * (size.height - 4) - 2;
      return Offset(x, y);
    });

    // Fill
    final fill = Path()
      ..moveTo(pts.first.dx, pts.first.dy)
      ..addPolygon(pts, false)
      ..lineTo(pts.last.dx, size.height)
      ..lineTo(pts.first.dx, size.height)
      ..close();
    canvas.drawPath(fill, Paint()..color = color.withAlpha(38));

    // Line
    final line = Path()
      ..moveTo(pts.first.dx, pts.first.dy)
      ..addPolygon(pts.skip(1).toList(), false);
    canvas.drawPath(
      line,
      Paint()
        ..color = color
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // End dot
    canvas.drawCircle(pts.last, 2.5, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_SparklinePainter old) =>
      old.data != data || old.color != color;
}
