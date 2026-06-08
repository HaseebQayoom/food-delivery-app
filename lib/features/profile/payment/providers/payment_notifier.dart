import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_delivery/models/payment_method_model.dart';
import 'package:food_delivery/repositories/profile_repository.dart';

class PaymentState {
  final List<PaymentMethodModel> methods;
  final bool isLoading;
  final String? error;

  const PaymentState({
    this.methods = const [],
    this.isLoading = false,
    this.error,
  });

  PaymentState copyWith({
    List<PaymentMethodModel>? methods,
    bool? isLoading,
    String? error,
  }) {
    return PaymentState(
      methods: methods ?? this.methods,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class PaymentNotifier extends Notifier<PaymentState> {
  ProfileRepository get _repo => ref.read(profileRepositoryProvider);

  @override
  PaymentState build() {
    Future.microtask(fetchMethods);
    return const PaymentState(isLoading: true);
  }

  Future<void> fetchMethods() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final methods = await _repo.getPaymentMethods();
      state = PaymentState(methods: methods);
    } catch (_) {
      state = state.copyWith(isLoading: false, error: 'Failed to load payment methods.');
    }
  }

  Future<void> addMethod(PaymentMethodModel method) async {
    await _repo.addPaymentMethod(method);
    await fetchMethods();
  }

  Future<void> setDefault(String id) async {
    await _repo.setDefaultPayment(id);
    state = state.copyWith(
      methods: state.methods.map((m) => m.copyWith(isDefault: m.id == id)).toList(),
    );
  }

  Future<void> deleteMethod(String id) async {
    await _repo.deletePaymentMethod(id);
    state = state.copyWith(
      methods: state.methods.where((m) => m.id != id).toList(),
    );
  }
}

final paymentNotifierProvider =
    NotifierProvider<PaymentNotifier, PaymentState>(PaymentNotifier.new);
