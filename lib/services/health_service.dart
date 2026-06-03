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
      return await _health.requestAuthorization(_types);
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
          HealthDataType.SLEEP_ASLEEP,
          HealthDataType.SLEEP_LIGHT,
          HealthDataType.SLEEP_DEEP,
          HealthDataType.SLEEP_REM,
          HealthDataType.APPLE_STAND_HOUR,
        ],
      );
      samples = _health.removeDuplicates(raw);
    } catch (_) {}

    int steps = 0;
    try {
      steps = (await _health.getTotalStepsInInterval(dayStart, dayEnd)) ?? 0;
    } catch (_) {}

    double kcal = 0;
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
      kcal = (watchPts.isNotEmpty ? watchPts : pts).fold(
        0.0,
        (s, p) => s + (p.value as NumericHealthValue).numericValue.toDouble(),
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

      // iOS 16+: stages (LIGHT = Core, DEEP, REM)
      final stages =
          sumType(HealthDataType.SLEEP_LIGHT) +
          sumType(HealthDataType.SLEEP_DEEP) +
          sumType(HealthDataType.SLEEP_REM);
      if (stages > 0) return stages / 60.0;

      return sumType(HealthDataType.SLEEP_ASLEEP) / 60.0;
    }

    int standHours() => samples
        .where(
          (p) =>
              p.type == HealthDataType.APPLE_STAND_HOUR &&
              p.dateFrom.toLocal().isAfter(dayStart) &&
              p.dateFrom.toLocal().isBefore(dayEnd),
        )
        .length;

    return HealthSnapshot(
      sleepHours: sleepHours(),
      steps: steps,
      kcal: kcal,
      standHours: standHours(),
      hrv: latestOf(HealthDataType.HEART_RATE_VARIABILITY_SDNN),
      restingHr: latestOf(HealthDataType.RESTING_HEART_RATE),
    );
  }

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
        value: snap.standHours > 0 ? '${snap.standHours} / 12' : '--',
        icon: '🧍',
      ),
    ];
  }
}
