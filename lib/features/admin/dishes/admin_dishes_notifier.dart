import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_delivery/models/dish_model.dart';
import 'package:food_delivery/repositories/dish_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminDishesState {
  final List<DishModel> dishes;
  final List<({String id, String name})> categories;
  final String selectedCategoryId; // 'all' or a category id
  final String? editingDishId; // null=closed, 'new'=creating, UUID=editing
  final bool isLoading;
  final String? error;

  const AdminDishesState({
    this.dishes = const [],
    this.categories = const [],
    this.selectedCategoryId = 'all',
    this.editingDishId,
    this.isLoading = false,
    this.error,
  });

  AdminDishesState copyWith({
    List<DishModel>? dishes,
    List<({String id, String name})>? categories,
    String? selectedCategoryId,
    String? editingDishId,
    bool clearEditingDishId = false,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return AdminDishesState(
      dishes: dishes ?? this.dishes,
      categories: categories ?? this.categories,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      editingDishId:
          clearEditingDishId ? null : editingDishId ?? this.editingDishId,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }
}

extension AdminDishesStateX on AdminDishesState {
  List<DishModel> get displayedDishes {
    if (selectedCategoryId == 'all') return dishes;
    return dishes.where((d) => d.categoryId == selectedCategoryId).toList();
  }

  int get availableCount => dishes.where((d) => d.isAvailable).length;

  String? get restaurantId =>
      dishes.isNotEmpty ? dishes.first.restaurantId : null;
}

class AdminDishesNotifier extends Notifier<AdminDishesState> {
  final _db = Supabase.instance.client;

  @override
  AdminDishesState build() => const AdminDishesState();

  Future<void> fetchDishes() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final dishes = await ref.read(dishRepositoryProvider).getAllDishes();
      final rawCats =
          await _db.from('categories').select('id, name').order('name');
      final categories = (rawCats as List)
          .map((e) => (id: e['id'] as String, name: e['name'] as String))
          .toList();
      state = state.copyWith(
        dishes: dishes,
        categories: categories,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setCategory(String categoryId) {
    state = state.copyWith(selectedCategoryId: categoryId);
  }

  void openEditor(String dishId) {
    state = state.copyWith(editingDishId: dishId);
  }

  void closeEditor() {
    state = state.copyWith(clearEditingDishId: true);
  }

  Future<void> toggleAvailability(String dishId, bool newValue) async {
    final prev = state.dishes;
    state = state.copyWith(
      dishes: state.dishes
          .map((d) => d.id == dishId ? d.copyWith(isAvailable: newValue) : d)
          .toList(),
    );
    try {
      await ref
          .read(dishRepositoryProvider)
          .toggleAvailability(dishId, newValue);
    } catch (e) {
      state = state.copyWith(dishes: prev, error: e.toString());
    }
  }

  Future<void> togglePopular(String dishId, bool newValue) async {
    final prev = state.dishes;
    state = state.copyWith(
      dishes: state.dishes
          .map((d) => d.id == dishId ? d.copyWith(popular: newValue) : d)
          .toList(),
    );
    try {
      await ref.read(dishRepositoryProvider).togglePopular(dishId, newValue);
    } catch (e) {
      state = state.copyWith(dishes: prev, error: e.toString());
    }
  }

  Future<void> deleteDish(String dishId) async {
    final prev = state.dishes;
    state = state.copyWith(
      dishes: state.dishes.where((d) => d.id != dishId).toList(),
    );
    try {
      await ref.read(dishRepositoryProvider).deleteDish(dishId);
    } catch (e) {
      state = state.copyWith(dishes: prev, error: e.toString());
    }
  }

  Future<void> createDish(Map<String, dynamic> fields) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final dish = await ref.read(dishRepositoryProvider).createDish(fields);
      state = state.copyWith(
        dishes: [dish, ...state.dishes],
        isLoading: false,
        clearEditingDishId: true,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateDish(String dishId, Map<String, dynamic> fields) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final updated =
          await ref.read(dishRepositoryProvider).updateDish(dishId, fields);
      state = state.copyWith(
        dishes: state.dishes.map((d) => d.id == dishId ? updated : d).toList(),
        isLoading: false,
        clearEditingDishId: true,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final adminDishesProvider =
    NotifierProvider<AdminDishesNotifier, AdminDishesState>(
  AdminDishesNotifier.new,
);
