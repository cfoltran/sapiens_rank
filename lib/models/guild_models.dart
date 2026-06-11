import 'package:json_annotation/json_annotation.dart';

part 'guild_models.g.dart';

enum GuildRole {
  @JsonValue('leader')
  leader,
  @JsonValue('member')
  member,
}

enum AttackStatus {
  @JsonValue('active')
  active,
  @JsonValue('resolved')
  resolved,
  @JsonValue('cancelled')
  cancelled,
}

enum AttackMetric {
  @JsonValue('steps')
  steps,
  @JsonValue('sleep')
  sleep,
  @JsonValue('calories')
  calories,
  @JsonValue('stand')
  stand,
  @JsonValue('hrv')
  hrv,
}

// Nested profile inside GuildMember
@JsonSerializable()
class GuildMemberProfile {
  const GuildMemberProfile({required this.name, this.country});

  @JsonKey(defaultValue: 'Sapien')
  final String name;
  final String? country;

  factory GuildMemberProfile.fromJson(Map<String, dynamic> json) =>
      _$GuildMemberProfileFromJson(json);
  Map<String, dynamic> toJson() => _$GuildMemberProfileToJson(this);
}

@JsonSerializable()
class GuildMember {
  const GuildMember({
    required this.guildId,
    required this.userId,
    required this.role,
    required this.joinedAt,
    required this.profiles,
  });

  @JsonKey(name: 'guild_id')
  final String guildId;

  @JsonKey(name: 'user_id')
  final String userId;

  final GuildRole role;

  @JsonKey(name: 'joined_at')
  final DateTime joinedAt;

  final GuildMemberProfile profiles;

  String get name => profiles.name;
  String? get country => profiles.country;
  bool get isLeader => role == GuildRole.leader;

  factory GuildMember.fromJson(Map<String, dynamic> json) =>
      _$GuildMemberFromJson(json);
  Map<String, dynamic> toJson() => _$GuildMemberToJson(this);
}

@JsonSerializable()
class GuildRow {
  const GuildRow({
    required this.id,
    required this.name,
    required this.color,
    required this.createdBy,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String color;

  @JsonKey(name: 'created_by')
  final String createdBy;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  factory GuildRow.fromJson(Map<String, dynamic> json) =>
      _$GuildRowFromJson(json);
  Map<String, dynamic> toJson() => _$GuildRowToJson(this);
}

// Lightweight guild info nested inside Territory for map rendering
@JsonSerializable()
class TerritoryGuild {
  const TerritoryGuild({
    required this.id,
    required this.name,
    required this.color,
  });

  final String id;
  final String name;
  final String color;

  factory TerritoryGuild.fromJson(Map<String, dynamic> json) =>
      _$TerritoryGuildFromJson(json);
  Map<String, dynamic> toJson() => _$TerritoryGuildToJson(this);
}

@JsonSerializable()
class Territory {
  const Territory({
    required this.id,
    required this.gridX,
    required this.gridY,
    this.ownerGuildId,
    this.conqueredAt,
    this.guilds,
  });

  final String id;

  @JsonKey(name: 'grid_x')
  final int gridX;

  @JsonKey(name: 'grid_y')
  final int gridY;

  @JsonKey(name: 'owner_guild_id')
  final String? ownerGuildId;

  @JsonKey(name: 'conquered_at')
  final DateTime? conqueredAt;

  final TerritoryGuild? guilds;

  bool get isNeutral => ownerGuildId == null;

  factory Territory.fromJson(Map<String, dynamic> json) =>
      _$TerritoryFromJson(json);
  Map<String, dynamic> toJson() => _$TerritoryToJson(this);
}

@JsonSerializable()
class Attack {
  const Attack({
    required this.id,
    required this.attackerGuildId,
    required this.territoryId,
    required this.metric,
    required this.startsAt,
    required this.endsAt,
    required this.status,
    this.defenderGuildId,
    this.attackerScore,
    this.defenderScore,
    this.winnerGuildId,
  });

  final String id;

  @JsonKey(name: 'attacker_guild_id')
  final String attackerGuildId;

  @JsonKey(name: 'defender_guild_id')
  final String? defenderGuildId;

  @JsonKey(name: 'territory_id')
  final String territoryId;

  final AttackMetric metric;

  @JsonKey(name: 'starts_at')
  final DateTime startsAt;

  @JsonKey(name: 'ends_at')
  final DateTime endsAt;

  final AttackStatus status;

  @JsonKey(name: 'attacker_score')
  final double? attackerScore;

  @JsonKey(name: 'defender_score')
  final double? defenderScore;

  @JsonKey(name: 'winner_guild_id')
  final String? winnerGuildId;

  bool get isActive => status == AttackStatus.active;

  factory Attack.fromJson(Map<String, dynamic> json) => _$AttackFromJson(json);
  Map<String, dynamic> toJson() => _$AttackToJson(this);
}
