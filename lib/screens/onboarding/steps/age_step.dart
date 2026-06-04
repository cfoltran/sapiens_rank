import 'package:flutter/material.dart';
import 'package:sapiens_rank/common/theme/sr_slider.dart';
import 'package:sapiens_rank/common/theme/sr_theme.dart';
import 'package:sapiens_rank/screens/onboarding/widgets/arena_button.dart';
import 'package:sapiens_rank/screens/onboarding/widgets/onboarding_text.dart';
import 'package:sapiens_rank/screens/onboarding/widgets/step_shell.dart';

class AgeStep extends StatefulWidget {
  const AgeStep({
    super.key,
    required this.progress,
    required this.total,
    required this.initialAge,
    required this.onSubmit,
    required this.onBack,
  });

  final int progress;
  final int total;
  final int initialAge;
  final void Function(int age) onSubmit;
  final VoidCallback onBack;

  @override
  State<AgeStep> createState() => _AgeStepState();
}

class _AgeStepState extends State<AgeStep> {
  late int _age;

  @override
  void initState() {
    super.initState();
    _age = widget.initialAge;
  }

  @override
  Widget build(BuildContext context) {
    return StepShell(
      progress: widget.progress,
      total: widget.total,
      footer: Column(
        children: [
          ArenaButton(label: 'Continue →', onTap: () => widget.onSubmit(_age)),
          const SizedBox(height: 8),
          ArenaSecondaryButton(label: 'Back', onTap: widget.onBack),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const OnboardingEyebrow('Calibration'),
          const SizedBox(height: 14),
          Text(
            'How old are you?',
            style: Theme.of(
              context,
            ).textTheme.displayMedium!.copyWith(color: context.srText),
          ),
          const SizedBox(height: 10),
          const OnboardingLede(
            "We'll baseline you against your cohort, not against 18-year-old triathletes.",
          ),
          const SizedBox(height: 48),
          _AgeSlider(age: _age, onChanged: (v) => setState(() => _age = v)),
        ],
      ),
    );
  }
}

class _AgeSlider extends StatelessWidget {
  const _AgeSlider({required this.age, required this.onChanged});

  final int age;
  final void Function(int) onChanged;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              'AGE',
              style: tt.labelSmall!.copyWith(
                color: context.srTextDim,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              '$age',
              style: tt.displayLarge!.copyWith(
                fontSize: 48,
                fontStyle: FontStyle.normal,
                height: 1,
                letterSpacing: 48 * -0.04,
                color: context.srLimeText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SrSlider(
          value: age.toDouble(),
          min: 16,
          max: 80,
          divisions: 64,
          color: context.srLime,
          onChanged: (v) => onChanged(v.round()),
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '16',
                style: tt.labelSmall!.copyWith(
                  fontWeight: FontWeight.normal,
                  color: context.srTextDim,
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                '80',
                style: tt.labelSmall!.copyWith(
                  fontWeight: FontWeight.normal,
                  color: context.srTextDim,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
