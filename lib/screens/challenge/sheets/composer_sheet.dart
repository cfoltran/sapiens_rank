import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sapiens_rank/common/theme/colors.dart';
import 'package:sapiens_rank/common/theme/sr_theme.dart';
import 'package:sapiens_rank/screens/challenge/cubit/challenge_state.dart';
import 'package:sapiens_rank/services/challenge_service.dart';

class Reward {
  const Reward({
    required this.id,
    required this.icon,
    required this.label,
    required this.desc,
    required this.isPartner,
  });
  final String id;
  final String icon;
  final String label;
  final String desc;
  final bool isPartner;
}

const rewards = [
  Reward(
    id: 'nespresso',
    icon: '☕',
    label: 'Nespresso',
    desc: 'Capsule pack',
    isPartner: true,
  ),
  Reward(
    id: 'decathlon',
    icon: '🏃',
    label: 'Decathlon',
    desc: '€50 voucher',
    isPartner: true,
  ),
  Reward(
    id: 'headspace',
    icon: '🧘',
    label: 'Headspace',
    desc: '1 month',
    isPartner: true,
  ),
  Reward(
    id: 'whoop',
    icon: '⌚',
    label: 'WHOOP',
    desc: '3 months free',
    isPartner: true,
  ),
  Reward(
    id: 'oatly',
    icon: '🥛',
    label: 'Oatly',
    desc: '12-pack',
    isPartner: true,
  ),
  Reward(
    id: 'restaurant',
    icon: '🍽️',
    label: 'Restaurant',
    desc: 'I invite you',
    isPartner: false,
  ),
  Reward(
    id: 'cinema',
    icon: '🎬',
    label: 'Cinema',
    desc: 'On me',
    isPartner: false,
  ),
  Reward(
    id: 'cash',
    icon: '€',
    label: 'Custom €',
    desc: 'Set amount',
    isPartner: false,
  ),
];

class ComposerSheet extends StatefulWidget {
  const ComposerSheet({super.key, required this.onCreateChallenge});

  final Future<void> Function({
    required String opponentId,
    required int durationDays,
    required String stakeIcon,
    required String stakeLabel,
  })
  onCreateChallenge;

  @override
  State<ComposerSheet> createState() => _ComposerSheetState();
}

class _ComposerSheetState extends State<ComposerSheet> {
  int _step = 1;
  ComposerUser? _opponent;
  String _metric = 'total';
  String _duration = '1d';
  Reward? _reward;
  bool _sent = false;
  bool _sending = false;

  List<ComposerUser> _users = [];
  bool _loadingUsers = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final opponents = await ChallengeService.instance.getPotentialOpponents();
      if (!mounted) return;
      setState(() {
        _users = opponents
            .map(
              (o) => ComposerUser(
                userId: o.userId,
                displayName: o.name,
                initials: _initials(o.name),
                avatarColor: _avatarColor(o.userId),
                flag: o.country != null ? _countryFlag(o.country!) : '🌍',
                score: o.score,
              ),
            )
            .toList();
        _loadingUsers = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingUsers = false);
    }
  }

  bool get _canContinue {
    if (_step == 1) return _opponent != null;
    if (_step == 2) return _duration.isNotEmpty;
    if (_step == 3) return _reward != null;
    return false;
  }

  Future<void> _next() async {
    if (_step < 3) {
      setState(() => _step++);
    } else {
      setState(() => _sending = true);
      await widget.onCreateChallenge(
        opponentId: _opponent!.userId,
        durationDays: int.parse(_duration.replaceAll('d', '')),
        stakeIcon: _reward!.icon,
        stakeLabel: _reward!.label,
      );
      if (mounted) {
        setState(() {
          _sent = true;
          _sending = false;
        });
      }
      await Future.delayed(const Duration(milliseconds: 1400));
      if (mounted) Navigator.of(context).pop();
    }
  }

  static String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.substring(0, math.min(2, name.length)).toUpperCase();
  }

  static const _palette = SrColors.avatarPalette;

  static Color _avatarColor(String userId) {
    final hash = userId.codeUnits.fold(0, (a, b) => a + b);
    return _palette[hash % _palette.length];
  }

  static String _countryFlag(String code) => code
      .toUpperCase()
      .runes
      .map((r) => String.fromCharCode(r + 0x1F1E6 - 0x41))
      .join();

  @override
  Widget build(BuildContext context) {
    final canAct = _canContinue && !_sending;
    return Container(
      decoration: BoxDecoration(
        color: context.srBgElev2,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: context.srLineStrong)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 14),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: context.srLineStrong,
              borderRadius: BorderRadius.circular(100),
            ),
          ),
          const SizedBox(height: 16),
          if (_sent)
            _SentConfirmation(opponentName: _opponent?.firstName ?? '')
          else ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
              child: _ComposerHeader(step: _step),
            ),
            Flexible(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                shrinkWrap: true,
                children: [
                  if (_step == 1)
                    _StepPickOpponent(
                      users: _users,
                      loading: _loadingUsers,
                      selected: _opponent,
                      onSelect: (u) => setState(() => _opponent = u),
                    ),
                  if (_step == 2)
                    _StepSetRules(
                      metric: _metric,
                      duration: _duration,
                      onMetric: (m) => setState(() => _metric = m),
                      onDuration: (d) => setState(() => _duration = d),
                    ),
                  if (_step == 3)
                    _StepPickReward(
                      selected: _reward,
                      onSelect: (r) => setState(() => _reward = r),
                    ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                18,
                16,
                18,
                MediaQuery.of(context).padding.bottom + 18,
              ),
              child: Row(
                children: [
                  if (_step > 1) ...[
                    GestureDetector(
                      onTap: () => setState(() => _step--),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: context.srLineStrong),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          'Back',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: context.srText,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: GestureDetector(
                      onTap: canAct ? _next : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: canAct ? context.srLime : context.srTintSm,
                          borderRadius: BorderRadius.circular(100),
                          boxShadow: canAct
                              ? [
                                  BoxShadow(
                                    color: context.srLime.withAlpha(0x44),
                                    blurRadius: 20,
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: _sending
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    color: SrColors.textInk,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  _step < 3 ? 'Continue' : 'Send challenge ⚔️',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: canAct
                                        ? SrColors.textInk
                                        : context.srTextDim,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ComposerHeader extends StatelessWidget {
  const _ComposerHeader({required this.step});
  final int step;

  @override
  Widget build(BuildContext context) {
    const titles = ['Pick opponent', 'Set the rules', 'Stake a reward'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          titles[step - 1],
          style: GoogleFonts.spaceGrotesk(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: context.srText,
            letterSpacing: -0.02 * 20,
          ),
        ),
        Row(
          children: List.generate(3, (i) {
            final active = i + 1 == step;
            final done = i + 1 < step;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: active ? 16 : 6,
              height: 6,
              margin: const EdgeInsets.only(left: 4),
              decoration: BoxDecoration(
                color: (active || done) ? context.srLime : context.srTintMd,
                borderRadius: BorderRadius.circular(100),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _StepPickOpponent extends StatelessWidget {
  const _StepPickOpponent({
    required this.users,
    required this.loading,
    required this.selected,
    required this.onSelect,
  });
  final List<ComposerUser> users;
  final bool loading;
  final ComposerUser? selected;
  final ValueChanged<ComposerUser> onSelect;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator(color: context.srLime)),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PLAYERS · ${users.length}',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 10,
            color: context.srTextDim,
            letterSpacing: 0.15 * 10,
          ),
        ),
        const SizedBox(height: 10),
        ...users.map((u) {
          final isSelected = selected?.userId == u.userId;
          return GestureDetector(
            onTap: () => onSelect(u),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? context.srLime.withAlpha(0x1A)
                    : context.srTintXs,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? context.srLime : Colors.transparent,
                ),
              ),
              child: Row(
                children: [
                  _ComposerAvatar(user: u, size: 40, ring: isSelected),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          u.displayName,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: context.srText,
                          ),
                        ),
                        Text(
                          '@${u.firstName.toLowerCase()}',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 11,
                            color: context.srTextMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'SCORE',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 9,
                          color: context.srTextDim,
                          letterSpacing: 0.1 * 9,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        u.score.toStringAsFixed(0),
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: context.srText,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _ComposerAvatar extends StatelessWidget {
  const _ComposerAvatar({
    required this.user,
    required this.size,
    required this.ring,
  });
  final ComposerUser user;
  final double size;
  final bool ring;

  @override
  Widget build(BuildContext context) {
    final badgeSize = size * 0.42;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: user.avatarColor.withAlpha(0x33),
              border: ring
                  ? Border.all(color: user.avatarColor, width: 2)
                  : Border.all(color: context.srLine, width: 1),
            ),
            child: Center(
              child: Text(
                user.initials,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: size * 0.3,
                  fontWeight: FontWeight.w700,
                  color: user.avatarColor,
                  height: 1,
                ),
              ),
            ),
          ),
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              width: badgeSize,
              height: badgeSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.srBgElev2,
              ),
              child: Center(
                child: Text(
                  user.flag,
                  style: TextStyle(fontSize: badgeSize * 0.56),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepSetRules extends StatelessWidget {
  const _StepSetRules({
    required this.metric,
    required this.duration,
    required this.onMetric,
    required this.onDuration,
  });
  final String metric;
  final String duration;
  final ValueChanged<String> onMetric;
  final ValueChanged<String> onDuration;

  @override
  Widget build(BuildContext context) {
    const metrics = [
      ('total', 'Sapiens Score', 'Overall'),
      ('steps', 'Steps', 'Daily count'),
      ('sleep', 'Sleep', 'Score / 100'),
      ('kcal', 'Active kcal', 'Daily burn'),
    ];
    const durations = [
      ('1d', '24h'),
      ('3d', '3 days'),
      ('7d', '1 week'),
      ('30d', '30 days'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'METRIC',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 10,
            color: context.srTextDim,
            letterSpacing: 0.15 * 10,
          ),
        ),
        const SizedBox(height: 10),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 2.6,
          children: metrics.map((m) {
            final (id, label, sub) = m;
            final active = metric == id;
            final locked = id != 'total';
            return GestureDetector(
              onTap: locked ? null : () => onMetric(id),
              child: Opacity(
                opacity: locked ? 0.45 : 1.0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: active
                        ? context.srLime.withAlpha(0x1A)
                        : context.srTintXs,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: active ? context.srLime : context.srLine,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              label,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: context.srText,
                              ),
                            ),
                          ),
                          if (locked)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: context.srTintMd,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Soon',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 8,
                                  color: context.srTextDim,
                                ),
                              ),
                            ),
                        ],
                      ),
                      Text(
                        sub,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 10,
                          color: context.srTextDim,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 18),
        Text(
          'DURATION',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 10,
            color: context.srTextDim,
            letterSpacing: 0.15 * 10,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: durations.map((d) {
            final (id, label) = d;
            final active = duration == id;
            return Expanded(
              child: GestureDetector(
                onTap: () => onDuration(id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    color: active
                        ? context.srLime.withAlpha(0x1A)
                        : context.srTintXs,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: active ? context.srLime : context.srLine,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      label,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: active
                            ? context.srLimeText
                            : context.srTextMuted,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _StepPickReward extends StatelessWidget {
  const _StepPickReward({required this.selected, required this.onSelect});
  final Reward? selected;
  final ValueChanged<Reward> onSelect;

  @override
  Widget build(BuildContext context) {
    final partners = rewards.where((r) => r.isPartner).toList();
    final custom = rewards.where((r) => !r.isPartner).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PARTNER REWARDS',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 10,
            color: context.srTextDim,
            letterSpacing: 0.15 * 10,
          ),
        ),
        const SizedBox(height: 10),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 2.6,
          children: partners.map((r) {
            final active = selected?.id == r.id;
            return GestureDetector(
              onTap: () => onSelect(r),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: active
                      ? context.srLime.withAlpha(0x1A)
                      : context.srTintXs,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: active ? context.srLime : context.srLine,
                  ),
                ),
                child: Row(
                  children: [
                    Text(r.icon, style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            r.label,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: context.srText,
                            ),
                          ),
                          Text(
                            r.desc,
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 9,
                              color: context.srTextDim,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 18),
        Text(
          '✦  OR · INVITE YOUR OPPONENT',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 10,
            color: context.srTextDim,
            letterSpacing: 0.15 * 10,
          ),
        ),
        const SizedBox(height: 10),
        ...custom.map((r) {
          final active = selected?.id == r.id;
          return GestureDetector(
            onTap: () => onSelect(r),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: active
                    ? context.srLime.withAlpha(0x1A)
                    : context.srTintXs,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: active ? context.srLime : context.srLine,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: context.srLime.withAlpha(0x1A),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        r.icon,
                        style: TextStyle(
                          fontSize: 18,
                          color: context.srLimeText,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r.id == 'restaurant'
                              ? 'If you win, I take you out'
                              : r.id == 'cinema'
                              ? 'If you win, cinema on me'
                              : 'If you win, I send you money',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: context.srText,
                          ),
                        ),
                        Text(
                          r.desc,
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10,
                            color: context.srTextDim,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _SentConfirmation extends StatelessWidget {
  const _SentConfirmation({required this.opponentName});
  final String opponentName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
      child: Column(
        children: [
          const Text('⚔️', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(
            'Challenge sent',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: context.srText,
              letterSpacing: -0.02 * 22,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$opponentName will be notified',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 12,
              color: context.srTextMuted,
            ),
          ),
        ],
      ),
    );
  }
}
