import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sapiens_rank/common/theme/colors.dart';
import 'package:sapiens_rank/common/theme/sr_theme.dart';
import 'package:sapiens_rank/common/widgets/sr_slider_card.dart';
import 'package:sapiens_rank/models/habits_data.dart';
import 'package:sapiens_rank/screens/profile/widgets/profile_sheet.dart';

class BodySheet extends StatefulWidget {
  const BodySheet({super.key, required this.habits, required this.onSave});
  final HabitsData habits;
  final ValueChanged<HabitsData> onSave;

  @override
  State<BodySheet> createState() => _BodySheetState();
}

class _BodySheetState extends State<BodySheet> {
  late double _height;
  late double _weight;
  late BmiFrequency _frequency;

  @override
  void initState() {
    super.initState();
    _height = (widget.habits.heightCm ?? 175).toDouble();
    _weight = widget.habits.weightKg ?? 70.0;
    _frequency = widget.habits.bmiFrequency ?? BmiFrequency.monthly;
  }

  double get _bmi {
    final h = _height / 100;
    return _weight / (h * h);
  }

  static Color _bmiColor(double bmi, BuildContext context) {
    if (bmi < 18.5) return SrColors.cyan;
    if (bmi < 25) return context.srLime;
    if (bmi < 30) return SrColors.amber;
    return SrColors.rose;
  }

  static Color _bmiTextColor(double bmi, BuildContext context) {
    if (bmi < 18.5) return SrColors.cyan;
    if (bmi < 25) return context.srLimeText;
    if (bmi < 30) return SrColors.amber;
    return SrColors.rose;
  }

  static String _bmiCategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Healthy';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  HabitsData get _current => HabitsData(
    heightCm: _height.round(),
    weightKg: (_weight * 10).round() / 10.0,
    bmiFrequency: _frequency,
    smokes: widget.habits.smokes,
    cigarettesPerDay: widget.habits.cigarettesPerDay,
    drinks: widget.habits.drinks,
    drinksPerWeek: widget.habits.drinksPerWeek,
  );

  @override
  Widget build(BuildContext context) {
    final bmi = _bmi;
    final color = _bmiColor(bmi, context);
    final textColor = _bmiTextColor(bmi, context);
    return ProfileSheet(
      title: 'Body',
      onSave: () {
        widget.onSave(_current);
        Navigator.pop(context);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: BorderRadius.circular(14),
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
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                        height: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                Container(width: 1, height: 40, color: color.withAlpha(60)),
                const SizedBox(width: 14),
                Text(
                  _bmiCategory(bmi),
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SrSliderCard(
            icon: '📏',
            label: 'Height',
            unit: 'cm',
            value: _height,
            min: 140,
            max: 220,
            divisions: 80,
            color: context.srLime,
            format: (v) => '${v.round()} cm',
            onChanged: (v) => setState(() => _height = v.roundToDouble()),
          ),
          const SizedBox(height: 10),
          SrSliderCard(
            icon: '⚖️',
            label: 'Weight',
            unit: 'kg',
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
            'WEIGHT UPDATE FREQUENCY',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 10,
              color: context.srTextDim,
              letterSpacing: 10 * 0.15,
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
