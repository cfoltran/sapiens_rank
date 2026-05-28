import 'dart:math';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum WorldScope { worldwide, country, weekly }

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
    required this.scope,
    required this.worldwidePlayers,
    required this.countryPlayers,
    this.myRankWorld,
    this.myRankCountry,
    required this.myScore,
    required this.myStreak,
    required this.myCountry,
    required this.myCountryFlag,
    this.myRankDelta,
  });

  final WorldScope scope;
  final List<WorldPlayer> worldwidePlayers;
  final List<WorldPlayer> countryPlayers;
  final int? myRankWorld;
  final int? myRankCountry;
  final double myScore;
  final int myStreak;
  final String myCountry;
  final String myCountryFlag;
  final int? myRankDelta;

  List<WorldPlayer> get activePlayers => switch (scope) {
    WorldScope.worldwide || WorldScope.weekly => worldwidePlayers,
    WorldScope.country => countryPlayers,
  };

  int? get myActiveRank => switch (scope) {
    WorldScope.worldwide || WorldScope.weekly => myRankWorld,
    WorldScope.country => myRankCountry,
  };

  WorldData copyWithScope(WorldScope s) => WorldData(
    scope: s,
    worldwidePlayers: worldwidePlayers,
    countryPlayers: countryPlayers,
    myRankWorld: myRankWorld,
    myRankCountry: myRankCountry,
    myScore: myScore,
    myStreak: myStreak,
    myCountry: myCountry,
    myCountryFlag: myCountryFlag,
    myRankDelta: myRankDelta,
  );

  @override
  List<Object?> get props => [
    scope,
    myRankWorld,
    myRankCountry,
    myScore,
    myStreak,
  ];
}
