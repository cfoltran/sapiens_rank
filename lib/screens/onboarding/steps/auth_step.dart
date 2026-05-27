import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sapiens_rank/common/theme/colors.dart';
import 'package:sapiens_rank/screens/onboarding/widgets/onboarding_text.dart';
import 'package:sapiens_rank/screens/onboarding/widgets/sr_text_field.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

class AuthStep extends StatefulWidget {
  const AuthStep({super.key, required this.firstName, required this.onAuth});

  final String firstName;
  final VoidCallback onAuth;

  @override
  State<AuthStep> createState() => _AuthStepState();
}

class _AuthStepState extends State<AuthStep> {
  final _emailCtrl = TextEditingController();
  bool _loading = false;
  bool _sent = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendMagicLink() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await Supabase.instance.client.auth.signInWithOtp(
        email: email,
        shouldCreateUser: true,
      );
      if (mounted) {
        setState(() {
          _sent = true;
          _loading = false;
        });
      }

      Supabase.instance.client.auth.onAuthStateChange.listen((event) {
        if (event.event == AuthChangeEvent.signedIn && mounted) {
          widget.onAuth();
        }
      });
    } on AuthException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: SrColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 32, 22, 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const OnboardingEyebrow('Almost there.', color: SrColors.magenta),
              const SizedBox(height: 14),
              RichText(
                text: TextSpan(
                  style: tt.displayMedium!.copyWith(color: SrColors.text),
                  children: [
                    TextSpan(
                      text:
                          '${widget.firstName.isNotEmpty ? widget.firstName.split(' ').first : 'Sapien'}, ',
                    ),
                    const TextSpan(
                      text: 'save your rank.',
                      style: TextStyle(color: SrColors.lime),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const OnboardingLede(
                "Your score, rank, and archetype are rea dy. Create an account to keep them.",
              ),
              const SizedBox(height: 40),
              if (_sent) ...[
                _SentConfirmation(email: _emailCtrl.text.trim()),
              ] else ...[
                if (Platform.isIOS) ...[
                  SupaSocialsAuth(
                    socialProviders: const [OAuthProvider.apple],
                    enableNativeAppleAuth: true,
                    redirectUrl: 'io.supabase.sapiensrank://login-callback/',
                    onSuccess: (_) => widget.onAuth(),
                    showSuccessSnackBar: false,
                    onError: (error) {
                      if (mounted) {
                        setState(() => _error = error.toString());
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  const _Divider(),
                  const SizedBox(height: 16),
                ],
                _EmailInput(controller: _emailCtrl),
                const SizedBox(height: 12),
                _MagicLinkButton(loading: _loading, onTap: _sendMagicLink),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: tt.labelMedium!.copyWith(
                      fontWeight: FontWeight.normal,
                      color: SrColors.rose,
                    ),
                  ),
                ],
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
        const Expanded(child: Divider(color: Color(0x18FFFFFF))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'or',
            style: Theme.of(context).textTheme.labelMedium!.copyWith(
              fontWeight: FontWeight.normal,
              color: SrColors.textDim,
            ),
          ),
        ),
        const Expanded(child: Divider(color: Color(0x18FFFFFF))),
      ],
    );
  }
}

class _EmailInput extends StatelessWidget {
  const _EmailInput({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return SrTextField(
      controller: controller,
      hintText: 'your@email.com',
      keyboardType: TextInputType.emailAddress,
      autocorrect: false,
    );
  }
}

class _MagicLinkButton extends StatelessWidget {
  const _MagicLinkButton({required this.loading, required this.onTap});
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 17),
        decoration: BoxDecoration(
          color: SrColors.lime,
          borderRadius: BorderRadius.circular(100),
          boxShadow: [
            BoxShadow(
              color: SrColors.lime.withAlpha(51),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: SrColors.textInk,
                  ),
                )
              : Text(
                  'Send magic link →',
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    fontWeight: FontWeight.w700,
                    color: SrColors.textInk,
                  ),
                ),
        ),
      ),
    );
  }
}

class _SentConfirmation extends StatelessWidget {
  const _SentConfirmation({required this.email});
  final String email;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0x14D9FF3D),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x40D9FF3D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('📬', style: TextStyle(fontSize: 32)),
          const SizedBox(height: 12),
          Text(
            'Check your inbox',
            style: tt.titleMedium!.copyWith(color: SrColors.text),
          ),
          const SizedBox(height: 6),
          Text(
            'Magic link sent to $email.\nTap it to complete your account.',
            style: tt.bodyMedium!.copyWith(color: SrColors.textMuted),
          ),
        ],
      ),
    );
  }
}
