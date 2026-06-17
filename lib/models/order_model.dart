import 'package:food_delivery/models/cart_item_model.dart';

enum OrderStatus {
  newOrder,
  preparing,
  onTheWay,
  delivered,
  cancelled;

  static OrderStatus fromJson(String value) => _statusFromDb(value);

  static OrderStatus _statusFromDb(String value) {
    switch (value) {
      case 'placed':
      case 'new':
        return OrderStatus.newOrder;
      case 'preparing':
        return OrderStatus.preparing;
      case 'picked':
      case 'on_the_way':
        return OrderStatus.onTheWay;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.newOrder;
    }
  }

  String toDbString() {
    switch (this) {
      case OrderStatus.newOrder:
        return 'new';
      case OrderStatus.preparing:
        return 'preparing';
      case OrderStatus.onTheWay:
        return 'on_the_way';
      case OrderStatus.delivered:
        return 'delivered';
      case OrderStatus.cancelled:
        return 'cancelled';
    }
  }

  String toJson() => toDbString();

  String get label {
    switch (this) {
      case OrderStatus.newOrder:
        return 'New Order';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.onTheWay:
        return 'On the Way';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}

class OrderModel {
  final String id;
  final List<CartItemModel> items;
  final OrderStatus status;
  final String restaurantName;
  final String deliveryAddress;
  final DateTime placedAt;
  final int subtotalRs;
  final int deliveryFeeRs;
  final int totalRs;
  final int discountRs;
  final String? courierName;
  final String? courierPhone;
  final double? courierLat;
  final double? courierLng;

  const OrderModel({
    required this.id,
    required this.items,
    required this.status,
    required this.restaurantName,
    required this.deliveryAddress,
    required this.placedAt,
    required this.subtotalRs,
    required this.deliveryFeeRs,
    required this.totalRs,
    this.discountRs = 0,
    this.courierName,
    this.courierPhone,
    this.courierLat,
    this.courierLng,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      status: OrderStatus.fromJson(json['status'] as String),
      restaurantName: json['restaurant_name'] as String,
      deliveryAddress: json['delivery_address'] as String,
      placedAt: DateTime.parse(json['placed_at'] as String),
      subtotalRs: json['subtotal_rs'] as int,
      deliveryFeeRs: json['delivery_fee_rs'] as int,
      totalRs: json['total_rs'] as int,
      discountRs: json['discount_rs'] as int? ?? 0,
      courierName: json['courier_name'] as String?,
      courierPhone: json['courier_phone'] as String?,
      courierLat: (json['courier_lat'] as num?)?.toDouble(),
      courierLng: (json['courier_lng'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'items': items.map((e) => e.toJson()).toList(),
        'status': status.toJson(),
        'restaurant_name': restaurantName,
        'delivery_address': deliveryAddress,
        'placed_at': placedAt.toIso8601String(),
        'subtotal_rs': subtotalRs,
        'delivery_fee_rs': deliveryFeeRs,
        'total_rs': totalRs,
        'discount_rs': discountRs,
        'courier_name': courierName,
        'courier_phone': courierPhone,
        'courier_lat': courierLat,
        'courier_lng': courierLng,
      };

  OrderModel copyWith({
    String? id,
    List<CartItemModel>? items,
    OrderStatus? status,
    String? restaurantName,
    String? deliveryAddress,
    DateTime? placedAt,
    int? subtotalRs,
    int? deliveryFeeRs,
    int? totalRs,
    int? discountRs,
    String? courierName,
    String? courierPhone,
    double? courierLat,
    double? courierLng,
  }) {
    return OrderModel(
      id: id ?? this.id,
      items: items ?? this.items,
      status: status ?? this.status,
      restaurantName: restaurantName ?? this.restaurantName,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      placedAt: placedAt ?? this.placedAt,
      subtotalRs: subtotalRs ?? this.subtotalRs,
      deliveryFeeRs: deliveryFeeRs ?? this.deliveryFeeRs,
      totalRs: totalRs ?? this.totalRs,
      discountRs: discountRs ?? this.discountRs,
      courierName: courierName ?? this.courierName,
      courierPhone: courierPhone ?? this.courierPhone,
      courierLat: courierLat ?? this.courierLat,
      courierLng: courierLng ?? this.courierLng,
    );
  }
}
