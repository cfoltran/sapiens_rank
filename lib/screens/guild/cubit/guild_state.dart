import 'package:equatable/equatable.dart';
import 'package:sapiens_rank/models/guild_models.dart';

class GuildData extends Equatable {
  const GuildData({
    required this.members,
    required this.maxMembers,
    required this.territoryCount,
    required this.attackHistory,
    this.guild,
    this.takenColors = const {},
  });

  final GuildRow? guild;
  final List<GuildMember> members;
  final int maxMembers;
  final int territoryCount;
  final List<Attack> attackHistory;
  final Set<String> takenColors;

  bool get isInGuild => guild != null;
  int get memberCount => members.length;

  GuildMember? memberById(String userId) {
    try {
      return members.firstWhere((m) => m.userId == userId);
    } catch (_) {
      return null;
    }
  }

  @override
  List<Object?> get props => [
    guild,
    members,
    maxMembers,
    territoryCount,
    attackHistory,
    takenColors,
  ];
}
