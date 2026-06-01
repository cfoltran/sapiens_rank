import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sapiens_rank/common/data_state.dart';
import 'package:sapiens_rank/models/challenge_models.dart';
import 'package:sapiens_rank/services/challenge_service.dart';

class ResultData {
  const ResultData({required this.challenge, required this.standings});

  final ChallengeRow challenge;
  final List<ChallengeStanding> standings;
}

class ResultCubit extends Cubit<DataState<ResultData>> {
  ResultCubit(this._challengeId) : super(const DataState.loading());

  final String _challengeId;

  Future<void> load() async {
    emit(const DataState.loading());
    final challenge = await ChallengeService.instance.fetchChallengeById(
      _challengeId,
    );
    if (challenge == null) {
      emit(DataState.error('not_found'));
      return;
    }
    final standings = await ChallengeService.instance.getStandings(
      _challengeId,
    );
    emit(
      DataState.success(ResultData(challenge: challenge, standings: standings)),
    );
  }
}
