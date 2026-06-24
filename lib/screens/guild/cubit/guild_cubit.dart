import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sapiens_rank/common/data_state.dart';
import 'package:sapiens_rank/services/guild_service.dart';
import 'package:sapiens_rank/services/map_service.dart';
import 'guild_state.dart';

class GuildCubit extends Cubit<DataState<GuildData>> {
  GuildCubit() : super(const DataState.loading());

  final _guildService = GuildService.instance;
  final _mapService = MapService.instance;

  Future<void> load() async {
    emit(const DataState.loading());
    try {
      final guild = await _guildService.fetchMyGuild();

      if (guild == null) {
        final territories = await _mapService.fetchTerritories();
        final takenColors = territories
            .where((t) => t.guilds?.color != null)
            .map((t) => t.guilds!.color)
            .toSet();
        emit(
          DataState.success(
            GuildData(
              members: [],
              maxMembers: 5,
              territoryCount: 0,
              attackHistory: [],
              takenColors: takenColors,
            ),
          ),
        );
        return;
      }

      final results = await Future.wait([
        _guildService.fetchMembers(guild.id),
        _guildService.fetchMaxMembers(guild.id),
        _mapService.fetchGuildAttacks(guild.id),
        _mapService.fetchTerritories(),
      ]);

      final territoryCount =
          (results[3] as dynamic)
                  .where((t) => t.ownerGuildId == guild.id)
                  .length
              as int;

      emit(
        DataState.success(
          GuildData(
            guild: guild,
            members: results[0] as dynamic,
            maxMembers: results[1] as int,
            territoryCount: territoryCount,
            attackHistory: results[2] as dynamic,
          ),
        ),
      );
    } catch (e, st) {
      emit(DataState.error('fetch_failed', error: e, stackTrace: st));
    }
  }

  Future<void> joinGuild(String guildId) async {
    await _guildService.joinGuild(guildId);
    load();
  }

  Future<void> leaveGuild(String guildId) async {
    await _guildService.leaveGuild(guildId);
    load();
  }

  Future<List<dynamic>> searchGuilds(String query) =>
      _guildService.searchGuilds(query);
}
