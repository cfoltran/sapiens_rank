import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sapiens_rank/models/habits_data.dart';
import 'package:sapiens_rank/models/health_targets.dart';

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
            'target_steps, target_kcal, target_sleep_hours, target_stand_hours, target_daily_exercise_minutes',
          )
          .eq('id', uid)
          .single();
      return HealthTargets.fromJson(row);
    } catch (_) {
      return HealthTargets.defaults;
    }
  }

  Future<void> updateTargets(HealthTargets targets) async {
    final uid = _userId;
    if (uid == null) return;
    await _db.from('profiles').update(targets.toJson()).eq('id', uid);
  }

  Future<void> updateHabits(HabitsData habits) async {
    final uid = _userId;
    if (uid == null) return;
    await _db.from('profiles').update(habits.toJson()).eq('id', uid);
  }
}
