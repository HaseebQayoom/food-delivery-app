import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_delivery/models/category_model.dart';
import 'package:food_delivery/models/dish_model.dart';
import 'package:food_delivery/models/restaurant_model.dart';
import 'package:food_delivery/repositories/dish_repository.dart';
import 'package:food_delivery/repositories/restaurant_repository.dart';

class HomeState {
  final List<RestaurantModel> restaurants;
  final List<DishModel> dishes;
  final List<CategoryModel> categories;
  final String? selectedCategoryId;
  final bool isLoading;
  final String? error;

  const HomeState({
    this.restaurants = const [],
    this.dishes = const [],
    this.categories = const [],
    this.selectedCategoryId,
    this.isLoading = false,
    this.error,
  });

  HomeState copyWith({
    List<RestaurantModel>? restaurants,
    List<DishModel>? dishes,
    List<CategoryModel>? categories,
    String? selectedCategoryId,
    bool? isLoading,
    String? error,
  }) {
    return HomeState(
      restaurants: restaurants ?? this.restaurants,
      dishes: dishes ?? this.dishes,
      categories: categories ?? this.categories,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Static categories for initial render (Supabase fetch on init)
final _staticCategories = [
  CategoryModel(id: '1', name: 'Burgers', emoji: '🍔', bgColor: const Color(0xFFFFE8DC)),
  CategoryModel(id: '2', name: 'Pizza', emoji: '🍕', bgColor: const Color(0xFFFFEBEB)),
  CategoryModel(id: '3', name: 'Asian', emoji: '🍜', bgColor: const Color(0xFFE8F4E5)),
  CategoryModel(id: '4', name: 'Salads', emoji: '🥗', bgColor: const Color(0xFFE8F0FF)),
  CategoryModel(id: '5', name: 'Desserts', emoji: '🍰', bgColor: const Color(0xFFF5E8F8)),
];

class HomeNotifier extends Notifier<HomeState> {
  @override
  HomeState build() {
    Future.microtask(fetchAll);
    return HomeState(categories: _staticCategories);
  }

  Future<void> fetchAll() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final restaurants = await ref.read(restaurantRepositoryProvider).getPopularRestaurants();
      final dishes = await ref.read(dishRepositoryProvider).getPopularDishes();
      state = state.copyWith(
        restaurants: restaurants,
        dishes: dishes,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Could not load feed. Tap to retry.',
      );
    }
  }

  Future<void> toggleDishFavorite(int index) async {
    final dish = state.dishes[index];
    await ref.read(dishRepositoryProvider).toggleFavoriteDish(dish.id);
    final updated = List<DishModel>.from(state.dishes);
    updated[index] = dish.copyWith(isFavorite: !dish.isFavorite);
    state = state.copyWith(dishes: updated);
  }

  Future<void> selectCategory(String? categoryId) async {
    state = state.copyWith(selectedCategoryId: categoryId ?? '');
    if (categoryId == null) {
      final dishes = await ref.read(dishRepositoryProvider).getPopularDishes();
      state = state.copyWith(dishes: dishes);
    } else {
      final dishes = await ref.read(dishRepositoryProvider).getDishesByCategory(categoryId);
      state = state.copyWith(dishes: dishes);
    }
  }
}

final homeNotifierProvider = NotifierProvider<HomeNotifier, HomeState>(HomeNotifier.new);
