import 'dart:math';

import 'package:health/health.dart';

class WorkoutEntry {
  const WorkoutEntry({
    required this.type,
    required this.icon,
    required this.startTime,
    required this.durationMinutes,
    required this.durationSeconds,
    required this.kcal,
    this.distanceKm,
    this.avgHeartRate,
  });

  final String type;
  final String icon;
  final DateTime startTime;
  final int durationMinutes;
  final int durationSeconds;
  final int kcal;
  final double? distanceKm;
  final int? avgHeartRate;
}

class HealthSnapshot {
  const HealthSnapshot({
    required this.sleepHours,
    required this.steps,
    required this.kcal,
    this.standHours,
    this.hrv,
    this.restingHr,
    this.workouts = const [],
    this.exerciseMinutes = 0,
    this.weeklyExerciseMinutes = 0,
  });

  final double sleepHours;
  final int steps;
  final double kcal;

  /// Null when no APPLE_STAND_TIME data is available (e.g. Garmin users).
  final int? standHours;
  final double? hrv;
  final double? restingHr;
  final List<WorkoutEntry> workouts;

  /// Daily exercise minutes: the larger of APPLE_EXERCISE_TIME and the summed
  /// workout durations, so rides that only land as the exercise-time series
  /// (no discrete WORKOUT sample) still count.
  final int exerciseMinutes;
  final int weeklyExerciseMinutes;

  static const empty = HealthSnapshot(sleepHours: 0, steps: 0, kcal: 0);
}

class HealthService {
  HealthService._();

  static final HealthService instance = HealthService._();

  final _health = Health();

  static final _types = [
    HealthDataType.HEART_RATE,
    HealthDataType.HEART_RATE_VARIABILITY_SDNN,
    HealthDataType.RESTING_HEART_RATE,
    HealthDataType.STEPS,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.EXERCISE_TIME,
    HealthDataType.DISTANCE_WALKING_RUNNING,
    HealthDataType.DISTANCE_CYCLING,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.SLEEP_AWAKE,
    HealthDataType.SLEEP_IN_BED,
    HealthDataType.SLEEP_LIGHT,
    HealthDataType.SLEEP_DEEP,
    HealthDataType.SLEEP_REM,
    HealthDataType.APPLE_STAND_TIME,
    HealthDataType.APPLE_STAND_HOUR,
    HealthDataType.WORKOUT,
  ];

  Future<void> configure() => _health.configure();

  Future<bool> requestPermissions() async {
    await configure();
    try {
      await _health.requestAuthorization(_types);
    } catch (_) {
      return false;
    }
    // iOS never exposes read permission status (by design, for user privacy).
    // We infer grant by attempting to read any health data over 30 days.
    // A full "Don't Allow" returns empty; a device with any activity returns data.
    try {
      final end = DateTime.now();
      final start = end.subtract(const Duration(days: 30));
      final data = await _health.getHealthDataFromTypes(
        startTime: start,
        endTime: end,
        types: _types,
      );
      return data.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Returns a [HealthSnapshot] for [date] (defaults to today).
  /// Uses the 7 days preceding [date] for context metrics (HRV, RHR).
  Future<HealthSnapshot> fetchDaySnapshot([DateTime? date]) async {
    final anchor = date ?? DateTime.now();
    final dayStart = DateTime(anchor.year, anchor.month, anchor.day);
    final dayEnd = dayStart.add(const Duration(days: 1));
    final weekBefore = dayStart.subtract(const Duration(days: 7));

    List<HealthDataPoint> samples = [];
    try {
      final raw = await _health.getHealthDataFromTypes(
        startTime: weekBefore,
        endTime: dayEnd,
        types: [
          HealthDataType.RESTING_HEART_RATE,
          HealthDataType.HEART_RATE_VARIABILITY_SDNN,
          HealthDataType.SLEEP_IN_BED,
          HealthDataType.SLEEP_ASLEEP,
          HealthDataType.SLEEP_LIGHT,
          HealthDataType.SLEEP_DEEP,
          HealthDataType.SLEEP_REM,
          HealthDataType.APPLE_STAND_TIME,
        ],
      );
      samples = _health.removeDuplicates(raw);
    } catch (_) {}

    int steps = 0;
    try {
      steps = (await _health.getTotalStepsInInterval(dayStart, dayEnd)) ?? 0;
    } catch (_) {}

    double kcal = 0;
    List<HealthDataPoint> activeKcalPts = [];
    try {
      final raw = await _health.getHealthDataFromTypes(
        startTime: dayStart,
        endTime: dayEnd,
        types: [HealthDataType.ACTIVE_ENERGY_BURNED],
      );
      final pts = _health
          .removeDuplicates(raw)
          .where((p) => p.value is NumericHealthValue)
          .toList();
      final watchPts = pts
          .where((p) => p.sourceName.toLowerCase().contains('watch'))
          .toList();
      activeKcalPts = watchPts.isNotEmpty ? watchPts : pts;
      kcal = activeKcalPts.fold(
        0.0,
        (s, p) => s + (p.value as NumericHealthValue).numericValue.toDouble(),
      );
    } catch (_) {}

    double exerciseTime = 0;
    try {
      final raw = await _health.getHealthDataFromTypes(
        startTime: dayStart,
        endTime: dayEnd,
        types: [HealthDataType.EXERCISE_TIME],
      );
      exerciseTime = _health
          .removeDuplicates(raw)
          .where((p) => p.value is NumericHealthValue)
          .fold(
            0.0,
            (s, p) =>
                s + (p.value as NumericHealthValue).numericValue.toDouble(),
          );
    } catch (_) {}

    double? latestOf(HealthDataType type) {
      final pts =
          samples
              .where((p) => p.type == type && p.value is NumericHealthValue)
              .toList()
            ..sort((a, b) => b.dateFrom.compareTo(a.dateFrom));
      if (pts.isEmpty) return null;
      return (pts.first.value as NumericHealthValue).numericValue.toDouble();
    }

    // Night anchored to dayStart: captures previous evening → morning.
    double sleepHours() {
      final nightStart = dayStart.subtract(const Duration(hours: 12));
      final nightEnd = dayStart.add(const Duration(hours: 12));
      bool inRange(HealthDataPoint p) =>
          p.dateFrom.isAfter(nightStart) && p.dateTo.isBefore(nightEnd);
      int sumType(HealthDataType t) => samples
          .where((p) => p.type == t && inRange(p))
          .fold(0, (s, p) => s + p.dateTo.difference(p.dateFrom).inMinutes);

      // Priority 1 — Apple Watch stages (iOS 16+)
      final stages =
          sumType(HealthDataType.SLEEP_LIGHT) +
          sumType(HealthDataType.SLEEP_DEEP) +
          sumType(HealthDataType.SLEEP_REM);
      if (stages > 0) return stages / 60.0;

      // Priority 2 — SLEEP_ASLEEP (some third-party apps, Watch without stages)
      final asleep = sumType(HealthDataType.SLEEP_ASLEEP);
      if (asleep > 0) return asleep / 60.0;

      // Priority 3 — SLEEP_IN_BED (iPhone-only tracking, Sleep Cycle, etc.)
      return sumType(HealthDataType.SLEEP_IN_BED) / 60.0;
    }

    int? standHours() {
      final standPts = samples
          .where(
            (p) =>
                p.type == HealthDataType.APPLE_STAND_TIME &&
                p.value is NumericHealthValue &&
                p.dateFrom.toLocal().isAfter(dayStart) &&
                p.dateFrom.toLocal().isBefore(dayEnd),
          )
          .toList();

      if (standPts.isEmpty) return null;

      final watchPts = standPts
          .where((p) => p.sourceName.toLowerCase().contains('watch'))
          .toList();

      final pts = watchPts.isNotEmpty ? watchPts : standPts;

      return pts.map((p) => p.dateFrom.toLocal().hour).toSet().length;
    }

    List<WorkoutEntry> todayWorkouts = [];
    int weeklyExerciseMinutes = 0;
    try {
      final weekStart = dayStart.subtract(const Duration(days: 6));
      final rawWorkouts = await _health.getHealthDataFromTypes(
        startTime: weekStart,
        endTime: dayEnd,
        types: [HealthDataType.WORKOUT],
      );
      final workoutPts = _health.removeDuplicates(rawWorkouts);

      for (final p in workoutPts) {
        final val = p.value;
        if (val is! WorkoutHealthValue) continue;
        final dur = p.dateTo.difference(p.dateFrom).inMinutes;
        final durSeconds = p.dateTo.difference(p.dateFrom).inSeconds;
        if (dur <= 0) continue;
        weeklyExerciseMinutes += dur;

        if (p.dateFrom.isAfter(dayStart) && p.dateFrom.isBefore(dayEnd)) {
          final kcalVal = val.totalEnergyBurned?.toInt() ?? 0;
          final distM = val.totalDistance;
          todayWorkouts.add(
            WorkoutEntry(
              type: _workoutLabel(val.workoutActivityType),
              icon: _workoutIcon(val.workoutActivityType),
              startTime: p.dateFrom.toLocal(),
              durationMinutes: dur,
              durationSeconds: durSeconds,
              kcal: kcalVal,
              distanceKm: distM != null && distM > 0 ? distM / 1000 : null,
            ),
          );
        }
      }
      todayWorkouts.sort((a, b) => a.startTime.compareTo(b.startTime));

      // Add each workout's energy when the active-energy series didn't already
      // cover its window (e.g. Garmin writes ride kcal only inside the WORKOUT
      // sample, not as minute-by-minute ACTIVE_ENERGY_BURNED). Avoids double
      // counting Apple Watch rides where active energy already includes them.
      for (final w in todayWorkouts) {
        if (w.kcal <= 0) continue;
        final wEnd = w.startTime.add(Duration(seconds: w.durationSeconds));
        final covered = activeKcalPts.any(
          (p) =>
              p.dateFrom.toLocal().isBefore(wEnd) &&
              p.dateTo.toLocal().isAfter(w.startTime),
        );
        if (!covered) kcal += w.kcal;
      }
    } catch (_) {}

    final workoutMinutes = todayWorkouts.fold(
      0,
      (s, w) => s + w.durationMinutes,
    );

    return HealthSnapshot(
      sleepHours: sleepHours(),
      steps: steps,
      kcal: kcal,
      standHours: standHours(),
      hrv: latestOf(HealthDataType.HEART_RATE_VARIABILITY_SDNN),
      restingHr: latestOf(HealthDataType.RESTING_HEART_RATE),
      workouts: todayWorkouts,
      exerciseMinutes: max(exerciseTime.round(), workoutMinutes),
      weeklyExerciseMinutes: weeklyExerciseMinutes,
    );
  }

  static String _workoutLabel(HealthWorkoutActivityType type) => switch (type) {
    HealthWorkoutActivityType.RUNNING => 'Running',
    HealthWorkoutActivityType.WALKING => 'Walking',
    HealthWorkoutActivityType.HIKING => 'Hiking',
    HealthWorkoutActivityType.BIKING => 'Cycling',
    HealthWorkoutActivityType.SWIMMING => 'Swimming',
    HealthWorkoutActivityType.SWIMMING_POOL => 'Swimming',
    HealthWorkoutActivityType.SWIMMING_OPEN_WATER => 'Swimming',
    HealthWorkoutActivityType.YOGA => 'Yoga',
    HealthWorkoutActivityType.HIGH_INTENSITY_INTERVAL_TRAINING => 'HIIT',
    HealthWorkoutActivityType.TRADITIONAL_STRENGTH_TRAINING => 'Strength',
    HealthWorkoutActivityType.FUNCTIONAL_STRENGTH_TRAINING => 'Strength',
    HealthWorkoutActivityType.CORE_TRAINING => 'Core',
    HealthWorkoutActivityType.CROSS_TRAINING => 'Cross Training',
    HealthWorkoutActivityType.ROWING => 'Rowing',
    HealthWorkoutActivityType.ELLIPTICAL => 'Elliptical',
    HealthWorkoutActivityType.STAIR_CLIMBING => 'Stair Climbing',
    HealthWorkoutActivityType.TENNIS => 'Tennis',
    HealthWorkoutActivityType.BASKETBALL => 'Basketball',
    HealthWorkoutActivityType.SOCCER => 'Football',
    HealthWorkoutActivityType.BOXING => 'Boxing',
    HealthWorkoutActivityType.CLIMBING => 'Climbing',
    HealthWorkoutActivityType.PILATES => 'Pilates',
    HealthWorkoutActivityType.MIXED_CARDIO => 'Cardio',
    HealthWorkoutActivityType.JUMP_ROPE => 'Jump Rope',
    HealthWorkoutActivityType.SURFING => 'Surfing',
    _ => 'Workout',
  };

  static String _workoutIcon(HealthWorkoutActivityType type) => switch (type) {
    HealthWorkoutActivityType.RUNNING => '🏃',
    HealthWorkoutActivityType.WALKING => '🚶',
    HealthWorkoutActivityType.HIKING => '🥾',
    HealthWorkoutActivityType.BIKING => '🚴',
    HealthWorkoutActivityType.SWIMMING => '🏊',
    HealthWorkoutActivityType.SWIMMING_POOL => '🏊',
    HealthWorkoutActivityType.SWIMMING_OPEN_WATER => '🏊',
    HealthWorkoutActivityType.YOGA => '🧘',
    HealthWorkoutActivityType.HIGH_INTENSITY_INTERVAL_TRAINING => '⚡',
    HealthWorkoutActivityType.TRADITIONAL_STRENGTH_TRAINING => '💪',
    HealthWorkoutActivityType.FUNCTIONAL_STRENGTH_TRAINING => '💪',
    HealthWorkoutActivityType.CORE_TRAINING => '🎯',
    HealthWorkoutActivityType.TENNIS => '🎾',
    HealthWorkoutActivityType.BASKETBALL => '🏀',
    HealthWorkoutActivityType.SOCCER => '⚽',
    HealthWorkoutActivityType.BOXING => '🥊',
    HealthWorkoutActivityType.CLIMBING => '🧗',
    HealthWorkoutActivityType.PILATES => '🤸',
    HealthWorkoutActivityType.SURFING => '🏄',
    HealthWorkoutActivityType.ROWING => '🚣',
    _ => '🏋️',
  };

  /// Formatted metrics for the onboarding sync step.
  Future<List<({String label, String value, String icon})>>
  fetchSyncMetrics() async {
    final snap = await fetchDaySnapshot();

    String fmt(double? v, String unit) =>
        (v == null || v == 0) ? '--' : '${v.round()} $unit';

    String fmtSteps(int v) {
      if (v == 0) return '--';
      return v >= 1000
          ? '${v ~/ 1000},${(v % 1000).toString().padLeft(3, '0')}'
          : '$v';
    }

    return [
      (label: 'Resting HR', value: fmt(snap.restingHr, 'bpm'), icon: '❤️'),
      (label: 'HRV (SDNN)', value: fmt(snap.hrv, 'ms'), icon: '📊'),
      (
        label: 'Sleep',
        value: snap.sleepHours > 0
            ? '${snap.sleepHours.toStringAsFixed(1)} h'
            : '--',
        icon: '😴',
      ),
      (label: 'Steps today', value: fmtSteps(snap.steps), icon: '🦶'),
      (
        label: 'Active kcal',
        value: fmt(snap.kcal > 0 ? snap.kcal : null, 'kcal'),
        icon: '🔥',
      ),
      (
        label: 'Stand hours',
        value: (snap.standHours ?? 0) > 0 ? '${snap.standHours} / 12' : '--',
        icon: '🧍',
      ),
    ];
  }
}
