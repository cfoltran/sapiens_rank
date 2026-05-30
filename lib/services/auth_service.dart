import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logging/logging.dart';

const _kThemeModeKey = 'theme_mode';
const _kOnboardingDoneKey = 'onboarding_done';

class AuthService with ChangeNotifier {
  AuthService() {
    _loadPrefs();
    _supabase.auth.onAuthStateChange.listen(
      (event) => _authStateChanged(event.session?.user),
    );
  }

  final SupabaseClient _supabase = Supabase.instance.client;
  final Logger logger = Logger('AuthService');
  ThemeMode _themeMode = ThemeMode.system;
  bool _onboardingDone = false;

  ThemeMode get themeMode => _themeMode;
  bool get isLoggedIn => _supabase.auth.currentSession != null;

  bool get onboardingDone => _onboardingDone;

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    final savedTheme = prefs.getString(_kThemeModeKey);
    _themeMode = switch (savedTheme) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };

    // Onboarding: if pref is not set but a session already exists, the user
    // is returning after a reinstall — treat them as done.
    final savedOnboarding = prefs.getBool(_kOnboardingDoneKey);
    if (savedOnboarding != null) {
      _onboardingDone = savedOnboarding;
    } else if (isLoggedIn) {
      _onboardingDone = true;
      await prefs.setBool(_kOnboardingDoneKey, true);
    }

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

  Future<void> setOnboardingDone() async {
    _onboardingDone = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kOnboardingDoneKey, true);
  }

  void _authStateChanged(User? user) async => notifyListeners();

  Future<void> signOut() async {
    await _supabase.auth.signOut();
    _onboardingDone = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kOnboardingDoneKey);
    notifyListeners();
  }
}
