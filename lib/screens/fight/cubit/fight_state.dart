import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class FightParticipant extends Equatable {
  const FightParticipant({
    required this.userId,
    required this.displayName,
    required this.initials,
    required this.avatarColor,
    required this.flag,
    required this.score,
    required this.rank,
    required this.isMe,
  });

  final String userId;
  final String displayName;
  final String initials;
  final Color avatarColor;
  final String flag;
  final double score;
  final int rank;
  final bool isMe;

  String get firstName => displayName.split(' ').first;

  @override
  List<Object?> get props => [userId, score, rank, isMe];
}

class LiveFight extends Equatable {
  const LiveFight({
    required this.id,
    required this.stakeIcon,
    required this.stakeLabel,
    required this.endsAt,
    required this.participants,
  });

  final String id;
  final String stakeIcon;
  final String stakeLabel;
  final DateTime endsAt;
  final List<FightParticipant> participants;

  FightParticipant get me => participants.firstWhere((p) => p.isMe);
  List<FightParticipant> get opponents =>
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

class PendingFight extends Equatable {
  const PendingFight({
    required this.id,
    required this.stakeIcon,
    required this.stakeLabel,
    required this.opponent,
    required this.iAmCreator,
  });

  final String id;
  final String stakeIcon;
  final String stakeLabel;
  final FightParticipant opponent;
  final bool iAmCreator;

  @override
  List<Object?> get props => [id];
}

class HistoryFight extends Equatable {
  const HistoryFight({
    required this.id,
    required this.stakeLabel,
    required this.opponent,
    required this.myScore,
    required this.opponentScore,
    required this.won,
    required this.endedAt,
  });

  final String id;
  final String stakeLabel;
  final FightParticipant opponent;
  final double myScore;
  final double opponentScore;
  final bool? won; // null = draw
  final DateTime endedAt;

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

class FightData extends Equatable {
  const FightData({
    required this.live,
    required this.pending,
    required this.history,
  });

  final List<LiveFight> live;
  final List<PendingFight> pending;
  final List<HistoryFight> history;

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
