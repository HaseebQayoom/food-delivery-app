import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_delivery/models/order_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardState {
  final int totalUsers;
  final int totalOrders;
  final int totalRevenue;
  final int totalDishes;
  final List<OrderModel> recentOrders;
  final bool isLoading;
  final String? error;

  const DashboardState({
    this.totalUsers = 0,
    this.totalOrders = 0,
    this.totalRevenue = 0,
    this.totalDishes = 0,
    this.recentOrders = const [],
    this.isLoading = false,
    this.error,
  });

  DashboardState copyWith({
    int? totalUsers,
    int? totalOrders,
    int? totalRevenue,
    int? totalDishes,
    List<OrderModel>? recentOrders,
    bool? isLoading,
    String? error,
  }) {
    return DashboardState(
      totalUsers: totalUsers ?? this.totalUsers,
      totalOrders: totalOrders ?? this.totalOrders,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      totalDishes: totalDishes ?? this.totalDishes,
      recentOrders: recentOrders ?? this.recentOrders,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class DashboardNotifier extends Notifier<DashboardState> {
  final _db = Supabase.instance.client;

  @override
  DashboardState build() {
    Future.microtask(fetchAll);
    return const DashboardState(isLoading: true);
  }

  Future<void> fetchAll() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final usersRes = await _db.from('profiles').select('id');
      final ordersRes = await _db.from('orders').select('id, total_rs, placed_at, status, restaurant_name, delivery_address, items, subtotal_rs, delivery_fee_rs, discount_rs').order('placed_at', ascending: false);
      final dishesRes = await _db.from('dishes').select('id');

      final orders = (ordersRes as List).map((e) => OrderModel.fromJson(e)).toList();
      final revenue = orders.fold<int>(0, (sum, o) => sum + o.totalRs);

      state = DashboardState(
        totalUsers: (usersRes as List).length,
        totalOrders: orders.length,
        totalRevenue: revenue,
        totalDishes: (dishesRes as List).length,
        recentOrders: orders.take(5).toList(),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Could not load dashboard data.');
    }
  }
}

final adminDashboardNotifierProvider =
    NotifierProvider<DashboardNotifier, DashboardState>(DashboardNotifier.new);
