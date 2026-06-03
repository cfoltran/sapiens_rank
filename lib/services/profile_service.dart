import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sapiens_rank/services/health_targets.dart';

class ProfileService {
  ProfileService._();
  static final ProfileService instance = ProfileService._();

  final _db = Supabase.instance.client;

  String? get _userId => _db.auth.currentUser?.id;

  Future<void> createProfile({
    required String name,
    required int age,
    required String country,
  }) async {
    final userId = _userId;
    if (userId == null) return;

    await _db.from('profiles').upsert({
      'id': userId,
      'name': name,
      'age': age,
      'country': country,
      'onboarding_done': true,
      'onboarding_step': 'done',
    });
  }

  Future<HealthTargets> getPersonalTargets() async {
    final uid = _userId;
    if (uid == null) return HealthTargets.defaults;
    try {
      final row = await _db
          .from('profiles')
          .select(
            'target_steps, target_kcal, target_sleep_hours, target_stand_hours',
          )
          .eq('id', uid)
          .single();
      final d = HealthTargets.defaults;
      return HealthTargets(
        steps: (row['target_steps'] as int?) ?? d.steps,
        kcal: (row['target_kcal'] as num?)?.toDouble() ?? d.kcal,
        sleepHours:
            (row['target_sleep_hours'] as num?)?.toDouble() ?? d.sleepHours,
        standHours: (row['target_stand_hours'] as int?) ?? d.standHours,
        hrv: d.hrv,
      );
    } catch (_) {
      return HealthTargets.defaults;
    }
  }

  Future<void> updateTargets(HealthTargets targets) async {
    final uid = _userId;
    if (uid == null) return;
    await _db
        .from('profiles')
        .update({
          'target_steps': targets.steps,
          'target_kcal': targets.kcal,
          'target_sleep_hours': targets.sleepHours,
          'target_stand_hours': targets.standHours,
        })
        .eq('id', uid);
  }
}
