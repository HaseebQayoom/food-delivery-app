import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_delivery/models/user_model.dart';
import 'package:food_delivery/repositories/auth_repository.dart';

class AuthState {
  final bool isLoading;
  final String? error;
  final UserModel? user;

  const AuthState({this.isLoading = false, this.error, this.user});

  AuthState copyWith({bool? isLoading, String? error, UserModel? user}) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      user: user ?? this.user,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await ref.read(authRepositoryProvider).login(email, password);
      state = AuthState(user: user);
      return true;
    } catch (e) {
      state = AuthState(error: e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  Future<bool> signup({
    required String name,
    required String email,
    // required String phone,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await ref.read(authRepositoryProvider).signup(
            name: name,
            email: email,
            //  phone: phone,
            password: password,
          );
      state = AuthState(user: user);
      return true;
    } catch (e) {
      state = AuthState(error: e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AuthState();
  }
}

final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
