import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sapiens_rank/screens/onboarding/cubit/onboarding_cubit.dart';
import 'package:sapiens_rank/services/auth_service.dart';
import 'package:sapiens_rank/screens/onboarding/cubit/onboarding_state.dart';
import 'package:sapiens_rank/screens/onboarding/steps/age_step.dart';
import 'package:sapiens_rank/screens/onboarding/steps/auth_step.dart';
import 'package:sapiens_rank/screens/onboarding/steps/country_step.dart';
import 'package:sapiens_rank/screens/onboarding/steps/done_step.dart';
import 'package:sapiens_rank/screens/onboarding/steps/name_step.dart';
import 'package:sapiens_rank/screens/onboarding/steps/notifications_step.dart';
import 'package:sapiens_rank/screens/onboarding/steps/permission_step.dart';
import 'package:sapiens_rank/screens/onboarding/steps/rank_reveal_step.dart';
import 'package:sapiens_rank/screens/onboarding/steps/score_reveal_step.dart';
import 'package:sapiens_rank/screens/onboarding/steps/sync_step.dart';
import 'package:sapiens_rank/screens/onboarding/steps/welcome_step.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OnboardingCubit(),
      child: const _OnboardingView(),
    );
  }
}

class _OnboardingView extends StatelessWidget {
  const _OnboardingView();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<OnboardingCubit>();

    return BlocBuilder<OnboardingCubit, OnboardingState>(
      builder: (context, state) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0.04, 0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(parent: animation, curve: Curves.easeOut),
                  ),
              child: child,
            ),
          ),
          child: _StepRouter(
            key: ValueKey(state.step),
            state: state,
            cubit: cubit,
          ),
        );
      },
    );
  }
}

class _StepRouter extends StatelessWidget {
  const _StepRouter({super.key, required this.state, required this.cubit});

  final OnboardingState state;
  final OnboardingCubit cubit;

  @override
  Widget build(BuildContext context) {
    return switch (state.step) {
      OnboardingStep.welcome => WelcomeStep(onNext: cubit.next, onLogin: () {}),
      OnboardingStep.permission => PermissionStep(
        progress: state.progressIndex,
        total: state.progressTotal,
        onNext: cubit.requestHealthPermissions,
        onBack: cubit.back,
      ),
      OnboardingStep.sync => SyncStep(onNext: cubit.next),
      OnboardingStep.name => NameStep(
        progress: state.progressIndex,
        total: state.progressTotal,
        initialValue: state.data.name,
        onSubmit: (name) {
          cubit.updateName(name);
          cubit.next();
        },
        onBack: cubit.back,
      ),
      OnboardingStep.demographics => AgeStep(
        progress: state.progressIndex,
        total: state.progressTotal,
        initialAge: state.data.age,
        onSubmit: (age) {
          cubit.updateAge(age);
          cubit.next();
        },
        onBack: cubit.back,
      ),
      OnboardingStep.country => CountryStep(
        progress: state.progressIndex,
        total: state.progressTotal,
        initialValue: state.data.country,
        onSubmit: (code) {
          cubit.updateCountry(code);
          cubit.next();
        },
        onBack: cubit.back,
      ),
      OnboardingStep.scoreReveal => ScoreRevealStep(
        progress: state.progressIndex,
        total: state.progressTotal,
        firstName: state.data.name,
        onNext: cubit.next,
      ),
      OnboardingStep.rankReveal => RankRevealStep(
        progress: state.progressIndex,
        total: state.progressTotal,
        firstName: state.data.name,
        countryCode: state.data.country,
        onNext: cubit.next,
      ),
      OnboardingStep.auth => AuthStep(
        firstName: state.data.name,
        onAuth: cubit.completeAuth,
      ),
      OnboardingStep.notifications => NotificationsStep(onNext: cubit.next),
      OnboardingStep.done => DoneStep(
        firstName: state.data.name,
        onEnter: context.read<AuthService>().setOnboardingDone,
      ),
    };
  }
}
