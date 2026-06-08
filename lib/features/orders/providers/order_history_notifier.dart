import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_delivery/models/order_model.dart';
import 'package:food_delivery/repositories/order_repository.dart';

class OrderHistoryState {
  final List<OrderModel> orders;
  final bool isLoading;
  final String? error;

  const OrderHistoryState({
    this.orders = const [],
    this.isLoading = false,
    this.error,
  });

  OrderHistoryState copyWith({
    List<OrderModel>? orders,
    bool? isLoading,
    String? error,
  }) {
    return OrderHistoryState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class OrderHistoryNotifier extends Notifier<OrderHistoryState> {
  @override
  OrderHistoryState build() {
    Future.microtask(fetchOrders);
    return const OrderHistoryState(isLoading: true);
  }

  Future<void> fetchOrders() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final orders = await ref.read(orderRepositoryProvider).getOrderHistory();
      state = OrderHistoryState(orders: orders);
    } catch (_) {
      state = state.copyWith(isLoading: false, error: 'Failed to load orders.');
    }
  }
}

final orderHistoryNotifierProvider =
    NotifierProvider<OrderHistoryNotifier, OrderHistoryState>(OrderHistoryNotifier.new);
