import 'package:food_delivery/models/dish_model.dart';

class CartItemModel {
  final DishModel dish;
  final int quantity;
  final String? selectedSize;
  final List<String> addonNames;
  final int unitPriceRs; // customised price per unit (size × base + addons)

  CartItemModel({
    required this.dish,
    required this.quantity,
    this.selectedSize,
    this.addonNames = const [],
    int? unitPriceRs,
  }) : unitPriceRs = unitPriceRs ?? dish.priceRs;

  int get totalPriceRs => unitPriceRs * quantity;

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      dish: DishModel.fromJson(json['dish'] as Map<String, dynamic>),
      quantity: (json['quantity'] as num).toInt(),
      selectedSize: json['selected_size'] as String?,
      addonNames: (json['addon_names'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      unitPriceRs: (json['unit_price_rs'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
        'dish': dish.toJson(),
        'quantity': quantity,
        'selected_size': selectedSize,
        'addon_names': addonNames,
        'unit_price_rs': unitPriceRs,
      };

  CartItemModel copyWith({
    DishModel? dish,
    int? quantity,
    String? selectedSize,
    List<String>? addonNames,
    int? unitPriceRs,
  }) {
    return CartItemModel(
      dish: dish ?? this.dish,
      quantity: quantity ?? this.quantity,
      selectedSize: selectedSize ?? this.selectedSize,
      addonNames: addonNames ?? this.addonNames,
      unitPriceRs: unitPriceRs ?? this.unitPriceRs,
    );
  }
}
