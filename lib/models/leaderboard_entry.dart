import 'package:equatable/equatable.dart';

class LeaderboardEntry extends Equatable {
  const LeaderboardEntry({
    required this.userId,
    required this.score,
    this.rankWorld,
    this.rankCountry,
    this.rankDelta,
    this.country,
    this.displayName,
  });

  final String userId;
  final double score;
  final int? rankWorld;
  final int? rankCountry;
  final int? rankDelta;
  final String? country;
  final String? displayName;

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    final profiles = json['profiles'] as Map<String, dynamic>?;
    return LeaderboardEntry(
      userId: json['user_id'] as String,
      score: (json['score'] as num).toDouble(),
      rankWorld: json['rank_world'] as int?,
      rankCountry: json['rank_country'] as int?,
      rankDelta: json['rank_delta'] as int?,
      country: json['country'] as String?,
      displayName: profiles?['name'] as String?,
    );
  }

  @override
  List<Object?> get props => [userId, score, rankWorld, rankCountry];
}
