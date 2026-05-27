import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sapiens_rank/services/health_service.dart';
import 'package:sapiens_rank/services/profile_service.dart';
import 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit() : super(const OnboardingState());

  static final _steps = OnboardingStep.values;

  void next() {
    final idx = _steps.indexOf(state.step);
    if (idx < _steps.length - 1) {
      emit(state.copyWith(step: _steps[idx + 1]));
    }
  }

  void back() {
    final idx = _steps.indexOf(state.step);
    if (idx > 0) {
      emit(state.copyWith(step: _steps[idx - 1]));
    }
  }

  Future<void> requestHealthPermissions() async {
    await HealthService.instance.requestPermissions();
    emit(state.copyWith(step: OnboardingStep.sync));
  }

  Future<void> completeAuth() async {
    await ProfileService.instance.createProfile(
      name: state.data.name,
      age: state.data.age,
      country: state.data.country,
    );
    emit(state.copyWith(step: OnboardingStep.done));
  }

  void updateName(String name) =>
      emit(state.copyWith(data: state.data.copyWith(name: name)));

  void updateAge(int age) =>
      emit(state.copyWith(data: state.data.copyWith(age: age)));

  void updateCountry(String country) =>
      emit(state.copyWith(data: state.data.copyWith(country: country)));
}
