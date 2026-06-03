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
