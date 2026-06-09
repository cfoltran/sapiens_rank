import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sapiens_rank/models/habits_data.dart';
import 'package:sapiens_rank/services/habits_service.dart';
import 'package:sapiens_rank/services/health_service.dart';
import 'package:sapiens_rank/services/profile_service.dart';
import 'package:sapiens_rank/services/score_service.dart';
import 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit() : super(const OnboardingState());

  static final _steps = OnboardingStep.values;

  Future<void> next() async {
    final idx = _steps.indexOf(state.step);
    if (idx >= _steps.length - 1) return;
    final nextStep = _steps[idx + 1];
    if (state.step == OnboardingStep.targets) {
      emit(state.copyWith(isLoading: true));
      try {
        final snap = await HealthService.instance.fetchDaySnapshot();
        final bd = ScoreBreakdown.compute(
          snap,
          targets: state.data.targets,
          habits: state.data.habits,
        );
        emit(
          state.copyWith(
            step: nextStep,
            personalScore: bd.score,
            isLoading: false,
          ),
        );
      } catch (_) {
        emit(
          state.copyWith(step: nextStep, personalScore: 0, isLoading: false),
        );
      }
    } else {
      emit(state.copyWith(step: nextStep));
    }
  }

  Future<void> submitTargets(HealthTargets targets) async {
    emit(state.copyWith(data: state.data.copyWith(targets: targets)));
    await next();
  }

  void back() {
    final idx = _steps.indexOf(state.step);
    if (idx > 0) {
      emit(state.copyWith(step: _steps[idx - 1]));
    }
  }

  Future<void> requestHealthPermissions() async {
    emit(state.copyWith(isLoading: true));
    final granted = await HealthService.instance.requestPermissions();
    if (granted) {
      emit(
        state.copyWith(
          step: OnboardingStep.sync,
          permissionDenied: false,
          isLoading: false,
        ),
      );
    } else {
      emit(state.copyWith(permissionDenied: true, isLoading: false));
    }
  }

  Future<void> completeAuth() async {
    emit(state.copyWith(isLoading: true));
    try {
      await ProfileService.instance.createProfile(
        name: state.data.name,
        age: state.data.age,
        country: state.data.country,
      );
      await Future.wait([
        ProfileService.instance.updateTargets(state.data.targets),
        HabitsService.instance.saveHabits(state.data.habits),
      ]);
      await ScoreService.instance.sync();
      final results = await Future.wait([
        ScoreService.instance.getMyRank(),
        ScoreService.instance.getLeaderboardCount(),
      ]);
      final entry = results[0] as LeaderboardEntry?;
      final total = results[1] as int;
      emit(
        state.copyWith(
          step: OnboardingStep.rankReveal,
          rank: entry,
          rankTotal: total,
          isLoading: false,
        ),
      );
    } catch (_) {
      emit(state.copyWith(isLoading: false));
    }
  }

  void updateName(String name) =>
      emit(state.copyWith(data: state.data.copyWith(name: name)));

  void updateAge(int age) =>
      emit(state.copyWith(data: state.data.copyWith(age: age)));

  void updateCountry(String country) =>
      emit(state.copyWith(data: state.data.copyWith(country: country)));

  void updateTargets(HealthTargets targets) =>
      emit(state.copyWith(data: state.data.copyWith(targets: targets)));

  void updateHabits(HabitsData habits) =>
      emit(state.copyWith(data: state.data.copyWith(habits: habits)));
}
