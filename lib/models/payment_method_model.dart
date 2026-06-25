enum PaymentType {
  card,
  cash,
  wallet;

  static PaymentType fromJson(String value) {
    return PaymentType.values.firstWhere(
      (t) => t.name == value,
      orElse: () => PaymentType.cash,
    );
  }

  String toJson() => name;

  String get label {
    switch (this) {
      case PaymentType.card:
        return 'Credit / Debit Card';
      case PaymentType.cash:
        return 'Cash on Delivery';
      case PaymentType.wallet:
        return 'Crave Wallet';
    }
  }
}

class PaymentMethodModel {
  final String id;
  final PaymentType type;
  final String label;
  final String? lastFour;
  final String? stripePaymentMethodId;
  final String? stripeCustomerId;
  final bool isDefault;

  const PaymentMethodModel({
    required this.id,
    required this.type,
    required this.label,
    this.lastFour,
    this.stripePaymentMethodId,
    this.stripeCustomerId,
    this.isDefault = false,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: json['id'] as String,
      type: PaymentType.fromJson(json['type'] as String),
      label: json['label'] as String,
      lastFour: json['last_four'] as String?,
      stripePaymentMethodId: json['stripe_pm_id'] as String?,
      stripeCustomerId: json['stripe_customer_id'] as String?,
      isDefault: json['is_default'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.toJson(),
        'label': label,
        'last_four': lastFour,
        'stripe_pm_id': stripePaymentMethodId,
        'stripe_customer_id': stripeCustomerId,
        'is_default': isDefault,
      };

  PaymentMethodModel copyWith({
    String? id,
    PaymentType? type,
    String? label,
    String? lastFour,
    String? stripePaymentMethodId,
    String? stripeCustomerId,
    bool? isDefault,
  }) {
    return PaymentMethodModel(
      id: id ?? this.id,
      type: type ?? this.type,
      label: label ?? this.label,
      lastFour: lastFour ?? this.lastFour,
      stripePaymentMethodId: stripePaymentMethodId ?? this.stripePaymentMethodId,
      stripeCustomerId: stripeCustomerId ?? this.stripeCustomerId,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
