import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_delivery/models/restaurant_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RestaurantRepository {
  final _db = Supabase.instance.client;

  Future<List<RestaurantModel>> getPopularRestaurants() async {
    final data = await _db
        .from('restaurants')
        .select()
        .order('rating', ascending: false)
        .limit(20);
    return (data as List).map((e) => RestaurantModel.fromJson(e)).toList();
  }

  Future<List<RestaurantModel>> searchRestaurants(String query) async {
    final data = await _db
        .from('restaurants')
        .select()
        .ilike('name', '%$query%');
    return (data as List).map((e) => RestaurantModel.fromJson(e)).toList();
  }

  Future<RestaurantModel> getRestaurantById(String id) async {
    final data = await _db.from('restaurants').select().eq('id', id).single();
    return RestaurantModel.fromJson(data);
  }

  Future<RestaurantModel> getFirstRestaurant() async {
    final data = await _db
        .from('restaurants')
        .select()
        .limit(1)
        .single();
    return RestaurantModel.fromJson(data);
  }

  Future<List<RestaurantModel>> getFavoriteRestaurants() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return [];
    final data = await _db
        .from('favorites')
        .select('restaurants(*)')
        .eq('user_id', userId)
        .eq('type', 'restaurant');
    return (data as List)
        .map((e) => RestaurantModel.fromJson(e['restaurants']))
        .toList();
  }

  Future<void> toggleFavorite(String restaurantId) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    final existing = await _db
        .from('favorites')
        .select()
        .eq('user_id', userId)
        .eq('restaurant_id', restaurantId)
        .maybeSingle();
    if (existing != null) {
      await _db
          .from('favorites')
          .delete()
          .eq('user_id', userId)
          .eq('restaurant_id', restaurantId);
    } else {
      await _db.from('favorites').insert({
        'user_id': userId,
        'restaurant_id': restaurantId,
        'type': 'restaurant',
      });
    }
  }
}

final restaurantRepositoryProvider = Provider<RestaurantRepository>((_) => RestaurantRepository());
