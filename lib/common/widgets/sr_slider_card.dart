import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sapiens_rank/common/theme/sr_slider.dart';
import 'package:sapiens_rank/common/theme/sr_theme.dart';

class SrSliderCard extends StatelessWidget {
  const SrSliderCard({
    super.key,
    required this.icon,
    required this.label,
    required this.unit,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.color,
    required this.format,
    required this.onChanged,
    this.suggested,
  });

  final String icon;
  final String label;
  final String unit;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final Color color;
  final String Function(double) format;
  final ValueChanged<double> onChanged;

  /// When provided, shows a "✓ recommended / custom" indicator.
  final double? suggested;

  bool get _isRecommended =>
      suggested != null && (value - suggested!).abs() < 0.01;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      decoration: BoxDecoration(
        color: context.srBgElev,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withAlpha(51)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withAlpha(31),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: color.withAlpha(85)),
                ),
                child: Center(
                  child: Text(icon, style: const TextStyle(fontSize: 17)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: context.srText,
                      ),
                    ),
                    Text(
                      unit,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        color: context.srTextDim,
                        letterSpacing: 10 * 0.05,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    format(value),
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: color,
                      letterSpacing: 26 * -0.03,
                      height: 1,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  if (suggested != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      _isRecommended ? '✓ recommended' : 'custom',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 8,
                        color: _isRecommended ? color : context.srTextDim,
                        letterSpacing: 8 * 0.1,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          SrSlider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            color: color,
            trackHeight: 5,
            thumbShape: suggested != null
                ? SrGlowThumbShape(color: color)
                : null,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class SrGlowThumbShape extends SliderComponentShape {
  const SrGlowThumbShape({required this.color});
  final Color color;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      const Size.fromRadius(10);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    canvas.drawCircle(center, 14, Paint()..color = color.withAlpha(51));
    canvas.drawCircle(
      center,
      10,
      Paint()
        ..color = color
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawCircle(
      center,
      10,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      center,
      10,
      Paint()
        ..color = const Color(0xFF15130F)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }
}
