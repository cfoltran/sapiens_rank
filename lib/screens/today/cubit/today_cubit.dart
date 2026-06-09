import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sapiens_rank/common/data_state.dart';
import 'package:sapiens_rank/screens/today/cubit/today_state.dart';
import 'package:sapiens_rank/services/health_service.dart';
import 'package:sapiens_rank/services/profile_service.dart';
import 'package:sapiens_rank/services/score_service.dart';

class TodayCubit extends Cubit<DataState<TodayData>> {
  TodayCubit() : super(const DataState.loading());

  Future<void> load() async {
    emit(const DataState.loading());
    try {
      await HealthService.instance.requestPermissions();

      // Sync first so today's score is in DB before we read the streak.
      // getStreak() reads DB; if today hasn't been upserted yet it returns 0.
      await ScoreService.instance.sync();

      // Fetch health data + remote data in parallel
      final results = await Future.wait([
        HealthService.instance.fetchDaySnapshot(), // today's live snapshot
        ScoreService.instance.getMyRank(), // leaderboard entry
        ScoreService.instance
            .getStreak(), // consecutive days (DB is up-to-date)
        ScoreService.instance.getPersonalScoreHistory(), // last 14 days from DB
        ProfileService.instance.getPersonalTargets(), // adaptive targets
      ]);

      final snap = results[0] as HealthSnapshot;
      final rank = results[1] as LeaderboardEntry?;
      final streak = results[2] as int;
      final dbHistory = results[3] as List<int>;
      final targets = results[4] as HealthTargets;

      final bd = ScoreBreakdown.compute(snap, targets: targets);

      // Score history from DB — append today's personal score if not already included
      final history = dbHistory.isNotEmpty && dbHistory.last == bd.score
          ? dbHistory
          : [...dbHistory, bd.score];
      final scoreDelta = history.length >= 2
          ? bd.score - history[history.length - 2]
          : 0;

      final sleepH = snap.sleepHours.floor();
      final sleepMin = ((snap.sleepHours % 1) * 60).round();

      String fmtSteps(int v) => v >= 1000
          ? '${v ~/ 1000},${(v % 1000).toString().padLeft(3, '0')}'
          : '$v';

      final dailyExerciseMinutes = snap.workouts.fold(
        0,
        (s, w) => s + w.durationMinutes,
      );

      final metrics = [
        TodayMetric(
          key: 'sleep',
          label: 'Sleep',
          iconName: 'sleep',
          contrib: bd.sleepPts,
          target: bd.sleepMax,
          rawLabel: sleepH > 0
              ? '${sleepH}h ${sleepMin}m / ${targets.sleepHours.toStringAsFixed(1)}h target'
              : '-- no sleep data',
        ),
        TodayMetric(
          key: 'steps',
          label: 'Steps',
          iconName: 'steps',
          contrib: bd.stepsPts,
          target: bd.stepsMax,
          rawLabel: '${fmtSteps(snap.steps)} / ${fmtSteps(targets.steps)}',
        ),
        TodayMetric(
          key: 'kcal',
          label: 'Active kcal',
          iconName: 'kcal',
          contrib: bd.kcalPts,
          target: bd.kcalMax,
          rawLabel: '${snap.kcal.round()} / ${targets.kcal.round()} kcal',
        ),
        TodayMetric(
          key: 'stand',
          label: 'Stand hours',
          iconName: 'stand',
          contrib: bd.standPts,
          target: bd.standMax,
          rawLabel: snap.standHours != null
              ? '${snap.standHours} / ${targets.standHours} hours'
              : '-- no Apple Watch data',
        ),
        TodayMetric(
          key: 'hrv',
          label: 'HRV',
          iconName: 'hrv',
          contrib: bd.hrvPts,
          target: bd.hrvMax,
          rawLabel: snap.hrv != null
              ? '${snap.hrv!.round()}ms · ${snap.hrv! > 55 ? 'above avg' : 'below avg'}'
              : '-- no data',
        ),
        TodayMetric(
          key: 'exercise',
          label: 'Exercise',
          iconName: 'exercise',
          contrib: bd.exercisePts,
          target: bd.exerciseMax,
          rawLabel: dailyExerciseMinutes > 0
              ? '${dailyExerciseMinutes}min / ${targets.dailyExerciseMinutes}min target'
              : '-- no workout today',
        ),
      ];

      final country = rank?.country ?? 'FR';
      final flag = _countryFlag(country);

      emit(
        DataState.success(
          TodayData(
            score: bd.score,
            scoreHistory: history,
            scoreDelta: scoreDelta,
            rankWorld: rank?.rankWorld,
            rankCountry: rank?.rankCountry,
            rankDelta: rank?.rankDelta,
            countryFlag: flag,
            streak: streak,
            metrics: metrics,
            workouts: snap.workouts,
            dailyExerciseMinutes: dailyExerciseMinutes,
            dailyExerciseTarget: targets.dailyExerciseMinutes,
          ),
        ),
      );
    } catch (e, st) {
      emit(DataState.error('fetch_failed', error: e, stackTrace: st));
    }
  }

  static String _countryFlag(String code) => code
      .toUpperCase()
      .runes
      .map((r) => String.fromCharCode(r + 0x1F1E6 - 0x41))
      .join();
}
