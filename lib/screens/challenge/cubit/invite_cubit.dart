import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sapiens_rank/common/data_state.dart';
import 'package:sapiens_rank/models/challenge_models.dart';
import 'package:sapiens_rank/services/challenge_service.dart';

class InviteCubit extends Cubit<DataState<ChallengeRow>> {
  InviteCubit(this._challengeId) : super(const DataState.loading());

  final String _challengeId;

  Future<void> load() async {
    emit(const DataState.loading());
    final challenge = await ChallengeService.instance.fetchChallengeById(
      _challengeId,
    );
    if (challenge == null) {
      emit(DataState.error('not_found'));
    } else {
      emit(DataState.success(challenge));
    }
  }

  Future<void> respond({required bool accept}) async {
    final challenge = state.data;
    if (challenge == null) return;
    emit(DataState.loading(challenge));
    await ChallengeService.instance.respondToChallenge(
      _challengeId,
      accept: accept,
    );
    emit(const DataState.initial());
  }
}
