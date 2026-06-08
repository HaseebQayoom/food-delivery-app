import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_delivery/models/category_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminCategoriesState {
  final List<CategoryModel> categories;
  final String searchQuery;
  final bool isLoading;
  final String? error;

  const AdminCategoriesState({
    this.categories = const [],
    this.searchQuery = '',
    this.isLoading = false,
    this.error,
  });

  List<CategoryModel> get filteredCategories {
    if (searchQuery.isEmpty) return categories;
    return categories
        .where((c) => c.name.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  AdminCategoriesState copyWith({
    List<CategoryModel>? categories,
    String? searchQuery,
    bool? isLoading,
    String? error,
  }) {
    return AdminCategoriesState(
      categories: categories ?? this.categories,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AdminCategoriesNotifier extends Notifier<AdminCategoriesState> {
  final _db = Supabase.instance.client;

  @override
  AdminCategoriesState build() {
    Future.microtask(fetchCategories);
    return const AdminCategoriesState(isLoading: true);
  }

  Future<void> fetchCategories() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _db.from('categories').select().order('name');
      state = AdminCategoriesState(
        categories: (data as List).map((e) => CategoryModel.fromJson(e)).toList(),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to load categories.');
    }
  }

  void setSearch(String query) => state = state.copyWith(searchQuery: query);

  Future<void> addCategory(CategoryModel cat) async {
    await _db.from('categories').insert(cat.toJson());
    await fetchCategories();
  }

  Future<void> updateCategory(CategoryModel cat) async {
    await _db.from('categories').update(cat.toJson()).eq('id', cat.id);
    await fetchCategories();
  }

  Future<void> deleteCategory(String id) async {
    await _db.from('categories').delete().eq('id', id);
    state = state.copyWith(
      categories: state.categories.where((c) => c.id != id).toList(),
    );
  }
}

final adminCategoriesNotifierProvider =
    NotifierProvider<AdminCategoriesNotifier, AdminCategoriesState>(
        AdminCategoriesNotifier.new);

// Preset colors for the category color picker
const categoryPresetColors = [
  Color(0xFFFFE8DC),
  Color(0xFFFFEBEB),
  Color(0xFFE8F4E5),
  Color(0xFFE8F0FF),
  Color(0xFFF5E8F8),
  Color(0xFFFFF1D6),
];
