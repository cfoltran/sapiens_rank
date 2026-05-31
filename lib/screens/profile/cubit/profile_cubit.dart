import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sapiens_rank/common/data_state.dart';
import 'package:sapiens_rank/screens/profile/cubit/profile_state.dart';
import 'package:sapiens_rank/services/score_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileCubit extends Cubit<DataState<ProfileData>> {
  ProfileCubit() : super(const DataState.loading());

  final _db = Supabase.instance.client;

  Future<void> load() async {
    emit(const DataState.loading());
    try {
      final uid = _db.auth.currentUser?.id;
      if (uid == null) {
        emit(const DataState.error('not_logged_in'));
        return;
      }

      final profile = await _db
          .from('profiles')
          .select('name, country, created_at')
          .eq('id', uid)
          .single();
      final allScoresRaw = await _db
          .from('scores')
          .select('score')
          .eq('user_id', uid);
      final streak = await ScoreService.instance.getStreak();
      final history30d = await ScoreService.instance.getScoreHistory(days: 30);

      final allScores = allScoresRaw;

      final name = (profile['name'] as String?) ?? 'Sapien';
      final country = (profile['country'] as String?) ?? 'FR';
      final createdAt = DateTime.parse(profile['created_at'] as String);

      final lifetimeAvg = allScores.isEmpty
          ? 0
          : (allScores.map((r) => r['score'] as int).reduce((a, b) => a + b) /
                    allScores.length)
                .round();

      // Trend: compare second half vs first half of 30-day window
      double trendDelta = 0;
      String trendLabel = 'Stable';
      if (history30d.length >= 4) {
        final half = history30d.length ~/ 2;
        final firstHalf = history30d.sublist(0, half);
        final secondHalf = history30d.sublist(half);
        final firstAvg = firstHalf.reduce((a, b) => a + b) / firstHalf.length;
        final secondAvg =
            secondHalf.reduce((a, b) => a + b) / secondHalf.length;
        trendDelta = secondAvg - firstAvg;
        if (trendDelta > 1) trendLabel = 'Climbing';
        if (trendDelta < -1) trendLabel = 'Declining';
      }

      emit(
        DataState.success(
          ProfileData(
            name: name,
            country: country,
            joinedAt: createdAt,
            lifetimeAvg: lifetimeAvg,
            streak: streak,
            scoreHistory30d: history30d,
            trendDelta: trendDelta,
            trendLabel: trendLabel,
          ),
        ),
      );
    } catch (e, st) {
      emit(DataState.error('fetch_failed', error: e, stackTrace: st));
    }
  }
}
