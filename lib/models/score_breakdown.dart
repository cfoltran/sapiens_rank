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
    this.habitsPenalty = 0,
  });

  final int score;
  final int sleepPts;
  final int stepsPts;
  final int kcalPts;
  final int standPts;
  final int hrvPts;
  final int habitsPenalty;

  /// Personal score using adaptive targets.
  /// When HRV data is unavailable, its 15 pts are redistributed:
  ///   sleep 25→29 · steps 25→29 · kcal 20→24 · stand 15→18 · hrv 0
  static ScoreBreakdown compute(
    HealthSnapshot snap, {
    HealthTargets targets = HealthTargets.defaults,
    HabitsData? habits,
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

    final raw = (sleep + steps + kcal + stand + hrv).round();
    final penalty = habits != null ? _habitsPenalty(habits) : 0;

    return ScoreBreakdown(
      score: (raw - penalty).clamp(0, 100),
      sleepPts: sleep.round(),
      stepsPts: steps.round(),
      kcalPts: kcal.round(),
      standPts: stand.round(),
      hrvPts: hrv.round(),
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
