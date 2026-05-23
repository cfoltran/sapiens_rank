import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sapiens_rank/screens/home/home_page.dart';
import 'package:sapiens_rank/screens/update/update_cubit.dart';
import 'package:sapiens_rank/screens/update/update_page.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, _, child) {
        final appUpdateCubit = context.watch<UpdateCubit>();

        if (appUpdateCubit.state.data == UpdateStatus.needsUpdate) {
          return const UpdatePage();
        }

        return child;
      },
      routes: routes,
    ),
  ],
);

final routes = [
  GoRoute(name: 'index', path: '/', builder: (context, state) => HomePage(initialTab: state.extra as int? ?? 0)),
];
