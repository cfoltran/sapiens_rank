import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sapiens_rank/common/data_state.dart';
import 'package:sapiens_rank/common/theme/sr_theme.dart';
import 'package:sapiens_rank/models/guild_models.dart';
import 'package:sapiens_rank/screens/guild/cubit/join_guild_cubit.dart';

Color _parse(String hex) {
  final h = hex.replaceAll('#', '');
  return Color(int.parse('FF$h', radix: 16));
}

class JoinGuildSheet extends StatelessWidget {
  const JoinGuildSheet({super.key, required this.onJoin});

  final void Function(String guildId) onJoin;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => JoinGuildCubit()..load(),
      child: _JoinGuildView(onJoin: onJoin),
    );
  }
}

class _JoinGuildView extends StatelessWidget {
  const _JoinGuildView({required this.onJoin});

  final void Function(String guildId) onJoin;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: context.srBgElev,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: context.srLine,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Join a guild',
            style: TextStyle(
              color: context.srText,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BlocBuilder<JoinGuildCubit, DataState<List<GuildRow>>>(
              builder: (context, state) => state.when(
                success: (guilds) => guilds.isEmpty
                    ? Center(
                        child: Text(
                          'No guilds found',
                          style: TextStyle(color: context.srTextMuted),
                        ),
                      )
                    : ListView.separated(
                        itemCount: guilds.length,
                        separatorBuilder: (context, i) =>
                            Divider(color: context.srLine, height: 1),
                        itemBuilder: (_, i) =>
                            _GuildTile(guild: guilds[i], onJoin: onJoin),
                      ),
                loading: () => Center(
                  child: CircularProgressIndicator(
                    color: context.srLime,
                    strokeWidth: 2,
                  ),
                ),
                error: (_) => Center(
                  child: TextButton(
                    onPressed: () => context.read<JoinGuildCubit>().load(),
                    child: const Text('Retry'),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GuildTile extends StatelessWidget {
  const _GuildTile({required this.guild, required this.onJoin});

  final GuildRow guild;
  final void Function(String guildId) onJoin;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: _parse(guild.color),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            guild.name[0].toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ),
      ),
      title: Text(
        guild.name,
        style: TextStyle(color: context.srText, fontWeight: FontWeight.w600),
      ),
      trailing: GestureDetector(
        onTap: () {
          Navigator.pop(context);
          onJoin(guild.id);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: context.srLime.withAlpha(30),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: context.srLime),
          ),
          child: Text(
            'Join',
            style: TextStyle(
              color: context.srLimeText,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
