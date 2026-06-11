import 'package:equatable/equatable.dart';
import 'package:sapiens_rank/models/guild_models.dart';

class MapData extends Equatable {
  const MapData({
    required this.territories,
    required this.activeAttacks,
    this.myGuildId,
  });

  final List<Territory> territories;
  final List<Attack> activeAttacks;
  final String? myGuildId;

  bool get myGuildHasActiveAttack =>
      myGuildId != null &&
      activeAttacks.any((a) => a.attackerGuildId == myGuildId);

  Set<String> get attackableTerritoryIds {
    if (myGuildId == null || myGuildHasActiveAttack) return {};

    final byPos = {for (final t in territories) '${t.gridX},${t.gridY}': t};
    final underAttack = {for (final a in activeAttacks) a.territoryId};
    final myTerritories = territories.where((t) => t.ownerGuildId == myGuildId);

    final result = <String>{};
    for (final mine in myTerritories) {
      for (final d in [
        [-1, 0],
        [1, 0],
        [0, -1],
        [0, 1],
      ]) {
        final neighbor = byPos['${mine.gridX + d[0]},${mine.gridY + d[1]}'];
        if (neighbor == null) continue;
        if (neighbor.ownerGuildId == myGuildId) continue;
        if (underAttack.contains(neighbor.id)) continue;
        result.add(neighbor.id);
      }
    }
    return result;
  }

  Territory? territoryAt(int x, int y) {
    try {
      return territories.firstWhere((t) => t.gridX == x && t.gridY == y);
    } catch (_) {
      return null;
    }
  }

  Attack? activeAttackOn(String territoryId) {
    try {
      return activeAttacks.firstWhere((a) => a.territoryId == territoryId);
    } catch (_) {
      return null;
    }
  }

  @override
  List<Object?> get props => [territories, activeAttacks, myGuildId];
}
