import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sapiens_rank/models/habits_data.dart';
import 'package:sapiens_rank/models/health_targets.dart';
import 'package:sapiens_rank/models/leaderboard_entry.dart';
import 'package:sapiens_rank/models/score_breakdown.dart';
import 'package:sapiens_rank/services/habits_service.dart';
import 'package:sapiens_rank/services/health_service.dart';
import 'package:sapiens_rank/services/profile_service.dart';

export 'package:sapiens_rank/models/health_targets.dart';
export 'package:sapiens_rank/models/leaderboard_entry.dart';
export 'package:sapiens_rank/models/score_breakdown.dart';

class ScoreService {
  ScoreService._();
  static final ScoreService instance = ScoreService._();

  final _db = Supabase.instance.client;

  String? get _userId => _db.auth.currentUser?.id;

  Future<void> sync() async {
    final uid = _userId;
    if (uid == null) return;

    try {
      final profile = await _db
          .from('profiles')
          .select('latest_sync')
          .eq('id', uid)
          .single();

      final latestSync = profile['latest_sync'] != null
          ? DateTime.parse(profile['latest_sync'] as String)
          : null;

      final today = _dateOnly(DateTime.now());

      final startDay = latestSync != null
          ? latestSync.add(const Duration(days: 1))
          : today.subtract(const Duration(days: 6));
      final actualStart = today.difference(startDay).inDays > 6
          ? today.subtract(const Duration(days: 6))
          : startDay;

      final results = await Future.wait([
        ProfileService.instance.getPersonalTargets(),
        HabitsService.instance.getHabits(),
      ]);
      final targets = results[0] as HealthTargets;
      final habits = results[1] as HabitsData?;

      var day = actualStart;
      while (!day.isAfter(today)) {
        await _syncDay(uid, day, targets, habits);
        day = day.add(const Duration(days: 1));
      }

      await _db
          .from('profiles')
          .update({'latest_sync': _isoDate(today)})
          .eq('id', uid);
    } catch (_) {}
  }

  Future<void> _syncDay(
    String uid,
    DateTime date,
    HealthTargets targets,
    HabitsData? habits,
  ) async {
    try {
      final snap = await HealthService.instance.fetchDaySnapshot(date);
      final ranking = ScoreBreakdown.computeRanking(snap);
      final personal = ScoreBreakdown.compute(
        snap,
        targets: targets,
        habits: habits,
      );

      await Future.wait([
        _db.from('scores').upsert({
          'user_id': uid,
          'date': _isoDate(date),
          'score': ranking.score,
          'personal_score': personal.score,
        }),
        _db.from('daily_metrics').upsert({
          'user_id': uid,
          'date': _isoDate(date),
          if (snap.sleepHours > 0) 'sleep_hours': snap.sleepHours,
          if (snap.steps > 0) 'steps': snap.steps,
          if (snap.kcal > 0) 'kcal': snap.kcal,
          if (snap.standHours > 0) 'stand_hours': snap.standHours,
          if (snap.hrv != null) 'hrv': snap.hrv,
          if (snap.restingHr != null) 'resting_hr': snap.restingHr,
        }),
      ]);
    } catch (_) {}
  }

  Future<LeaderboardEntry?> getMyRank() async {
    final uid = _userId;
    if (uid == null) return null;
    try {
      final row = await _db
          .from('leaderboard')
          .select()
          .eq('user_id', uid)
          .maybeSingle();
      return row != null ? LeaderboardEntry.fromJson(row) : null;
    } catch (_) {
      return null;
    }
  }

  Future<int> getLeaderboardCount() async {
    try {
      final res = await _db
          .from('leaderboard')
          .select('user_id')
          .count(CountOption.exact);
      return res.count;
    } catch (_) {
      return 0;
    }
  }

  Future<List<int>> getPersonalScoreHistory({int days = 14}) async {
    final uid = _userId;
    if (uid == null) return [];
    try {
      final rows = await _db
          .from('scores')
          .select('score, personal_score')
          .eq('user_id', uid)
          .gte(
            'date',
            _isoDate(DateTime.now().subtract(Duration(days: days - 1))),
          )
          .order('date')
          .limit(days);
      return rows
          .map<int>((r) => (r['personal_score'] as int?) ?? (r['score'] as int))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<(DateTime, int)>> getPersonalScoreHistoryDated({
    int days = 30,
  }) async {
    final uid = _userId;
    if (uid == null) return [];
    try {
      final rows = await _db
          .from('scores')
          .select('date, score, personal_score')
          .eq('user_id', uid)
          .gte(
            'date',
            _isoDate(DateTime.now().subtract(Duration(days: days - 1))),
          )
          .order('date')
          .limit(days);
      return rows
          .map<(DateTime, int)>(
            (r) => (
              DateTime.parse(r['date'] as String),
              (r['personal_score'] as int?) ?? (r['score'] as int),
            ),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<LeaderboardEntry>> getTopLeaderboard({
    String? country,
    int limit = 12,
  }) async {
    try {
      var query = _db
          .from('leaderboard')
          .select(
            'user_id, score, rank_world, rank_country, country, rank_delta, profiles(name)',
          );

      if (country != null) {
        return (await query
                .eq('country', country)
                .order('rank_country')
                .limit(limit))
            .map<LeaderboardEntry>((r) => LeaderboardEntry.fromJson(r))
            .toList();
      }
      return (await query.order('rank_world').limit(limit))
          .map<LeaderboardEntry>((r) => LeaderboardEntry.fromJson(r))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<int> getStreak() async {
    final uid = _userId;
    if (uid == null) return 0;
    try {
      final rows = await _db
          .from('scores')
          .select('date')
          .eq('user_id', uid)
          .order('date', ascending: false)
          .limit(365);

      if (rows.isEmpty) return 0;
      final dates = rows
          .map((r) => DateTime.parse(r['date'] as String))
          .toList();

      int streak = 1;
      for (int i = 1; i < dates.length; i++) {
        if (dates[i - 1].difference(dates[i]).inDays == 1) {
          streak++;
        } else {
          break;
        }
      }
      return streak;
    } catch (_) {
      return 0;
    }
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
  static String _isoDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
