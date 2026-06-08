import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_delivery/core/providers/shared_prefs_provider.dart';
import 'package:food_delivery/models/cart_item_model.dart';
import 'package:food_delivery/models/dish_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartRepository {
  final SharedPreferences _prefs;
  static const _key = 'cart_items';

  CartRepository(this._prefs);

  List<CartItemModel> getCart() {
    final raw = _prefs.getString(_key);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => CartItemModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveCart(List<CartItemModel> items) {
    return _prefs.setString(_key, jsonEncode(items.map((e) => e.toJson()).toList()));
  }

  List<CartItemModel> addItem(List<CartItemModel> cart, DishModel dish) {
    final idx = cart.indexWhere((e) => e.dish.id == dish.id);
    if (idx >= 0) {
      final updated = List<CartItemModel>.from(cart);
      updated[idx] = cart[idx].copyWith(quantity: cart[idx].quantity + 1);
      return updated;
    }
    return [...cart, CartItemModel(dish: dish, quantity: 1)];
  }

  List<CartItemModel> removeItem(List<CartItemModel> cart, String dishId) {
    return cart.where((e) => e.dish.id != dishId).toList();
  }

  List<CartItemModel> updateQuantity(
      List<CartItemModel> cart, String dishId, int quantity) {
    if (quantity <= 0) return removeItem(cart, dishId);
    return cart
        .map((e) => e.dish.id == dishId ? e.copyWith(quantity: quantity) : e)
        .toList();
  }
}

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return CartRepository(ref.read(sharedPrefsProvider));
});
