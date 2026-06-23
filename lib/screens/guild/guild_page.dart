import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sapiens_rank/common/data_state.dart';
import 'package:sapiens_rank/common/theme/guild_skeleton.dart';
import 'package:sapiens_rank/common/theme/sr_theme.dart';
import 'package:sapiens_rank/models/guild_models.dart';
import 'package:sapiens_rank/screens/guild/cubit/guild_cubit.dart';
import 'package:sapiens_rank/screens/guild/cubit/guild_state.dart';
import 'package:sapiens_rank/common/widgets/sr_app_bar.dart';
import 'package:sapiens_rank/common/widgets/sr_pill.dart';
import 'package:sapiens_rank/screens/guild/widgets/create_guild_sheet.dart';
import 'package:sapiens_rank/screens/guild/widgets/join_guild_sheet.dart';

Color _parse(String hex) {
  final h = hex.replaceAll('#', '');
  return Color(int.parse('FF$h', radix: 16));
}

class GuildPage extends StatelessWidget {
  const GuildPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GuildCubit()..load(),
      child: const _GuildView(),
    );
  }
}

class _GuildView extends StatelessWidget {
  const _GuildView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.srBg,
      appBar: const SrAppBar(title: 'GUILD'),
      body: BlocBuilder<GuildCubit, DataState<GuildData>>(
        builder: (context, state) => state.when(
          success: (data) => data.isInGuild
              ? _GuildBody(data: data)
              : _NoGuildBody(takenColors: data.takenColors),
          loading: () => const GuildLoadingSkeleton(),
          error: (_) => Center(
            child: TextButton(
              onPressed: () => context.read<GuildCubit>().load(),
              child: const Text('Retry'),
            ),
          ),
        ),
      ),
    );
  }
}

class _NoGuildBody extends StatelessWidget {
  const _NoGuildBody({required this.takenColors});

  final Set<String> takenColors;

  void _openCreate(BuildContext context) {
    final cubit = context.read<GuildCubit>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CreateGuildSheet(
        takenColors: takenColors,
        onCreate: (name, color) => cubit.createGuild(name: name, color: color),
      ),
    );
  }

  void _openJoin(BuildContext context) {
    final cubit = context.read<GuildCubit>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          JoinGuildSheet(onJoin: (guildId) => cubit.joinGuild(guildId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You\'re a lone wolf',
              style: TextStyle(
                color: context.srText,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Join or create a guild to conquer territories and fight other guilds together.',
              style: TextStyle(
                color: context.srTextMuted,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            _ActionCard(
              icon: Icons.add,
              title: 'Create a guild',
              subtitle: 'You become leader, claim your first territory.',
              onTap: () => _openCreate(context),
            ),
            const SizedBox(height: 12),
            _ActionCard(
              icon: Icons.group_add,
              title: 'Join a guild',
              subtitle: 'Find an existing guild and contribute immediately.',
              onTap: () => _openJoin(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: context.srBgElev,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.srLine),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: context.srLime.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: context.srLimeText, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: context.srText,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(color: context.srTextMuted, fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: context.srTextDim, size: 20),
          ],
        ),
      ),
    );
  }
}

class _GuildBody extends StatelessWidget {
  const _GuildBody({required this.data});
  final GuildData data;

  @override
  Widget build(BuildContext context) {
    final guild = data.guild!;
    final guildColor = _parse(guild.color);
    final bottomPad = MediaQuery.of(context).padding.bottom + 16;

    return ListView(
      padding: EdgeInsets.fromLTRB(18, 0, 18, bottomPad),
      children: [
        _GuildHeader(guild: guild, data: data, guildColor: guildColor),
        const SizedBox(height: 18),
        _MembersCard(data: data, guildColor: guildColor),
        if (data.attackHistory.isNotEmpty) ...[
          const SizedBox(height: 18),
          _AttackHistoryCard(attacks: data.attackHistory),
        ],
        const SizedBox(height: 24),
        _LeaveButton(guildId: guild.id, guildName: guild.name),
      ],
    );
  }
}

class _GuildHeader extends StatelessWidget {
  const _GuildHeader({
    required this.guild,
    required this.data,
    required this.guildColor,
  });

  final GuildRow guild;
  final GuildData data;
  final Color guildColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.srBgElev,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: guildColor.withAlpha(80)),
        boxShadow: [BoxShadow(color: guildColor.withAlpha(30), blurRadius: 20)],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: guildColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                guild.name[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  guild.name,
                  style: TextStyle(
                    color: context.srText,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    SrPill(
                      size: SrPillSize.small,
                      icon: Icons.grid_on,
                      label: '${data.territoryCount} territories',
                      color: context.srLimeText,
                    ),
                    const SizedBox(width: 8),
                    SrPill(
                      size: SrPillSize.small,
                      icon: Icons.group,
                      label: '${data.memberCount}/${data.maxMembers}',
                      color: context.srTextMuted,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MembersCard extends StatelessWidget {
  const _MembersCard({required this.data, required this.guildColor});
  final GuildData data;
  final Color guildColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.srBgElev,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.srLine),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MEMBERS',
            style: TextStyle(
              color: context.srTextDim,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 14),
          ...data.members.map(
            (m) => _MemberRow(member: m, guildColor: guildColor),
          ),
        ],
      ),
    );
  }
}

class _MemberRow extends StatelessWidget {
  const _MemberRow({required this.member, required this.guildColor});
  final GuildMember member;
  final Color guildColor;

  @override
  Widget build(BuildContext context) {
    final initials = member.name
        .trim()
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: guildColor.withAlpha(40),
              shape: BoxShape.circle,
              border: Border.all(color: guildColor.withAlpha(80)),
            ),
            child: Center(
              child: Text(
                initials,
                style: TextStyle(
                  color: guildColor,
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
            SrPill(
              size: SrPillSize.small,
              label: 'Leader',
              color: context.srAmber,
            ),
        ],
      ),
    );
  }
}

class _AttackHistoryCard extends StatelessWidget {
  const _AttackHistoryCard({required this.attacks});
  final List<Attack> attacks;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.srBgElev,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.srLine),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RECENT ATTACKS',
            style: TextStyle(
              color: context.srTextDim,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 14),
          ...attacks.take(5).map((a) => _AttackRow(attack: a)),
        ],
      ),
    );
  }
}

class _AttackRow extends StatelessWidget {
  const _AttackRow({required this.attack});
  final Attack attack;

  static const _metricLabel = {
    AttackMetric.steps: '👟',
    AttackMetric.sleep: '😴',
    AttackMetric.calories: '🔥',
    AttackMetric.stand: '🧍',
  };

  @override
  Widget build(BuildContext context) {
    final isActive = attack.isActive;
    final won = attack.winnerGuildId == attack.attackerGuildId;
    final icon = _metricLabel[attack.metric] ?? '';

    Color statusColor;
    String statusLabel;
    if (isActive) {
      statusColor = context.srAmber;
      statusLabel = 'Active';
    } else if (attack.winnerGuildId == null) {
      statusColor = context.srTextMuted;
      statusLabel = 'Tie';
    } else if (won) {
      statusColor = context.srLimeText;
      statusLabel = 'Won';
    } else {
      statusColor = context.srRose;
      statusLabel = 'Lost';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attack.metric.name[0].toUpperCase() +
                      attack.metric.name.substring(1),
                  style: TextStyle(
                    color: context.srText,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (!isActive && attack.attackerScore != null)
                  Text(
                    '${attack.attackerScore!.toStringAsFixed(0)} vs ${attack.defenderScore?.toStringAsFixed(0) ?? '0'}',
                    style: TextStyle(color: context.srTextMuted, fontSize: 11),
                  ),
              ],
            ),
          ),
          SrPill(
            size: SrPillSize.small,
            label: statusLabel,
            color: statusColor,
          ),
        ],
      ),
    );
  }
}

class _LeaveButton extends StatelessWidget {
  const _LeaveButton({required this.guildId, required this.guildName});
  final String guildId;
  final String guildName;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            backgroundColor: context.srBgElev,
            title: Text(
              'Leave guild?',
              style: TextStyle(color: context.srText),
            ),
            content: Text(
              'You will leave $guildName. Your guild\'s territories remain.',
              style: TextStyle(color: context.srTextMuted),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: context.srTextMuted),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text('Leave', style: TextStyle(color: context.srRose)),
              ),
            ],
          ),
        );
        if (confirm != true || !context.mounted) return;
        try {
          await context.read<GuildCubit>().leaveGuild(guildId);
        } catch (_) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Could not leave guild. Try again.'),
              ),
            );
          }
        }
      },
      child: Center(
        child: Text(
          'Leave guild',
          style: TextStyle(
            color: context.srRose,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
