import 'package:equatable/equatable.dart';
import 'package:sapiens_rank/models/habits_data.dart';
import 'package:sapiens_rank/models/health_targets.dart';
import 'package:sapiens_rank/models/leaderboard_entry.dart';

enum OnboardingStep {
  welcome,
  permission,
  sync,
  name,
  demographics,
  country,
  bmi,
  smoking,
  alcohol,
  targets,
  scoreReveal,
  auth,
  rankReveal,
  notifications,
  done,
}

class OnboardingData extends Equatable {
  const OnboardingData({
    this.name = '',
    this.age = 28,
    this.country = 'FR',
    this.targets = HealthTargets.defaults,
    this.habits = const HabitsData(),
  });

  final String name;
  final int age;
  final String country;
  final HealthTargets targets;
  final HabitsData habits;

  OnboardingData copyWith({
    String? name,
    int? age,
    String? country,
    HealthTargets? targets,
    HabitsData? habits,
  }) => OnboardingData(
    name: name ?? this.name,
    age: age ?? this.age,
    country: country ?? this.country,
    targets: targets ?? this.targets,
    habits: habits ?? this.habits,
  );

  @override
  List<Object?> get props => [name, age, country, targets];
}

class OnboardingState extends Equatable {
  const OnboardingState({
    this.step = OnboardingStep.welcome,
    this.data = const OnboardingData(),
    this.personalScore,
    this.rank,
    this.rankTotal = 0,
    this.isLoading = false,
    this.permissionDenied = false,
  });

  final OnboardingStep step;
  final OnboardingData data;
  final int? personalScore;
  final LeaderboardEntry? rank;
  final int rankTotal;
  final bool isLoading;
  final bool permissionDenied;

  static int get _progressTotal => OnboardingStep.values
      .where(
        (s) =>
            s != OnboardingStep.welcome &&
            s != OnboardingStep.auth &&
            s != OnboardingStep.notifications &&
            s != OnboardingStep.done,
      )
      .length;

  int get progressTotal => _progressTotal;

  int get progressIndex {
    final idx = OnboardingStep.values.indexOf(step);
    return (idx - 1).clamp(0, _progressTotal - 1);
  }

  bool get showsProgress =>
      step != OnboardingStep.welcome &&
      step != OnboardingStep.auth &&
      step != OnboardingStep.notifications;

  OnboardingState copyWith({
    OnboardingStep? step,
    OnboardingData? data,
    int? personalScore,
    LeaderboardEntry? rank,
    int? rankTotal,
    bool? isLoading,
    bool? permissionDenied,
  }) => OnboardingState(
    step: step ?? this.step,
    data: data ?? this.data,
    personalScore: personalScore ?? this.personalScore,
    rank: rank ?? this.rank,
    rankTotal: rankTotal ?? this.rankTotal,
    isLoading: isLoading ?? this.isLoading,
    permissionDenied: permissionDenied ?? this.permissionDenied,
  );

  @override
  List<Object?> get props => [
    step,
    data,
    personalScore,
    rank,
    rankTotal,
    isLoading,
    permissionDenied,
  ];
}
