import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sapiens_rank/common/theme/colors.dart';
import 'package:sapiens_rank/common/theme/sr_slider.dart';
import 'package:sapiens_rank/common/theme/sr_theme.dart';
import 'package:sapiens_rank/models/habits_data.dart';
import 'package:sapiens_rank/screens/onboarding/widgets/arena_button.dart';
import 'package:sapiens_rank/screens/onboarding/widgets/step_shell.dart';

class BmiStep extends StatefulWidget {
  const BmiStep({
    super.key,
    required this.progress,
    required this.total,
    required this.initialData,
    required this.onSubmit,
    required this.onBack,
  });

  final int progress;
  final int total;
  final HabitsData initialData;
  final ValueChanged<HabitsData> onSubmit;
  final VoidCallback onBack;

  @override
  State<BmiStep> createState() => _BmiStepState();
}

class _BmiStepState extends State<BmiStep> {
  late double _height;
  late double _weight;
  late BmiFrequency _frequency;

  @override
  void initState() {
    super.initState();
    _height = (widget.initialData.heightCm ?? 175).toDouble();
    _weight = widget.initialData.weightKg ?? 70.0;
    _frequency = widget.initialData.bmiFrequency ?? BmiFrequency.monthly;
  }

  double get _bmi {
    final h = _height / 100;
    return _weight / (h * h);
  }

  String get _bmiCategory {
    final b = _bmi;
    if (b < 18.5) return 'Underweight';
    if (b < 25) return 'Healthy';
    if (b < 30) return 'Overweight';
    return 'Obese';
  }

  Color _bmiColor(BuildContext context) {
    final b = _bmi;
    if (b < 18.5) return SrColors.cyan;
    if (b < 25) return context.srLime;
    if (b < 30) return SrColors.amber;
    return SrColors.rose;
  }

  Color _bmiTextColor(BuildContext context) {
    final b = _bmi;
    if (b < 18.5) return SrColors.cyan;
    if (b < 25) return context.srLimeText;
    if (b < 30) return SrColors.amber;
    return SrColors.rose;
  }

  HabitsData get _current => HabitsData(
    heightCm: _height.round(),
    weightKg: (_weight * 10).round() / 10.0,
    bmiFrequency: _frequency,
    smokes: widget.initialData.smokes,
    cigarettesPerDay: widget.initialData.cigarettesPerDay,
    drinks: widget.initialData.drinks,
    drinksPerWeek: widget.initialData.drinksPerWeek,
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
            label: 'Continue →',
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
            'BODY',
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
                const TextSpan(text: 'Body '),
                TextSpan(
                  text: 'composition.',
                  style: TextStyle(
                    color: context.srLimeText,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Used to refine your personal score.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium!.copyWith(color: context.srTextMuted),
          ),
          const SizedBox(height: 24),
          _BmiDisplay(
            bmi: _bmi,
            category: _bmiCategory,
            color: _bmiColor(context),
            textColor: _bmiTextColor(context),
          ),
          const SizedBox(height: 16),
          _MetricSlider(
            icon: '📏',
            label: 'Height',
            value: _height,
            min: 140,
            max: 220,
            divisions: 80,
            color: context.srLime,
            textColor: context.srLimeText,
            format: (v) => '${v.round()} cm',
            onChanged: (v) => setState(() => _height = v.roundToDouble()),
          ),
          const SizedBox(height: 10),
          _MetricSlider(
            icon: '⚖️',
            label: 'Weight',
            value: _weight,
            min: 40,
            max: 150,
            divisions: (150 - 40) ~/ 1,
            color: SrColors.amber,
            format: (v) => '${v.toStringAsFixed(1)} kg',
            onChanged: (v) => setState(() => _weight = (v * 2).round() / 2.0),
          ),
          const SizedBox(height: 20),
          Text(
            'How often do you want to update your weight?',
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: context.srTextDim,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: BmiFrequency.values.map((f) {
              final selected = f == _frequency;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: f != BmiFrequency.values.last ? 8 : 0,
                  ),
                  child: GestureDetector(
                    onTap: () => setState(() => _frequency = f),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: selected
                            ? context.srLime.withAlpha(31)
                            : context.srBgElev,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected ? context.srLime : context.srLine,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          f.name[0].toUpperCase() + f.name.substring(1),
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: selected
                                ? context.srLimeText
                                : context.srTextMuted,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _BmiDisplay extends StatelessWidget {
  const _BmiDisplay({
    required this.bmi,
    required this.category,
    required this.color,
    required this.textColor,
  });

  final double bmi;
  final String category;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'BMI',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  color: context.srTextDim,
                  letterSpacing: 10 * 0.1,
                ),
              ),
              Text(
                bmi.toStringAsFixed(1),
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                  letterSpacing: -1,
                  height: 1,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Container(width: 1, height: 48, color: color.withAlpha(60)),
          const SizedBox(width: 16),
          Text(
            category,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricSlider extends StatelessWidget {
  const _MetricSlider({
    required this.icon,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.color,
    required this.format,
    required this.onChanged,
    Color? textColor,
  }) : textColor = textColor ?? color;

  final String icon;
  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final Color color;
  final Color textColor;
  final String Function(double) format;
  final ValueChanged<double> onChanged;

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
                child: Text(
                  label,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: context.srText,
                  ),
                ),
              ),
              Text(
                format(value),
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                  letterSpacing: -0.5,
                  height: 1,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
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
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
