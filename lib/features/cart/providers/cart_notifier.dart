import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_delivery/models/cart_item_model.dart';
import 'package:food_delivery/models/dish_model.dart';
import 'package:food_delivery/repositories/cart_repository.dart';

class CartNotifier extends Notifier<List<CartItemModel>> {
  static const _deliveryFeeRs = 50;
  String? promoCode;
  int discountRs = 0;
  String selectedPaymentMethod = 'Visa';
  String get deliveryAddress => 'Home — DHA Phase 5, Lahore';

  CartRepository get _repo => ref.read(cartRepositoryProvider);

  @override
  List<CartItemModel> build() => _repo.getCart();

  void addItem(
    DishModel dish, {
    String? selectedSize,
    List<String> addonNames = const [],
    int? unitPriceRs,
  }) {
    state = _repo.addItem(
      state,
      dish,
      selectedSize: selectedSize,
      addonNames: addonNames,
      unitPriceRs: unitPriceRs,
    );
    _repo.saveCart(state);
  }

  void removeItem(String dishId) {
    state = _repo.removeItem(state, dishId);
    _repo.saveCart(state);
  }

  void increment(String dishId) {
    final idx = state.indexWhere((e) => e.dish.id == dishId);
    if (idx < 0) return;
    state = _repo.updateQuantity(state, dishId, state[idx].quantity + 1);
    _repo.saveCart(state);
  }

  void decrement(String dishId) {
    final idx = state.indexWhere((e) => e.dish.id == dishId);
    if (idx < 0) return;
    state = _repo.updateQuantity(state, dishId, state[idx].quantity - 1);
    _repo.saveCart(state);
  }

  void clear() {
    state = [];
    _repo.saveCart(state);
  }

  void setPaymentMethod(String method) {
    selectedPaymentMethod = method;
  }

  bool applyPromoCode(String code) {
    // Demo promo codes for FYP
    const codes = {'CRAVE10': 100, 'FIRST50': 50, 'SAVE20': 200};
    if (codes.containsKey(code.toUpperCase())) {
      promoCode = code.toUpperCase();
      discountRs = codes[promoCode]!;
      return true;
    }
    return false;
  }

  int get subtotalRs => state.fold(0, (sum, e) => sum + e.totalPriceRs);
  int get deliveryFeeRs => _deliveryFeeRs;
  int get totalRs => subtotalRs + deliveryFeeRs - discountRs;
  int get itemCount => state.fold(0, (sum, e) => sum + e.quantity);
}

final cartNotifierProvider =
    NotifierProvider<CartNotifier, List<CartItemModel>>(CartNotifier.new);
