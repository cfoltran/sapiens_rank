import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sapiens_rank/models/habits_data.dart';

class HabitsService {
  HabitsService._();
  static final HabitsService instance = HabitsService._();

  final _db = Supabase.instance.client;

  String? get _userId => _db.auth.currentUser?.id;

  Future<void> saveHabits(HabitsData habits) async {
    final uid = _userId;
    if (uid == null) return;
    await _db.from('habits').upsert({'user_id': uid, ...habits.toJson()});
  }

  Future<HabitsData?> getHabits() async {
    final uid = _userId;
    if (uid == null) return null;
    try {
      final row = await _db
          .from('habits')
          .select()
          .eq('user_id', uid)
          .maybeSingle();
      return row != null ? HabitsData.fromJson(row) : null;
    } catch (_) {
      return null;
    }
  }
}
