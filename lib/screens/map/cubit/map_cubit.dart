import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sapiens_rank/common/data_state.dart';
import 'package:sapiens_rank/models/booster.dart';
import 'package:sapiens_rank/models/guild_models.dart';
import 'package:sapiens_rank/services/guild_service.dart';
import 'package:sapiens_rank/services/map_service.dart';
import 'package:sapiens_rank/services/sapies_service.dart';
import 'map_state.dart';

class MapCubit extends Cubit<DataState<MapData>> {
  MapCubit() : super(const DataState.loading());

  final _mapService = MapService.instance;
  final _guildService = GuildService.instance;

  Future<void> load() async {
    emit(const DataState.loading());
    try {
      final results = await Future.wait([
        _mapService.fetchTerritories(),
        _mapService.fetchActiveAttacks(),
        _guildService.fetchMyGuild(),
        SapiesService.instance.load(),
      ]);

      final territories = results[0] as List<Territory>;
      final attacks = results[1] as List<Attack>;
      final myGuild = results[2] as GuildRow?;
      final wallet = results[3] as SapiesWallet;

      emit(
        DataState.success(
          MapData(
            territories: territories,
            activeAttacks: attacks,
            myGuildId: myGuild?.id,
            sapiesBalance: wallet.balance,
          ),
        ),
      );
    } catch (e, st) {
      emit(DataState.error('fetch_failed', error: e, stackTrace: st));
    }
  }

  Future<void> launchAttack({
    required String territoryId,
    required String? defenderGuildId,
    required AttackMetric metric,
    required DateTime endsAt,
    BoosterType? booster,
    bool chooseMetric = false,
  }) async {
    if (state.data?.myGuildId == null) return;

    await _mapService.createAttack(
      territoryId: territoryId,
      defenderGuildId: defenderGuildId,
      metric: metric,
      endsAt: endsAt,
      booster: booster,
      chooseMetric: chooseMetric,
    );
    load();
  }
}
