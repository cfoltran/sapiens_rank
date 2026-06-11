import 'package:sapiens_rank/models/guild_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MapService {
  MapService._();
  static final instance = MapService._();

  final _db = Supabase.instance.client;

  Future<List<Territory>> fetchTerritories() async {
    final rows = await _db
        .from('territories')
        .select(
          'id, grid_x, grid_y, owner_guild_id, conquered_at, guilds(id, name, color)',
        );
    return (rows as List)
        .cast<Map<String, dynamic>>()
        .map(Territory.fromJson)
        .toList();
  }

  Future<List<Attack>> fetchActiveAttacks() async {
    final rows = await _db
        .from('attacks')
        .select(
          'id, attacker_guild_id, defender_guild_id, territory_id, '
          'metric, starts_at, ends_at, status, '
          'attacker_score, defender_score, winner_guild_id',
        )
        .eq('status', 'active');
    return (rows as List)
        .cast<Map<String, dynamic>>()
        .map(Attack.fromJson)
        .toList();
  }

  Future<List<Attack>> fetchGuildAttacks(String guildId) async {
    final rows = await _db
        .from('attacks')
        .select(
          'id, attacker_guild_id, defender_guild_id, territory_id, '
          'metric, starts_at, ends_at, status, '
          'attacker_score, defender_score, winner_guild_id',
        )
        .or('attacker_guild_id.eq.$guildId,defender_guild_id.eq.$guildId')
        .order('created_at', ascending: false)
        .limit(20);
    return (rows as List)
        .cast<Map<String, dynamic>>()
        .map(Attack.fromJson)
        .toList();
  }

  Future<Attack> createAttack({
    required String attackerGuildId,
    required String territoryId,
    required String? defenderGuildId,
    required AttackMetric metric,
    required DateTime endsAt,
  }) async {
    final row = await _db
        .from('attacks')
        .insert({
          'attacker_guild_id': attackerGuildId,
          'defender_guild_id': defenderGuildId,
          'territory_id': territoryId,
          'metric': metric.name,
          'ends_at': endsAt.toIso8601String(),
        })
        .select(
          'id, attacker_guild_id, defender_guild_id, territory_id, '
          'metric, starts_at, ends_at, status, '
          'attacker_score, defender_score, winner_guild_id',
        )
        .single();
    return Attack.fromJson(row);
  }
}
