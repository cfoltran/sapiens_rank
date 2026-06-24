import 'package:sapiens_rank/models/booster.dart';
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

  static const _attackSelect =
      'id, attacker_guild_id, defender_guild_id, territory_id, '
      'metric, starts_at, ends_at, status, '
      'attacker_score, defender_score, winner_guild_id, booster';

  Future<List<Attack>> fetchActiveAttacks() async {
    final rows = await _db
        .from('attacks')
        .select(_attackSelect)
        .eq('status', 'active');
    return (rows as List)
        .cast<Map<String, dynamic>>()
        .map(Attack.fromJson)
        .toList();
  }

  Future<List<Attack>> fetchGuildAttacks(String guildId) async {
    final rows = await _db
        .from('attacks')
        .select(_attackSelect)
        .or('attacker_guild_id.eq.$guildId,defender_guild_id.eq.$guildId')
        .order('created_at', ascending: false)
        .limit(20);
    return (rows as List)
        .cast<Map<String, dynamic>>()
        .map(Attack.fromJson)
        .toList();
  }

  Future<void> createAttack({
    required String territoryId,
    required String? defenderGuildId,
    required AttackMetric metric,
    required DateTime endsAt,
    BoosterType? booster,
    bool chooseMetric = false,
  }) async {
    final boosterValue = switch (booster) {
      BoosterType.boost => 'boost',
      BoosterType.surge => 'surge',
      BoosterType.blitz => 'blitz',
      null => null,
    };

    await _db.rpc(
      'launch_attack',
      params: {
        'p_territory_id': territoryId,
        'p_defender_guild_id': defenderGuildId,
        'p_metric': metric.name,
        'p_ends_at': endsAt.toIso8601String(),
        'p_booster': boosterValue,
        'p_choose_metric': chooseMetric,
      },
    );
  }
}
