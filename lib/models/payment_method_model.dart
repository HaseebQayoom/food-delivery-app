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
  final String? lastFour; // last 4 digits for card type
  final bool isDefault;

  const PaymentMethodModel({
    required this.id,
    required this.type,
    required this.label,
    this.lastFour,
    this.isDefault = false,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: json['id'] as String,
      type: PaymentType.fromJson(json['type'] as String),
      label: json['label'] as String,
      lastFour: json['last_four'] as String?,
      isDefault: json['is_default'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.toJson(),
        'label': label,
        'last_four': lastFour,
        'is_default': isDefault,
      };

  PaymentMethodModel copyWith({
    String? id,
    PaymentType? type,
    String? label,
    String? lastFour,
    bool? isDefault,
  }) {
    return PaymentMethodModel(
      id: id ?? this.id,
      type: type ?? this.type,
      label: label ?? this.label,
      lastFour: lastFour ?? this.lastFour,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
