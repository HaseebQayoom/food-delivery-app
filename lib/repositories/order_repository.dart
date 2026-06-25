import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_delivery/models/cart_item_model.dart';
import 'package:food_delivery/models/order_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrderRepository {
  final _db = Supabase.instance.client;

  Future<OrderModel> placeOrder({
    required List<CartItemModel> items,
    required String deliveryAddress,
    int deliveryFeeRs = 50,
    int discountRs = 0,
  }) async {
    final userId = _db.auth.currentUser?.id;
    if (userId == null) throw Exception('Not logged in');

    final subtotal = items.fold<int>(0, (sum, e) => sum + e.totalPriceRs);
    final total = subtotal + deliveryFeeRs - discountRs;
    final restaurantName = items.isNotEmpty ? items[0].dish.restaurantName : '';

    final data = await _db.from('orders').insert({
      'user_id': userId,
      'items': items.map((e) => e.toJson()).toList(),
      'status': OrderStatus.newOrder.toDbString(),
      'restaurant_name': restaurantName,
      'delivery_address': deliveryAddress,
      'placed_at': DateTime.now().toIso8601String(),
      'subtotal_rs': subtotal,
      'delivery_fee_rs': deliveryFeeRs,
      'total_rs': total,
      'discount_rs': discountRs,
    }).select().single();

    return OrderModel.fromJson(data);
  }

  Future<List<OrderModel>> getOrderHistory() async {
    final userId = _db.auth.currentUser?.id;
    if (userId == null) return [];
    final data = await _db
        .from('orders')
        .select()
        .eq('user_id', userId)
        .order('placed_at', ascending: false);
    return (data as List).map((e) => OrderModel.fromJson(e)).toList();
  }

  Future<List<OrderModel>> getActiveOrders() async {
    final userId = _db.auth.currentUser?.id;
    if (userId == null) return [];
    final data = await _db
        .from('orders')
        .select()
        .eq('user_id', userId)
        .inFilter('status', ['new', 'preparing', 'on_the_way'])
        .order('placed_at', ascending: false);
    return (data as List).map((e) => OrderModel.fromJson(e)).toList();
  }

  Future<OrderModel> trackOrder(String orderId) async {
    final data = await _db.from('orders').select().eq('id', orderId).single();
    return OrderModel.fromJson(data);
  }

  Future<void> updateStatus(String orderId, OrderStatus status) async {
    await _db
        .from('orders')
        .update({'status': status.toDbString()})
        .eq('id', orderId);
  }

  // ─── Admin methods ────────────────────────────────────────

  Future<List<OrderModel>> getAllOrdersAdmin() async {
    final data = await _db
        .from('orders')
        .select()
        .order('placed_at', ascending: false);
    return (data as List).map((e) => OrderModel.fromJson(e)).toList();
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) =>
      updateStatus(orderId, status);
}

final orderRepositoryProvider = Provider<OrderRepository>((_) => OrderRepository());
