import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_delivery/models/user_model.dart';
import 'package:food_delivery/repositories/auth_repository.dart';
import 'package:food_delivery/repositories/profile_repository.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
      await ref
          .read(profileRepositoryProvider)
          .updateProfile(name: name, phone: phone);
      await fetchProfile();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Update failed.');
      return false;
    }
  }

  Future<void> uploadAvatarFromGallery() =>
      _uploadAvatar(ImageSource.gallery);

  Future<void> uploadAvatarFromCamera() =>
      _uploadAvatar(ImageSource.camera);

  Future<void> _uploadAvatar(ImageSource source) async {
    if (state.user == null) return;
    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 400,
      maxHeight: 400,
      imageQuality: 85,
    );
    if (picked == null) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      final bytes = await picked.readAsBytes();
      final ext = picked.name.split('.').last.toLowerCase();
      final path = '$userId/avatar.$ext';
      await Supabase.instance.client.storage.from('avatars').uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(contentType: 'image/$ext', upsert: true),
          );
      final url =
          Supabase.instance.client.storage.from('avatars').getPublicUrl(path);
      await ref.read(profileRepositoryProvider).updateProfile(
            name: state.user!.fullName,
            phone: state.user!.phone,
            avatarUrl: url,
          );
      await fetchProfile();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Upload failed.');
    }
  }

  Future<void> updateAvatar(String code) async {
    if (state.user == null) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      await ref.read(profileRepositoryProvider).updateProfile(
            name: state.user!.fullName,
            phone: state.user!.phone,
            avatarUrl: code,
          );
      await fetchProfile();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Update failed.');
    }
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const ProfileState();
  }
}

final profileNotifierProvider =
    NotifierProvider<ProfileNotifier, ProfileState>(ProfileNotifier.new);
