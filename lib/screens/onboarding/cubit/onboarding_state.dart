import 'package:equatable/equatable.dart';

enum OnboardingStep {
  welcome,
  permission,
  sync,
  name,
  demographics,
  country,
  scoreReveal,
  rankReveal,
  auth,
  // friends,
  // firstFight,
  // notifications,
  done,
}

class OnboardingData extends Equatable {
  const OnboardingData({this.name = '', this.age = 28, this.country = 'FR'});

  final String name;
  final int age;
  final String country;

  OnboardingData copyWith({String? name, int? age, String? country}) =>
      OnboardingData(
        name: name ?? this.name,
        age: age ?? this.age,
        country: country ?? this.country,
      );

  @override
  List<Object?> get props => [name, age, country];
}

class OnboardingState extends Equatable {
  const OnboardingState({
    this.step = OnboardingStep.welcome,
    this.data = const OnboardingData(),
  });

  final OnboardingStep step;
  final OnboardingData data;

  static int get _progressTotal => OnboardingStep.values
      .where(
        (s) =>
            s != OnboardingStep.welcome &&
            s != OnboardingStep.auth &&
            s != OnboardingStep.done,
      )
      .length;

  int get progressTotal => _progressTotal;

  int get progressIndex {
    final idx = OnboardingStep.values.indexOf(step);
    return (idx - 1).clamp(0, _progressTotal - 1);
  }

  bool get showsProgress =>
      step != OnboardingStep.welcome && step != OnboardingStep.auth;

  OnboardingState copyWith({OnboardingStep? step, OnboardingData? data}) =>
      OnboardingState(step: step ?? this.step, data: data ?? this.data);

  @override
  List<Object?> get props => [step, data];
}
