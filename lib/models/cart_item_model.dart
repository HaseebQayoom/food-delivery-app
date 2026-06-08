import 'package:food_delivery/models/dish_model.dart';

class CartItemModel {
  final DishModel dish;
  final int quantity;

  const CartItemModel({
    required this.dish,
    required this.quantity,
  });

  int get totalPriceRs => dish.priceRs * quantity;

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      dish: DishModel.fromJson(json['dish'] as Map<String, dynamic>),
      quantity: json['quantity'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'dish': dish.toJson(),
        'quantity': quantity,
      };

  CartItemModel copyWith({DishModel? dish, int? quantity}) {
    return CartItemModel(
      dish: dish ?? this.dish,
      quantity: quantity ?? this.quantity,
    );
  }
}
