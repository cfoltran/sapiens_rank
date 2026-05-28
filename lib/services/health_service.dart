import 'package:health/health.dart';

class HealthSnapshot {
  const HealthSnapshot({
    required this.sleepHours,
    required this.steps,
    required this.kcal,
    required this.standHours,
    this.hrv,
    this.restingHr,
  });

  final double sleepHours;
  final int steps;
  final double kcal;
  final int standHours;
  final double? hrv;
  final double? restingHr;

  static const empty = HealthSnapshot(
    sleepHours: 0,
    steps: 0,
    kcal: 0,
    standHours: 0,
  );
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
    HealthDataType.DISTANCE_WALKING_RUNNING,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.SLEEP_AWAKE,
    HealthDataType.SLEEP_IN_BED,
    HealthDataType.SLEEP_LIGHT, // iOS 16+ Core stage
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
      return await _health.requestAuthorization(_types);
    } catch (_) {
      return false;
    }
  }

  Future<List<({String label, String value, String icon})>>
  fetchSyncMetrics() async {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final startOfToday = DateTime(now.year, now.month, now.day);

    List<HealthDataPoint> samples = [];
    try {
      final raw = await _health.getHealthDataFromTypes(
        startTime: weekAgo,
        endTime: now,
        types: [
          HealthDataType.RESTING_HEART_RATE,
          HealthDataType.HEART_RATE_VARIABILITY_SDNN,
          HealthDataType.SLEEP_ASLEEP,
          HealthDataType.SLEEP_LIGHT,
          HealthDataType.SLEEP_DEEP,
          HealthDataType.SLEEP_REM,
          HealthDataType.APPLE_STAND_HOUR,
        ],
      );
      samples = _health.removeDuplicates(raw);
    } catch (_) {}

    int? stepsToday;
    try {
      stepsToday = await _health.getTotalStepsInInterval(startOfToday, now);
    } catch (_) {}

    // Active kcal — prefer Watch source to avoid iPhone+Watch double-counting.
    double kcalToday = 0;
    try {
      final raw = await _health.getHealthDataFromTypes(
        startTime: startOfToday,
        endTime: now,
        types: [HealthDataType.ACTIVE_ENERGY_BURNED],
      );
      final pts = _health
          .removeDuplicates(raw)
          .where((p) => p.value is NumericHealthValue)
          .toList();
      final watchPts = pts
          .where((p) => p.sourceName.toLowerCase().contains('watch'))
          .toList();
      kcalToday = (watchPts.isNotEmpty ? watchPts : pts).fold(
        0.0,
        (sum, p) =>
            sum + (p.value as NumericHealthValue).numericValue.toDouble(),
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

    double sleepLastNight() {
      final nightStart = startOfToday.subtract(const Duration(hours: 12));
      final nightEnd = startOfToday.add(const Duration(hours: 12));
      bool inRange(HealthDataPoint p) =>
          p.dateFrom.isAfter(nightStart) && p.dateTo.isBefore(nightEnd);
      int sumType(HealthDataType t) => samples
          .where((p) => p.type == t && inRange(p))
          .fold(0, (s, p) => s + p.dateTo.difference(p.dateFrom).inMinutes);

      // iOS 16+: sleep stored as stages (LIGHT = Core, DEEP, REM)
      final stagesMins =
          sumType(HealthDataType.SLEEP_LIGHT) +
          sumType(HealthDataType.SLEEP_DEEP) +
          sumType(HealthDataType.SLEEP_REM);
      if (stagesMins > 0) return stagesMins / 60.0;

      // Legacy / iPhone sleep
      return sumType(HealthDataType.SLEEP_ASLEEP) / 60.0;
    }

    int standHoursToday() => samples
        .where(
          (p) =>
              p.type == HealthDataType.APPLE_STAND_HOUR &&
              p.dateFrom.toLocal().isAfter(startOfToday),
        )
        .length;

    String fmt(double? v, String unit) {
      if (v == null || v == 0) return '--';
      return '${v.round()} $unit';
    }

    String fmtSteps(int? v) {
      if (v == null || v == 0) return '--';
      return v >= 1000
          ? '${v ~/ 1000},${(v % 1000).toString().padLeft(3, '0')}'
          : '$v';
    }

    final sleep = sleepLastNight();
    final stand = standHoursToday();

    return [
      (
        label: 'Resting HR',
        value: fmt(latestOf(HealthDataType.RESTING_HEART_RATE), 'bpm'),
        icon: '❤️',
      ),
      (
        label: 'HRV (SDNN)',
        value: fmt(latestOf(HealthDataType.HEART_RATE_VARIABILITY_SDNN), 'ms'),
        icon: '📊',
      ),
      (
        label: 'Sleep',
        value: sleep > 0 ? '${sleep.toStringAsFixed(1)} h' : '--',
        icon: '😴',
      ),
      (label: 'Steps today', value: fmtSteps(stepsToday), icon: '🦶'),
      (
        label: 'Active kcal',
        value: fmt(kcalToday > 0 ? kcalToday : null, 'kcal'),
        icon: '🔥',
      ),
      (
        label: 'Stand hours',
        value: stand > 0 ? '$stand / 12' : '--',
        icon: '🧍',
      ),
    ];
  }

  Future<HealthSnapshot> fetchTodaySnapshot() async {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final startOfToday = DateTime(now.year, now.month, now.day);

    List<HealthDataPoint> samples = [];
    try {
      final raw = await _health.getHealthDataFromTypes(
        startTime: weekAgo,
        endTime: now,
        types: [
          HealthDataType.RESTING_HEART_RATE,
          HealthDataType.HEART_RATE_VARIABILITY_SDNN,
          HealthDataType.SLEEP_ASLEEP,
          HealthDataType.SLEEP_LIGHT,
          HealthDataType.SLEEP_DEEP,
          HealthDataType.SLEEP_REM,
          HealthDataType.APPLE_STAND_HOUR,
        ],
      );
      samples = _health.removeDuplicates(raw);
    } catch (_) {}

    int stepsToday = 0;
    try {
      stepsToday =
          (await _health.getTotalStepsInInterval(startOfToday, now)) ?? 0;
    } catch (_) {}

    double kcalToday = 0;
    try {
      final raw = await _health.getHealthDataFromTypes(
        startTime: startOfToday,
        endTime: now,
        types: [HealthDataType.ACTIVE_ENERGY_BURNED],
      );
      final pts = _health
          .removeDuplicates(raw)
          .where((p) => p.value is NumericHealthValue)
          .toList();
      final watchPts = pts
          .where((p) => p.sourceName.toLowerCase().contains('watch'))
          .toList();
      kcalToday = (watchPts.isNotEmpty ? watchPts : pts).fold(
        0.0,
        (sum, p) =>
            sum + (p.value as NumericHealthValue).numericValue.toDouble(),
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

    double sleepLastNight() {
      final nightStart = startOfToday.subtract(const Duration(hours: 12));
      final nightEnd = startOfToday.add(const Duration(hours: 12));
      bool inRange(HealthDataPoint p) =>
          p.dateFrom.isAfter(nightStart) && p.dateTo.isBefore(nightEnd);
      int sumType(HealthDataType t) => samples
          .where((p) => p.type == t && inRange(p))
          .fold(0, (s, p) => s + p.dateTo.difference(p.dateFrom).inMinutes);

      // iOS 16+: sleep stored as stages (LIGHT = Core, DEEP, REM)
      final stagesMins =
          sumType(HealthDataType.SLEEP_LIGHT) +
          sumType(HealthDataType.SLEEP_DEEP) +
          sumType(HealthDataType.SLEEP_REM);
      if (stagesMins > 0) return stagesMins / 60.0;

      // Legacy / iPhone sleep
      return sumType(HealthDataType.SLEEP_ASLEEP) / 60.0;
    }

    int standHoursToday() => samples
        .where(
          (p) =>
              p.type == HealthDataType.APPLE_STAND_HOUR &&
              p.dateFrom.toLocal().isAfter(startOfToday),
        )
        .length;

    return HealthSnapshot(
      sleepHours: sleepLastNight(),
      steps: stepsToday,
      kcal: kcalToday,
      standHours: standHoursToday(),
      hrv: latestOf(HealthDataType.HEART_RATE_VARIABILITY_SDNN),
      restingHr: latestOf(HealthDataType.RESTING_HEART_RATE),
    );
  }
}
