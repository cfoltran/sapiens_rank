import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sapiens_rank/common/data_state.dart';
import 'package:sapiens_rank/models/guild_models.dart';
import 'package:sapiens_rank/services/guild_service.dart';

class JoinGuildCubit extends Cubit<DataState<List<GuildRow>>> {
  JoinGuildCubit() : super(const DataState.loading());

  final _guildService = GuildService.instance;

  Future<void> load() async {
    emit(const DataState.loading());
    try {
      final guilds = await _guildService.searchGuilds('');
      emit(DataState.success(guilds));
    } catch (e, st) {
      emit(DataState.error('fetch_failed', error: e, stackTrace: st));
    }
  }
}
