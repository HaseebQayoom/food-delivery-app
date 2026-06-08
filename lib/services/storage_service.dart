import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static const String tokenKey = 'auth_token';
  static const String userKey = 'cached_user';
  static const String onboardingSeenKey = 'onboarding_seen';
  static const String cartKey = 'cart_items';

  Future<bool> saveString(String key, String value) => _prefs.setString(key, value);
  String? getString(String key) => _prefs.getString(key);

  Future<bool> saveBool(String key, {required bool value}) => _prefs.setBool(key, value);
  bool getBool(String key, {bool defaultValue = false}) => _prefs.getBool(key) ?? defaultValue;

  Future<bool> remove(String key) => _prefs.remove(key);
}
