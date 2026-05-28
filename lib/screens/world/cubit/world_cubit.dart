import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sapiens_rank/common/data_state.dart';
import 'package:sapiens_rank/screens/world/cubit/world_state.dart';
import 'package:sapiens_rank/services/score_service.dart';

class WorldCubit extends Cubit<DataState<WorldData>> {
  WorldCubit() : super(const DataState.loading());

  Future<void> load() async {
    emit(const DataState.loading());
    try {
      final myRank = await ScoreService.instance.getMyRank();
      final myCountry = myRank?.country ?? 'FR';

      final results = await Future.wait([
        ScoreService.instance.getTopLeaderboard(),
        ScoreService.instance.getTopLeaderboard(country: myCountry),
        ScoreService.instance.getStreak(),
      ]);

      final worldwidePlayers = _toPlayers(
        results[0] as List<LeaderboardEntry>,
        worldwide: true,
      );
      final countryPlayers = _toPlayers(
        results[1] as List<LeaderboardEntry>,
        worldwide: false,
      );
      final streak = results[2] as int;

      final myFlag = _countryFlag(myCountry);

      emit(
        DataState.success(
          WorldData(
            scope: WorldScope.worldwide,
            worldwidePlayers: worldwidePlayers,
            countryPlayers: countryPlayers,
            myRankWorld: myRank?.rankWorld,
            myRankCountry: myRank?.rankCountry,
            myScore: myRank?.score ?? 0,
            myStreak: streak,
            myCountry: myCountry,
            myCountryFlag: myFlag,
            myRankDelta: myRank?.rankDelta,
          ),
        ),
      );
    } catch (e, st) {
      emit(DataState.error('fetch_failed', error: e, stackTrace: st));
    }
  }

  void setScope(WorldScope scope) {
    final current = state.data;
    if (current == null) return;
    emit(DataState.success(current.copyWithScope(scope)));
  }

  static List<WorldPlayer> _toPlayers(
    List<LeaderboardEntry> entries, {
    required bool worldwide,
  }) {
    return entries.map((e) {
      final rank =
          (worldwide ? e.rankWorld : e.rankCountry) ?? entries.indexOf(e) + 1;
      final name = e.displayName ?? 'Sapien';
      return WorldPlayer(
        rank: rank,
        userId: e.userId,
        displayName: name,
        score: e.score,
        avatarColor: _avatarColor(e.userId),
        country: e.country,
        flag: e.country != null ? _countryFlag(e.country!) : null,
        rankDelta: e.rankDelta,
      );
    }).toList();
  }

  static Color _avatarColor(String userId) {
    const palette = [
      Color(0xFFFF6B7A),
      Color(0xFF7CB6FF),
      Color(0xFFF0A64A),
      Color(0xFFC5A3FF),
      Color(0xFF9BE7C4),
      Color(0xFFFFB84A),
      Color(0xFF7CE5FF),
      Color(0xFFFF9B7A),
      Color(0xFFD9FF3D),
      Color(0xFFB5A8FF),
      Color(0xFFF5D76E),
      Color(0xFFFF7AD9),
    ];
    final hash = userId.codeUnits.fold(0, (a, b) => a + b);
    return palette[hash % palette.length];
  }

  static String _countryFlag(String code) => code
      .toUpperCase()
      .runes
      .map((r) => String.fromCharCode(r + 0x1F1E6 - 0x41))
      .join();
}
