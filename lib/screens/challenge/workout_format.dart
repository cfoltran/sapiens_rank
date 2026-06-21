class WorkoutSport {
  const WorkoutSport(this.id, this.label, this.icon, this.presets);

  final String id;
  final String label;
  final String icon;
  final List<double> presets;
}

const workoutSports = [
  WorkoutSport('running', 'Running', '🏃', [5, 10, 21.1, 42.2]),
  WorkoutSport('walking', 'Walking', '🚶', [5, 10, 15]),
  WorkoutSport('swimming', 'Swimming', '🏊', [1, 2, 3, 5]),
  WorkoutSport('cycling', 'Cycling', '🚴', [20, 50, 100]),
];

WorkoutSport? sportById(String? id) {
  for (final s in workoutSports) {
    if (s.id == id) return s;
  }
  return null;
}

abstract final class WorkoutFormat {
  static String sportIcon(String? id) => sportById(id)?.icon ?? '🏃';

  static String sportLabel(String? id) => sportById(id)?.label ?? 'Workout';

  static String distance(double? km) {
    if (km == null) return '—';
    if (km == km.roundToDouble()) return '${km.toInt()} km';
    return '${km.toStringAsFixed(1)} km';
  }

  static String time(int? seconds) {
    if (seconds == null) return 'DNF';
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    final mm = m.toString().padLeft(2, '0');
    final ss = s.toString().padLeft(2, '0');
    return h > 0 ? '$h:$mm:$ss' : '$mm:$ss';
  }

  static String pace(int? seconds, double? km) {
    if (seconds == null || km == null || km <= 0) return '—';
    final paceSec = (seconds / km).round();
    final m = paceSec ~/ 60;
    final s = (paceSec % 60).toString().padLeft(2, '0');
    return '$m:$s/km';
  }
}
