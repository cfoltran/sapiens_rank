// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guild_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GuildMemberProfile _$GuildMemberProfileFromJson(Map<String, dynamic> json) =>
    GuildMemberProfile(
      name: json['name'] as String? ?? 'Sapien',
      country: json['country'] as String?,
    );

Map<String, dynamic> _$GuildMemberProfileToJson(GuildMemberProfile instance) =>
    <String, dynamic>{'name': instance.name, 'country': instance.country};

GuildMember _$GuildMemberFromJson(Map<String, dynamic> json) => GuildMember(
  guildId: json['guild_id'] as String,
  userId: json['user_id'] as String,
  role: $enumDecode(_$GuildRoleEnumMap, json['role']),
  joinedAt: DateTime.parse(json['joined_at'] as String),
  profiles: GuildMemberProfile.fromJson(
    json['profiles'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$GuildMemberToJson(GuildMember instance) =>
    <String, dynamic>{
      'guild_id': instance.guildId,
      'user_id': instance.userId,
      'role': _$GuildRoleEnumMap[instance.role]!,
      'joined_at': instance.joinedAt.toIso8601String(),
      'profiles': instance.profiles,
    };

const _$GuildRoleEnumMap = {
  GuildRole.leader: 'leader',
  GuildRole.member: 'member',
};

GuildRow _$GuildRowFromJson(Map<String, dynamic> json) => GuildRow(
  id: json['id'] as String,
  name: json['name'] as String,
  color: json['color'] as String,
  createdBy: json['created_by'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$GuildRowToJson(GuildRow instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'color': instance.color,
  'created_by': instance.createdBy,
  'created_at': instance.createdAt.toIso8601String(),
};

TerritoryGuild _$TerritoryGuildFromJson(Map<String, dynamic> json) =>
    TerritoryGuild(
      id: json['id'] as String,
      name: json['name'] as String,
      color: json['color'] as String,
    );

Map<String, dynamic> _$TerritoryGuildToJson(TerritoryGuild instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'color': instance.color,
    };

Territory _$TerritoryFromJson(Map<String, dynamic> json) => Territory(
  id: json['id'] as String,
  gridX: (json['grid_x'] as num).toInt(),
  gridY: (json['grid_y'] as num).toInt(),
  ownerGuildId: json['owner_guild_id'] as String?,
  conqueredAt: json['conquered_at'] == null
      ? null
      : DateTime.parse(json['conquered_at'] as String),
  guilds: json['guilds'] == null
      ? null
      : TerritoryGuild.fromJson(json['guilds'] as Map<String, dynamic>),
);

Map<String, dynamic> _$TerritoryToJson(Territory instance) => <String, dynamic>{
  'id': instance.id,
  'grid_x': instance.gridX,
  'grid_y': instance.gridY,
  'owner_guild_id': instance.ownerGuildId,
  'conquered_at': instance.conqueredAt?.toIso8601String(),
  'guilds': instance.guilds,
};

Attack _$AttackFromJson(Map<String, dynamic> json) => Attack(
  id: json['id'] as String,
  attackerGuildId: json['attacker_guild_id'] as String,
  territoryId: json['territory_id'] as String,
  metric: $enumDecode(_$AttackMetricEnumMap, json['metric']),
  startsAt: DateTime.parse(json['starts_at'] as String),
  endsAt: DateTime.parse(json['ends_at'] as String),
  status: $enumDecode(_$AttackStatusEnumMap, json['status']),
  defenderGuildId: json['defender_guild_id'] as String?,
  attackerScore: (json['attacker_score'] as num?)?.toDouble(),
  defenderScore: (json['defender_score'] as num?)?.toDouble(),
  winnerGuildId: json['winner_guild_id'] as String?,
  boosterRaw: json['booster'] as String?,
);

Map<String, dynamic> _$AttackToJson(Attack instance) => <String, dynamic>{
  'id': instance.id,
  'attacker_guild_id': instance.attackerGuildId,
  'defender_guild_id': instance.defenderGuildId,
  'territory_id': instance.territoryId,
  'metric': _$AttackMetricEnumMap[instance.metric]!,
  'starts_at': instance.startsAt.toIso8601String(),
  'ends_at': instance.endsAt.toIso8601String(),
  'status': _$AttackStatusEnumMap[instance.status]!,
  'attacker_score': instance.attackerScore,
  'defender_score': instance.defenderScore,
  'winner_guild_id': instance.winnerGuildId,
  'booster': instance.boosterRaw,
};

const _$AttackMetricEnumMap = {
  AttackMetric.steps: 'steps',
  AttackMetric.sleep: 'sleep',
  AttackMetric.calories: 'calories',
  AttackMetric.stand: 'stand',
};

const _$AttackStatusEnumMap = {
  AttackStatus.active: 'active',
  AttackStatus.resolved: 'resolved',
  AttackStatus.cancelled: 'cancelled',
};
