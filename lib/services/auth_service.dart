import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logging/logging.dart';

const _kThemeModeKey = 'theme_mode';

class AuthService with ChangeNotifier {
  AuthService() {
    _loadThemeMode();
    _supabase.auth.onAuthStateChange.listen(
      (event) => _authStateChanged(event.session?.user),
    );
  }

  final SupabaseClient _supabase = Supabase.instance.client;
  final Logger logger = Logger('AuthService');
  ThemeMode _themeMode = ThemeMode.system;
  // ProfileModel? _profile;

  ThemeMode get themeMode => _themeMode;
  bool get isLoggedIn => Supabase.instance.client.auth.currentSession != null;
  // ProfileModel? get profile => _profile;

  // set profile(ProfileModel? value) {
  //   _profile = value;
  //   notifyListeners();
  // }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kThemeModeKey);
    _themeMode = switch (saved) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode value) async {
    _themeMode = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kThemeModeKey, switch (value) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    });
  }

  void _authStateChanged(User? user) async => notifyListeners();

  Future<void> signOut() async {
    notifyListeners();
    await _supabase.auth.signOut();
  }
}
