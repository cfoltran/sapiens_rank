import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sapiens_rank/common/data_state.dart';
import 'package:sapiens_rank/common/helpers/guild_visuals.dart';
import 'package:sapiens_rank/common/theme/sr_theme.dart';
import 'package:sapiens_rank/models/guild_models.dart';
import 'package:sapiens_rank/screens/guild/guild_page.dart';
import 'package:sapiens_rank/screens/map/cubit/map_cubit.dart';
import 'package:sapiens_rank/screens/map/cubit/map_state.dart';
import 'package:sapiens_rank/screens/map/game/map_game.dart';
import 'package:sapiens_rank/screens/map/widgets/attack_sheet.dart';
import 'package:sapiens_rank/screens/map/widgets/battle_sheet.dart';
import 'package:sapiens_rank/screens/map/widgets/rules_sheet.dart';
import 'package:sapiens_rank/screens/map/widgets/territory_info_sheet.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MapCubit()..load(),
      child: const _MapView(),
    );
  }
}

class _MapView extends StatefulWidget {
  const _MapView();

  @override
  State<_MapView> createState() => _MapViewState();
}

class _MapViewState extends State<_MapView> {
  MapGame? _game;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _game ??= MapGame(colors: _colorsFor(context))
      ..onTerritoryTapHandler = _onTerritoryTap;
  }

  MapColors _colorsFor(BuildContext context) {
    final dark = context.isDark;
    return MapColors(
      neutral: dark ? const Color(0xFF1B2B1C) : const Color(0xFFB8C9B0),
      border: dark ? const Color(0xFF3A3A3A) : const Color(0xFFBBBBBB),
      highlight: context.srLime,
      text: dark ? Colors.white70 : Colors.black54,
      ambient: context.srLime,
    );
  }

  void _onTerritoryTap(Territory territory) {
    final data = context.read<MapCubit>().state.data;
    if (data == null) return;

    final isAttackable = data.attackableTerritoryIds.contains(territory.id);
    final activeAttack = data.activeAttackOn(territory.id);
    final isMine =
        territory.ownerGuildId == data.myGuildId && data.myGuildId != null;

    if (activeAttack != null) {
      BattleSheet.show(
        context,
        attack: activeAttack,
        territory: territory,
        territories: data.territories,
        myGuildId: data.myGuildId,
      );
      return;
    }

    if (isMine) return;

    if (!isAttackable) {
      if (!territory.isNeutral) {
        TerritoryInfoSheet.show(context, territory: territory);
      } else if (data.myGuildId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Join a guild to attack territories')),
        );
      }
      return;
    }

    HapticFeedback.mediumImpact();
    final cubit = context.read<MapCubit>();
    AttackSheet.show(
      context,
      territory: territory,
      onConfirm: ({required metric, required endsAt}) => cubit.launchAttack(
        territoryId: territory.id,
        defenderGuildId: territory.ownerGuildId,
        metric: metric,
        endsAt: endsAt,
      ),
    );
  }

  void _openRules() => RulesSheet.show(context);

  Future<void> _openGuild() async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => const GuildPage()),
    );
    if (mounted) context.read<MapCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    final game = _game!..colors = _colorsFor(context);
    return Scaffold(
      backgroundColor: context.srBg,
      body: BlocListener<MapCubit, DataState<MapData>>(
        listener: (context, state) =>
            state.maybeWhen(success: game.applyData, orElse: () {}),
        child: BlocBuilder<MapCubit, DataState<MapData>>(
          builder: (context, state) {
            return state.when(
              success: (data) => _MapStack(
                game: game,
                data: data,
                onRecenter: () {
                  HapticFeedback.lightImpact();
                  game.focusOnMine(data.ownTerritories);
                },
                onOpenRules: _openRules,
                onOpenGuild: _openGuild,
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Failed to load map',
                      style: TextStyle(color: context.srTextMuted),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => context.read<MapCubit>().load(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MapStack extends StatelessWidget {
  const _MapStack({
    required this.game,
    required this.data,
    required this.onRecenter,
    required this.onOpenRules,
    required this.onOpenGuild,
  });

  final MapGame game;
  final MapData data;
  final VoidCallback onRecenter;
  final VoidCallback onOpenRules;
  final VoidCallback onOpenGuild;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: GameWidget(game: game)),
        Positioned(
          top: MediaQuery.of(context).padding.top + 12,
          right: 14,
          child: Row(
            children: [
              _RoundButton(icon: Icons.info_outline, onTap: onOpenRules),
              const SizedBox(width: 8),
              _GuildBadge(
                myGuildId: data.myGuildId,
                territories: data.territories,
                onTap: onOpenGuild,
              ),
            ],
          ),
        ),
        Positioned(
          right: 14,
          bottom: MediaQuery.of(context).padding.bottom + 24,
          child: _RoundButton(icon: Icons.my_location, onTap: onRecenter),
        ),
      ],
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: context.srBgElev.withAlpha(220),
          shape: BoxShape.circle,
          border: Border.all(color: context.srLine),
          boxShadow: [
            BoxShadow(
              color: context.srShadow,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, size: 18, color: context.srTextMuted),
      ),
    );
  }
}

class _GuildBadge extends StatelessWidget {
  const _GuildBadge({
    required this.myGuildId,
    required this.territories,
    required this.onTap,
  });

  final String? myGuildId;
  final List<Territory> territories;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    TerritoryGuild? guild;
    if (myGuildId != null) {
      for (final t in territories) {
        if (t.ownerGuildId == myGuildId && t.guilds != null) {
          guild = t.guilds;
          break;
        }
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: context.srBgElev.withAlpha(220),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: context.srLine),
          boxShadow: [
            BoxShadow(
              color: context.srShadow,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (guild != null) ...[
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: guildColorFromHex(guild.color),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 7),
              Text(
                guild.name,
                style: TextStyle(
                  color: context.srText,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ] else ...[
              Icon(Icons.group_add, size: 16, color: context.srLimeText),
              const SizedBox(width: 6),
              Text(
                'Guild',
                style: TextStyle(
                  color: context.srLimeText,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, size: 16, color: context.srTextDim),
          ],
        ),
      ),
    );
  }
}
