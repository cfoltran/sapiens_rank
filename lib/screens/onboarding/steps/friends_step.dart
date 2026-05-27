import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sapiens_rank/common/theme/colors.dart';
import 'package:sapiens_rank/screens/onboarding/widgets/arena_button.dart';
import 'package:sapiens_rank/screens/onboarding/widgets/onboarding_text.dart';
import 'package:sapiens_rank/screens/onboarding/widgets/sr_selectable_card.dart';
import 'package:sapiens_rank/screens/onboarding/widgets/step_shell.dart';

class FriendsStep extends StatefulWidget {
  const FriendsStep({
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
  State<FriendsStep> createState() => _FriendsStepState();
}

class _FriendsStepState extends State<FriendsStep> {
  final _followed = <String>{};

  static const _friends = [
    (
      name: 'Émile Lefèvre',
      handle: '@emile',
      initials: 'EL',
      flag: '🇫🇷',
      color: Color(0xFFF5D76E),
      score: 84,
      mutual: 4,
    ),
    (
      name: 'Camille Roux',
      handle: '@camille',
      initials: 'CR',
      flag: '🇫🇷',
      color: Color(0xFFFF9B7A),
      score: 79,
      mutual: 7,
    ),
    (
      name: 'Théo Marchand',
      handle: '@theo',
      initials: 'TM',
      flag: '🇫🇷',
      color: Color(0xFF7CB6FF),
      score: 91,
      mutual: 2,
    ),
    (
      name: 'Léa Bernard',
      handle: '@lea',
      initials: 'LB',
      flag: '🇫🇷',
      color: Color(0xFFD9FF3D),
      score: 76,
      mutual: 11,
    ),
    (
      name: 'Hugo Petit',
      handle: '@hugo',
      initials: 'HP',
      flag: '🇫🇷',
      color: Color(0xFFC5A3FF),
      score: 82,
      mutual: 3,
    ),
    (
      name: 'Manon Garnier',
      handle: '@manon',
      initials: 'MG',
      flag: '🇫🇷',
      color: Color(0xFF9BE7C4),
      score: 88,
      mutual: 5,
    ),
  ];

  void _followAll() =>
      setState(() => _followed.addAll(_friends.map((f) => f.handle)));

  @override
  Widget build(BuildContext context) {
    final count = _followed.length;
    final ctaLabel = count > 0
        ? 'Follow $count & continue →'
        : 'Skip — go solo';

    return StepShell(
      progress: widget.progress,
      total: widget.total,
      footer: Column(
        children: [
          ArenaButton(label: ctaLabel, onTap: widget.onNext),
          const SizedBox(height: 8),
          ArenaSecondaryButton(label: 'Back', onTap: widget.onBack),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const OnboardingEyebrow("Don't fight alone"),
          const SizedBox(height: 14),
          _Headline(),
          const SizedBox(height: 8),
          const OnboardingLede(
            "Some of them are below you. Some are above. Either way — you'll want to know.",
          ),
          const SizedBox(height: 18),
          _FollowAllChip(onTap: _followAll),
          const SizedBox(height: 16),
          for (final f in _friends) ...[
            _FriendRow(
              friend: f,
              isFollowed: _followed.contains(f.handle),
              onToggle: () => setState(() {
                if (_followed.contains(f.handle)) {
                  _followed.remove(f.handle);
                } else {
                  _followed.add(f.handle);
                }
              }),
            ),
            const SizedBox(height: 8),
          ],
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
        style: Theme.of(context).textTheme.displayMedium!.copyWith(
          fontStyle: FontStyle.normal,
          color: SrColors.text,
        ),
        children: const [
          TextSpan(
            text: '8 of your contacts',
            style: TextStyle(color: SrColors.lime, fontStyle: FontStyle.italic),
          ),
          TextSpan(text: ' already rank.'),
        ],
      ),
    );
  }
}

class _FollowAllChip extends StatelessWidget {
  const _FollowAllChip({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: const Color(0x1AD9FF3D),
          border: Border.all(color: const Color(0x66D9FF3D)),
        ),
        child: Text(
          '+ Follow all 6',
          style: Theme.of(context).textTheme.bodySmall!.copyWith(
            fontWeight: FontWeight.w600,
            color: SrColors.lime,
          ),
        ),
      ),
    );
  }
}

class _FriendRow extends StatelessWidget {
  const _FriendRow({
    required this.friend,
    required this.isFollowed,
    required this.onToggle,
  });

  final ({
    String name,
    String handle,
    String initials,
    String flag,
    Color color,
    int score,
    int mutual,
  })
  friend;
  final bool isFollowed;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return SrSelectableCard(
      isSelected: isFollowed,
      onTap: onToggle,
      borderRadius: 16,
      child: Row(
        children: [
          _Avatar(
            initials: friend.initials,
            color: friend.color,
            flag: friend.flag,
            size: 42,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  friend.name,
                  style: tt.bodyMedium!.copyWith(
                    fontWeight: FontWeight.w600,
                    color: SrColors.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Score ${friend.score} · ${friend.mutual} mutuals',
                  style: tt.labelMedium!.copyWith(
                    fontWeight: FontWeight.normal,
                    color: SrColors.textDim,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _FollowButton(isFollowed: isFollowed, onTap: onToggle),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.initials,
    required this.color,
    required this.flag,
    required this.size,
  });

  final String initials;
  final Color color;
  final String flag;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size + 10,
      height: size,
      child: Stack(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            child: Center(
              child: Text(
                initials,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: size * 0.32,
                  fontWeight: FontWeight.w700,
                  color: SrColors.textInk,
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Text(flag, style: TextStyle(fontSize: size * 0.32)),
          ),
        ],
      ),
    );
  }
}

class _FollowButton extends StatelessWidget {
  const _FollowButton({required this.isFollowed, required this.onTap});
  final bool isFollowed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: isFollowed ? SrColors.lime : Colors.transparent,
          border: Border.all(
            color: isFollowed ? SrColors.lime : SrColors.lineStrong,
          ),
        ),
        child: Text(
          isFollowed ? '✓ Following' : 'Follow',
          style: Theme.of(context).textTheme.bodySmall!.copyWith(
            fontWeight: FontWeight.w600,
            color: isFollowed ? SrColors.textInk : SrColors.text,
          ),
        ),
      ),
    );
  }
}
