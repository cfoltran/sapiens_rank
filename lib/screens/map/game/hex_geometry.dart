import 'dart:math' as math;
import 'dart:ui';

const double hexSize = 34.0;
const int gridCols = 6;
const int gridRows = 9;

const double tileGap = 3.5;
const double tileDepth = 4.0;
const double cornerRadius = 7.0;

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

/// Flat-top hexagon path with rounded corners, centered on [center].
Path hexPath(Offset center, double size, {double corner = cornerRadius}) {
  final pts = List.generate(6, (i) {
    final angle = math.pi / 180 * (60 * i);
    return center + Offset(size * math.cos(angle), size * math.sin(angle));
  });

  final path = Path();
  for (var i = 0; i < 6; i++) {
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
