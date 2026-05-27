import 'package:flutter/material.dart';
import 'package:sapiens_rank/common/theme/colors.dart';
import 'package:sapiens_rank/screens/onboarding/widgets/arena_button.dart';
import 'package:sapiens_rank/screens/onboarding/widgets/onboarding_text.dart';
import 'package:sapiens_rank/screens/onboarding/widgets/sr_text_field.dart';
import 'package:sapiens_rank/screens/onboarding/widgets/step_shell.dart';

class NameStep extends StatefulWidget {
  const NameStep({
    super.key,
    required this.progress,
    required this.total,
    required this.initialValue,
    required this.onSubmit,
    required this.onBack,
  });

  final int progress;
  final int total;
  final String initialValue;
  final void Function(String name) onSubmit;
  final VoidCallback onBack;

  @override
  State<NameStep> createState() => _NameStepState();
}

class _NameStepState extends State<NameStep> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialValue);
    _ctrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String get _initials {
    final words = _ctrl.text.trim().split(RegExp(r'\s+'));
    return words
        .map((w) => w.isNotEmpty ? w[0] : '')
        .take(2)
        .join()
        .toUpperCase();
  }

  String get _handle {
    final slug = _ctrl.text.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
    final trimmed = slug.length > 12 ? slug.substring(0, 12) : slug;
    return '@${trimmed.isEmpty ? 'sapien' : trimmed}';
  }

  bool get _canSubmit => _ctrl.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return StepShell(
      progress: widget.progress,
      total: widget.total,
      footer: Column(
        children: [
          ArenaButton(
            label: "That's me →",
            onTap: _canSubmit ? () => widget.onSubmit(_ctrl.text.trim()) : null,
          ),
          const SizedBox(height: 8),
          ArenaSecondaryButton(label: 'Back', onTap: widget.onBack),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const OnboardingEyebrow('Identity check'),
          const SizedBox(height: 14),
          Text(
            'What should the\nworld call you?',
            style: Theme.of(
              context,
            ).textTheme.displayMedium!.copyWith(color: SrColors.text),
          ),
          const SizedBox(height: 10),
          const OnboardingLede(
            "You can change it later. The leaderboard doesn't care, but your friends will.",
          ),
          const SizedBox(height: 40),
          _AvatarPreview(
            initials: _initials.isEmpty ? '?' : _initials,
            handle: _handle,
          ),
          const SizedBox(height: 36),
          _NameInput(controller: _ctrl, hasText: _ctrl.text.isNotEmpty),
        ],
      ),
    );
  }
}

class _AvatarPreview extends StatelessWidget {
  const _AvatarPreview({required this.initials, required this.handle});

  final String initials;
  final String handle;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Column(
      children: [
        Center(
          child: Container(
            width: 104,
            height: 104,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: SrColors.lime,
              boxShadow: [
                BoxShadow(
                  color: SrColors.lime.withAlpha(60),
                  blurRadius: 28,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Text(
                initials,
                style: tt.headlineLarge!.copyWith(
                  fontStyle: FontStyle.normal,
                  color: SrColors.textInk,
                  letterSpacing: -1.5,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Center(
          child: Text(
            handle,
            style: tt.labelMedium!.copyWith(
              fontWeight: FontWeight.normal,
              color: SrColors.textMuted,
              letterSpacing: 0.6,
            ),
          ),
        ),
      ],
    );
  }
}

class _NameInput extends StatelessWidget {
  const _NameInput({required this.controller, required this.hasText});

  final TextEditingController controller;
  final bool hasText;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final borderColor = hasText ? SrColors.lime : SrColors.lineStrong;

    return SrTextField(
      controller: controller,
      hintText: 'First & last name',
      style: tt.titleSmall!.copyWith(fontWeight: FontWeight.w500),
      autofocus: true,
      textCapitalization: TextCapitalization.words,
      borderColor: borderColor,
      focusedBorderColor: borderColor,
    );
  }
}
