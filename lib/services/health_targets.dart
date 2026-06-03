class HealthTargets {
  const HealthTargets({
    required this.sleepHours,
    required this.steps,
    required this.kcal,
    required this.standHours,
    required this.hrv,
  });

  final double sleepHours;
  final int steps;
  final double kcal;
  final int standHours;
  final double hrv;

  static const defaults = HealthTargets(
    sleepHours: 7.0,
    steps: 7000,
    kcal: 380.0,
    standHours: 12,
    hrv: 60.0,
  );
}
