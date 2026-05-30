import 'package:json_annotation/json_annotation.dart';

part 'challenge_models.g.dart';

enum ChallengeStatus {
  @JsonValue('pending')  pending,
  @JsonValue('live')     live,
  @JsonValue('done')     done,
  @JsonValue('cancelled') cancelled,
}

@JsonSerializable()
class ChallengeParticipantProfile {
  const ChallengeParticipantProfile({
    required this.name,
    this.country,
  });

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
    this.startsAt,
    this.endsAt,
    this.winnerId,
  });

  final String id;
  final String metric;

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
  });

  @JsonKey(name: 'user_id')
  final String userId;

  final double score;
  final int rank;

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
