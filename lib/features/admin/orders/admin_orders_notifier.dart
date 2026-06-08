import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_delivery/models/order_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminOrdersState {
  final List<OrderModel> orders;
  final String searchQuery;
  final OrderStatus? statusFilter;
  final bool isLoading;
  final String? error;

  const AdminOrdersState({
    this.orders = const [],
    this.searchQuery = '',
    this.statusFilter,
    this.isLoading = false,
    this.error,
  });

  List<OrderModel> get filteredOrders {
    var list = orders;
    if (statusFilter != null) {
      list = list.where((o) => o.status == statusFilter).toList();
    }
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      list = list.where((o) =>
          o.id.toLowerCase().contains(q) ||
          o.restaurantName.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  AdminOrdersState copyWith({
    List<OrderModel>? orders,
    String? searchQuery,
    OrderStatus? statusFilter,
    bool clearFilter = false,
    bool? isLoading,
    String? error,
  }) {
    return AdminOrdersState(
      orders: orders ?? this.orders,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: clearFilter ? null : (statusFilter ?? this.statusFilter),
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AdminOrdersNotifier extends Notifier<AdminOrdersState> {
  final _db = Supabase.instance.client;

  @override
  AdminOrdersState build() {
    Future.microtask(fetchOrders);
    return const AdminOrdersState(isLoading: true);
  }

  Future<void> fetchOrders() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _db
          .from('orders')
          .select()
          .order('placed_at', ascending: false);
      state = AdminOrdersState(
        orders: (data as List).map((e) => OrderModel.fromJson(e)).toList(),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to load orders.');
    }
  }

  void setSearch(String query) => state = state.copyWith(searchQuery: query);

  void setStatusFilter(OrderStatus? status) {
    if (status == null) {
      state = state.copyWith(clearFilter: true);
    } else {
      state = state.copyWith(statusFilter: status);
    }
  }

  Future<void> updateStatus(String orderId, OrderStatus status) async {
    await _db.from('orders').update({'status': status.toJson()}).eq('id', orderId);
    final updated = state.orders.map((o) => o.id == orderId ? o.copyWith(status: status) : o).toList();
    state = state.copyWith(orders: updated);
  }
}

final adminOrdersNotifierProvider =
    NotifierProvider<AdminOrdersNotifier, AdminOrdersState>(AdminOrdersNotifier.new);
