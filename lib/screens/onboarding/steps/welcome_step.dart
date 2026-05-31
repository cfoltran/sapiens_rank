import 'package:flutter/material.dart';
import 'package:sapiens_rank/common/theme/colors.dart';
import 'package:sapiens_rank/common/theme/sr_theme.dart';
import 'package:sapiens_rank/screens/onboarding/widgets/arena_button.dart';

class WelcomeStep extends StatefulWidget {
  const WelcomeStep({super.key, required this.onNext, required this.onLogin});

  final VoidCallback onNext;
  final VoidCallback onLogin;

  @override
  State<WelcomeStep> createState() => _WelcomeStepState();
}

class _WelcomeStepState extends State<WelcomeStep>
    with TickerProviderStateMixin {
  late final AnimationController _blinkCtrl;
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _blinkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _blinkCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: context.srBg,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      AnimatedBuilder(
                        animation: _blinkCtrl,
                        builder: (_, _) => RepaintBoundary(
                          child: Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: context.srLime,
                              boxShadow: [
                                BoxShadow(
                                  color: context.srLime.withAlpha(
                                    (80 + (_blinkCtrl.value * 120).round()),
                                  ),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 7),
                      Text(
                        'LIVE · WORLD LEADERBOARD',
                        style: tt.labelSmall!.copyWith(
                          color: context.srLimeText,
                          letterSpacing: 1.8,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '2,401,839 sapiens ranked today',
                    style: tt.bodySmall!.copyWith(
                      color: context.srTextMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
                    child: SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          for (final (i, row) in _leaderboard.indexed)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: row.isMe
                                  ? _YouRow(row: row, pulseCtrl: _pulseCtrl)
                                  : Opacity(
                                      opacity: 1.0 - i * 0.04,
                                      child: _LeaderRow(row: row),
                                    ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 80,
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [context.srBg.withAlpha(0), context.srBg],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Container(
              color: context.srBg,
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: tt.displayMedium!.copyWith(
                        fontSize: 34,
                        height: 1.05,
                        color: context.srText,
                      ),
                      children: [
                        const TextSpan(text: 'Where would you\n'),
                        TextSpan(
                          text: 'land today?',
                          style: TextStyle(color: context.srLimeText),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'We read your Health data and slot you in.\nTakes 30 seconds.',
                    style: tt.bodySmall!.copyWith(
                      color: context.srTextMuted,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 22),
                  RepaintBoundary(
                    child: ArenaButton(
                      label: 'Find my rank →',
                      onTap: widget.onNext,
                    ),
                  ),
                  ArenaSecondaryButton(
                    label: 'I already have an account',
                    onTap: widget.onLogin,
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

typedef _Row = ({
  String rank,
  String name,
  String flag,
  String score,
  Color color,
  String initials,
  bool isMe,
});

const _leaderboard = <_Row>[
  (
    rank: '1',
    name: 'Kenji Tanaka',
    flag: '🇯🇵',
    score: '99',
    color: SrColors.rose,
    initials: 'KT',
    isMe: false,
  ),
  (
    rank: '2',
    name: 'Astrid Berg',
    flag: '🇳🇴',
    score: '98',
    color: SrColors.cyan,
    initials: 'AB',
    isMe: false,
  ),
  (
    rank: '3',
    name: 'Mateo Rivera',
    flag: '🇪🇸',
    score: '97',
    color: SrColors.amber,
    initials: 'MR',
    isMe: false,
  ),
  (
    rank: '4',
    name: 'Priya Shah',
    flag: '🇮🇳',
    score: '96',
    color: SrColors.violet,
    initials: 'PS',
    isMe: false,
  ),
  (
    rank: '5',
    name: 'Lukas Weber',
    flag: '🇩🇪',
    score: '95',
    color: SrColors.mint,
    initials: 'LW',
    isMe: false,
  ),
  (
    rank: '6',
    name: 'Chiamaka O.',
    flag: '🇳🇬',
    score: '94',
    color: SrColors.gold,
    initials: 'CO',
    isMe: false,
  ),
  (
    rank: '7',
    name: 'Sofia L.',
    flag: '🇸🇪',
    score: '93',
    color: SrColors.ice,
    initials: 'SL',
    isMe: false,
  ),
  (
    rank: '?',
    name: 'YOU',
    flag: '',
    score: '–',
    color: SrColors.lime,
    initials: '?',
    isMe: true,
  ),
];

class _LeaderRow extends StatelessWidget {
  const _LeaderRow({required this.row});
  final _Row row;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: context.srTintXs,
        border: Border.all(color: context.srLine),
      ),
      child: _RowContent(row: row, tt: tt),
    );
  }
}

class _YouRow extends StatelessWidget {
  const _YouRow({required this.row, required this.pulseCtrl});
  final _Row row;
  final AnimationController pulseCtrl;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: pulseCtrl,
        builder: (_, child) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: context.srLime.withAlpha(26),
            border: Border.all(color: context.srLime),
            boxShadow: [
              BoxShadow(
                color: context.srLime.withAlpha(
                  (20 + (pulseCtrl.value * 40).round()),
                ),
                blurRadius: 12 + pulseCtrl.value * 6,
                spreadRadius: 0,
              ),
            ],
          ),
          child: child,
        ),
        child: _RowContent(row: row, tt: tt),
      ),
    );
  }
}

class _RowContent extends StatelessWidget {
  const _RowContent({required this.row, required this.tt});
  final _Row row;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 28,
          child: Text(
            '#${row.rank}',
            style: tt.labelMedium!.copyWith(
              color: row.isMe ? context.srLimeText : context.srTextMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: row.color,
            border: row.isMe
                ? Border.all(color: context.srLime, width: 2)
                : null,
          ),
          child: Center(
            child: Text(
              row.initials,
              style: tt.bodySmall!.copyWith(
                fontWeight: FontWeight.w700,
                color: SrColors.textInk,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            row.flag.isEmpty ? row.name : '${row.name} ${row.flag}',
            overflow: TextOverflow.ellipsis,
            style: tt.bodyMedium!.copyWith(
              fontWeight: row.isMe ? FontWeight.w700 : FontWeight.w600,
              fontStyle: row.isMe ? FontStyle.italic : FontStyle.normal,
              color: context.srText,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          row.score,
          style: tt.titleSmall!.copyWith(
            fontWeight: FontWeight.w700,
            fontStyle: row.isMe ? FontStyle.italic : FontStyle.normal,
            color: row.isMe ? context.srLimeText : context.srText,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}
