import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sapiens_rank/common/data_state.dart';
import 'package:sapiens_rank/models/habits_data.dart';
import 'package:sapiens_rank/screens/profile/cubit/profile_state.dart';
import 'package:sapiens_rank/services/habits_service.dart';
import 'package:sapiens_rank/services/profile_service.dart';
import 'package:sapiens_rank/services/score_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileCubit extends Cubit<DataState<ProfileData>> {
  ProfileCubit() : super(const DataState.loading());

  final _db = Supabase.instance.client;

  Future<void> load() async {
    emit(const DataState.loading());
    try {
      final uid = _db.auth.currentUser?.id;
      if (uid == null) {
        emit(const DataState.error('not_logged_in'));
        return;
      }

      final results = await Future.wait<dynamic>([
        _db
            .from('profiles')
            .select(
              'name, country, created_at, '
              'target_steps, target_kcal, target_sleep_hours, target_stand_hours, target_daily_exercise_minutes',
            )
            .eq('id', uid)
            .single(),
        _db.from('scores').select('score, personal_score').eq('user_id', uid),
        ScoreService.instance.getStreak(),
        ScoreService.instance.getPersonalScoreHistoryDated(days: 30),
        HabitsService.instance.getHabits(),
      ]);

      final profile = results[0] as Map<String, dynamic>;
      final allScoresRaw = results[1] as List<dynamic>;
      final streak = results[2] as int;
      final history30d = results[3] as List<(DateTime, int)>;
      final habits = (results[4] as HabitsData?) ?? const HabitsData();

      final name = (profile['name'] as String?) ?? 'Sapien';
      final country = (profile['country'] as String?) ?? 'FR';
      final createdAt = DateTime.parse(profile['created_at'] as String);
      final d = HealthTargets.defaults;
      final targets = HealthTargets(
        steps: (profile['target_steps'] as int?) ?? d.steps,
        kcal: (profile['target_kcal'] as num?)?.toDouble() ?? d.kcal,
        sleepHours:
            (profile['target_sleep_hours'] as num?)?.toDouble() ?? d.sleepHours,
        standHours: (profile['target_stand_hours'] as int?) ?? d.standHours,
        hrv: d.hrv,
        dailyExerciseMinutes:
            (profile['target_daily_exercise_minutes'] as int?) ??
            d.dailyExerciseMinutes,
      );

      final lifetimeAvg = allScoresRaw.isEmpty
          ? 0
          : (allScoresRaw
                        .map(
                          (r) =>
                              (r['personal_score'] as int?) ??
                              (r['score'] as int),
                        )
                        .reduce((a, b) => a + b) /
                    allScoresRaw.length)
                .round();

      // Trend: compare second half vs first half of available data
      double trendDelta = 0;
      String trendLabel = 'Stable';
      if (history30d.length >= 4) {
        final scores = history30d.map((e) => e.$2).toList();
        final half = scores.length ~/ 2;
        final firstAvg = scores.sublist(0, half).reduce((a, b) => a + b) / half;
        final secondAvg =
            scores.sublist(half).reduce((a, b) => a + b) /
            (scores.length - half);
        trendDelta = secondAvg - firstAvg;
        if (trendDelta > 1) trendLabel = 'Climbing';
        if (trendDelta < -1) trendLabel = 'Declining';
      }

      emit(
        DataState.success(
          ProfileData(
            name: name,
            country: country,
            joinedAt: createdAt,
            lifetimeAvg: lifetimeAvg,
            streak: streak,
            scoreHistory30d: history30d,
            trendDelta: trendDelta,
            trendLabel: trendLabel,
            targets: targets,
            habits: habits,
          ),
        ),
      );
    } catch (e, st) {
      emit(DataState.error('fetch_failed', error: e, stackTrace: st));
    }
  }

  Future<void> updateTargets(HealthTargets targets) async {
    final current = state.data;
    if (current == null) return;
    emit(DataState.success(current.copyWith(targets: targets)));
    await ProfileService.instance.updateTargets(targets);
  }

  Future<void> updateHabits(HabitsData habits) async {
    final current = state.data;
    if (current == null) return;
    emit(DataState.success(current.copyWith(habits: habits)));
    await ProfileService.instance.updateHabits(habits);
  }

  Future<void> deleteAccount() async {
    await ProfileService.instance.deleteAccount();
    await _db.auth.signOut();
  }
}
