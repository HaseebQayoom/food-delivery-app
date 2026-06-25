import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_delivery/features/profile/providers/profile_notifier.dart';
import 'package:food_delivery/models/dish_model.dart';
import 'package:food_delivery/models/restaurant_model.dart';
import 'package:food_delivery/repositories/dish_repository.dart';
import 'package:food_delivery/repositories/restaurant_repository.dart';

enum FavoritesFilter { all, dishes, kitchens, lists }

class FavoritesState {
  final List<DishModel> dishes;
  final List<RestaurantModel> restaurants;
  final List<String> lists;
  final FavoritesFilter filter;
  final bool isLoading;
  final String? error;

  const FavoritesState({
    this.dishes = const [],
    this.restaurants = const [],
    this.lists = const [],
    this.filter = FavoritesFilter.all,
    this.isLoading = false,
    this.error,
  });

  FavoritesState copyWith({
    List<DishModel>? dishes,
    List<RestaurantModel>? restaurants,
    List<String>? lists,
    FavoritesFilter? filter,
    bool? isLoading,
    String? error,
  }) {
    return FavoritesState(
      dishes: dishes ?? this.dishes,
      restaurants: restaurants ?? this.restaurants,
      lists: lists ?? this.lists,
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
      List<RestaurantModel> restaurants = [];
      try {
        restaurants = await ref
            .read(restaurantRepositoryProvider)
            .getFavoriteRestaurants();
      } catch (_) {}
      state = state.copyWith(dishes: dishes, restaurants: restaurants, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Could not load favorites.');
    }
  }

  void setFilter(FavoritesFilter filter) {
    state = state.copyWith(filter: filter);
  }

  Future<void> addFavoriteDish(DishModel dish) async {
    await ref.read(dishRepositoryProvider).toggleFavoriteDish(dish.id);
    state = state.copyWith(
      dishes: [...state.dishes, dish.copyWith(isFavorite: true)],
    );
    ref.read(profileNotifierProvider.notifier).fetchProfile();
  }

  Future<void> removeFavoriteDish(String dishId) async {
    await ref.read(dishRepositoryProvider).toggleFavoriteDish(dishId);
    state = state.copyWith(dishes: state.dishes.where((d) => d.id != dishId).toList());
    ref.read(profileNotifierProvider.notifier).fetchProfile();
  }

  Future<void> toggleFavoriteDish(DishModel dish) async {
    final exists = state.dishes.any((d) => d.id == dish.id);
    if (exists) {
      await removeFavoriteDish(dish.id);
    } else {
      await addFavoriteDish(dish);
    }
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
