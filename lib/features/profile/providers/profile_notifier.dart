import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_delivery/models/user_model.dart';
import 'package:food_delivery/repositories/auth_repository.dart';
import 'package:food_delivery/repositories/profile_repository.dart';

class ProfileState {
  final UserModel? user;
  final bool isLoading;
  final String? error;

  const ProfileState({this.user, this.isLoading = false, this.error});

  ProfileState copyWith({UserModel? user, bool? isLoading, String? error}) {
    return ProfileState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ProfileNotifier extends Notifier<ProfileState> {
  @override
  ProfileState build() {
    Future.microtask(fetchProfile);
    return const ProfileState(isLoading: true);
  }

  Future<void> fetchProfile() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await ref.read(profileRepositoryProvider).getProfile();
      state = ProfileState(user: user);
    } catch (e) {
      state = ProfileState(error: 'Could not load profile.');
    }
  }

  Future<bool> updateProfile({required String name, required String phone}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await ref
          .read(profileRepositoryProvider)
          .updateProfile(name: name, phone: phone);
      state = ProfileState(user: user);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Update failed.');
      return false;
    }
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const ProfileState();
  }
}

final profileNotifierProvider =
    NotifierProvider<ProfileNotifier, ProfileState>(ProfileNotifier.new);
