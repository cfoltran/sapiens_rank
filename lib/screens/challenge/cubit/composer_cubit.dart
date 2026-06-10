import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sapiens_rank/common/theme/colors.dart';
import 'package:sapiens_rank/screens/challenge/cubit/challenge_state.dart';
import 'package:sapiens_rank/screens/challenge/cubit/composer_state.dart';
import 'package:sapiens_rank/services/challenge_service.dart';

class ComposerCubit extends Cubit<ComposerState> {
  ComposerCubit() : super(const ComposerState());

  Future<void> load() async {
    try {
      final opponents = await ChallengeService.instance.getPotentialOpponents();
      emit(
        state.copyWith(
          opponents: opponents
              .map(
                (o) => ComposerUser(
                  userId: o.userId,
                  displayName: o.name,
                  initials: _initials(o.name),
                  avatarColor: _avatarColor(o.userId),
                  flag: o.country != null ? _countryFlag(o.country!) : '🌍',
                  score: o.score,
                ),
              )
              .toList(),
          loadingOpponents: false,
        ),
      );
    } catch (_) {
      emit(state.copyWith(loadingOpponents: false));
    }
  }

  void selectOpponent(ComposerUser u) => emit(state.copyWith(opponent: u));

  void setMetric(String m) => emit(
    state.copyWith(metric: m, goalValue: () => null),
  );

  void setDuration(String d) => emit(state.copyWith(duration: d));
  void setGoalValue(double? v) => emit(state.copyWith(goalValue: () => v));
  void selectReward(Reward? r) => emit(state.copyWith(reward: () => r));

  void next() {
    if (state.step < 3) emit(state.copyWith(step: state.step + 1));
  }

  void back() {
    if (state.step > 1) emit(state.copyWith(step: state.step - 1));
  }

  Future<void> send(
    Future<void> Function({
      required String opponentId,
      required int durationDays,
      required String metric,
      required double? goalValue,
      required String stakeIcon,
      required String stakeLabel,
    })
    onCreate,
  ) async {
    if (!state.canContinue) return;
    emit(state.copyWith(sending: true));
    await onCreate(
      opponentId: state.opponent!.userId,
      durationDays: int.parse(state.duration.replaceAll('d', '')),
      metric: state.metric,
      goalValue: state.goalValue,
      stakeIcon: state.reward!.icon,
      stakeLabel: state.reward!.label,
    );
    emit(state.copyWith(sending: false, sent: true));
  }

  static String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.substring(0, math.min(2, name.length)).toUpperCase();
  }

  static Color _avatarColor(String userId) {
    final hash = userId.codeUnits.fold(0, (a, b) => a + b);
    return SrColors.avatarPalette[hash % SrColors.avatarPalette.length];
  }

  static String _countryFlag(String code) => code
      .toUpperCase()
      .runes
      .map((r) => String.fromCharCode(r + 0x1F1E6 - 0x41))
      .join();
}
