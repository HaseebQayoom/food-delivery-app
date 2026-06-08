class RestaurantModel {
  final String id;
  final String name;
  final String? imageUrl;
  final List<String> cuisineTags;
  final double rating;
  final int deliveryTimeMin;
  final int minOrderRs;
  final bool isFavorite;

  const RestaurantModel({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.cuisineTags,
    required this.rating,
    required this.deliveryTimeMin,
    required this.minOrderRs,
    this.isFavorite = false,
  });

  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    return RestaurantModel(
      id: json['id'] as String,
      name: json['name'] as String,
      imageUrl: json['image_url'] as String?,
      cuisineTags: (json['cuisine_tags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      rating: (json['rating'] as num).toDouble(),
      deliveryTimeMin: json['delivery_time_min'] as int,
      minOrderRs: json['min_order_rs'] as int,
      isFavorite: json['is_favorite'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'image_url': imageUrl,
        'cuisine_tags': cuisineTags,
        'rating': rating,
        'delivery_time_min': deliveryTimeMin,
        'min_order_rs': minOrderRs,
        'is_favorite': isFavorite,
      };

  RestaurantModel copyWith({
    String? id,
    String? name,
    String? imageUrl,
    List<String>? cuisineTags,
    double? rating,
    int? deliveryTimeMin,
    int? minOrderRs,
    bool? isFavorite,
  }) {
    return RestaurantModel(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      cuisineTags: cuisineTags ?? this.cuisineTags,
      rating: rating ?? this.rating,
      deliveryTimeMin: deliveryTimeMin ?? this.deliveryTimeMin,
      minOrderRs: minOrderRs ?? this.minOrderRs,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
