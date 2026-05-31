import 'package:equatable/equatable.dart';

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
  });

  final String name;
  final String country;
  final DateTime joinedAt;
  final int lifetimeAvg;
  final int streak;
  final List<int> scoreHistory30d;

  /// Difference between avg of last 15 days vs first 15 days
  final double trendDelta;

  /// "Climbing" | "Declining" | "Stable"
  final String trendLabel;

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

  @override
  List<Object?> get props => [name, lifetimeAvg, streak, scoreHistory30d];
}
