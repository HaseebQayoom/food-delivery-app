import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_delivery/models/dish_model.dart';
import 'package:food_delivery/models/restaurant_model.dart';
import 'package:food_delivery/repositories/dish_repository.dart';
import 'package:food_delivery/repositories/restaurant_repository.dart';

class RestaurantDetailState {
  final RestaurantModel? restaurant;
  final List<DishModel> dishes;
  final bool isLoading;
  final String? error;

  const RestaurantDetailState({
    this.restaurant,
    this.dishes = const [],
    this.isLoading = false,
    this.error,
  });

  RestaurantDetailState copyWith({
    RestaurantModel? restaurant,
    List<DishModel>? dishes,
    bool? isLoading,
    String? error,
  }) {
    return RestaurantDetailState(
      restaurant: restaurant ?? this.restaurant,
      dishes: dishes ?? this.dishes,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class RestaurantDetailNotifier
    extends FamilyNotifier<RestaurantDetailState, String> {
  @override
  RestaurantDetailState build(String restaurantId) {
    Future.microtask(() => _load(restaurantId));
    return const RestaurantDetailState(isLoading: true);
  }

  Future<void> _load(String restaurantId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final results = await Future.wait([
        ref.read(restaurantRepositoryProvider).getRestaurantById(restaurantId),
        ref.read(dishRepositoryProvider).getDishesByRestaurant(restaurantId),
      ]);
      state = RestaurantDetailState(
        restaurant: results[0] as RestaurantModel?,
        dishes: results[1] as List<DishModel>,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false, error: 'Failed to load menu.');
    }
  }

  Future<void> refresh() => _load(arg);
}

final restaurantDetailProvider = NotifierProvider.family<
    RestaurantDetailNotifier,
    RestaurantDetailState,
    String>(RestaurantDetailNotifier.new);
