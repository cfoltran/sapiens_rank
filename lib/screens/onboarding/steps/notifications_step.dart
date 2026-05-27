import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sapiens_rank/common/theme/colors.dart';
import 'package:sapiens_rank/screens/onboarding/widgets/arena_button.dart';
import 'package:sapiens_rank/screens/onboarding/widgets/onboarding_text.dart';
import 'package:sapiens_rank/screens/onboarding/widgets/step_shell.dart';

class NotificationsStep extends StatefulWidget {
  const NotificationsStep({
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
  State<NotificationsStep> createState() => _NotificationsStepState();
}

class _NotificationsStepState extends State<NotificationsStep> {
  bool _granted = false;

  void _grant() {
    setState(() => _granted = true);
    Timer(const Duration(milliseconds: 600), () {
      if (mounted) widget.onNext();
    });
  }

  @override
  Widget build(BuildContext context) {
    return StepShell(
      progress: widget.progress,
      total: widget.total,
      footer: Column(
        children: [
          ArenaButton(label: 'Yes, keep me in the loop 🔔', onTap: _grant),
          const SizedBox(height: 8),
          ArenaSecondaryButton(label: 'Not now', onTap: widget.onNext),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const OnboardingEyebrow('Last thing.'),
          const SizedBox(height: 14),
          const _Headline(),
          const SizedBox(height: 10),
          const OnboardingLede(
            'Daily score updates. Fight invites. When a friend passes you, you\'ll know.',
          ),
          const SizedBox(height: 28),
          const _NotifPreview(
            icon: '⚔️',
            title: 'Émile challenged you',
            body: '1v1 · Sapiens Score · 24h · Coffee on the line',
            time: '2m',
          ),
          const SizedBox(height: 8),
          const _NotifPreview(
            icon: '📈',
            title: 'You climbed 184 spots',
            body: 'World rank is now #2,847 - top 0.4%',
            time: '9m',
          ),
          const SizedBox(height: 8),
          const _NotifPreview(
            icon: '😴',
            title: 'Sleep score: 92',
            body: 'Best night of the week. Recovery looking elite.',
            time: 'this morning',
            muted: true,
          ),
          if (_granted) ...[
            const SizedBox(height: 24),
            AnimatedOpacity(
              opacity: _granted ? 1 : 0,
              duration: const Duration(milliseconds: 400),
              child: Center(
                child: Text(
                  'Welcome to the ranks, Sapien. ✓',
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    fontStyle: FontStyle.italic,
                    color: SrColors.lime,
                  ),
                ),
              ),
            ),
          ],
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
        style: Theme.of(context).textTheme.displayMedium!.copyWith(
          fontStyle: FontStyle.normal,
          color: SrColors.text,
        ),
        children: const [
          TextSpan(text: 'Stay in the '),
          TextSpan(
            text: 'fight.',
            style: TextStyle(fontStyle: FontStyle.italic, color: SrColors.lime),
          ),
        ],
      ),
    );
  }
}

class _NotifPreview extends StatelessWidget {
  const _NotifPreview({
    required this.icon,
    required this.title,
    required this.body,
    required this.time,
    this.muted = false,
  });

  final String icon;
  final String title;
  final String body;
  final String time;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Opacity(
      opacity: muted ? 0.7 : 1.0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: muted ? const Color(0x05FFFFFF) : const Color(0x0AFFFFFF),
          border: Border.all(color: SrColors.line),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: SrColors.lime,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(icon, style: const TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: tt.bodyMedium!.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: SrColors.text,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        time,
                        style: tt.labelSmall!.copyWith(
                          fontWeight: FontWeight.normal,
                          color: SrColors.textDim,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    body,
                    style: tt.bodySmall!.copyWith(color: SrColors.textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
