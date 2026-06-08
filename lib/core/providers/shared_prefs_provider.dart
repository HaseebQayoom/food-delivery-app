import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Initialized in main() and injected via ProviderScope.overrides.
// Use Provider<SharedPreferences> — no FutureProvider needed.
//
// Usage:
//   final prefs = ref.read(sharedPrefsProvider);
//   prefs.setBool(StorageKeys.onboardingSeen, true);
final sharedPrefsProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError(
    'sharedPrefsProvider must be overridden in ProviderScope — '
    'call SharedPreferences.getInstance() in main() first.',
  ),
);

// Convenience keys — use these constants everywhere instead of raw strings.
class StorageKeys {
  StorageKeys._();

  static const String onboardingSeen = 'onboarding_seen';
  static const String cachedUserJson = 'cached_user';
}
