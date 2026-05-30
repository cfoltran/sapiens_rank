import 'package:flutter/material.dart';
import 'package:sapiens_rank/common/widgets/sr_bottom_sheet.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

class EmailAuthSheet extends StatelessWidget {
  const EmailAuthSheet({super.key, required this.onAuth});

  final VoidCallback onAuth;

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onAuth,
  }) {
    return SrBottomSheet.show(
      context: context,
      title: 'Continue with email',
      child: EmailAuthSheet(onAuth: onAuth),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SupaEmailAuth(
      redirectTo: 'io.supabase.sapiensrank://login-callback/',
      onSignInComplete: (_) {
        Navigator.of(context).pop();
        onAuth();
      },
      onSignUpComplete: (_) {
        Navigator.of(context).pop();
        onAuth();
      },
    );
  }
}
