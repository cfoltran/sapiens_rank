import 'package:flutter/material.dart';
import 'package:sapiens_rank/common/theme/colors.dart';
import 'package:sapiens_rank/common/theme/sr_theme.dart';
import 'package:sapiens_rank/screens/onboarding/widgets/arena_button.dart';
import 'package:sapiens_rank/screens/onboarding/widgets/onboarding_text.dart';
import 'package:sapiens_rank/screens/onboarding/widgets/sr_selectable_card.dart';
import 'package:sapiens_rank/screens/onboarding/widgets/step_shell.dart';

class FirstFightStep extends StatefulWidget {
  const FirstFightStep({
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
  State<FirstFightStep> createState() => _FirstFightStepState();
}

class _FirstFightStepState extends State<FirstFightStep> {
  String _reward = 'coffee';

  @override
  Widget build(BuildContext context) {
    return StepShell(
      progress: widget.progress,
      total: widget.total,
      footer: Column(
        children: [
          ArenaButton(
            label: '⚔️ Send challenge',
            onTap: widget.onNext,
            color: SrColors.magenta,
          ),
          const SizedBox(height: 8),
          ArenaSecondaryButton(label: 'Maybe later', onTap: widget.onNext),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const OnboardingEyebrow("Don't just rank.", color: SrColors.magenta),
          const SizedBox(height: 6),
          Text(
            'Fight.',
            style: Theme.of(context).textTheme.displayLarge!.copyWith(
              height: 1.0,
              color: context.srText,
            ),
          ),
          const SizedBox(height: 10),
          const _Lede(),
          const SizedBox(height: 28),
          _FaceOffCard(),
          const SizedBox(height: 22),
          _StakeSection(
            selected: _reward,
            onSelect: (id) => setState(() => _reward = id),
          ),
        ],
      ),
    );
  }
}

class _Lede extends StatelessWidget {
  const _Lede();

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: Theme.of(
          context,
        ).textTheme.bodyLarge!.copyWith(color: context.srTextMuted),
        children: [
          const TextSpan(text: 'Émile is sitting '),
          TextSpan(
            text: '3 points behind you',
            style: TextStyle(color: context.srLimeText),
          ),
          const TextSpan(text: '. Make him sweat.'),
        ],
      ),
    );
  }
}

class _FaceOffCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [context.srBgElev2, context.srBgElev],
        ),
        border: Border.all(color: SrColors.magentaBorder),
        boxShadow: const [
          BoxShadow(color: SrColors.magentaFaint, blurRadius: 40),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [SrColors.magentaGlow, Colors.transparent],
                  stops: [0.0, 0.7],
                ),
              ),
            ),
          ),
          Column(
            children: [
              Row(
                children: [
                  Expanded(child: _Fighter(isMe: true)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'VS',
                      style: tt.headlineMedium!.copyWith(
                        color: SrColors.magenta,
                      ),
                    ),
                  ),
                  Expanded(child: _Fighter(isMe: false)),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Sapiens Score · next 24 hours',
                  textAlign: TextAlign.center,
                  style: tt.labelMedium!.copyWith(
                    fontWeight: FontWeight.normal,
                    color: context.srTextMuted,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Fighter extends StatelessWidget {
  const _Fighter({required this.isMe});
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isMe ? context.srLime : SrColors.yellow,
            boxShadow: isMe
                ? [
                    BoxShadow(
                      color: context.srLime.withAlpha(80),
                      blurRadius: 16,
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              isMe ? 'YO' : 'EL',
              style: tt.titleSmall!.copyWith(color: SrColors.textInk),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isMe ? 'You' : 'Émile',
          style: tt.bodyMedium!.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: context.srText,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          isMe ? '87' : '84',
          style: tt.headlineLarge!.copyWith(
            height: 1,
            color: isMe ? context.srLimeText : context.srText.withAlpha(150),
          ),
        ),
      ],
    );
  }
}

class _StakeSection extends StatelessWidget {
  const _StakeSection({required this.selected, required this.onSelect});

  final String selected;
  final void Function(String) onSelect;

  static const _rewards = [
    (id: 'coffee', label: 'Coffee ☕', desc: 'Loser buys'),
    (id: 'dinner', label: 'Dinner 🍽️', desc: 'I invite you out'),
    (id: 'honor', label: 'Honor 👊', desc: 'Just bragging'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OnboardingEyebrow('Stake', color: context.srTextDim),
        const SizedBox(height: 12),
        Row(
          children: [
            for (var i = 0; i < _rewards.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(
                child: _StakeChip(
                  reward: _rewards[i],
                  isSelected: selected == _rewards[i].id,
                  onTap: () => onSelect(_rewards[i].id),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _StakeChip extends StatelessWidget {
  const _StakeChip({
    required this.reward,
    required this.isSelected,
    required this.onTap,
  });

  final ({String id, String label, String desc}) reward;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return SrSelectableCard(
      isSelected: isSelected,
      onTap: onTap,
      accentColor: SrColors.magenta,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Column(
        children: [
          Text(
            reward.label,
            textAlign: TextAlign.center,
            style: tt.bodyMedium!.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: context.srText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            reward.desc,
            textAlign: TextAlign.center,
            style: tt.labelSmall!.copyWith(
              fontSize: 9,
              fontWeight: FontWeight.normal,
              color: context.srTextDim,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
