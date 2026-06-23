import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sapiens_rank/common/theme/colors.dart';
import 'package:sapiens_rank/common/theme/sr_theme.dart';
import 'package:sapiens_rank/l10n/app_localizations.dart';
import 'package:sapiens_rank/models/habits_data.dart';
import 'package:sapiens_rank/screens/onboarding/widgets/arena_button.dart';
import 'package:sapiens_rank/screens/onboarding/widgets/habit_choice_card.dart';
import 'package:sapiens_rank/screens/onboarding/widgets/step_shell.dart';

enum _SmokingChoice { no, yes, decline }

class SmokingStep extends StatefulWidget {
  const SmokingStep({
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
  State<SmokingStep> createState() => _SmokingStepState();
}

class _SmokingStepState extends State<SmokingStep> {
  late _SmokingChoice _choice;
  late double _cigarettes;

  @override
  void initState() {
    super.initState();
    if (widget.initialData.smokes == null) {
      _choice = _SmokingChoice.decline;
    } else if (widget.initialData.smokes!) {
      _choice = _SmokingChoice.yes;
    } else {
      _choice = _SmokingChoice.no;
    }
    _cigarettes = (widget.initialData.cigarettesPerDay ?? 10).toDouble();
  }

  HabitsData get _current {
    final bool? smokes = switch (_choice) {
      _SmokingChoice.no => false,
      _SmokingChoice.yes => true,
      _SmokingChoice.decline => null,
    };
    return HabitsData(
      heightCm: widget.initialData.heightCm,
      weightKg: widget.initialData.weightKg,
      bmiFrequency: widget.initialData.bmiFrequency,
      smokes: smokes,
      cigarettesPerDay: _choice == _SmokingChoice.yes
          ? _cigarettes.round()
          : null,
      drinks: widget.initialData.drinks,
      drinksPerWeek: widget.initialData.drinksPerWeek,
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
            label: AppLocalizations.of(context).onboarding_age_cta,
            onTap: () => widget.onSubmit(_current),
          ),
          const SizedBox(height: 4),
          ArenaSecondaryButton(label: AppLocalizations.of(context).back, onTap: widget.onBack),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).profile_habits,
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
                TextSpan(text: '${AppLocalizations.of(context).onboarding_habits_do_you} '),
                TextSpan(
                  text: AppLocalizations.of(context).onboarding_smoking_verb,
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
            AppLocalizations.of(context).onboarding_habits_score_hint,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium!.copyWith(color: context.srTextMuted),
          ),
          const SizedBox(height: 28),
          HabitChoiceCard(
            selected: _choice == _SmokingChoice.no,
            icon: '🚭',
            title: AppLocalizations.of(context).onboarding_smoking_no,
            subtitle: AppLocalizations.of(context).onboarding_habits_no_impact,
            onTap: () => setState(() => _choice = _SmokingChoice.no),
          ),
          const SizedBox(height: 10),
          HabitChoiceCard(
            selected: _choice == _SmokingChoice.yes,
            icon: '🚬',
            title: AppLocalizations.of(context).onboarding_habits_yes,
            subtitle: AppLocalizations.of(context).onboarding_habits_quantity_impact,
            onTap: () => setState(() => _choice = _SmokingChoice.yes),
          ),
          if (_choice == _SmokingChoice.yes) ...[
            const SizedBox(height: 12),
            HabitQuantitySlider(
              label: AppLocalizations.of(context).onboarding_smoking_count,
              value: _cigarettes,
              min: 1,
              max: 40,
              divisions: 39,
              color: SrColors.rose,
              format: (v) => '${v.round()}',
              onChanged: (v) => setState(() => _cigarettes = v.roundToDouble()),
            ),
          ],
          const SizedBox(height: 10),
          HabitChoiceCard(
            selected: _choice == _SmokingChoice.decline,
            icon: '🔒',
            title: AppLocalizations.of(context).onboarding_habits_decline,
            subtitle: AppLocalizations.of(context).onboarding_habits_still_affects,
            onTap: () => setState(() => _choice = _SmokingChoice.decline),
          ),
        ],
      ),
    );
  }
}
