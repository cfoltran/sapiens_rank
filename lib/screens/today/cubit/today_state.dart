import 'package:equatable/equatable.dart';
import 'package:sapiens_rank/services/health_service.dart';

class TodayMetric extends Equatable {
  const TodayMetric({
    required this.key,
    required this.label,
    required this.iconName,
    required this.contrib,
    required this.target,
    required this.rawLabel,
  });

  final String key;
  final String label;

  /// One of: 'sleep' | 'steps' | 'kcal' | 'stand' | 'hrv'
  final String iconName;

  /// Points earned today
  final int contrib;

  /// Max points possible for this metric
  final int target;

  /// Human-readable raw value, e.g. "7h 42m last night"
  final String rawLabel;

  double get progress => target > 0 ? contrib / target : 0;
  bool get isMaxed => progress >= 0.9;
  bool get isOnTrack => progress >= 0.6;

  @override
  List<Object?> get props => [key, contrib, target, rawLabel];
}

class TodayData extends Equatable {
  const TodayData({
    required this.score,
    required this.scoreHistory,
    required this.scoreDelta,
    this.rankWorld,
    this.rankCountry,
    this.rankDelta,
    required this.countryFlag,
    required this.streak,
    required this.metrics,
    required this.workouts,
    required this.dailyExerciseMinutes,
    required this.dailyExerciseTarget,
    required this.sapiesBalance,
    required this.harvestedToday,
  });

  final int score;
  final List<int> scoreHistory;
  final int scoreDelta;
  final int? rankWorld;
  final int? rankCountry;
  final int? rankDelta;
  final String countryFlag;
  final int streak;
  final List<TodayMetric> metrics;
  final List<WorkoutEntry> workouts;
  final int dailyExerciseMinutes;
  final int dailyExerciseTarget;

  /// Running Sapie balance and how much of today's score is already collected.
  final int sapiesBalance;
  final int harvestedToday;

  /// Coins still collectable from today's score.
  int get harvestable => (score - harvestedToday).clamp(0, score);

  TodayData copyWith({int? sapiesBalance, int? harvestedToday}) => TodayData(
    score: score,
    scoreHistory: scoreHistory,
    scoreDelta: scoreDelta,
    rankWorld: rankWorld,
    rankCountry: rankCountry,
    rankDelta: rankDelta,
    countryFlag: countryFlag,
    streak: streak,
    metrics: metrics,
    workouts: workouts,
    dailyExerciseMinutes: dailyExerciseMinutes,
    dailyExerciseTarget: dailyExerciseTarget,
    sapiesBalance: sapiesBalance ?? this.sapiesBalance,
    harvestedToday: harvestedToday ?? this.harvestedToday,
  );

  @override
  List<Object?> get props => [
    score,
    rankWorld,
    rankCountry,
    streak,
    metrics,
    workouts,
    dailyExerciseMinutes,
    sapiesBalance,
    harvestedToday,
  ];
}
