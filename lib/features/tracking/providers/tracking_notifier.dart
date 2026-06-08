import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_delivery/models/order_model.dart';
import 'package:food_delivery/repositories/order_repository.dart';

class TrackingState {
  final OrderModel? order;
  final bool isLoading;
  final String? error;

  const TrackingState({this.order, this.isLoading = false, this.error});

  TrackingState copyWith({OrderModel? order, bool? isLoading, String? error}) {
    return TrackingState(
      order: order ?? this.order,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class TrackingNotifier extends Notifier<TrackingState> {
  Timer? _pollTimer;

  @override
  TrackingState build() => const TrackingState(isLoading: true);

  Future<void> startTracking(String orderId) async {
    await _fetchOrder(orderId);
    // Poll every 15 seconds for status updates
    _pollTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      _fetchOrder(orderId);
    });
    ref.onDispose(() => _pollTimer?.cancel());
  }

  Future<void> _fetchOrder(String orderId) async {
    try {
      final order = await ref.read(orderRepositoryProvider).trackOrder(orderId);
      state = TrackingState(order: order);
      // Stop polling when delivered
      if (order.status == OrderStatus.delivered) {
        _pollTimer?.cancel();
      }
    } catch (e) {
      state = state.copyWith(error: 'Could not fetch order status.');
    }
  }
}

final trackingNotifierProvider =
    NotifierProvider<TrackingNotifier, TrackingState>(TrackingNotifier.new);
