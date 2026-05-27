import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  ProfileService._();
  static final ProfileService instance = ProfileService._();

  final _db = Supabase.instance.client;

  Future<void> createProfile({
    required String name,
    required int age,
    required String country,
  }) async {
    final userId = _db.auth.currentUser?.id;
    if (userId == null) return;

    await _db.from('profiles').upsert({
      'id': userId,
      'name': name,
      'age': age,
      'country': country,
      'archetype': 'night-owl',
      'onboarding_done': true,
      'onboarding_step': 'done',
    });
  }
}
