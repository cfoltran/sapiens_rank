import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sapiens_rank/common/data_state.dart';
import 'package:sapiens_rank/screens/today/cubit/today_state.dart';
import 'package:sapiens_rank/services/health_service.dart';

class TodayCubit extends Cubit<DataState<TodayData>> {
  TodayCubit() : super(const DataState.loading());

  Future<void> load() async {
    emit(const DataState.loading());
    try {
      final snap = await HealthService.instance.fetchTodaySnapshot();

      // Scoring algorithm (total max = 100 pts)
      final sleepPts = (snap.sleepHours / 8.0).clamp(0.0, 1.0) * 25;
      final stepsPts = (snap.steps / 10000.0).clamp(0.0, 1.0) * 25;
      final kcalPts = (snap.kcal / 750.0).clamp(0.0, 1.0) * 20;
      final standPts = (snap.standHours / 12.0).clamp(0.0, 1.0) * 15;
      final hrvPts = snap.hrv != null
          ? (snap.hrv! / 60.0).clamp(0.0, 1.0) * 15
          : 0.0;

      final score = (sleepPts + stepsPts + kcalPts + standPts + hrvPts).round();

      // Score history — last 13 days mocked, today appended
      final history = [72, 78, 81, 75, 82, 79, 84, 88, 85, 80, 86, 89, 84];
      final scoreHistory = [...history, score];
      final scoreDelta = score - scoreHistory[scoreHistory.length - 2];

      final sleepH = snap.sleepHours.floor();
      final sleepMin = ((snap.sleepHours % 1) * 60).round();

      String fmtSteps(int v) => v >= 1000
          ? '${v ~/ 1000},${(v % 1000).toString().padLeft(3, '0')}'
          : '$v';

      final metrics = [
        TodayMetric(
          key: 'sleep',
          label: 'Sleep',
          iconName: 'sleep',
          contrib: sleepPts.round(),
          target: 25,
          rawLabel: sleepH > 0
              ? '${sleepH}h ${sleepMin}m last night'
              : '-- no sleep data',
        ),
        TodayMetric(
          key: 'steps',
          label: 'Steps',
          iconName: 'steps',
          contrib: stepsPts.round(),
          target: 25,
          rawLabel: '${fmtSteps(snap.steps)} / 10,000',
        ),
        TodayMetric(
          key: 'kcal',
          label: 'Active kcal',
          iconName: 'kcal',
          contrib: kcalPts.round(),
          target: 20,
          rawLabel: '${snap.kcal.round()} / 750 kcal',
        ),
        TodayMetric(
          key: 'stand',
          label: 'Stand hours',
          iconName: 'stand',
          contrib: standPts.round(),
          target: 15,
          rawLabel: '${snap.standHours} / 12 hours',
        ),
        TodayMetric(
          key: 'hrv',
          label: 'HRV',
          iconName: 'hrv',
          contrib: hrvPts.round(),
          target: 15,
          rawLabel: snap.hrv != null
              ? '${snap.hrv!.round()}ms · ${snap.hrv! > 55 ? 'above avg' : 'below avg'}'
              : '-- no data',
        ),
      ];

      emit(
        DataState.success(
          TodayData(
            score: score,
            scoreHistory: scoreHistory,
            scoreDelta: scoreDelta,
            rankWorld: 2847, // TODO: from profile service
            rankCountry: 412, // TODO: from profile service
            rankDelta: 184, // TODO: from profile service
            countryFlag: '🇫🇷',
            streak: 12, // TODO: from profile service
            metrics: metrics,
            topPct: 0.4,
          ),
        ),
      );
    } catch (e, st) {
      emit(DataState.error('fetch_failed', error: e, stackTrace: st));
    }
  }
}
