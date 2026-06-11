import 'package:flutter/material.dart';
import 'package:sapiens_rank/common/theme/sr_theme.dart';
import 'package:sapiens_rank/models/guild_models.dart';
import 'package:sapiens_rank/services/guild_service.dart';

Color _parse(String hex) {
  final h = hex.replaceAll('#', '');
  return Color(int.parse('FF$h', radix: 16));
}

class JoinGuildSheet extends StatefulWidget {
  const JoinGuildSheet({super.key, required this.onJoin});

  final void Function(String guildId) onJoin;

  @override
  State<JoinGuildSheet> createState() => _JoinGuildSheetState();
}

class _JoinGuildSheetState extends State<JoinGuildSheet> {
  final _controller = TextEditingController();
  List<GuildRow> _results = [];
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    _search('');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    setState(() => _searching = true);
    try {
      final results = await GuildService.instance.searchGuilds(query);
      if (mounted) setState(() => _results = results);
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: context.srBgElev,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
        24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36, height: 4,
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
          TextField(
            controller: _controller,
            style: TextStyle(color: context.srText),
            onChanged: (v) => _search(v),
            decoration: InputDecoration(
              hintText: 'Search by name',
              hintStyle: TextStyle(color: context.srTextDim),
              prefixIcon: Icon(Icons.search, color: context.srTextDim, size: 20),
              filled: true,
              fillColor: context.srBgElev2,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: context.srLine),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: context.srLine),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: context.srLime),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _searching
                ? Center(
                    child: CircularProgressIndicator(
                      color: context.srLime, strokeWidth: 2,
                    ),
                  )
                : _results.isEmpty
                    ? Center(
                        child: Text(
                          'No guilds found',
                          style: TextStyle(color: context.srTextMuted),
                        ),
                      )
                    : ListView.separated(
                        itemCount: _results.length,
                        separatorBuilder: (context, i) => Divider(
                          color: context.srLine, height: 1,
                        ),
                        itemBuilder: (_, i) {
                          final guild = _results[i];
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
                              style: TextStyle(
                                color: context.srText,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            trailing: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                widget.onJoin(guild.id);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 6,
                                ),
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
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
