class DishModel {
  final String id;
  final String name;
  final String? imageUrl;
  final String restaurantId;
  final String restaurantName;
  final int priceRs;
  final int calories;
  final String tag; // badge label e.g. "BESTSELLER"
  final bool isFavorite;
  final String categoryId;
  // Admin-panel fields
  final String description;
  final bool isAvailable;
  final double rating;
  final int prepTimeMin;
  final bool popular;

  const DishModel({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.restaurantId,
    required this.restaurantName,
    required this.priceRs,
    required this.calories,
    this.tag = '',
    this.isFavorite = false,
    this.categoryId = '',
    this.description = '',
    this.isAvailable = true,
    this.rating = 0.0,
    this.prepTimeMin = 0,
    this.popular = false,
  });

  factory DishModel.fromJson(Map<String, dynamic> json) {
    return DishModel(
      id: json['id'] as String,
      name: json['name'] as String,
      imageUrl: json['image_url'] as String?,
      restaurantId: json['restaurant_id'] as String? ?? '',
      restaurantName: json['restaurant_name'] as String? ?? '',
      priceRs: (json['price_rs'] as num?)?.toInt() ?? 0,
      calories: (json['calories'] as num?)?.toInt() ?? 0,
      tag: json['tag'] as String? ?? '',
      isFavorite: json['is_favorite'] as bool? ?? false,
      categoryId: json['category_id'] as String? ?? '',
      description: json['description'] as String? ?? '',
      isAvailable: json['is_available'] as bool? ?? true,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      prepTimeMin: (json['prep_time_min'] as num?)?.toInt() ?? 0,
      popular: json['popular'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'image_url': imageUrl,
        'restaurant_id': restaurantId,
        'restaurant_name': restaurantName,
        'price_rs': priceRs,
        'calories': calories,
        'tag': tag,
        'is_favorite': isFavorite,
        'category_id': categoryId,
        'description': description,
        'is_available': isAvailable,
        'rating': rating,
        'prep_time_min': prepTimeMin,
        'popular': popular,
      };

  DishModel copyWith({
    String? id,
    String? name,
    String? imageUrl,
    String? restaurantId,
    String? restaurantName,
    int? priceRs,
    int? calories,
    String? tag,
    bool? isFavorite,
    String? categoryId,
    String? description,
    bool? isAvailable,
    double? rating,
    int? prepTimeMin,
    bool? popular,
  }) {
    return DishModel(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      restaurantId: restaurantId ?? this.restaurantId,
      restaurantName: restaurantName ?? this.restaurantName,
      priceRs: priceRs ?? this.priceRs,
      calories: calories ?? this.calories,
      tag: tag ?? this.tag,
      isFavorite: isFavorite ?? this.isFavorite,
      categoryId: categoryId ?? this.categoryId,
      description: description ?? this.description,
      isAvailable: isAvailable ?? this.isAvailable,
      rating: rating ?? this.rating,
      prepTimeMin: prepTimeMin ?? this.prepTimeMin,
      popular: popular ?? this.popular,
    );
  }
}
