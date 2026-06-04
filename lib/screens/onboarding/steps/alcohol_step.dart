import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sapiens_rank/common/theme/colors.dart';
import 'package:sapiens_rank/common/theme/sr_theme.dart';
import 'package:sapiens_rank/models/habits_data.dart';
import 'package:sapiens_rank/screens/onboarding/widgets/arena_button.dart';
import 'package:sapiens_rank/screens/onboarding/widgets/habit_choice_card.dart';
import 'package:sapiens_rank/screens/onboarding/widgets/step_shell.dart';

enum _AlcoholChoice { no, yes, decline }

class AlcoholStep extends StatefulWidget {
  const AlcoholStep({
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
  State<AlcoholStep> createState() => _AlcoholStepState();
}

class _AlcoholStepState extends State<AlcoholStep> {
  late _AlcoholChoice _choice;
  late double _drinks;

  @override
  void initState() {
    super.initState();
    if (widget.initialData.drinks == null) {
      _choice = _AlcoholChoice.decline;
    } else if (widget.initialData.drinks!) {
      _choice = _AlcoholChoice.yes;
    } else {
      _choice = _AlcoholChoice.no;
    }
    _drinks = (widget.initialData.drinksPerWeek ?? 5).toDouble();
  }

  HabitsData get _current {
    final bool? drinks = switch (_choice) {
      _AlcoholChoice.no => false,
      _AlcoholChoice.yes => true,
      _AlcoholChoice.decline => null,
    };
    return HabitsData(
      heightCm: widget.initialData.heightCm,
      weightKg: widget.initialData.weightKg,
      bmiFrequency: widget.initialData.bmiFrequency,
      smokes: widget.initialData.smokes,
      cigarettesPerDay: widget.initialData.cigarettesPerDay,
      drinks: drinks,
      drinksPerWeek: _choice == _AlcoholChoice.yes ? _drinks.round() : null,
    );
  }

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
            'HABITS',
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
                const TextSpan(text: 'Do you '),
                TextSpan(
                  text: 'drink?',
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
            'Affects your personal Sapiens Score.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium!.copyWith(color: context.srTextMuted),
          ),
          const SizedBox(height: 28),
          HabitChoiceCard(
            selected: _choice == _AlcoholChoice.no,
            icon: '🚫',
            title: "No, I don't drink",
            subtitle: 'No impact on score',
            onTap: () => setState(() => _choice = _AlcoholChoice.no),
          ),
          const SizedBox(height: 10),
          HabitChoiceCard(
            selected: _choice == _AlcoholChoice.yes,
            icon: '🍷',
            title: 'Yes',
            subtitle: 'Affects score based on quantity',
            onTap: () => setState(() => _choice = _AlcoholChoice.yes),
          ),
          if (_choice == _AlcoholChoice.yes) ...[
            const SizedBox(height: 12),
            HabitQuantitySlider(
              label: 'Drinks per week',
              value: _drinks,
              min: 1,
              max: 30,
              divisions: 29,
              color: SrColors.magenta,
              format: (v) => '${v.round()}',
              onChanged: (v) => setState(() => _drinks = v.roundToDouble()),
            ),
          ],
          const SizedBox(height: 10),
          HabitChoiceCard(
            selected: _choice == _AlcoholChoice.decline,
            icon: '🔒',
            title: 'I prefer not to say',
            subtitle: 'Still affects score',
            onTap: () => setState(() => _choice = _AlcoholChoice.decline),
          ),
        ],
      ),
    );
  }
}
