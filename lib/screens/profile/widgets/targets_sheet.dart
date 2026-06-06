import 'package:flutter/material.dart';
import 'package:sapiens_rank/common/theme/colors.dart';
import 'package:sapiens_rank/common/widgets/sr_slider_card.dart';
import 'package:sapiens_rank/models/health_targets.dart';
import 'package:sapiens_rank/screens/profile/widgets/profile_sheet.dart';

class TargetsSheet extends StatefulWidget {
  const TargetsSheet({super.key, required this.targets, required this.onSave});
  final HealthTargets targets;
  final ValueChanged<HealthTargets> onSave;

  @override
  State<TargetsSheet> createState() => _TargetsSheetState();
}

class _TargetsSheetState extends State<TargetsSheet> {
  late double _steps;
  late double _kcal;
  late double _sleep;
  late double _stand;
  late double _exercise;

  @override
  void initState() {
    super.initState();
    _steps = widget.targets.steps.toDouble();
    _kcal = widget.targets.kcal;
    _sleep = widget.targets.sleepHours;
    _stand = widget.targets.standHours.toDouble();
    _exercise = widget.targets.dailyExerciseMinutes.toDouble();
  }

  HealthTargets get _current => HealthTargets(
    steps: _steps.round(),
    kcal: _kcal,
    sleepHours: _sleep,
    standHours: _stand.round(),
    dailyExerciseMinutes: _exercise.round(),
  );

  String _fmtSteps(double v) {
    final n = v.round();
    return n >= 1000
        ? '${n ~/ 1000},${(n % 1000).toString().padLeft(3, '0')}'
        : '$n';
  }

  @override
  Widget build(BuildContext context) {
    return ProfileSheet(
      title: 'Edit Targets',
      onSave: () {
        widget.onSave(_current);
        Navigator.pop(context);
      },
      child: Column(
        children: [
          SrSliderCard(
            icon: '👟',
            label: 'Steps',
            unit: 'steps / day',
            value: _steps,
            min: 3000,
            max: 20000,
            divisions: (20000 - 3000) ~/ 500,
            color: SrColors.lime,
            format: _fmtSteps,
            onChanged: (v) => setState(() => _steps = (v / 500).round() * 500.0),
          ),
          const SizedBox(height: 10),
          SrSliderCard(
            icon: '🔥',
            label: 'Active energy',
            unit: 'kcal / day',
            value: _kcal,
            min: 100,
            max: 1000,
            divisions: (1000 - 100) ~/ 10,
            color: SrColors.magenta,
            format: (v) => '${v.round()}',
            onChanged: (v) => setState(() => _kcal = (v / 10).round() * 10.0),
          ),
          const SizedBox(height: 10),
          SrSliderCard(
            icon: '😴',
            label: 'Sleep',
            unit: 'per night',
            value: _sleep,
            min: 5,
            max: 10,
            divisions: (10 - 5) ~/ 1,
            color: SrColors.cyan,
            format: (v) {
              final h = v.floor();
              final m = ((v % 1) * 60).round();
              return m > 0 ? '${h}h ${m}m' : '${h}h';
            },
            onChanged: (v) => setState(() => _sleep = (v * 4).round() / 4.0),
          ),
          const SizedBox(height: 10),
          SrSliderCard(
            icon: '🧍',
            label: 'Stand hours',
            unit: 'on your feet',
            value: _stand,
            min: 4,
            max: 16,
            divisions: 12,
            color: SrColors.amber,
            format: (v) => '${v.round()}h',
            onChanged: (v) => setState(() => _stand = v.roundToDouble()),
          ),
          const SizedBox(height: 10),
          SrSliderCard(
            icon: '🏃',
            label: 'Exercise',
            unit: 'min / day',
            value: _exercise,
            min: 10,
            max: 120,
            divisions: (120 - 10) ~/ 5,
            color: SrColors.blue,
            format: (v) => '${v.round()}min',
            onChanged: (v) =>
                setState(() => _exercise = (v / 5).round() * 5.0),
          ),
        ],
      ),
    );
  }
}
