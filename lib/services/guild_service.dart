import 'package:sapiens_rank/models/guild_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GuildService {
  GuildService._();
  static final instance = GuildService._();

  final _db = Supabase.instance.client;
  String get _myId => _db.auth.currentUser!.id;

  Future<GuildRow?> fetchMyGuild() async {
    final rows = await _db
        .from('guild_members')
        .select('guilds!inner(id, name, color, created_by, created_at)')
        .eq('user_id', _myId)
        .limit(1);

    if ((rows as List).isEmpty) return null;
    return GuildRow.fromJson(rows.first['guilds']);
  }

  Future<GuildRow> fetchGuildById(String guildId) async {
    final row = await _db
        .from('guilds')
        .select('id, name, color, created_by, created_at')
        .eq('id', guildId)
        .single();
    return GuildRow.fromJson(row);
  }

  Future<List<GuildMember>> fetchMembers(String guildId) async {
    final rows = await _db
        .from('guild_members')
        .select(
          'guild_id, user_id, role, joined_at, profiles!inner(name, country)',
        )
        .eq('guild_id', guildId)
        .order('joined_at');
    return (rows as List)
        .cast<Map<String, dynamic>>()
        .map(GuildMember.fromJson)
        .toList();
  }

  Future<int> fetchMaxMembers(String guildId) async {
    final result = await _db.rpc(
      'guild_max_members',
      params: {'p_guild_id': guildId},
    );
    return result as int;
  }

  Future<GuildRow> createGuild({
    required String name,
    required String color,
  }) async {
    final row = await _db
        .from('guilds')
        .insert({'name': name, 'color': color, 'created_by': _myId})
        .select('id, name, color, created_by, created_at')
        .single();
    return GuildRow.fromJson(row);
  }

  Future<void> joinGuild(String guildId) async {
    await _db.from('guild_members').insert({
      'guild_id': guildId,
      'user_id': _myId,
    });
  }

  Future<void> leaveGuild(String guildId) async {
    await _db
        .from('guild_members')
        .delete()
        .eq('guild_id', guildId)
        .eq('user_id', _myId);
  }

  Future<List<GuildRow>> searchGuilds(String query) async {
    final rows = await _db
        .from('guilds')
        .select('id, name, color, created_by, created_at')
        .ilike('name', '%$query%')
        .limit(20);
    return (rows as List)
        .cast<Map<String, dynamic>>()
        .map(GuildRow.fromJson)
        .toList();
  }
}
