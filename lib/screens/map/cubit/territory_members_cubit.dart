import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sapiens_rank/common/data_state.dart';
import 'package:sapiens_rank/models/guild_models.dart';
import 'package:sapiens_rank/services/guild_service.dart';

class TerritoryMembersCubit extends Cubit<DataState<List<GuildMember>>> {
  TerritoryMembersCubit() : super(const DataState.loading());

  Future<void> load(String? guildId) async {
    if (guildId == null) {
      emit(const DataState.success([]));
      return;
    }
    emit(const DataState.loading());
    try {
      final members = await GuildService.instance.fetchMembers(guildId);
      emit(DataState.success(members));
    } catch (e, st) {
      emit(DataState.error('fetch_failed', error: e, stackTrace: st));
    }
  }
}
