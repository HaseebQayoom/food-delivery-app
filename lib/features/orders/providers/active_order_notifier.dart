import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_delivery/models/order_model.dart';
import 'package:food_delivery/repositories/order_repository.dart';

class ActiveOrderNotifier extends Notifier<List<OrderModel>> {
  @override
  List<OrderModel> build() {
    Future.microtask(refresh);
    return [];
  }

  Future<void> refresh() async {
    try {
      final orders = await ref.read(orderRepositoryProvider).getActiveOrders();
      state = orders;
    } catch (_) {
      state = [];
    }
  }
}

final activeOrderNotifierProvider =
    NotifierProvider<ActiveOrderNotifier, List<OrderModel>>(
        ActiveOrderNotifier.new);
