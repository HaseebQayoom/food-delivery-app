import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_delivery/models/category_model.dart';
import 'package:food_delivery/models/dish_model.dart';
import 'package:food_delivery/models/restaurant_model.dart';
import 'package:food_delivery/repositories/dish_repository.dart';
import 'package:food_delivery/repositories/restaurant_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeState {
  final RestaurantModel? restaurant;
  final List<DishModel> popularDishes;
  final List<DishModel> dishes; // filteredMenuDishes — dishes shown in active category
  final Map<String, List<DishModel>> menuByCategory; // keyed by categoryId
  final List<CategoryModel> categories;
  final String? selectedCategoryId;
  final bool isLoading;
  final String? error;

  const HomeState({
    this.restaurant,
    this.popularDishes = const [],
    this.dishes = const [],
    this.menuByCategory = const {},
    this.categories = const [],
    this.selectedCategoryId,
    this.isLoading = false,
    this.error,
  });

  // Alias so Phase-5 screen can use the semantic name
  List<DishModel> get filteredMenuDishes => dishes;

  HomeState copyWith({
    RestaurantModel? restaurant,
    List<DishModel>? popularDishes,
    List<DishModel>? dishes,
    Map<String, List<DishModel>>? menuByCategory,
    List<CategoryModel>? categories,
    String? selectedCategoryId,
    bool? isLoading,
    String? error,
    bool clearSelectedCategory = false,
    bool clearError = false,
  }) {
    return HomeState(
      restaurant: restaurant ?? this.restaurant,
      popularDishes: popularDishes ?? this.popularDishes,
      dishes: dishes ?? this.dishes,
      menuByCategory: menuByCategory ?? this.menuByCategory,
      categories: categories ?? this.categories,
      selectedCategoryId: clearSelectedCategory
          ? null
          : selectedCategoryId ?? this.selectedCategoryId,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class HomeNotifier extends Notifier<HomeState> {
  final _db = Supabase.instance.client;

  @override
  HomeState build() {
    Future.microtask(fetchRestaurantData);
    return const HomeState(isLoading: true);
  }

  Future<void> fetchRestaurantData() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final restaurant =
          await ref.read(restaurantRepositoryProvider).getFirstRestaurant();

      final popularDishes = await ref
          .read(dishRepositoryProvider)
          .getPopularDishesByRestaurant(restaurant.id);

      final allDishes = await ref
          .read(dishRepositoryProvider)
          .getAllDishesByRestaurant(restaurant.id);

      final catData =
          await _db.from('categories').select().order('name') as List;
      final categories =
          catData.map((e) => CategoryModel.fromJson(e)).toList();

      final menuByCategory = <String, List<DishModel>>{};
      for (final cat in categories) {
        menuByCategory[cat.id] =
            allDishes.where((d) => d.categoryId == cat.id).toList();
      }

      final displayedPopular = popularDishes.isNotEmpty
          ? popularDishes
          : allDishes.take(5).toList();

      state = state.copyWith(
        restaurant: restaurant,
        popularDishes: displayedPopular,
        dishes: displayedPopular,
        menuByCategory: menuByCategory,
        categories: categories,
        isLoading: false,
        clearSelectedCategory: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Could not load feed. Tap to retry.',
      );
    }
  }

  void selectCategory(String? categoryId) {
    if (categoryId == null || categoryId.isEmpty) {
      state = state.copyWith(
        dishes: state.popularDishes,
        clearSelectedCategory: true,
      );
    } else {
      final filtered = state.menuByCategory[categoryId] ?? [];
      state = state.copyWith(
        selectedCategoryId: categoryId,
        dishes: filtered,
      );
    }
  }

  Future<void> toggleDishFavorite(int index) async {
    final dish = state.popularDishes[index];
    await ref.read(dishRepositoryProvider).toggleFavoriteDish(dish.id);
    final updated = List<DishModel>.from(state.popularDishes);
    updated[index] = dish.copyWith(isFavorite: !dish.isFavorite);
    state = state.copyWith(popularDishes: updated);
  }
}

final homeNotifierProvider =
    NotifierProvider<HomeNotifier, HomeState>(HomeNotifier.new);
