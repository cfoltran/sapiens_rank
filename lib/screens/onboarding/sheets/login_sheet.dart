import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sapiens_rank/common/theme/sr_theme.dart';
import 'package:sapiens_rank/common/widgets/sr_bottom_sheet.dart';
import 'package:sapiens_rank/screens/onboarding/sheets/email_auth_sheet.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

class LoginSheet extends StatelessWidget {
  const LoginSheet({super.key, required this.onAuth});

  final VoidCallback onAuth;

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onAuth,
  }) {
    return SrBottomSheet.show(
      context: context,
      title: 'Welcome back',
      child: LoginSheet(onAuth: onAuth),
    );
  }

  void _complete(BuildContext context) {
    Navigator.of(context).pop();
    onAuth();
  }

  void _showEmailSheet(BuildContext context) {
    Navigator.of(context).pop();
    EmailAuthSheet.show(context, onAuth: onAuth);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (Platform.isIOS) ...[
          SupaSocialsAuth(
            socialProviders: const [OAuthProvider.apple],
            enableNativeAppleAuth: true,
            redirectUrl: 'com.pommef.sapiensrank/',
            onSuccess: (_) => _complete(context),
            showSuccessSnackBar: false,
          ),
          const SizedBox(height: 4),
          _OrDivider(),
          Center(
            child: TextButton(
              onPressed: () => _showEmailSheet(context),
              child: Text(
                'Continue with email',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: context.srTextMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ] else ...[
          SupaEmailAuth(
            redirectTo: 'com.pommef.sapiensrank/',
            onSignInComplete: (_) => _complete(context),
            onSignUpComplete: (_) => _complete(context),
          ),
        ],
      ],
    );
  }
}

class _OrDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) => Row(
        children: [
          Expanded(child: Divider(color: context.srLine)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'or',
              style: Theme.of(context).textTheme.labelMedium!.copyWith(
                color: context.srTextDim,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          Expanded(child: Divider(color: context.srLine)),
        ],
      ),
    );
  }
}
