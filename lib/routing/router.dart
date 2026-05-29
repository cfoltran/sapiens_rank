import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:sapiens_rank/screens/home/home_page.dart';
import 'package:sapiens_rank/screens/onboarding/onboarding_page.dart';
import 'package:sapiens_rank/screens/update/update_cubit.dart';
import 'package:sapiens_rank/screens/update/update_page.dart';
import 'package:sapiens_rank/services/auth_service.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, _, child) {
        final updateCubit = context.watch<UpdateCubit>();
        if (updateCubit.state.data == UpdateStatus.needsUpdate) {
          return const UpdatePage();
        }

        final authService = context.watch<AuthService>();
        if (!authService.isLoggedIn || !authService.onboardingDone) {
          return const OnboardingPage();
        }

        return child;
      },
      routes: routes,
    ),
  ],
);

final routes = [
  GoRoute(
    name: 'index',
    path: '/',
    builder: (context, state) => HomePage(initialTab: state.extra as int? ?? 0),
  ),
];
