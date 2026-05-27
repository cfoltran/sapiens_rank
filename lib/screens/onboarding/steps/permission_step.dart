import 'package:flutter/material.dart';
import 'package:sapiens_rank/common/theme/colors.dart';
import 'package:sapiens_rank/screens/onboarding/widgets/arena_button.dart';
import 'package:sapiens_rank/screens/onboarding/widgets/onboarding_text.dart';
import 'package:sapiens_rank/screens/onboarding/widgets/step_shell.dart';

class PermissionStep extends StatelessWidget {
  const PermissionStep({
    super.key,
    required this.progress,
    required this.total,
    required this.onNext,
    required this.onBack,
  });

  final int progress;
  final int total;
  final VoidCallback onNext;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return StepShell(
      progress: progress,
      total: total,
      footer: Column(
        children: [
          ArenaButton(label: 'Allow health access →', onTap: onNext),
          const SizedBox(height: 8),
          ArenaSecondaryButton(label: 'Back', onTap: onBack),
        ],
      ),
      body: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OnboardingEyebrow('One permission. Worth it.'),
          SizedBox(height: 14),
          _Headline(),
          SizedBox(height: 28),
          _HealthKitCards(),
          SizedBox(height: 22),
          _PrivacyNote(),
        ],
      ),
    );
  }
}

class _Headline extends StatelessWidget {
  const _Headline();

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: Theme.of(
          context,
        ).textTheme.displayMedium!.copyWith(color: SrColors.text),
        children: const [
          TextSpan(text: 'Your Watch knows\neverything. '),
          TextSpan(
            text: 'We just do the math.',
            style: TextStyle(color: SrColors.cyan),
          ),
        ],
      ),
    );
  }
}

class _HealthKitCards extends StatelessWidget {
  const _HealthKitCards();

  static const _items = [
    (icon: '❤️', label: 'Heart Rate', desc: 'Resting + HRV'),
    (icon: '🦶', label: 'Activity', desc: 'Steps, distance, kcal'),
    (icon: '😴', label: 'Sleep Analysis', desc: 'Stages, duration, score'),
    (icon: '🧍', label: 'Stand Hours', desc: 'Hours moved per day'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < _items.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          _HealthKitCard(item: _items[i]),
        ],
      ],
    );
  }
}

class _HealthKitCard extends StatelessWidget {
  const _HealthKitCard({required this.item});

  final ({String icon, String label, String desc}) item;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0x08FFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SrColors.line),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0x0DFFFFFF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(item.icon, style: const TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: tt.bodyMedium!.copyWith(
                    fontWeight: FontWeight.w600,
                    color: SrColors.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.desc,
                  style: tt.labelMedium!.copyWith(
                    fontWeight: FontWeight.normal,
                    color: SrColors.textDim,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.check, size: 16, color: SrColors.lime),
        ],
      ),
    );
  }
}

class _PrivacyNote extends StatelessWidget {
  const _PrivacyNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0x0D5CE1FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x335CE1FF)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🔒', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.labelMedium!.copyWith(
                  fontWeight: FontWeight.normal,
                  color: SrColors.text,
                  height: 1.5,
                ),
                children: const [
                  TextSpan(
                    text: 'Your data never leaves your phone. Only your ',
                  ),
                  TextSpan(
                    text: 'score and rank',
                    style: TextStyle(color: SrColors.cyan),
                  ),
                  TextSpan(text: ' are uploaded — never the raw numbers.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
