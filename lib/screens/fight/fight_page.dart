import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sapiens_rank/common/data_state.dart';
import 'package:sapiens_rank/common/theme/colors.dart';
import 'package:sapiens_rank/common/theme/sr_theme.dart';
import 'package:sapiens_rank/screens/fight/cubit/fight_cubit.dart';
import 'package:sapiens_rank/screens/fight/cubit/fight_state.dart';
import 'package:sapiens_rank/screens/fight/sheets/composer_sheet.dart';

enum _FightTab { live, pending, history }

class FightPage extends StatelessWidget {
  const FightPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FightCubit()..load(),
      child: const _FightView(),
    );
  }
}

class _FightView extends StatefulWidget {
  const _FightView();

  @override
  State<_FightView> createState() => _FightViewState();
}

class _FightViewState extends State<_FightView> {
  _FightTab _tab = _FightTab.live;

  void _openComposer() {
    final cubit = context.read<FightCubit>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ComposerSheet(
        onCreateChallenge:
            ({
              required opponentId,
              required durationDays,
              required stakeIcon,
              required stakeLabel,
            }) => cubit.createChallenge(
              opponentId: opponentId,
              durationDays: durationDays,
              stakeIcon: stakeIcon,
              stakeLabel: stakeLabel,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FightCubit, DataState<FightData>>(
      builder: (context, state) {
        final cubit = context.read<FightCubit>();
        final data = state.data;
        final liveCount = data?.live.length ?? 0;

        return Scaffold(
          backgroundColor: context.srBg,
          body: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  18,
                  MediaQuery.of(context).padding.top + 8,
                  18,
                  0,
                ),
                child: Column(
                  children: [
                    _Header(liveCount: liveCount, onNew: _openComposer),
                    const SizedBox(height: 16),
                    _TabSwitcher(
                      tab: _tab,
                      pendingCount: data?.pending.length ?? 0,
                      onSelect: (t) => setState(() => _tab = t),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: switch (state.status) {
                  DataStatus.loading => const Center(
                    child: CircularProgressIndicator(color: SrColors.lime),
                  ),
                  DataStatus.error => Center(
                    child: GestureDetector(
                      onTap: cubit.load,
                      child: Text(
                        'Retry',
                        style: GoogleFonts.spaceGrotesk(
                          color: SrColors.lime,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  _ => ListView(
                    padding: const EdgeInsets.fromLTRB(18, 12, 18, 100),
                    children: [
                      if (_tab == _FightTab.live) ...[
                        ...?data?.live.map(
                          (f) => Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: f.is1v1
                                ? _DuelCard(fight: f)
                                : _RoyaleCard(fight: f),
                          ),
                        ),
                        if (data?.live.isEmpty ?? true)
                          const _EmptyState(label: 'No live challenges'),
                      ],
                      if (_tab == _FightTab.pending) ...[
                        ...?data?.pending.map(
                          (f) => Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _PendingCard(
                              fight: f,
                              onAccept: () => cubit.respond(f.id, accept: true),
                              onDecline: () =>
                                  cubit.respond(f.id, accept: false),
                              onCancel: () => cubit.cancel(f.id),
                            ),
                          ),
                        ),
                        if (data?.pending.isEmpty ?? true)
                          const _EmptyState(label: 'No pending invites'),
                      ],
                      if (_tab == _FightTab.history) ...[
                        ...?data?.history.map(
                          (f) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _HistoryRow(fight: f),
                          ),
                        ),
                        if (data?.history.isEmpty ?? true)
                          const _EmptyState(label: 'No fights yet'),
                      ],
                    ],
                  ),
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.liveCount, required this.onNew});
  final int liveCount;
  final VoidCallback onNew;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CHALLENGES · $liveCount LIVE',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  color: context.srTextDim,
                  letterSpacing: 0.15 * 11,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Fight',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                  color: context.srText,
                  letterSpacing: -0.03 * 30,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: onNew,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: SrColors.lime,
              borderRadius: BorderRadius.circular(100),
              boxShadow: [
                BoxShadow(color: SrColors.lime.withAlpha(0x44), blurRadius: 20),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add, size: 14, color: SrColors.textInk),
                const SizedBox(width: 4),
                Text(
                  'New',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: SrColors.textInk,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TabSwitcher extends StatelessWidget {
  const _TabSwitcher({
    required this.tab,
    required this.pendingCount,
    required this.onSelect,
  });
  final _FightTab tab;
  final int pendingCount;
  final ValueChanged<_FightTab> onSelect;

  @override
  Widget build(BuildContext context) {
    final tabs = [
      (_FightTab.live, 'Live'),
      (_FightTab.pending, 'Pending · $pendingCount'),
      (_FightTab.history, 'History'),
    ];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.srTintXs,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        children: tabs.map((entry) {
          final (t, label) = entry;
          final active = tab == t;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelect(t),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: active ? context.srBgElev2 : Colors.transparent,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Center(
                  child: Text(
                    label,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: active ? context.srText : context.srTextMuted,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _DuelCard extends StatelessWidget {
  const _DuelCard({required this.fight});
  final LiveFight fight;

  @override
  Widget build(BuildContext context) {
    final me = fight.me;
    final opponent = fight.opponents.first;
    final meWinning = me.score > opponent.score;
    final diff = (me.score - opponent.score).abs().toStringAsFixed(0);
    final myPct = (me.score + opponent.score) > 0
        ? me.score / (me.score + opponent.score)
        : 0.5;

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: context.srBgElev,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: context.srLineStrong),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _StatusStrip(label: '1v1 LIVE', endsIn: fight.endsInFormatted),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 18, 14, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        _Avatar(player: me, size: 52, ring: meWinning),
                        const SizedBox(height: 6),
                        Text(
                          'You',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: context.srText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          me.score.toStringAsFixed(0),
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            color: meWinning ? SrColors.lime : context.srText,
                            letterSpacing: -0.04 * 36,
                            height: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        'VS',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: context.srTextDim,
                          letterSpacing: 0.1 * 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: meWinning
                              ? SrColors.lime.withAlpha(0x22)
                              : SrColors.rose.withAlpha(0x22),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          '${meWinning ? '+' : '−'}$diff',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: meWinning ? SrColors.lime : SrColors.rose,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        _Avatar(player: opponent, size: 52, ring: !meWinning),
                        const SizedBox(height: 6),
                        Text(
                          opponent.firstName,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: context.srText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          opponent.score.toStringAsFixed(0),
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            color: !meWinning ? SrColors.amber : context.srText,
                            letterSpacing: -0.04 * 36,
                            height: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 4),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: SizedBox(
                      height: 6,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Container(color: SrColors.amber.withAlpha(0x33)),
                          FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: myPct,
                            child: Container(
                              decoration: BoxDecoration(
                                color: SrColors.lime,
                                boxShadow: [
                                  BoxShadow(
                                    color: SrColors.lime.withAlpha(0xCC),
                                    blurRadius: 4,
                                    offset: const Offset(-2, 0),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${(myPct * 100).round()}%',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 9,
                          color: SrColors.lime,
                          letterSpacing: 0.1 * 9,
                        ),
                      ),
                      Text(
                        'SAPIENS SCORE',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 9,
                          color: context.srTextDim,
                          letterSpacing: 0.1 * 9,
                        ),
                      ),
                      Text(
                        '${((1 - myPct) * 100).round()}%',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 9,
                          color: SrColors.amber,
                          letterSpacing: 0.1 * 9,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _StakeBanner(
              icon: fight.stakeIcon,
              label: fight.stakeLabel,
              isLime: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _RoyaleCard extends StatelessWidget {
  const _RoyaleCard({required this.fight});
  final LiveFight fight;

  @override
  Widget build(BuildContext context) {
    final players = fight.participants;
    final maxScore = players.isNotEmpty ? players.first.score : 1.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: context.srBgElev,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: context.srLineStrong),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _StatusStrip(
              label: '1 v ${fight.opponents.length} · SAPIENS SCORE',
              endsIn: fight.endsInFormatted,
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: List.generate(players.length, (i) {
                  final p = players[i];
                  final widthFactor = maxScore > 0 ? p.score / maxScore : 0.0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: p.isMe
                            ? SrColors.lime.withAlpha(0x14)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: p.isMe
                              ? SrColors.lime.withAlpha(0x44)
                              : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 18,
                            child: Text(
                              '${i + 1}',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: i == 0
                                    ? SrColors.lime
                                    : context.srTextMuted,
                              ),
                            ),
                          ),
                          _Avatar(player: p, size: 28, ring: p.isMe),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      p.isMe ? 'You' : p.firstName,
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 13,
                                        fontWeight: p.isMe
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                        color: context.srText,
                                      ),
                                    ),
                                    Text(
                                      p.score.toStringAsFixed(0),
                                      style: GoogleFonts.jetBrainsMono(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: p.isMe
                                            ? SrColors.lime
                                            : context.srText,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: SizedBox(
                                    height: 3,
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        Container(color: context.srTintSm),
                                        FractionallySizedBox(
                                          alignment: Alignment.centerLeft,
                                          widthFactor: widthFactor,
                                          child: Container(
                                            color: p.isMe
                                                ? SrColors.lime
                                                : context.srTintLg,
                                          ),
                                        ),
                                      ],
                                    ),
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
              ),
            ),
            _StakeBanner(
              icon: fight.stakeIcon,
              label: fight.stakeLabel,
              isLime: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _PendingCard extends StatelessWidget {
  const _PendingCard({
    required this.fight,
    required this.onAccept,
    required this.onDecline,
    required this.onCancel,
  });
  final PendingFight fight;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.srBgElev,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.srLineStrong),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            _Avatar(player: fight.opponent, size: 48, ring: false),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fight.iAmCreator
                        ? 'WAITING FOR ACCEPT'
                        : 'CHALLENGE RECEIVED',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 9,
                      color: SrColors.amber,
                      letterSpacing: 0.15 * 9,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    fight.iAmCreator
                        ? 'You challenged ${fight.opponent.firstName}'
                        : '${fight.opponent.firstName} challenged you',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: context.srText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${fight.stakeIcon} ${fight.stakeLabel}',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      color: context.srTextMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (fight.iAmCreator)
              GestureDetector(
                onTap: onCancel,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    border: Border.all(color: context.srLineStrong),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.close,
                    size: 16,
                    color: context.srTextMuted,
                  ),
                ),
              )
            else
              Row(
                children: [
                  GestureDetector(
                    onTap: onDecline,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        border: Border.all(color: context.srLineStrong),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.close,
                        size: 16,
                        color: context.srTextMuted,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: onAccept,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: SrColors.lime,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Accept',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: SrColors.textInk,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.fight});
  final HistoryFight fight;

  @override
  Widget build(BuildContext context) {
    final won = fight.won;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: context.srBgElev,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.srLine),
      ),
      child: Row(
        children: [
          _Avatar(player: fight.opponent, size: 36, ring: false),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'vs ${fight.opponent.firstName}',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: context.srText,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: won == null
                            ? context.srTextDim.withAlpha(0x1F)
                            : won
                            ? SrColors.lime.withAlpha(0x1F)
                            : SrColors.rose.withAlpha(0x1F),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        won == null ? 'DRAW' : (won ? 'WON' : 'LOST'),
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: won == null
                              ? context.srTextDim
                              : won
                              ? SrColors.lime
                              : SrColors.rose,
                          letterSpacing: 0.05 * 9,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${fight.myScore.toStringAsFixed(0)}–${fight.opponentScore.toStringAsFixed(0)} · ${fight.stakeLabel} · ${fight.dateFormatted}',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    color: context.srTextDim,
                  ),
                ),
              ],
            ),
          ),
          Text(
            won == null ? '½' : (won ? '+1' : '0'),
            style: GoogleFonts.jetBrainsMono(
              fontSize: 18,
              color: won == null
                  ? context.srTextDim
                  : won
                  ? SrColors.lime
                  : context.srTextDim,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusStrip extends StatelessWidget {
  const _StatusStrip({required this.label, required this.endsIn});
  final String label;
  final String endsIn;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: context.srTintXs,
        border: Border(bottom: BorderSide(color: context.srLine)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: SrColors.lime,
                  boxShadow: [
                    BoxShadow(
                      color: SrColors.lime.withAlpha(0xFF),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  color: context.srText,
                  letterSpacing: 0.15 * 10,
                ),
              ),
            ],
          ),
          RichText(
            text: TextSpan(
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                color: context.srTextMuted,
              ),
              children: [
                const TextSpan(text: 'ends in '),
                TextSpan(
                  text: endsIn,
                  style: const TextStyle(color: SrColors.amber),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StakeBanner extends StatelessWidget {
  const _StakeBanner({
    required this.icon,
    required this.label,
    required this.isLime,
  });
  final String icon;
  final String label;
  final bool isLime;

  @override
  Widget build(BuildContext context) {
    final accent = isLime ? SrColors.lime : SrColors.amber;
    return Container(
      margin: const EdgeInsets.all(14),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: accent.withAlpha(0x0F),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withAlpha(0x44)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: context.srTintSm,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(icon, style: const TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'WINNER TAKES',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 9,
                    color: context.srTextDim,
                    letterSpacing: 0.15 * 9,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  label,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: context.srText,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.emoji_events_outlined, size: 18, color: accent),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.player, required this.size, required this.ring});
  final FightParticipant player;
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
              color: player.avatarColor.withAlpha(0x33),
              border: ring
                  ? Border.all(color: player.avatarColor, width: 2)
                  : Border.all(color: context.srLine, width: 1),
            ),
            child: Center(
              child: Text(
                player.initials,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: size * 0.3,
                  fontWeight: FontWeight.w700,
                  color: player.avatarColor,
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
                  player.flag,
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

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Text(
          label,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 12,
            color: context.srTextDim,
          ),
        ),
      ),
    );
  }
}
