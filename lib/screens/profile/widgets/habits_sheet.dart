import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sapiens_rank/common/theme/colors.dart';
import 'package:sapiens_rank/common/theme/sr_theme.dart';
import 'package:sapiens_rank/common/widgets/sr_slider_card.dart';
import 'package:sapiens_rank/models/habits_data.dart';
import 'package:sapiens_rank/screens/onboarding/widgets/habit_choice_card.dart';
import 'package:sapiens_rank/screens/profile/widgets/profile_sheet.dart';

class HabitsSheet extends StatefulWidget {
  const HabitsSheet({super.key, required this.habits, required this.onSave});
  final HabitsData habits;
  final ValueChanged<HabitsData> onSave;

  @override
  State<HabitsSheet> createState() => _HabitsSheetState();
}

class _HabitsSheetState extends State<HabitsSheet> {
  late bool? _smokes;
  late double _cigarettes;
  late bool? _drinks;
  late double _drinksPerWeek;

  @override
  void initState() {
    super.initState();
    _smokes = widget.habits.smokes;
    _cigarettes = (widget.habits.cigarettesPerDay ?? 10).toDouble();
    _drinks = widget.habits.drinks;
    _drinksPerWeek = (widget.habits.drinksPerWeek ?? 5).toDouble();
  }

  HabitsData get _current => HabitsData(
    heightCm: widget.habits.heightCm,
    weightKg: widget.habits.weightKg,
    bmiFrequency: widget.habits.bmiFrequency,
    smokes: _smokes,
    cigarettesPerDay: _smokes == true ? _cigarettes.round() : null,
    drinks: _drinks,
    drinksPerWeek: _drinks == true ? _drinksPerWeek.round() : null,
  );

  @override
  Widget build(BuildContext context) {
    return ProfileSheet(
      title: 'Habits',
      onSave: () {
        widget.onSave(_current);
        Navigator.pop(context);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SMOKING',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 10,
              color: context.srTextDim,
              letterSpacing: 10 * 0.15,
            ),
          ),
          const SizedBox(height: 8),
          HabitChoiceCard(
            selected: _smokes == false,
            icon: '🚭',
            title: "I don't smoke",
            onTap: () => setState(() => _smokes = false),
          ),
          const SizedBox(height: 8),
          HabitChoiceCard(
            selected: _smokes == true,
            icon: '🚬',
            title: 'I smoke',
            onTap: () => setState(() => _smokes = true),
          ),
          if (_smokes == true) ...[
            const SizedBox(height: 10),
            SrSliderCard(
              icon: '🚬',
              label: 'Per day',
              unit: 'cigarettes',
              value: _cigarettes,
              min: 1,
              max: 40,
              divisions: 39,
              color: SrColors.rose,
              format: (v) => '${v.round()}',
              onChanged: (v) => setState(() => _cigarettes = v.roundToDouble()),
            ),
          ],
          const SizedBox(height: 8),
          HabitChoiceCard(
            selected: _smokes == null,
            icon: '🔒',
            title: 'Prefer not to say',
            onTap: () => setState(() => _smokes = null),
          ),
          const SizedBox(height: 20),
          Text(
            'ALCOHOL',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 10,
              color: context.srTextDim,
              letterSpacing: 10 * 0.15,
            ),
          ),
          const SizedBox(height: 8),
          HabitChoiceCard(
            selected: _drinks == false,
            icon: '🚫',
            title: "I don't drink",
            onTap: () => setState(() => _drinks = false),
          ),
          const SizedBox(height: 8),
          HabitChoiceCard(
            selected: _drinks == true,
            icon: '🍷',
            title: 'I drink',
            onTap: () => setState(() => _drinks = true),
          ),
          if (_drinks == true) ...[
            const SizedBox(height: 10),
            SrSliderCard(
              icon: '🍷',
              label: 'Per week',
              unit: 'drinks',
              value: _drinksPerWeek,
              min: 1,
              max: 30,
              divisions: 29,
              color: SrColors.magenta,
              format: (v) => '${v.round()}',
              onChanged: (v) =>
                  setState(() => _drinksPerWeek = v.roundToDouble()),
            ),
          ],
          const SizedBox(height: 8),
          HabitChoiceCard(
            selected: _drinks == null,
            icon: '🔒',
            title: 'Prefer not to say',
            onTap: () => setState(() => _drinks = null),
          ),
        ],
      ),
    );
  }
}
