import 'package:flutter/material.dart';
import 'package:sapiens_rank/common/theme/colors.dart';

enum BoosterType { boost, surge, blitz }

extension BoosterTypeX on BoosterType {
  String get emoji => switch (this) {
    BoosterType.boost => '⚡',
    BoosterType.surge => '⚡⚡',
    BoosterType.blitz => '⚡⚡⚡',
  };

  String get displayName => switch (this) {
    BoosterType.boost => 'Boost',
    BoosterType.surge => 'Surge',
    BoosterType.blitz => 'Blitz',
  };

  String get effectLabel => switch (this) {
    BoosterType.boost => '+5%',
    BoosterType.surge => '+15%',
    BoosterType.blitz => '+20%',
  };

  int get cost => switch (this) {
    BoosterType.boost => 300,
    BoosterType.surge => 500,
    BoosterType.blitz => 900,
  };

  Color get accent => switch (this) {
    BoosterType.boost => SrColors.lime,
    BoosterType.surge => SrColors.amber,
    BoosterType.blitz => SrColors.rose,
  };
}
