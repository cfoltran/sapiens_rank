import 'package:equatable/equatable.dart';

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
    required this.rankWorld,
    required this.rankCountry,
    required this.rankDelta,
    required this.countryFlag,
    required this.streak,
    required this.metrics,
    required this.topPct,
  });

  final int score;
  final List<int> scoreHistory;
  final int scoreDelta;
  final int rankWorld;
  final int rankCountry;
  final int rankDelta;
  final String countryFlag;
  final int streak;
  final List<TodayMetric> metrics;

  /// Top X% globally (e.g. 0.4 means top 0.4%)
  final double topPct;

  @override
  List<Object?> get props => [
    score,
    rankWorld,
    rankCountry,
    streak,
    metrics,
  ];
}
