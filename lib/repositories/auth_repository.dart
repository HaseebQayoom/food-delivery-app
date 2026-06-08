import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_delivery/models/user_model.dart';
import 'package:food_delivery/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final AuthService _auth;
  final _db = Supabase.instance.client;

  AuthRepository(this._auth);

  Future<UserModel> login(String email, String password) async {
    final res = await _auth.login(email, password);
    final user = res.user;
    if (user == null) throw Exception('Login failed');
    return _fetchProfile(user.id);
  }

  Future<UserModel> signup({
    required String name,
    required String email,
    // required String phone,
    required String password,
  }) async {
    final res = await _auth.signup(
      name: name,
      email: email,
      // phone: phone,
      password: password,
    );
    final user = res.user;
    if (user == null) throw Exception('Signup failed');
    if (res.session == null) {
      // Email confirmation is enabled — account created but no session yet.
      throw Exception('Account created! Check your email to confirm, then log in.');
    }
    // Profile row is created by the handle_new_user trigger.
    // Upsert patches full_name in case trigger ran before metadata was set.
    try {
      await _db.from('profiles').upsert({
        'id': user.id,
        'full_name': name,
        'email': email,
      });
    } catch (_) {}
    return _fetchProfile(user.id);
  }

  Future<void> logout() => _auth.logout();

  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _fetchProfile(user.id);
  }

  Future<UserModel> _fetchProfile(String userId) async {
    final data = await _db
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    if (data == null) {
      final u = _auth.currentUser!;
      return UserModel(
        id: u.id,
        fullName: u.userMetadata?['full_name'] as String? ?? '',
        email: u.email ?? '',
        phone: u.userMetadata?['phone'] as String? ?? '',
      );
    }
    return UserModel.fromJson(data);
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(AuthService());
});
