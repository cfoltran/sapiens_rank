import 'package:sapiens_rank/models/habits_data.dart';
import 'package:sapiens_rank/models/health_targets.dart';
import 'package:sapiens_rank/services/health_service.dart';

class ScoreBreakdown {
  const ScoreBreakdown({
    required this.score,
    required this.sleepPts,
    required this.stepsPts,
    required this.kcalPts,
    required this.standPts,
    required this.hrvPts,
    required this.exercisePts,
    required this.sleepMax,
    required this.stepsMax,
    required this.kcalMax,
    required this.standMax,
    required this.hrvMax,
    required this.exerciseMax,
    this.habitsPenalty = 0,
  });

  final int score;
  final int sleepPts;
  final int stepsPts;
  final int kcalPts;
  final int standPts;
  final int hrvPts;
  final int exercisePts;
  final int sleepMax;
  final int stepsMax;
  final int kcalMax;
  final int standMax;
  final int hrvMax;
  final int exerciseMax;
  final int habitsPenalty;

  /// Point caps per metric depending on data availability.
  ///
  /// Base distribution: sleep=25, steps=22, kcal=18, stand=15, hrv=10, exercise=10
  ///
  /// When HRV or stand data is missing (e.g. Garmin users lack APPLE_STAND_TIME),
  /// the missing metric's points are redistributed proportionally so no user is
  /// structurally penalised by their device.
  ///
  /// | hasHrv | hasStand | sleep | steps | kcal | stand | hrv | exercise |
  /// |--------|----------|-------|-------|------|-------|-----|----------|
  /// | true   | true     |  25   |  22   |  18  |  15   |  10 |    10    |
  /// | false  | true     |  28   |  24   |  20  |  17   |   0 |    11    |
  /// | true   | false    |  29   |  26   |  21  |   0   |  12 |    12    |
  /// | false  | false    |  33   |  29   |  24  |   0   |   0 |    14    |
  static ScoreBreakdown compute(
    HealthSnapshot snap, {
    HealthTargets targets = HealthTargets.defaults,
    HabitsData? habits,
  }) {
    final hasHrv = snap.hrv != null;
    final hasStand = snap.standHours != null;

    final double sleepMax;
    final double stepsMax;
    final double kcalMax;
    final double standMax;
    final double hrvMax;
    final double exerciseMax;

    if (hasHrv && hasStand) {
      sleepMax = 25;
      stepsMax = 22;
      kcalMax = 18;
      standMax = 15;
      hrvMax = 10;
      exerciseMax = 10;
    } else if (!hasHrv && hasStand) {
      sleepMax = 28;
      stepsMax = 24;
      kcalMax = 20;
      standMax = 17;
      hrvMax = 0;
      exerciseMax = 11;
    } else if (hasHrv && !hasStand) {
      sleepMax = 29;
      stepsMax = 26;
      kcalMax = 21;
      standMax = 0;
      hrvMax = 12;
      exerciseMax = 12;
    } else {
      sleepMax = 33;
      stepsMax = 29;
      kcalMax = 24;
      standMax = 0;
      hrvMax = 0;
      exerciseMax = 14;
    }

    final exerciseMinutes = snap.workouts.fold(
      0,
      (s, w) => s + w.durationMinutes,
    );

    final sleep =
        (snap.sleepHours / targets.sleepHours).clamp(0.0, 1.0) * sleepMax;
    final steps = (snap.steps / targets.steps).clamp(0.0, 1.0) * stepsMax;
    final kcal = (snap.kcal / targets.kcal).clamp(0.0, 1.0) * kcalMax;
    final stand = hasStand
        ? (snap.standHours! / targets.standHours).clamp(0.0, 1.0) * standMax
        : 0.0;
    final hrv = hasHrv
        ? (snap.hrv! / targets.hrv).clamp(0.0, 1.0) * hrvMax
        : 0.0;
    final exercise =
        (exerciseMinutes / targets.dailyExerciseMinutes).clamp(0.0, 1.0) *
        exerciseMax;

    final raw = (sleep + steps + kcal + stand + hrv + exercise).round();
    final penalty = habits != null ? _habitsPenalty(habits) : 0;

    return ScoreBreakdown(
      score: (raw - penalty).clamp(0, 100),
      sleepPts: sleep.round(),
      stepsPts: steps.round(),
      kcalPts: kcal.round(),
      standPts: stand.round(),
      hrvPts: hrv.round(),
      exercisePts: exercise.round(),
      sleepMax: sleepMax.round(),
      stepsMax: stepsMax.round(),
      kcalMax: kcalMax.round(),
      standMax: standMax.round(),
      hrvMax: hrvMax.round(),
      exerciseMax: exerciseMax.round(),
      habitsPenalty: penalty,
    );
  }

  /// Fixed-target score used for the leaderboard and challenges.
  static ScoreBreakdown computeRanking(HealthSnapshot snap) => compute(snap);

  static int _habitsPenalty(HabitsData h) {
    int penalty = 0;

    // BMI penalty (only when both height and weight provided)
    final bmi = h.bmi;
    if (bmi != null) {
      if (bmi < 18.5) {
        penalty += ((18.5 - bmi) / 3.5 * 8).clamp(0, 8).round();
      } else if (bmi > 25) {
        penalty += ((bmi - 25) / 10 * 8).clamp(0, 8).round();
      }
    }

    // Smoking penalty
    // null = declined → 8 pts
    // true = smoker → 2–12 pts based on quantity
    // false = no penalty
    if (h.smokes == null) {
      penalty += 8;
    } else if (h.smokes!) {
      final cigs = h.cigarettesPerDay ?? 0;
      penalty += (2 + (cigs / 20) * 10).clamp(2, 12).round();
    }

    // Alcohol penalty
    // null = declined → 5 pts
    // true = drinker → 1–8 pts based on quantity
    // false = no penalty
    if (h.drinks == null) {
      penalty += 5;
    } else if (h.drinks!) {
      final drinks = h.drinksPerWeek ?? 0;
      penalty += (1 + (drinks / 14) * 7).clamp(1, 8).round();
    }

    return penalty;
  }
}
