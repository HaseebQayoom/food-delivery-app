import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_delivery/models/address_model.dart';
import 'package:food_delivery/repositories/profile_repository.dart';

class AddressState {
  final List<AddressModel> addresses;
  final bool isLoading;
  final String? error;

  const AddressState({
    this.addresses = const [],
    this.isLoading = false,
    this.error,
  });

  AddressState copyWith({
    List<AddressModel>? addresses,
    bool? isLoading,
    String? error,
  }) {
    return AddressState(
      addresses: addresses ?? this.addresses,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AddressNotifier extends Notifier<AddressState> {
  ProfileRepository get _repo => ref.read(profileRepositoryProvider);

  @override
  AddressState build() {
    Future.microtask(fetchAddresses);
    return const AddressState(isLoading: true);
  }

  Future<void> fetchAddresses() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final addresses = await _repo.getSavedAddresses();
      state = AddressState(addresses: addresses);
    } catch (_) {
      state = state.copyWith(isLoading: false, error: 'Failed to load addresses.');
    }
  }

  Future<void> addAddress(AddressModel address) async {
    await _repo.addAddress(address);
    await fetchAddresses();
  }

  Future<void> setDefault(String id) async {
    await _repo.setDefaultAddress(id);
    state = state.copyWith(
      addresses: state.addresses.map((a) => a.copyWith(isDefault: a.id == id)).toList(),
    );
  }

  Future<void> delete(String id) async {
    await _repo.deleteAddress(id);
    state = state.copyWith(addresses: state.addresses.where((a) => a.id != id).toList());
  }
}

final addressNotifierProvider =
    NotifierProvider<AddressNotifier, AddressState>(AddressNotifier.new);
