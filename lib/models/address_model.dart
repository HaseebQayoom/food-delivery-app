class AddressModel {
  final String id;
  final String label;       // e.g. "Home", "Work", "Other"
  final String fullAddress;
  final double lat;
  final double lng;
  final bool isDefault;

  const AddressModel({
    required this.id,
    required this.label,
    required this.fullAddress,
    required this.lat,
    required this.lng,
    this.isDefault = false,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] as String,
      label: json['label'] as String,
      fullAddress: json['full_address'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      isDefault: json['is_default'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'full_address': fullAddress,
        'lat': lat,
        'lng': lng,
        'is_default': isDefault,
      };

  AddressModel copyWith({
    String? id,
    String? label,
    String? fullAddress,
    double? lat,
    double? lng,
    bool? isDefault,
  }) {
    return AddressModel(
      id: id ?? this.id,
      label: label ?? this.label,
      fullAddress: fullAddress ?? this.fullAddress,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
