import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sapiens_rank/common/data_state.dart';
import 'package:sapiens_rank/models/guild_models.dart';
import 'package:sapiens_rank/services/guild_service.dart';

class CreateGuildCubit extends Cubit<DataState<GuildRow>> {
  CreateGuildCubit() : super(const DataState.initial());

  final _guildService = GuildService.instance;

  Future<void> create({required String name, required String color}) async {
    emit(const DataState.loading());
    try {
      final guild = await _guildService.createGuild(name: name, color: color);
      emit(DataState.success(guild));
    } catch (e, st) {
      emit(DataState.error('create_failed', error: e, stackTrace: st));
    }
  }
}
