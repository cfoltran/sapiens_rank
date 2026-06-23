import 'package:flutter/material.dart';
import 'package:sapiens_rank/common/theme/sr_theme.dart';
import 'package:sapiens_rank/l10n/app_localizations.dart';
import 'package:sapiens_rank/screens/onboarding/widgets/arena_button.dart';
import 'package:sapiens_rank/screens/onboarding/widgets/onboarding_text.dart';
import 'package:sapiens_rank/screens/onboarding/widgets/step_shell.dart';
import 'package:sapiens_rank/services/messaging_service.dart';

class NotificationsStep extends StatefulWidget {
  const NotificationsStep({super.key, required this.onNext});

  final VoidCallback onNext;

  @override
  State<NotificationsStep> createState() => _NotificationsStepState();
}

class _NotificationsStepState extends State<NotificationsStep> {
  bool _loading = false;
  bool _granted = false;

  Future<void> _requestPermission() async {
    if (_loading) return;
    setState(() => _loading = true);
    final granted = await MessagingService.instance.requestPermission();
    if (!mounted) return;
    setState(() {
      _loading = false;
      _granted = granted;
    });
    await Future.delayed(const Duration(milliseconds: 700));
    if (mounted) widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    return StepShell(
      progress: 0,
      total: 0,
      footer: Column(
        children: [
          ArenaButton(
            label: _loading ? AppLocalizations.of(context).onboarding_notif_authorizing : AppLocalizations.of(context).onboarding_notif_yes,
            onTap: _loading ? null : _requestPermission,
          ),
          const SizedBox(height: 8),
          ArenaSecondaryButton(
            label: AppLocalizations.of(context).onboarding_notif_skip,
            onTap: _loading ? () {} : widget.onNext,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OnboardingEyebrow(AppLocalizations.of(context).onboarding_notif_headline),
          const SizedBox(height: 14),
          _Headline(),
          const SizedBox(height: 10),
          OnboardingLede(AppLocalizations.of(context).onboarding_notif_body),
          const SizedBox(height: 28),
          _NotifPreview(
            icon: '⚔️',
            title: 'Émile challenged you',
            body: '1v1 · Sapiens Score · 24h · Coffee on the line',
            time: '2m',
          ),
          const SizedBox(height: 8),
          _NotifPreview(
            icon: '📈',
            title: 'You climbed 184 spots',
            body: 'World rank is now #2,847 — top 0.4%',
            time: '9m',
          ),
          const SizedBox(height: 8),
          _NotifPreview(
            icon: '😴',
            title: 'Sleep score: 92',
            body: 'Best night of the week. Recovery looking elite.',
            time: 'this morning',
            muted: true,
          ),
          if (_granted) ...[
            const SizedBox(height: 24),
            AnimatedOpacity(
              opacity: 1,
              duration: const Duration(milliseconds: 400),
              child: Center(
                child: Text(
                  AppLocalizations.of(context).onboarding_notif_granted,
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    fontStyle: FontStyle.italic,
                    color: context.srLimeText,
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
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return RichText(
      text: TextSpan(
        style: Theme.of(context).textTheme.displayMedium!.copyWith(
          fontStyle: FontStyle.normal,
          color: context.srText,
        ),
        children: [
          TextSpan(text: '${l.onboarding_notif_headline_prefix} '),
          TextSpan(
            text: l.onboarding_notif_headline_accent,
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: context.srLimeText,
            ),
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
          color: muted ? context.srTintXxs : context.srTintXs,
          border: Border.all(color: context.srLine),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: context.srLime,
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
                            color: context.srText,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        time,
                        style: tt.labelSmall!.copyWith(
                          fontWeight: FontWeight.normal,
                          color: context.srTextDim,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    body,
                    style: tt.bodySmall!.copyWith(color: context.srTextMuted),
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
