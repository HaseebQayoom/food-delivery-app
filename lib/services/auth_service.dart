import 'package:flutter/material.dart';
import 'package:food_delivery/core/navigation/app_navigator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final _auth = Supabase.instance.client.auth;

  Future<void> listenAuthentication(BuildContext context) async {
    _auth.onAuthStateChange.listen((event) {
      final session = event.session;
      if (session != null) {
        final user = event.session!.user;
        if (user.emailConfirmedAt != null && context.mounted) {
          AppNavigator.toHome(context);
        }
      }
    });
  }

  Future<AuthResponse> login(String email, String password) {
    return _auth.signInWithPassword(email: email, password: password);
  }

  Future<AuthResponse> signup({
    required String name,
    required String email,
    // required String phone,
    required String password,
  }) {
    return _auth.signUp(
      email: email,
      password: password,
      data: {'full_name': name, 
      // 'phone': phone
      },
    );
  }

  Future<void> logout() => _auth.signOut();

  User? get currentUser => _auth.currentUser;

  bool get isLoggedIn => _auth.currentSession != null;
}
