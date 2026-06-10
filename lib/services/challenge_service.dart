import 'package:sapiens_rank/models/challenge_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChallengeService {
  ChallengeService._();
  static final instance = ChallengeService._();

  final _db = Supabase.instance.client;
  String get _myId => _db.auth.currentUser!.id;

  Future<List<ChallengeRow>> fetchMyChallenges() async {
    final rows = await _db
        .from('challenge_participants')
        .select('''
          challenges!inner(
            id, metric, duration_days, starts_at, ends_at,
            stake_icon, stake_label, status, winner_id, created_by, created_at, goal_value,
            challenge_participants(
              user_id, is_creator, status,
              profiles!inner(name, country)
            )
          )
        ''')
        .eq('user_id', _myId);

    return (rows as List)
        .map((r) => ChallengeRow.fromJson(r['challenges']))
        .toList();
  }

  Future<List<ChallengeStanding>> getStandings(String challengeId) async {
    final result = await _db.rpc(
      'get_challenge_standings',
      params: {'p_challenge_id': challengeId},
    );
    return (result as List)
        .cast<Map<String, dynamic>>()
        .map(ChallengeStanding.fromJson)
        .toList();
  }

  Future<void> createChallenge({
    required String opponentId,
    required int durationDays,
    required String metric,
    required double? goalValue,
    required String stakeIcon,
    required String stakeLabel,
  }) async {
    final challenge = await _db
        .from('challenges')
        .insert({
          'created_by': _myId,
          'metric': metric,
          'duration_days': durationDays,
          'stake_icon': stakeIcon,
          'stake_label': stakeLabel,
          if (goalValue != null) 'goal_value': goalValue,
          if (goalValue != null) 'goal_unit': 'km',
        })
        .select()
        .single();

    await _db.from('challenge_participants').insert({
      'challenge_id': challenge['id'],
      'user_id': opponentId,
    });
  }

  Future<ChallengeRow?> fetchChallengeById(String challengeId) async {
    try {
      final row = await _db
          .from('challenge_participants')
          .select('''
            challenges!inner(
              id, metric, duration_days, starts_at, ends_at,
              stake_icon, stake_label, status, winner_id, created_by, created_at,
              challenge_participants(
                user_id, is_creator, status,
                profiles!inner(name, country)
              )
            )
          ''')
          .eq('challenge_id', challengeId)
          .eq('user_id', _myId)
          .single();
      return ChallengeRow.fromJson(row['challenges']);
    } catch (_) {
      return null;
    }
  }

  Future<void> respondToChallenge(
    String challengeId, {
    required bool accept,
  }) async => await _db
      .from('challenge_participants')
      .update({
        'status': accept ? 'accepted' : 'declined',
        'responded_at': DateTime.now().toIso8601String(),
      })
      .eq('challenge_id', challengeId)
      .eq('user_id', _myId);

  Future<void> cancelChallenge(String challengeId) async => await _db
      .from('challenges')
      .update({'status': 'cancelled'})
      .eq('id', challengeId)
      .eq('created_by', _myId);

  Future<List<OpponentRow>> getPotentialOpponents() async {
    final rows = await _db
        .from('leaderboard')
        .select('user_id, score, country, profiles!inner(name)')
        .neq('user_id', _myId)
        .order('score', ascending: false)
        .limit(30);
    return (rows as List)
        .cast<Map<String, dynamic>>()
        .map(OpponentRow.fromJson)
        .toList();
  }
}
