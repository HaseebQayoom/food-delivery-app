import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Returns the currently logged-in Supabase user, or null if not logged in.
// Supabase persists the session automatically — no manual token storage needed.
//
// Usage:
//   final user = ref.watch(currentUserProvider);
//   if (user != null) { ... }
final currentUserProvider = Provider<User?>((ref) {
  return Supabase.instance.client.auth.currentUser;
});

// True when a valid Supabase session exists.
//
// Usage:
//   final loggedIn = ref.watch(isLoggedInProvider);
final isLoggedInProvider = Provider<bool>((ref) {
  return Supabase.instance.client.auth.currentSession != null;
});
