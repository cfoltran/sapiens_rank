import 'package:flutter/material.dart';
import 'package:sapiens_rank/common/theme/colors.dart';
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
            ).textTheme.displayMedium!.copyWith(color: SrColors.text),
          ),
          const SizedBox(height: 10),
          const OnboardingLede(
            "We'll baseline you against your cohort — not against 18-year-old triathletes.",
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
                color: SrColors.textDim,
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
                color: SrColors.lime,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: SrColors.lime,
            inactiveTrackColor: SrColors.lineStrong,
            thumbColor: SrColors.lime,
            overlayColor: SrColors.lime.withAlpha(30),
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
          ),
          child: Slider(
            min: 16,
            max: 80,
            value: age.toDouble(),
            onChanged: (v) => onChanged(v.round()),
          ),
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
                  color: SrColors.textDim,
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                '80',
                style: tt.labelSmall!.copyWith(
                  fontWeight: FontWeight.normal,
                  color: SrColors.textDim,
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
