import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sapiens_rank/common/theme/colors.dart';
import 'package:sapiens_rank/common/theme/sr_slider.dart';
import 'package:sapiens_rank/common/theme/sr_theme.dart';
import 'package:sapiens_rank/models/health_targets.dart';
import 'package:sapiens_rank/screens/onboarding/widgets/arena_button.dart';
import 'package:sapiens_rank/screens/onboarding/widgets/step_shell.dart';

class TargetStep extends StatefulWidget {
  const TargetStep({
    super.key,
    required this.progress,
    required this.total,
    required this.initialTargets,
    required this.onSubmit,
    required this.onBack,
  });

  final int progress;
  final int total;
  final HealthTargets initialTargets;
  final ValueChanged<HealthTargets> onSubmit;
  final VoidCallback onBack;

  @override
  State<TargetStep> createState() => _TargetStepState();
}

class _TargetStepState extends State<TargetStep> {
  late double _steps;
  late double _kcal;
  late double _sleep;
  late double _stand;
  late double _exercise;

  static const _suggestedSteps = 7000.0;
  static const _suggestedKcal = 380.0;
  static const _suggestedSleep = 7.0;
  static const _suggestedStand = 12.0;
  static const _suggestedExercise = 30.0;

  @override
  void initState() {
    super.initState();
    _steps = widget.initialTargets.steps.toDouble();
    _kcal = widget.initialTargets.kcal;
    _sleep = widget.initialTargets.sleepHours;
    _stand = widget.initialTargets.standHours.toDouble();
    _exercise = widget.initialTargets.dailyExerciseMinutes.toDouble();
  }

  HealthTargets get _current => HealthTargets(
    steps: _steps.round(),
    kcal: _kcal,
    sleepHours: _sleep,
    standHours: _stand.round(),
    dailyExerciseMinutes: _exercise.round(),
  );

  @override
  Widget build(BuildContext context) {
    return StepShell(
      progress: widget.progress,
      total: widget.total,
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ArenaButton(
            label: 'Lock my targets →',
            onTap: () => widget.onSubmit(_current),
          ),
          const SizedBox(height: 4),
          ArenaSecondaryButton(label: 'Back', onTap: widget.onBack),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SET THE BAR',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 10,
              color: context.srLimeText,
              letterSpacing: 10 * 0.18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          RichText(
            text: TextSpan(
              style: GoogleFonts.spaceGrotesk(
                fontSize: 34,
                fontWeight: FontWeight.w700,
                color: context.srText,
                letterSpacing: 34 * -0.03,
                height: 1.1,
              ),
              children: [
                const TextSpan(text: 'Pick the numbers '),
                TextSpan(
                  text: "you'll defend",
                  style: TextStyle(
                    color: context.srLimeText,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const TextSpan(text: ' daily.'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _TargetSlider(
            icon: '👟',
            label: 'Steps',
            unit: 'steps / day',
            value: _steps,
            min: 3000,
            max: 20000,
            divisions: (20000 - 3000) ~/ 500,
            suggested: _suggestedSteps,
            color: SrColors.lime,
            format: (v) {
              final n = v.round();
              return n >= 1000
                  ? '${n ~/ 1000},${(n % 1000).toString().padLeft(3, '0')}'
                  : '$n';
            },
            onChanged: (v) =>
                setState(() => _steps = (v / 500).round() * 500.0),
          ),
          const SizedBox(height: 10),
          _TargetSlider(
            icon: '🔥',
            label: 'Active energy',
            unit: 'kcal / day',
            value: _kcal,
            min: 100,
            max: 1000,
            divisions: (1000 - 100) ~/ 10,
            suggested: _suggestedKcal,
            color: SrColors.magenta,
            format: (v) => '${v.round()}',
            onChanged: (v) => setState(() => _kcal = (v / 10).round() * 10.0),
          ),
          const SizedBox(height: 10),
          _TargetSlider(
            icon: '😴',
            label: 'Sleep',
            unit: 'per night',
            value: _sleep,
            min: 5,
            max: 10,
            divisions: (10 - 5) ~/ 1,
            suggested: _suggestedSleep,
            color: SrColors.cyan,
            format: (v) {
              final h = v.floor();
              final m = ((v % 1) * 60).round();
              return m > 0 ? '${h}h ${m}m' : '${h}h';
            },
            onChanged: (v) => setState(() => _sleep = (v * 4).round() / 4.0),
          ),
          const SizedBox(height: 10),
          _TargetSlider(
            icon: '🧍',
            label: 'Stand hours',
            unit: 'on your feet',
            value: _stand,
            min: 4,
            max: 16,
            divisions: 12,
            suggested: _suggestedStand,
            color: SrColors.amber,
            format: (v) => '${v.round()}h',
            onChanged: (v) => setState(() => _stand = v.roundToDouble()),
          ),
          const SizedBox(height: 10),
          _TargetSlider(
            icon: '🏃',
            label: 'Exercise',
            unit: 'min / day',
            value: _exercise,
            min: 10,
            max: 120,
            divisions: (120 - 10) ~/ 5,
            suggested: _suggestedExercise,
            color: SrColors.blue,
            format: (v) => '${v.round()}min',
            onChanged: (v) => setState(() => _exercise = (v / 5).round() * 5.0),
          ),
        ],
      ),
    );
  }
}

class _TargetSlider extends StatelessWidget {
  const _TargetSlider({
    required this.icon,
    required this.label,
    required this.unit,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.suggested,
    required this.color,
    required this.format,
    required this.onChanged,
  });

  final String icon;
  final String label;
  final String unit;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final double suggested;
  final Color color;
  final String Function(double) format;
  final ValueChanged<double> onChanged;

  bool get _isRecommended => (value - suggested).abs() < 0.01;

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
            thumbShape: _GlowThumbShape(color: color),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _GlowThumbShape extends SliderComponentShape {
  const _GlowThumbShape({required this.color});
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
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 6),
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
