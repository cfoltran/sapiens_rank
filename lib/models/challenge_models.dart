import 'package:json_annotation/json_annotation.dart';

part 'challenge_models.g.dart';

enum ChallengeStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('live')
  live,
  @JsonValue('done')
  done,
  @JsonValue('cancelled')
  cancelled,
}

enum ChallengeType {
  @JsonValue('score')
  score,
  @JsonValue('workout')
  workout,
}

@JsonSerializable()
class ChallengeParticipantProfile {
  const ChallengeParticipantProfile({required this.name, this.country});

  final String name;
  final String? country;

  factory ChallengeParticipantProfile.fromJson(Map<String, dynamic> json) =>
      _$ChallengeParticipantProfileFromJson(json);

  Map<String, dynamic> toJson() => _$ChallengeParticipantProfileToJson(this);
}

@JsonSerializable()
class ChallengeParticipant {
  const ChallengeParticipant({
    required this.userId,
    required this.isCreator,
    required this.status,
    required this.profiles,
  });

  @JsonKey(name: 'user_id')
  final String userId;

  @JsonKey(name: 'is_creator', defaultValue: false)
  final bool isCreator;

  final String status;

  final ChallengeParticipantProfile profiles;

  factory ChallengeParticipant.fromJson(Map<String, dynamic> json) =>
      _$ChallengeParticipantFromJson(json);

  Map<String, dynamic> toJson() => _$ChallengeParticipantToJson(this);
}

@JsonSerializable()
class ChallengeRow {
  const ChallengeRow({
    required this.id,
    required this.metric,
    required this.durationDays,
    required this.status,
    required this.stakeIcon,
    required this.stakeLabel,
    required this.createdBy,
    required this.challengeParticipants,
    this.challengeType = ChallengeType.score,
    this.workoutType,
    this.targetDistanceKm,
    this.startsAt,
    this.endsAt,
    this.winnerId,
  });

  final String id;
  final String metric;

  @JsonKey(
    name: 'challenge_type',
    defaultValue: ChallengeType.score,
    unknownEnumValue: ChallengeType.score,
  )
  final ChallengeType challengeType;

  @JsonKey(name: 'workout_type')
  final String? workoutType;

  @JsonKey(name: 'target_distance_km')
  final double? targetDistanceKm;

  bool get isWorkout => challengeType == ChallengeType.workout;

  @JsonKey(name: 'duration_days')
  final int durationDays;

  final ChallengeStatus status;

  @JsonKey(name: 'stake_icon', defaultValue: '🏆')
  final String stakeIcon;

  @JsonKey(name: 'stake_label', defaultValue: '')
  final String stakeLabel;

  @JsonKey(name: 'created_by')
  final String createdBy;

  @JsonKey(name: 'starts_at')
  final DateTime? startsAt;

  @JsonKey(name: 'ends_at')
  final DateTime? endsAt;

  @JsonKey(name: 'winner_id')
  final String? winnerId;

  @JsonKey(name: 'challenge_participants')
  final List<ChallengeParticipant> challengeParticipants;

  factory ChallengeRow.fromJson(Map<String, dynamic> json) =>
      _$ChallengeRowFromJson(json);

  Map<String, dynamic> toJson() => _$ChallengeRowToJson(this);
}

@JsonSerializable()
class ChallengeStanding {
  const ChallengeStanding({
    required this.userId,
    required this.score,
    required this.rank,
    this.durationSeconds,
    this.distanceKm,
    this.completed = false,
  });

  @JsonKey(name: 'user_id')
  final String userId;

  final double score;
  final int rank;

  @JsonKey(name: 'duration_seconds')
  final int? durationSeconds;

  @JsonKey(name: 'distance_km')
  final double? distanceKm;

  @JsonKey(defaultValue: false)
  final bool completed;

  factory ChallengeStanding.fromJson(Map<String, dynamic> json) =>
      _$ChallengeStandingFromJson(json);

  Map<String, dynamic> toJson() => _$ChallengeStandingToJson(this);
}

@JsonSerializable()
class OpponentRow {
  const OpponentRow({
    required this.userId,
    required this.score,
    required this.country,
    required this.profiles,
  });

  @JsonKey(name: 'user_id')
  final String userId;

  final double score;
  final String? country;

  final OpponentProfile profiles;

  String get name => profiles.name;

  factory OpponentRow.fromJson(Map<String, dynamic> json) =>
      _$OpponentRowFromJson(json);

  Map<String, dynamic> toJson() => _$OpponentRowToJson(this);
}

@JsonSerializable()
class OpponentProfile {
  const OpponentProfile({required this.name});

  @JsonKey(defaultValue: 'Sapien')
  final String name;

  factory OpponentProfile.fromJson(Map<String, dynamic> json) =>
      _$OpponentProfileFromJson(json);

  Map<String, dynamic> toJson() => _$OpponentProfileToJson(this);
}
