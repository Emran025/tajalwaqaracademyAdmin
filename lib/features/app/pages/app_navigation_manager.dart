import 'package:shared_preferences/shared_preferences.dart';

class AppNavigationManager {
  static const String _hasSeenWelcomeScreenKey = 'has_seen_welcome_screen';

  Future<bool> hasSeenWelcomeScreen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasSeenWelcomeScreenKey) ?? false;
  }

  Future<void> setHasSeenWelcomeScreen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasSeenWelcomeScreenKey, true);
  }
}
