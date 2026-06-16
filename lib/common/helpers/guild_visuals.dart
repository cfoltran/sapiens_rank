import 'package:flutter/widgets.dart';
import 'package:sapiens_rank/models/guild_models.dart';

Color guildColorFromHex(String hex) =>
    Color(int.parse('FF${hex.replaceAll('#', '')}', radix: 16));

String guildInitials(String? name) => (name ?? '?')
    .trim()
    .split(' ')
    .where((w) => w.isNotEmpty)
    .take(2)
    .map((w) => w[0].toUpperCase())
    .join();

String countryFlag(String code) {
  final base = 0x1F1E6 - 0x41;
  final chars = code.toUpperCase().codeUnits;
  if (chars.length < 2) return '';
  return String.fromCharCode(base + chars[0]) +
      String.fromCharCode(base + chars[1]);
}

extension AttackMetricVisuals on AttackMetric {
  String get emoji => switch (this) {
    AttackMetric.steps => '👟',
    AttackMetric.sleep => '😴',
    AttackMetric.calories => '🔥',
    AttackMetric.stand => '🧍',
  };

  String get label => switch (this) {
    AttackMetric.steps => 'Steps',
    AttackMetric.sleep => 'Sleep',
    AttackMetric.calories => 'Calories',
    AttackMetric.stand => 'Stand',
  };
}
