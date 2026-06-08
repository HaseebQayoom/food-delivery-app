import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_delivery/models/dish_model.dart';
import 'package:food_delivery/models/restaurant_model.dart';
import 'package:food_delivery/repositories/dish_repository.dart';
import 'package:food_delivery/repositories/restaurant_repository.dart';

enum FavoritesFilter { all, dishes, restaurants }

class FavoritesState {
  final List<DishModel> dishes;
  final List<RestaurantModel> restaurants;
  final FavoritesFilter filter;
  final bool isLoading;
  final String? error;

  const FavoritesState({
    this.dishes = const [],
    this.restaurants = const [],
    this.filter = FavoritesFilter.all,
    this.isLoading = false,
    this.error,
  });

  FavoritesState copyWith({
    List<DishModel>? dishes,
    List<RestaurantModel>? restaurants,
    FavoritesFilter? filter,
    bool? isLoading,
    String? error,
  }) {
    return FavoritesState(
      dishes: dishes ?? this.dishes,
      restaurants: restaurants ?? this.restaurants,
      filter: filter ?? this.filter,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class FavoritesNotifier extends Notifier<FavoritesState> {
  @override
  FavoritesState build() {
    Future.microtask(fetchFavorites);
    return const FavoritesState(isLoading: true);
  }

  Future<void> fetchFavorites() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final dishes = await ref.read(dishRepositoryProvider).getFavoriteDishes();
      final restaurants = await ref.read(restaurantRepositoryProvider).getFavoriteRestaurants();
      state = state.copyWith(dishes: dishes, restaurants: restaurants, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Could not load favorites.');
    }
  }

  void setFilter(FavoritesFilter filter) {
    state = state.copyWith(filter: filter);
  }

  Future<void> removeFavoriteDish(String dishId) async {
    await ref.read(dishRepositoryProvider).toggleFavoriteDish(dishId);
    state = state.copyWith(dishes: state.dishes.where((d) => d.id != dishId).toList());
  }

  Future<void> removeFavoriteRestaurant(String restaurantId) async {
    await ref.read(restaurantRepositoryProvider).toggleFavorite(restaurantId);
    state = state.copyWith(
      restaurants: state.restaurants.where((r) => r.id != restaurantId).toList(),
    );
  }
}

final favoritesNotifierProvider =
    NotifierProvider<FavoritesNotifier, FavoritesState>(FavoritesNotifier.new);
