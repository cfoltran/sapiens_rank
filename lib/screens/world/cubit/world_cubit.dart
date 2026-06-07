import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sapiens_rank/common/theme/colors.dart';
import 'package:sapiens_rank/common/data_state.dart';
import 'package:sapiens_rank/screens/world/cubit/world_state.dart';
import 'package:sapiens_rank/services/score_service.dart';

class WorldCubit extends Cubit<DataState<WorldData>> {
  WorldCubit() : super(const DataState.loading());

  Future<void> load() async {
    emit(const DataState.loading());
    try {
      final myRank = await ScoreService.instance.getMyRank();

      final results = await Future.wait([
        ScoreService.instance.getTopLeaderboard(),
        ScoreService.instance.getStreak(),
      ]);

      final players = _toPlayers(results[0] as List<LeaderboardEntry>);
      final streak = results[1] as int;

      emit(
        DataState.success(
          WorldData(
            players: players,
            myRank: myRank?.rankWorld,
            myScore: myRank?.score ?? 0,
            myStreak: streak,
            myRankDelta: myRank?.rankDelta,
          ),
        ),
      );
    } catch (e, st) {
      emit(DataState.error('fetch_failed', error: e, stackTrace: st));
    }
  }

  static List<WorldPlayer> _toPlayers(List<LeaderboardEntry> entries) {
    final players = entries.map((e) {
      final rank = e.rankWorld ?? entries.indexOf(e) + 1;
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
    players.sort((a, b) => a.rank.compareTo(b.rank));
    return players;
  }

  static Color _avatarColor(String userId) {
    const palette = SrColors.avatarPalette;
    final hash = userId.codeUnits.fold(0, (a, b) => a + b);
    return palette[hash % palette.length];
  }

  static String _countryFlag(String code) => code
      .toUpperCase()
      .runes
      .map((r) => String.fromCharCode(r + 0x1F1E6 - 0x41))
      .join();
}
