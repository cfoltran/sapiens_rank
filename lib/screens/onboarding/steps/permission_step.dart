import 'package:flutter/material.dart';
import 'package:sapiens_rank/common/theme/colors.dart';
import 'package:sapiens_rank/common/theme/sr_theme.dart';
import 'package:sapiens_rank/l10n/app_localizations.dart';
import 'package:sapiens_rank/screens/onboarding/widgets/arena_button.dart';
import 'package:sapiens_rank/screens/onboarding/widgets/onboarding_text.dart';
import 'package:sapiens_rank/screens/onboarding/widgets/step_shell.dart';
import 'package:url_launcher/url_launcher.dart';

class PermissionStep extends StatelessWidget {
  const PermissionStep({
    super.key,
    required this.progress,
    required this.total,
    required this.onNext,
    required this.onBack,
    this.denied = false,
    this.isLoading = false,
  });

  final int progress;
  final int total;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final bool denied;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return StepShell(
      progress: progress,
      total: total,
      footer: Column(
        children: [
          ArenaButton(
            label: denied ? AppLocalizations.of(context).onboarding_permission_settings : AppLocalizations.of(context).onboarding_permission_cta,
            isLoading: isLoading,
            onTap: denied
                ? () => launchUrl(Uri.parse('app-settings:'))
                : onNext,
          ),
          const SizedBox(height: 8),
          ArenaSecondaryButton(label: AppLocalizations.of(context).back, onTap: onBack),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OnboardingEyebrow(AppLocalizations.of(context).onboarding_permission_headline),
          const SizedBox(height: 14),
          _Headline(),
          const SizedBox(height: 28),
          const _HealthKitCards(),
          const SizedBox(height: 22),
          if (denied) ...[_DeniedBanner(), const SizedBox(height: 12)],
          const _PrivacyNote(),
        ],
      ),
    );
  }
}

class _Headline extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: Theme.of(
          context,
        ).textTheme.displayMedium!.copyWith(color: context.srText),
        children: [
          TextSpan(text: '${AppLocalizations.of(context).onboarding_permission_subheadline} '),
          TextSpan(
            text: AppLocalizations.of(context).onboarding_permission_body,
            style: const TextStyle(color: SrColors.cyan),
          ),
        ],
      ),
    );
  }
}

class _DeniedBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: SrColors.rose.withAlpha(20),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: SrColors.rose.withAlpha(80)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('⚠️', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.labelMedium!.copyWith(
                  fontWeight: FontWeight.normal,
                  color: context.srText,
                  height: 1.5,
                ),
                children: [
                  TextSpan(
                    text: '${AppLocalizations.of(context).onboarding_permission_denied_body} ',
                  ),
                  TextSpan(
                    text: AppLocalizations.of(context).onboarding_permission_denied_path,
                    style: const TextStyle(
                      color: SrColors.rose,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(text: ' ${AppLocalizations.of(context).onboarding_permission_denied_enable}'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HealthKitCards extends StatelessWidget {
  const _HealthKitCards();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final items = [
      (icon: '❤️', label: l.onboarding_permission_heart_rate, desc: l.onboarding_permission_heart_rate_sub),
      (icon: '🦶', label: l.onboarding_permission_activity, desc: l.onboarding_permission_activity_sub),
      (icon: '😴', label: l.onboarding_permission_sleep, desc: l.onboarding_permission_sleep_sub),
      (icon: '🧍', label: l.onboarding_permission_stand, desc: l.onboarding_permission_stand_sub),
    ];
    return Column(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          _HealthKitCard(item: items[i]),
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
        color: context.srTintXs,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.srLine),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: context.srTintSm,
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
                    color: context.srText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.desc,
                  style: tt.labelMedium!.copyWith(
                    fontWeight: FontWeight.normal,
                    color: context.srTextDim,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.check, size: 16, color: context.srLimeText),
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
        color: SrColors.cyanSubtle,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: SrColors.cyanBorder),
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
                  color: context.srText,
                  height: 1.5,
                ),
                children: [
                  TextSpan(
                    text: '${AppLocalizations.of(context).onboarding_privacy_body} ',
                  ),
                  TextSpan(
                    text: AppLocalizations.of(context).onboarding_privacy_accent,
                    style: const TextStyle(color: SrColors.cyan),
                  ),
                  TextSpan(text: ' ${AppLocalizations.of(context).onboarding_privacy_suffix}'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
