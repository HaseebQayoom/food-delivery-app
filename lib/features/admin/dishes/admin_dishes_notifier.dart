import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_delivery/models/dish_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminDishesState {
  final List<DishModel> dishes;
  final String searchQuery;
  final bool isLoading;
  final String? error;

  const AdminDishesState({
    this.dishes = const [],
    this.searchQuery = '',
    this.isLoading = false,
    this.error,
  });

  List<DishModel> get filteredDishes {
    if (searchQuery.isEmpty) return dishes;
    final q = searchQuery.toLowerCase();
    return dishes.where((d) =>
        d.name.toLowerCase().contains(q) ||
        d.restaurantName.toLowerCase().contains(q) ||
        d.tag.toLowerCase().contains(q)).toList();
  }

  AdminDishesState copyWith({
    List<DishModel>? dishes,
    String? searchQuery,
    bool? isLoading,
    String? error,
  }) {
    return AdminDishesState(
      dishes: dishes ?? this.dishes,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AdminDishesNotifier extends Notifier<AdminDishesState> {
  final _db = Supabase.instance.client;

  @override
  AdminDishesState build() {
    Future.microtask(fetchDishes);
    return const AdminDishesState(isLoading: true);
  }

  Future<void> fetchDishes() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _db.from('dishes').select().order('name');
      state = AdminDishesState(dishes: (data as List).map((e) => DishModel.fromJson(e)).toList());
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to load dishes.');
    }
  }

  void setSearch(String query) => state = state.copyWith(searchQuery: query);

  Future<void> addDish(DishModel dish) async {
    await _db.from('dishes').insert(dish.toJson());
    await fetchDishes();
  }

  Future<void> updateDish(DishModel dish) async {
    await _db.from('dishes').update(dish.toJson()).eq('id', dish.id);
    await fetchDishes();
  }

  Future<void> deleteDish(String id) async {
    await _db.from('dishes').delete().eq('id', id);
    state = state.copyWith(dishes: state.dishes.where((d) => d.id != id).toList());
  }
}

final adminDishesNotifierProvider =
    NotifierProvider<AdminDishesNotifier, AdminDishesState>(AdminDishesNotifier.new);
