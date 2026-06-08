import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminAuthState {
  final bool isLoading;
  final String? error;

  const AdminAuthState({this.isLoading = false, this.error});

  AdminAuthState copyWith({bool? isLoading, String? error}) {
    return AdminAuthState(isLoading: isLoading ?? this.isLoading, error: error);
  }
}

class AdminAuthNotifier extends Notifier<AdminAuthState> {
  @override
  AdminAuthState build() => const AdminAuthState();

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = res.user;
      if (user == null) {
        state = AdminAuthState(error: 'Login failed.');
        return false;
      }
      // Check admin role in user metadata
      final role = user.userMetadata?['role'] as String?;
      if (role != 'admin') {
        await Supabase.instance.client.auth.signOut();
        state = AdminAuthState(error: 'Access denied. Admin account required.');
        return false;
      }
      state = const AdminAuthState();
      return true;
    } catch (e) {
      state = AdminAuthState(error: 'Invalid credentials.');
      return false;
    }
  }

  Future<void> logout() async {
    await Supabase.instance.client.auth.signOut();
    state = const AdminAuthState();
  }
}

final adminAuthNotifierProvider =
    NotifierProvider<AdminAuthNotifier, AdminAuthState>(AdminAuthNotifier.new);
