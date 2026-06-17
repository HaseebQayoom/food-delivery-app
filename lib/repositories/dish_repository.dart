import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_delivery/models/dish_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DishRepository {
  final _db = Supabase.instance.client;

  Future<List<DishModel>> getPopularDishes() async {
    final data = await _db.from('dishes').select().limit(20);
    return (data as List).map((e) => DishModel.fromJson(e)).toList();
  }

  Future<List<DishModel>> getDishesByCategory(String categoryId) async {
    final data = await _db
        .from('dishes')
        .select()
        .eq('category_id', categoryId);
    return (data as List).map((e) => DishModel.fromJson(e)).toList();
  }

  Future<List<DishModel>> getDishesByRestaurant(String restaurantId) async {
    final data = await _db
        .from('dishes')
        .select()
        .eq('restaurant_id', restaurantId);
    return (data as List).map((e) => DishModel.fromJson(e)).toList();
  }

  Future<List<DishModel>> getPopularDishesByRestaurant(String restaurantId) async {
    final data = await _db
        .from('dishes')
        .select()
        .eq('restaurant_id', restaurantId)
        .eq('popular', true)
        .limit(10);
    return (data as List).map((e) => DishModel.fromJson(e)).toList();
  }

  Future<List<DishModel>> getAllDishesByRestaurant(String restaurantId) async {
    final data = await _db
        .from('dishes')
        .select()
        .eq('restaurant_id', restaurantId)
        .eq('is_available', true)
        .order('category_id');
    return (data as List).map((e) => DishModel.fromJson(e)).toList();
  }

  Future<List<DishModel>> getFavoriteDishes() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return [];
    final data = await _db
        .from('favorites')
        .select('dishes(*)')
        .eq('user_id', userId)
        .eq('type', 'dish');
    return (data as List)
        .map((e) => DishModel.fromJson(e['dishes']))
        .toList();
  }

  Future<void> toggleFavoriteDish(String dishId) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    final existing = await _db
        .from('favorites')
        .select()
        .eq('user_id', userId)
        .eq('dish_id', dishId)
        .maybeSingle();
    if (existing != null) {
      await _db
          .from('favorites')
          .delete()
          .eq('user_id', userId)
          .eq('dish_id', dishId);
    } else {
      await _db.from('favorites').insert({
        'user_id': userId,
        'dish_id': dishId,
        'type': 'dish',
      });
    }
  }

  // ─── Admin methods ────────────────────────────────────────

  Future<List<DishModel>> getAllDishes() async {
    final data = await _db
        .from('dishes')
        .select()
        .order('created_at', ascending: false);
    return (data as List).map((e) => DishModel.fromJson(e)).toList();
  }

  Future<void> toggleAvailability(String dishId, bool newValue) async {
    await _db
        .from('dishes')
        .update({'is_available': newValue})
        .eq('id', dishId);
  }

  Future<void> togglePopular(String dishId, bool newValue) async {
    await _db
        .from('dishes')
        .update({'popular': newValue})
        .eq('id', dishId);
  }

  Future<void> deleteDish(String dishId) async {
    await _db.from('dishes').delete().eq('id', dishId);
  }

  Future<DishModel> createDish(Map<String, dynamic> fields) async {
    final data = await _db
        .from('dishes')
        .insert(fields)
        .select()
        .single();
    return DishModel.fromJson(data);
  }

  Future<DishModel> updateDish(String dishId, Map<String, dynamic> fields) async {
    final data = await _db
        .from('dishes')
        .update(fields)
        .eq('id', dishId)
        .select()
        .single();
    return DishModel.fromJson(data);
  }
}

final dishRepositoryProvider = Provider<DishRepository>((_) => DishRepository());
