import 'package:equatable/equatable.dart';
import 'package:sapiens_rank/services/health_targets.dart';
import 'package:sapiens_rank/services/score_service.dart';

class ProfileData extends Equatable {
  const ProfileData({
    required this.name,
    required this.country,
    required this.joinedAt,
    required this.lifetimeAvg,
    required this.streak,
    required this.scoreHistory30d,
    required this.trendDelta,
    required this.trendLabel,
    required this.targets,
  });

  final String name;
  final String country;
  final DateTime joinedAt;
  final int lifetimeAvg;
  final int streak;
  final List<(DateTime, int)> scoreHistory30d;
  final double trendDelta;
  final String trendLabel;
  final HealthTargets targets;

  String get handle =>
      '@${name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_')}';

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length.clamp(0, 2)).toUpperCase();
  }

  String get flag => _countryFlag(country);
  String get joinedLabel => _fmtJoined(joinedAt);

  static String _countryFlag(String code) => code
      .toUpperCase()
      .runes
      .map((r) => String.fromCharCode(r + 0x1F1E6 - 0x41))
      .join();

  static String _fmtJoined(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return 'joined ${months[d.month - 1]} ${d.year}';
  }

  ProfileData copyWith({HealthTargets? targets}) => ProfileData(
    name: name,
    country: country,
    joinedAt: joinedAt,
    lifetimeAvg: lifetimeAvg,
    streak: streak,
    scoreHistory30d: scoreHistory30d,
    trendDelta: trendDelta,
    trendLabel: trendLabel,
    targets: targets ?? this.targets,
  );

  @override
  List<Object?> get props => [name, lifetimeAvg, streak, targets];
}
