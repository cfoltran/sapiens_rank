import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sapiens_rank/common/data_state.dart';
import 'package:sapiens_rank/common/helpers/guild_visuals.dart';
import 'package:sapiens_rank/common/theme/sr_theme.dart';
import 'package:sapiens_rank/l10n/app_localizations.dart';
import 'package:sapiens_rank/common/widgets/sr_pill.dart';
import 'package:sapiens_rank/models/guild_models.dart';
import 'package:sapiens_rank/screens/guild/guild_page.dart';
import 'package:sapiens_rank/screens/map/cubit/map_cubit.dart';
import 'package:sapiens_rank/screens/map/cubit/map_state.dart';
import 'package:sapiens_rank/screens/map/game/map_game.dart';
import 'package:sapiens_rank/screens/map/widgets/attack_sheet.dart';
import 'package:sapiens_rank/screens/map/widgets/battle_sheet.dart';
import 'package:sapiens_rank/screens/map/widgets/rules_sheet.dart';
import 'package:sapiens_rank/screens/map/widgets/territory_info_sheet.dart';
import 'package:sapiens_rank/screens/today/widgets/sapie_coin.dart';
import 'package:sapiens_rank/screens/today/widgets/sapies_info_sheet.dart';

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
          SnackBar(content: Text(AppLocalizations.of(context).map_no_guild)),
        );
      }
      return;
    }

    HapticFeedback.mediumImpact();
    final cubit = context.read<MapCubit>();
    AttackSheet.show(
      context,
      territory: territory,
      onConfirm: ({required metric, required endsAt, booster}) =>
          cubit.launchAttack(
            territoryId: territory.id,
            defenderGuildId: territory.ownerGuildId,
            metric: metric,
            endsAt: endsAt,
            booster: booster,
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
                sapiesBalance: data.sapiesBalance,
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
                      AppLocalizations.of(context).map_error,
                      style: TextStyle(color: context.srTextMuted),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => context.read<MapCubit>().load(),
                      child: Text(AppLocalizations.of(context).retry),
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
    required this.sapiesBalance,
    required this.onRecenter,
    required this.onOpenRules,
    required this.onOpenGuild,
  });

  final MapGame game;
  final MapData data;
  final int sapiesBalance;
  final VoidCallback onRecenter;
  final VoidCallback onOpenRules;
  final VoidCallback onOpenGuild;

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top + 12;
    return Stack(
      children: [
        Positioned.fill(child: GameWidget(game: game)),
        Positioned(
          top: topPad,
          left: 14,
          child: WalletPill(
            balance: sapiesBalance,
            onTap: () => SapiesInfoSheet.show(context),
          ),
        ),
        Positioned(
          top: topPad,
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
      child: SrPill(icon: icon, floating: true),
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

    final hasGuild = guild != null;
    return GestureDetector(
      onTap: onTap,
      child: SrPill(
        floating: true,
        leading: hasGuild
            ? Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: guildColorFromHex(guild.color),
                  shape: BoxShape.circle,
                ),
              )
            : null,
        icon: hasGuild ? null : Icons.group_add,
        label: hasGuild ? guild.name : AppLocalizations.of(context).nav_guild,
        textColor: hasGuild ? context.srText : context.srLimeText,
        trailing: Icon(Icons.chevron_right, size: 16, color: context.srTextDim),
      ),
    );
  }
}
