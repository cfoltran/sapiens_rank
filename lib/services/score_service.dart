import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sapiens_rank/services/health_service.dart';
import 'package:sapiens_rank/services/health_targets.dart';
import 'package:sapiens_rank/services/profile_service.dart';

class ScoreBreakdown {
  const ScoreBreakdown({
    required this.score,
    required this.sleepPts,
    required this.stepsPts,
    required this.kcalPts,
    required this.standPts,
    required this.hrvPts,
  });

  final int score;
  final int sleepPts;
  final int stepsPts;
  final int kcalPts;
  final int standPts;
  final int hrvPts;

  /// Personal score using adaptive targets.
  /// When HRV data is unavailable, its 15 pts are redistributed:
  ///   sleep 25→29 · steps 25→29 · kcal 20→24 · stand 15→18 · hrv 0
  static ScoreBreakdown compute(
    HealthSnapshot snap, {
    HealthTargets targets = HealthTargets.defaults,
  }) {
    final hasHrv = snap.hrv != null;
    final sleepMax = hasHrv ? 25.0 : 29.0;
    final stepsMax = hasHrv ? 25.0 : 29.0;
    final kcalMax = hasHrv ? 20.0 : 24.0;
    final standMax = hasHrv ? 15.0 : 18.0;

    final sleep =
        (snap.sleepHours / targets.sleepHours).clamp(0.0, 1.0) * sleepMax;
    final steps = (snap.steps / targets.steps).clamp(0.0, 1.0) * stepsMax;
    final kcal = (snap.kcal / targets.kcal).clamp(0.0, 1.0) * kcalMax;
    final stand =
        (snap.standHours / targets.standHours).clamp(0.0, 1.0) * standMax;
    final hrv = hasHrv ? (snap.hrv! / targets.hrv).clamp(0.0, 1.0) * 15 : 0.0;

    return ScoreBreakdown(
      score: (sleep + steps + kcal + stand + hrv).round(),
      sleepPts: sleep.round(),
      stepsPts: steps.round(),
      kcalPts: kcal.round(),
      standPts: stand.round(),
      hrvPts: hrv.round(),
    );
  }

  /// Fixed-target score used for the leaderboard and challenges.
  static ScoreBreakdown computeRanking(HealthSnapshot snap) => compute(snap);
}

class LeaderboardEntry {
  const LeaderboardEntry({
    required this.userId,
    required this.score,
    this.rankWorld,
    this.rankCountry,
    this.rankDelta,
    this.country,
    this.displayName,
  });

  final String userId;
  final double score;
  final int? rankWorld;
  final int? rankCountry;
  final int? rankDelta;
  final String? country;
  final String? displayName;

  factory LeaderboardEntry.fromJson(Map<String, dynamic> j) {
    final profiles = j['profiles'] as Map<String, dynamic>?;
    return LeaderboardEntry(
      userId: j['user_id'] as String,
      score: (j['score'] as num).toDouble(),
      rankWorld: j['rank_world'] as int?,
      rankCountry: j['rank_country'] as int?,
      rankDelta: j['rank_delta'] as int?,
      country: j['country'] as String?,
      displayName: profiles?['name'] as String?,
    );
  }
}

class ScoreService {
  ScoreService._();
  static final ScoreService instance = ScoreService._();

  final _db = Supabase.instance.client;

  String? get _userId => _db.auth.currentUser?.id;

  /// Backfills any missing days between [latest_sync] and today (max 7),
  /// then updates [latest_sync] on the profile.
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

      final targets = await ProfileService.instance.getPersonalTargets();

      var day = actualStart;
      while (!day.isAfter(today)) {
        await _syncDay(uid, day, targets);
        day = day.add(const Duration(days: 1));
      }

      await _db
          .from('profiles')
          .update({'latest_sync': _isoDate(today)})
          .eq('id', uid);
    } catch (_) {}
  }

  Future<void> _syncDay(String uid, DateTime date, HealthTargets targets) async {
    try {
      final snap = await HealthService.instance.fetchDaySnapshot(date);
      final ranking = ScoreBreakdown.computeRanking(snap);
      final personal = ScoreBreakdown.compute(snap, targets: targets);

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

  Future<List<int>> getScoreHistory({int days = 14}) async {
    final uid = _userId;
    if (uid == null) return [];
    try {
      final rows = await _db
          .from('scores')
          .select('score')
          .eq('user_id', uid)
          .gte(
            'date',
            _isoDate(DateTime.now().subtract(Duration(days: days - 1))),
          )
          .order('date')
          .limit(days);
      return rows.map<int>((r) => r['score'] as int).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<(DateTime, int)>> getScoreHistoryDated({int days = 30}) async {
    final uid = _userId;
    if (uid == null) return [];
    try {
      final rows = await _db
          .from('scores')
          .select('date, score')
          .eq('user_id', uid)
          .gte(
            'date',
            _isoDate(DateTime.now().subtract(Duration(days: days - 1))),
          )
          .order('date')
          .limit(days);
      return rows
          .map<(DateTime, int)>(
            (r) => (DateTime.parse(r['date'] as String), r['score'] as int),
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
      return (await (query.order('rank_world').limit(limit)))
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
