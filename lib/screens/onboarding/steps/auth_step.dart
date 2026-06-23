import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sapiens_rank/common/theme/colors.dart';
import 'package:sapiens_rank/common/theme/sr_theme.dart';
import 'package:sapiens_rank/l10n/app_localizations.dart';
import 'package:sapiens_rank/screens/onboarding/sheets/email_auth_sheet.dart';
import 'package:sapiens_rank/screens/onboarding/widgets/onboarding_text.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

class AuthStep extends StatelessWidget {
  const AuthStep({
    super.key,
    required this.firstName,
    required this.isLoading,
    required this.onAuth,
    required this.onBack,
  });

  final String firstName;
  final bool isLoading;
  final VoidCallback onAuth;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final name = firstName.isNotEmpty ? firstName.split(' ').first : 'Sapien';

    return Scaffold(
      backgroundColor: context.srBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 32, 22, 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: onBack,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 14,
                      color: context.srTextMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      AppLocalizations.of(context).back,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: context.srTextMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              OnboardingEyebrow(AppLocalizations.of(context).onboarding_auth_headline, color: SrColors.magenta),
              const SizedBox(height: 14),
              RichText(
                text: TextSpan(
                  style: tt.displayMedium!.copyWith(color: context.srText),
                  children: [
                    TextSpan(text: '$name, '),
                    TextSpan(
                      text: AppLocalizations.of(context).onboarding_auth_subheadline,
                      style: TextStyle(color: context.srLimeText),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              OnboardingLede(AppLocalizations.of(context).onboarding_auth_body),
              const Spacer(),
              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else ...[
                if (Platform.isIOS) ...[
                  SupaSocialsAuth(
                    socialProviders: const [OAuthProvider.apple],
                    enableNativeAppleAuth: true,
                    redirectUrl: 'com.pommef.sapiensrank/',
                    onSuccess: (_) => onAuth(),
                    showSuccessSnackBar: false,
                  ),
                  const SizedBox(height: 12),
                ],
                const _Divider(),
                const SizedBox(height: 4),
                Center(
                  child: TextButton(
                    onPressed: () =>
                        EmailAuthSheet.show(context, onAuth: onAuth),
                    child: Text(
                      AppLocalizations.of(context).onboarding_auth_email,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: context.srTextMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: context.srLine)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            AppLocalizations.of(context).onboarding_auth_or,
            style: Theme.of(context).textTheme.labelMedium!.copyWith(
              color: context.srTextDim,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        Expanded(child: Divider(color: context.srLine)),
      ],
    );
  }
}
