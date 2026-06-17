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
  String? _trackedOrderId;

  @override
  TrackingState build() {
    // ref.onDispose belongs here — runs when the provider is destroyed
    ref.onDispose(() => _pollTimer?.cancel());
    return const TrackingState(isLoading: true);
  }

  Future<void> startTracking(String orderId) async {
    // Cancel any previous timer and reset for the new order
    _pollTimer?.cancel();
    _pollTimer = null;
    _trackedOrderId = orderId;
    state = const TrackingState(isLoading: true);

    await _fetchOrder(orderId);

    // Only start polling if we're still tracking the same order
    if (_trackedOrderId != orderId) return;
    _pollTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (_trackedOrderId == orderId) _fetchOrder(orderId);
    });
  }

  Future<void> _fetchOrder(String orderId) async {
    try {
      final order = await ref.read(orderRepositoryProvider).trackOrder(orderId);
      if (_trackedOrderId != orderId) return; // stale response, discard
      state = TrackingState(order: order);
      if (order.status == OrderStatus.delivered ||
          order.status == OrderStatus.cancelled) {
        _pollTimer?.cancel();
        _pollTimer = null;
      }
    } catch (e) {
      if (_trackedOrderId != orderId) return;
      state = state.copyWith(isLoading: false, error: 'Could not fetch order status.');
    }
  }
}

final trackingNotifierProvider =
    NotifierProvider<TrackingNotifier, TrackingState>(TrackingNotifier.new);
