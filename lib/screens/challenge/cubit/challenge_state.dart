import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:sapiens_rank/models/challenge_models.dart';

class ChallengePlayer extends Equatable {
  const ChallengePlayer({
    required this.userId,
    required this.displayName,
    required this.initials,
    required this.avatarColor,
    required this.flag,
    required this.score,
    required this.rank,
    required this.isMe,
    this.durationSeconds,
    this.distanceKm,
    this.completed = false,
  });

  final String userId;
  final String displayName;
  final String initials;
  final Color avatarColor;
  final String flag;
  final double score;
  final int rank;
  final bool isMe;
  final int? durationSeconds;
  final double? distanceKm;
  final bool completed;

  String get firstName => displayName.split(' ').first;

  @override
  List<Object?> get props => [userId, score, rank, isMe, durationSeconds];
}

class LiveChallenge extends Equatable {
  const LiveChallenge({
    required this.id,
    required this.stakeIcon,
    required this.stakeLabel,
    required this.endsAt,
    required this.participants,
    this.challengeType = ChallengeType.score,
    this.workoutType,
    this.targetDistanceKm,
  });

  final String id;
  final String stakeIcon;
  final String stakeLabel;
  final DateTime endsAt;
  final List<ChallengePlayer> participants;
  final ChallengeType challengeType;
  final String? workoutType;
  final double? targetDistanceKm;

  bool get isWorkout => challengeType == ChallengeType.workout;

  ChallengePlayer get me => participants.firstWhere((p) => p.isMe);
  List<ChallengePlayer> get opponents =>
      participants.where((p) => !p.isMe).toList();
  bool get is1v1 => participants.length == 2;

  String get endsInFormatted {
    final diff = endsAt.difference(DateTime.now());
    if (diff.isNegative) return 'ended';
    if (diff.inDays > 0) {
      return '${diff.inDays}d ${diff.inHours.remainder(24)}h';
    }
    if (diff.inHours > 0) {
      return '${diff.inHours}h ${diff.inMinutes.remainder(60)}m';
    }
    return '${diff.inMinutes}m';
  }

  @override
  List<Object?> get props => [id, participants];
}

class PendingChallenge extends Equatable {
  const PendingChallenge({
    required this.id,
    required this.stakeIcon,
    required this.stakeLabel,
    required this.opponent,
    required this.iAmCreator,
  });

  final String id;
  final String stakeIcon;
  final String stakeLabel;
  final ChallengePlayer opponent;
  final bool iAmCreator;

  @override
  List<Object?> get props => [id];
}

class HistoryChallenge extends Equatable {
  const HistoryChallenge({
    required this.id,
    required this.stakeLabel,
    required this.opponent,
    required this.myScore,
    required this.opponentScore,
    required this.won,
    required this.endedAt,
    this.challengeType = ChallengeType.score,
    this.myDurationSeconds,
    this.opponentDurationSeconds,
  });

  final String id;
  final String stakeLabel;
  final ChallengePlayer opponent;
  final double myScore;
  final double opponentScore;
  final bool? won; // null = draw
  final DateTime endedAt;
  final ChallengeType challengeType;
  final int? myDurationSeconds;
  final int? opponentDurationSeconds;

  bool get isWorkout => challengeType == ChallengeType.workout;

  String get dateFormatted {
    final diff = DateTime.now().difference(endedAt);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return 'Last week';
  }

  @override
  List<Object?> get props => [id];
}

class ChallengeData extends Equatable {
  const ChallengeData({
    required this.live,
    required this.pending,
    required this.history,
  });

  final List<LiveChallenge> live;
  final List<PendingChallenge> pending;
  final List<HistoryChallenge> history;

  @override
  List<Object?> get props => [live, pending, history];
}

class ComposerUser extends Equatable {
  const ComposerUser({
    required this.userId,
    required this.displayName,
    required this.initials,
    required this.avatarColor,
    required this.flag,
    required this.score,
  });

  final String userId;
  final String displayName;
  final String initials;
  final Color avatarColor;
  final String flag;
  final double score;

  String get firstName => displayName.split(' ').first;

  @override
  List<Object?> get props => [userId];
}
