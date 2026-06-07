import 'dart:math';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class WorldPlayer extends Equatable {
  const WorldPlayer({
    required this.rank,
    required this.userId,
    required this.displayName,
    required this.score,
    required this.avatarColor,
    this.country,
    this.flag,
    this.rankDelta,
  });

  final int rank;
  final String userId;
  final String displayName;
  final double score;
  final Color avatarColor;
  final String? country;
  final String? flag;
  final int? rankDelta;

  String get avatarInitials {
    final parts = displayName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return displayName.substring(0, min(2, displayName.length)).toUpperCase();
  }

  @override
  List<Object?> get props => [rank, userId, score];
}

class WorldData extends Equatable {
  const WorldData({
    required this.players,
    this.myRank,
    required this.myScore,
    required this.myStreak,
    this.myRankDelta,
  });

  final List<WorldPlayer> players;
  final int? myRank;
  final double myScore;
  final int myStreak;
  final int? myRankDelta;

  @override
  List<Object?> get props => [myRank, myScore, myStreak];
}
