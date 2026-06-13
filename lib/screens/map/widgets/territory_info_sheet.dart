import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sapiens_rank/common/data_state.dart';
import 'package:sapiens_rank/common/helpers/guild_visuals.dart';
import 'package:sapiens_rank/common/theme/sr_theme.dart';
import 'package:sapiens_rank/common/widgets/guild_avatar.dart';
import 'package:sapiens_rank/common/widgets/sr_bottom_sheet.dart';
import 'package:sapiens_rank/models/guild_models.dart';
import 'package:sapiens_rank/screens/map/cubit/territory_members_cubit.dart';

class TerritoryInfoSheet extends StatelessWidget {
  const TerritoryInfoSheet({super.key, required this.territory});

  final Territory territory;

  static Future<void> show(
    BuildContext context, {
    required Territory territory,
  }) {
    return SrBottomSheet.show(
      context: context,
      child: BlocProvider(
        create: (_) => TerritoryMembersCubit()..load(territory.guilds?.id),
        child: TerritoryInfoSheet(territory: territory),
      ),
    );
  }

  String _sinceLabel() {
    final at = territory.conqueredAt;
    if (at == null) return 'Unknown';
    final diff = DateTime.now().difference(at);
    if (diff.inDays >= 365) return 'for ${diff.inDays ~/ 365}y';
    if (diff.inDays >= 30) return 'for ${diff.inDays ~/ 30}mo';
    if (diff.inDays >= 1) return 'for ${diff.inDays}d';
    if (diff.inHours >= 1) return 'for ${diff.inHours}h';
    return 'just claimed';
  }

  @override
  Widget build(BuildContext context) {
    final guild = territory.guilds;
    final color = guild != null
        ? guildColorFromHex(guild.color)
        : context.srTextMuted;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _GuildHeader(guild: guild, color: color, since: _sinceLabel()),
        const SizedBox(height: 20),
        Text(
          'MEMBERS',
          style: TextStyle(
            color: context.srTextDim,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        BlocBuilder<TerritoryMembersCubit, DataState<List<GuildMember>>>(
          builder: (context, state) => state.when(
            loading: () => Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: context.srLime,
                  ),
                ),
              ),
            ),
            error: (_) => Text(
              'Could not load members.',
              style: TextStyle(color: context.srTextMuted, fontSize: 13),
            ),
            success: (members) => members.isEmpty
                ? Text(
                    'No members found.',
                    style: TextStyle(color: context.srTextMuted, fontSize: 13),
                  )
                : Column(
                    children: members
                        .map((m) => _MemberRow(member: m, guildColor: color))
                        .toList(),
                  ),
          ),
        ),
      ],
    );
  }
}

class _GuildHeader extends StatelessWidget {
  const _GuildHeader({
    required this.guild,
    required this.color,
    required this.since,
  });

  final TerritoryGuild? guild;
  final Color color;
  final String since;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GuildAvatar(color: color, initials: guildInitials(guild?.name)),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                guild?.name ?? 'Unknown guild',
                style: TextStyle(
                  color: context.srText,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Holds this territory $since',
                style: TextStyle(color: context.srTextMuted, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MemberRow extends StatelessWidget {
  const _MemberRow({required this.member, required this.guildColor});

  final GuildMember member;
  final Color guildColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: context.srBgElev2,
              shape: BoxShape.circle,
              border: Border.all(
                color: member.isLeader
                    ? guildColor.withAlpha(160)
                    : context.srLine,
              ),
            ),
            child: Center(
              child: Text(
                member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
                style: TextStyle(
                  color: member.isLeader ? guildColor : context.srTextMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              member.name,
              style: TextStyle(
                color: context.srText,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (member.isLeader)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: guildColor.withAlpha(25),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: guildColor.withAlpha(80)),
              ),
              child: Text(
                'Leader',
                style: TextStyle(
                  color: guildColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else if (member.country != null)
            Text(
              countryFlag(member.country!),
              style: const TextStyle(fontSize: 18),
            ),
        ],
      ),
    );
  }
}
