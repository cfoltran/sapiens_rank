import 'package:flutter/material.dart';
import 'package:sapiens_rank/common/theme/sr_theme.dart';

class OnboardingEyebrow extends StatelessWidget {
  const OnboardingEyebrow(this.text, {super.key, this.color});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(
        context,
      ).textTheme.labelMedium!.copyWith(color: color ?? context.srLimeText),
    );
  }
}

class OnboardingLede extends StatelessWidget {
  const OnboardingLede(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.bodyLarge!.copyWith(color: context.srTextMuted, height: 1.4),
    );
  }
}
