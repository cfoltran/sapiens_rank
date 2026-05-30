import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sapiens_rank/common/data_state.dart';
import 'package:sapiens_rank/common/theme/colors.dart';
import 'package:sapiens_rank/common/theme/world_skeleton.dart';
import 'package:sapiens_rank/screens/world/cubit/world_cubit.dart';
import 'package:sapiens_rank/screens/world/cubit/world_state.dart';

class WorldPage extends StatelessWidget {
  const WorldPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WorldCubit()..load(),
      child: BlocBuilder<WorldCubit, DataState<WorldData>>(
        builder: (ctx, state) {
          if (state.status == DataStatus.loading) {
            return const WorldLoadingSkeleton();
          }
          if (state.status == DataStatus.error) {
            return _ErrorBody(onRetry: () => ctx.read<WorldCubit>().load());
          }
          final data = state.data!;
          return _LoadedBody(data: data);
        },
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SrColors.bg,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Could not load leaderboard',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                color: SrColors.textMuted,
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: onRetry,
              child: Text(
                'Retry',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: SrColors.lime,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadedBody extends StatelessWidget {
  const _LoadedBody({required this.data});

  final WorldData data;

  @override
  Widget build(BuildContext context) {
    final players = data.activePlayers;
    final listPlayers = players.length > 3
        ? players.sublist(3)
        : <WorldPlayer>[];
    final myRank = data.myActiveRank;
    final showGap = myRank != null && myRank > (players.length + 3);

    return Scaffold(
      backgroundColor: SrColors.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Header(data: data),
                  const SizedBox(height: 16),
                  _ScopeFilter(data: data),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 24, 18, 16),
                children: [
                  if (players.length >= 3) _Podium(players: players),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'RANK',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10,
                            color: SrColors.textDim,
                            letterSpacing: 10 * 0.2,
                          ),
                        ),
                        Text(
                          'SCORE',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10,
                            color: SrColors.textDim,
                            letterSpacing: 10 * 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...listPlayers.map((p) => _PlayerRow(player: p)),
                  if (showGap) ...[
                    const SizedBox(height: 4),
                    _GapIndicator(gapCount: myRank - players.length),
                  ],
                ],
              ),
            ),
            _YouCard(data: data),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.data});

  final WorldData data;

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
                'LEADERBOARD · LIVE',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  color: SrColors.textDim,
                  letterSpacing: 11 * 0.15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'World',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: SrColors.text,
                  height: 1.0,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '2.4M sapiens',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: SrColors.text,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: SrColors.lime,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'ranked today',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    color: SrColors.lime,
                    letterSpacing: 10 * 0.05,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _ScopeFilter extends StatelessWidget {
  const _ScopeFilter({required this.data});

  final WorldData data;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<WorldCubit>();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _SrChip(
            label: 'Worldwide',
            active: data.scope == WorldScope.worldwide,
            onTap: () => cubit.setScope(WorldScope.worldwide),
          ),
          const SizedBox(width: 8),
          _SrChip(
            label: data.myCountryFlag,
            active: data.scope == WorldScope.country,
            onTap: () => cubit.setScope(WorldScope.country),
          ),
          const SizedBox(width: 8),
          _SrChip(
            label: 'Weekly',
            active: data.scope == WorldScope.weekly,
            onTap: () => cubit.setScope(WorldScope.weekly),
          ),
        ],
      ),
    );
  }
}

class _SrChip extends StatelessWidget {
  const _SrChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: active ? SrColors.lime : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: active ? SrColors.lime : SrColors.lineStrong,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: active ? SrColors.textInk : SrColors.text,
          ),
        ),
      ),
    );
  }
}

class _Podium extends StatelessWidget {
  const _Podium({required this.players});

  final List<WorldPlayer> players;

  @override
  Widget build(BuildContext context) {
    // Visual order: 2nd · 1st · 3rd
    final p2 = players[1];
    final p1 = players[0];
    final p3 = players[2];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: _PodiumSlot(
            player: p2,
            blockHeight: 100,
            color: SrColors.sand,
            avatarSize: 50,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _PodiumSlot(
            player: p1,
            blockHeight: 130,
            color: SrColors.lime,
            avatarSize: 60,
            crown: true,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _PodiumSlot(
            player: p3,
            blockHeight: 86,
            color: SrColors.amber,
            avatarSize: 50,
          ),
        ),
      ],
    );
  }
}

class _PodiumSlot extends StatelessWidget {
  const _PodiumSlot({
    required this.player,
    required this.blockHeight,
    required this.color,
    required this.avatarSize,
    this.crown = false,
  });

  final WorldPlayer player;
  final double blockHeight;
  final Color color;
  final double avatarSize;
  final bool crown;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Crown above #1 avatar; spacer keeps other slots aligned
        if (crown) ...[
          const Text('👑', style: TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
        ] else
          const SizedBox(height: 26), // same height as crown + gap
        _Avatar(player: player, size: avatarSize),
        const SizedBox(height: 6),
        Text(
          _firstName(player.displayName),
          style: GoogleFonts.spaceGrotesk(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: SrColors.text,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        Text(
          '@${_handle(player.displayName)}',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 9,
            color: SrColors.textDim,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        _PodiumBlock(
          player: player,
          height: blockHeight,
          color: color,
          scoreSize: player.rank == 1 ? 32.0 : 24.0,
        ),
      ],
    );
  }

  static String _firstName(String name) => name.trim().split(' ').first;

  static String _handle(String name) =>
      name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');
}

class _PodiumBlock extends StatelessWidget {
  const _PodiumBlock({
    required this.player,
    required this.height,
    required this.color,
    required this.scoreSize,
  });

  final WorldPlayer player;
  final double height;
  final Color color;
  final double scoreSize;

  @override
  Widget build(BuildContext context) {
    final isFirst = player.rank == 1;
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [color.withAlpha(0x22), color.withAlpha(0x08)],
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
          border: Border(
            top: BorderSide(color: color.withAlpha(0x44), width: 1),
            left: BorderSide(color: color.withAlpha(0x44), width: 1),
            right: BorderSide(color: color.withAlpha(0x44), width: 1),
          ),
        ),
        child: Stack(
          children: [
            // Glow line at the very top of the block
            Positioned(
              top: 0,
              left: 8,
              right: 8,
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: isFirst
                      ? [BoxShadow(color: color, blurRadius: 12)]
                      : null,
                ),
              ),
            ),
            // Score + rank — top-aligned with paddingTop 14 (matches design)
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Align(
                alignment: Alignment.topCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      player.score.toStringAsFixed(0),
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: scoreSize,
                        fontWeight: FontWeight.w700,
                        color: color,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '#${player.rank}',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        letterSpacing: 11 * 0.1,
                        color: SrColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayerRow extends StatelessWidget {
  const _PlayerRow({required this.player});

  final WorldPlayer player;

  @override
  Widget build(BuildContext context) {
    final handle = player.displayName.toLowerCase().replaceAll(' ', '_');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              '${player.rank}',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: SrColors.textMuted,
              ),
            ),
          ),
          const SizedBox(width: 10),
          _Avatar(player: player, size: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.displayName,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: SrColors.text,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '@$handle',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    color: SrColors.textDim,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            player.score.toStringAsFixed(0),
            style: GoogleFonts.spaceGrotesk(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: SrColors.text,
            ),
          ),
        ],
      ),
    );
  }
}

class _GapIndicator extends StatelessWidget {
  const _GapIndicator({required this.gapCount});

  final int gapCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          const Expanded(
            child: Divider(color: SrColors.lineStrong, thickness: 1),
          ),
          const SizedBox(width: 10),
          Text(
            '· · · $gapCount sapiens · · ·',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 10,
              color: SrColors.textDim,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Divider(color: SrColors.lineStrong, thickness: 1),
          ),
        ],
      ),
    );
  }
}

class _YouCard extends StatelessWidget {
  const _YouCard({required this.data});

  final WorldData data;

  @override
  Widget build(BuildContext context) {
    final myRank = data.myActiveRank;
    final delta = data.myRankDelta;

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
      child: RepaintBoundary(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [SrColors.bgElev2Fade, SrColors.bgElev2Opaque],
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: SrColors.lime.withAlpha(100),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: SrColors.lime.withAlpha(30),
                    blurRadius: 20,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Rank
                  Text(
                    myRank != null ? '#$myRank' : '---',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: SrColors.lime,
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Avatar with lime ring
                  _YouAvatar(size: 36),
                  const SizedBox(width: 12),
                  // Center: name + delta + subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'You',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: SrColors.text,
                              ),
                            ),
                            if (delta != null) ...[
                              const SizedBox(width: 6),
                              _DeltaBadge(delta: delta),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${data.myStreak}d streak',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 11,
                            color: SrColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Score
                  Text(
                    data.myScore.toStringAsFixed(0),
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: SrColors.text,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _YouAvatar extends StatelessWidget {
  const _YouAvatar({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: SrColors.lime, width: 2),
        boxShadow: [
          BoxShadow(
            color: SrColors.lime.withAlpha(60),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [SrColors.blue, SrColors.blueDeep],
        ),
      ),
      child: Center(
        child: Text(
          'ME',
          style: GoogleFonts.spaceGrotesk(
            fontSize: size * 0.36,
            fontWeight: FontWeight.w700,
            color: SrColors.textInk,
          ),
        ),
      ),
    );
  }
}

class _DeltaBadge extends StatelessWidget {
  const _DeltaBadge({required this.delta});

  final int delta;

  @override
  Widget build(BuildContext context) {
    final isPositive = delta >= 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isPositive ? SrColors.lime : SrColors.rose.withAlpha(40),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        isPositive ? '↑$delta' : '↓${delta.abs()}',
        style: GoogleFonts.jetBrainsMono(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: isPositive ? SrColors.textInk : SrColors.rose,
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.player, required this.size});

  final WorldPlayer player;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = player.avatarColor;
    Widget avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withAlpha(170)],
        ),
      ),
      child: Center(
        child: Text(
          player.avatarInitials,
          style: GoogleFonts.spaceGrotesk(
            fontSize: size * 0.36,
            fontWeight: FontWeight.w700,
            color: SrColors.textInk,
          ),
        ),
      ),
    );

    // Flag badge
    if (player.flag != null) {
      avatar = Stack(
        clipBehavior: Clip.none,
        children: [
          avatar,
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              width: size * 0.38,
              height: size * 0.38,
              decoration: const BoxDecoration(
                color: SrColors.bg,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  player.flag!,
                  style: TextStyle(fontSize: size * 0.22),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return avatar;
  }
}
