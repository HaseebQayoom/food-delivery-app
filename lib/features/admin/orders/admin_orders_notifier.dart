import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_delivery/models/order_model.dart';
import 'package:food_delivery/repositories/order_repository.dart';

class AdminOrdersState {
  final List<OrderModel> orders;
  final String filterTab; // 'active' | 'ontheway' | 'delivered'
  final String? selectedOrderId;
  final bool isLoading;
  final String? error;

  const AdminOrdersState({
    this.orders = const [],
    this.filterTab = 'active',
    this.selectedOrderId,
    this.isLoading = false,
    this.error,
  });

  AdminOrdersState copyWith({
    List<OrderModel>? orders,
    String? filterTab,
    String? selectedOrderId,
    bool clearSelectedOrder = false,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return AdminOrdersState(
      orders: orders ?? this.orders,
      filterTab: filterTab ?? this.filterTab,
      selectedOrderId:
          clearSelectedOrder ? null : selectedOrderId ?? this.selectedOrderId,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }
}

extension AdminOrdersStateX on AdminOrdersState {
  List<OrderModel> get filteredOrders {
    switch (filterTab) {
      case 'active':
        return orders
            .where((o) =>
                o.status == OrderStatus.newOrder ||
                o.status == OrderStatus.preparing)
            .toList();
      case 'ontheway':
        return orders
            .where((o) => o.status == OrderStatus.onTheWay)
            .toList();
      case 'delivered':
        return orders
            .where((o) =>
                o.status == OrderStatus.delivered ||
                o.status == OrderStatus.cancelled)
            .toList();
      default:
        return orders;
    }
  }

  OrderModel? get selectedOrder =>
      orders.where((o) => o.id == selectedOrderId).firstOrNull;
}

class AdminOrdersNotifier extends Notifier<AdminOrdersState> {
  @override
  AdminOrdersState build() => const AdminOrdersState();

  Future<void> fetchOrders() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final orders =
          await ref.read(orderRepositoryProvider).getAllOrdersAdmin();
      final active = orders
          .where((o) =>
              o.status == OrderStatus.newOrder ||
              o.status == OrderStatus.preparing)
          .toList();
      final autoId = active.isNotEmpty
          ? active.first.id
          : (orders.isNotEmpty ? orders.first.id : null);
      state = state.copyWith(
        orders: orders,
        isLoading: false,
        selectedOrderId: state.selectedOrderId ?? autoId,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setFilter(String tab) {
    state = state.copyWith(filterTab: tab, clearSelectedOrder: true);
  }

  void selectOrder(String orderId) {
    state = state.copyWith(selectedOrderId: orderId);
  }

  Future<void> acceptOrder(String orderId) async {
    _optimisticStatusUpdate(orderId, OrderStatus.preparing);
    try {
      await ref
          .read(orderRepositoryProvider)
          .updateOrderStatus(orderId, OrderStatus.preparing);
    } catch (e) {
      await fetchOrders();
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> rejectOrder(String orderId) async {
    _optimisticStatusUpdate(orderId, OrderStatus.cancelled);
    try {
      await ref
          .read(orderRepositoryProvider)
          .updateOrderStatus(orderId, OrderStatus.cancelled);
    } catch (e) {
      await fetchOrders();
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> markOnTheWay(String orderId) async {
    _optimisticStatusUpdate(orderId, OrderStatus.onTheWay);
    try {
      await ref
          .read(orderRepositoryProvider)
          .updateOrderStatus(orderId, OrderStatus.onTheWay);
    } catch (e) {
      await fetchOrders();
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> markDelivered(String orderId) async {
    _optimisticStatusUpdate(orderId, OrderStatus.delivered);
    try {
      await ref
          .read(orderRepositoryProvider)
          .updateOrderStatus(orderId, OrderStatus.delivered);
    } catch (e) {
      await fetchOrders();
      state = state.copyWith(error: e.toString());
    }
  }

  void _optimisticStatusUpdate(String orderId, OrderStatus newStatus) {
    final updated = state.orders.map((o) {
      return o.id == orderId ? o.copyWith(status: newStatus) : o;
    }).toList();
    state = state.copyWith(orders: updated);
  }
}

final adminOrdersProvider =
    NotifierProvider<AdminOrdersNotifier, AdminOrdersState>(
  AdminOrdersNotifier.new,
);
