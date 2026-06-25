import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:food_delivery/features/cart/providers/cart_notifier.dart';
import 'package:food_delivery/models/address_model.dart';
import 'package:food_delivery/models/order_model.dart';
import 'package:food_delivery/models/payment_method_model.dart';
import 'package:food_delivery/repositories/order_repository.dart';
import 'package:food_delivery/services/stripe_service.dart';

class CheckoutState {
  final AddressModel? selectedAddress;
  final PaymentMethodModel? selectedPayment;
  final String specialInstructions;
  final int tipRs;
  final bool isPlacingOrder;
  final String? error;
  final OrderModel? placedOrder;

  const CheckoutState({
    this.selectedAddress,
    this.selectedPayment,
    this.specialInstructions = '',
    this.tipRs = 0,
    this.isPlacingOrder = false,
    this.error,
    this.placedOrder,
  });

  CheckoutState copyWith({
    AddressModel? selectedAddress,
    PaymentMethodModel? selectedPayment,
    String? specialInstructions,
    int? tipRs,
    bool? isPlacingOrder,
    String? error,
    OrderModel? placedOrder,
  }) {
    return CheckoutState(
      selectedAddress: selectedAddress ?? this.selectedAddress,
      selectedPayment: selectedPayment ?? this.selectedPayment,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      tipRs: tipRs ?? this.tipRs,
      isPlacingOrder: isPlacingOrder ?? this.isPlacingOrder,
      error: error,
      placedOrder: placedOrder ?? this.placedOrder,
    );
  }
}

class CheckoutNotifier extends Notifier<CheckoutState> {
  @override
  CheckoutState build() => const CheckoutState();

  void selectAddress(AddressModel address) {
    state = state.copyWith(selectedAddress: address);
  }

  void selectPayment(PaymentMethodModel method) {
    state = state.copyWith(selectedPayment: method);
  }

  void setInstructions(String text) {
    state = state.copyWith(specialInstructions: text);
  }

  void setTip(int tipRs) {
    state = state.copyWith(tipRs: tipRs);
  }

  Future<OrderModel?> placeOrder() async {
    if (state.selectedAddress == null) {
      state = state.copyWith(error: 'Please select a delivery address.');
      return null;
    }
    if (state.selectedPayment == null) {
      state = state.copyWith(error: 'Please select a payment method.');
      return null;
    }

    state = state.copyWith(isPlacingOrder: true, error: null);
    try {
      final cart = ref.read(cartNotifierProvider);
      final cartNotifier = ref.read(cartNotifierProvider.notifier);
      final total = cartNotifier.totalRs + state.tipRs;

      // Charge card — silently if saved PM+Customer exist, otherwise show sheet
      if (state.selectedPayment!.type == PaymentType.card) {
        await StripeService.processPayment(
          amountRs: total,
          stripePaymentMethodId: state.selectedPayment!.stripePaymentMethodId,
          stripeCustomerId: state.selectedPayment!.stripeCustomerId,
        );
      }

      final order = await ref.read(orderRepositoryProvider).placeOrder(
            items: cart,
            deliveryAddress: state.selectedAddress!.fullAddress,
            deliveryFeeRs: cartNotifier.deliveryFeeRs,
            discountRs: cartNotifier.discountRs,
          );

      cartNotifier.clear();
      state = state.copyWith(isPlacingOrder: false, placedOrder: order);
      return order;
    } on StripeException catch (e) {
      final msg = e.error.localizedMessage ?? 'Payment cancelled.';
      state = state.copyWith(isPlacingOrder: false, error: msg);
      return null;
    } catch (_) {
      state = state.copyWith(
        isPlacingOrder: false,
        error: 'Failed to place order. Please try again.',
      );
      return null;
    }
  }
}

final checkoutNotifierProvider =
    NotifierProvider<CheckoutNotifier, CheckoutState>(CheckoutNotifier.new);
