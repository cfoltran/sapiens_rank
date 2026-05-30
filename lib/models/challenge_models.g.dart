// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'challenge_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChallengeParticipantProfile _$ChallengeParticipantProfileFromJson(
  Map<String, dynamic> json,
) => ChallengeParticipantProfile(
  name: json['name'] as String,
  country: json['country'] as String?,
);

Map<String, dynamic> _$ChallengeParticipantProfileToJson(
  ChallengeParticipantProfile instance,
) => <String, dynamic>{'name': instance.name, 'country': instance.country};

ChallengeParticipant _$ChallengeParticipantFromJson(
  Map<String, dynamic> json,
) => ChallengeParticipant(
  userId: json['user_id'] as String,
  isCreator: json['is_creator'] as bool? ?? false,
  status: json['status'] as String,
  profiles: ChallengeParticipantProfile.fromJson(
    json['profiles'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$ChallengeParticipantToJson(
  ChallengeParticipant instance,
) => <String, dynamic>{
  'user_id': instance.userId,
  'is_creator': instance.isCreator,
  'status': instance.status,
  'profiles': instance.profiles,
};

ChallengeRow _$ChallengeRowFromJson(Map<String, dynamic> json) => ChallengeRow(
  id: json['id'] as String,
  metric: json['metric'] as String,
  durationDays: (json['duration_days'] as num).toInt(),
  status: $enumDecode(_$ChallengeStatusEnumMap, json['status']),
  stakeIcon: json['stake_icon'] as String? ?? '🏆',
  stakeLabel: json['stake_label'] as String? ?? '',
  createdBy: json['created_by'] as String,
  challengeParticipants: (json['challenge_participants'] as List<dynamic>)
      .map((e) => ChallengeParticipant.fromJson(e as Map<String, dynamic>))
      .toList(),
  startsAt: json['starts_at'] == null
      ? null
      : DateTime.parse(json['starts_at'] as String),
  endsAt: json['ends_at'] == null
      ? null
      : DateTime.parse(json['ends_at'] as String),
  winnerId: json['winner_id'] as String?,
);

Map<String, dynamic> _$ChallengeRowToJson(ChallengeRow instance) =>
    <String, dynamic>{
      'id': instance.id,
      'metric': instance.metric,
      'duration_days': instance.durationDays,
      'status': _$ChallengeStatusEnumMap[instance.status]!,
      'stake_icon': instance.stakeIcon,
      'stake_label': instance.stakeLabel,
      'created_by': instance.createdBy,
      'starts_at': instance.startsAt?.toIso8601String(),
      'ends_at': instance.endsAt?.toIso8601String(),
      'winner_id': instance.winnerId,
      'challenge_participants': instance.challengeParticipants,
    };

const _$ChallengeStatusEnumMap = {
  ChallengeStatus.pending: 'pending',
  ChallengeStatus.live: 'live',
  ChallengeStatus.done: 'done',
  ChallengeStatus.cancelled: 'cancelled',
};

ChallengeStanding _$ChallengeStandingFromJson(Map<String, dynamic> json) =>
    ChallengeStanding(
      userId: json['user_id'] as String,
      score: (json['score'] as num).toDouble(),
      rank: (json['rank'] as num).toInt(),
    );

Map<String, dynamic> _$ChallengeStandingToJson(ChallengeStanding instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'score': instance.score,
      'rank': instance.rank,
    };

OpponentRow _$OpponentRowFromJson(Map<String, dynamic> json) => OpponentRow(
  userId: json['user_id'] as String,
  score: (json['score'] as num).toDouble(),
  country: json['country'] as String?,
  profiles: OpponentProfile.fromJson(json['profiles'] as Map<String, dynamic>),
);

Map<String, dynamic> _$OpponentRowToJson(OpponentRow instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'score': instance.score,
      'country': instance.country,
      'profiles': instance.profiles,
    };

OpponentProfile _$OpponentProfileFromJson(Map<String, dynamic> json) =>
    OpponentProfile(name: json['name'] as String? ?? 'Sapien');

Map<String, dynamic> _$OpponentProfileToJson(OpponentProfile instance) =>
    <String, dynamic>{'name': instance.name};
