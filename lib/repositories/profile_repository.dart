import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_delivery/models/address_model.dart';
import 'package:food_delivery/models/payment_method_model.dart';
import 'package:food_delivery/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileRepository {
  final _db = Supabase.instance.client;

  Future<UserModel> getProfile() async {
    final authUser = _db.auth.currentUser;
    if (authUser == null) throw Exception('Not logged in');
    final userId = authUser.id;
    final metaName = authUser.userMetadata?['full_name'] as String? ?? '';
    final email = authUser.email ?? '';

    final data =
        await _db.from('profiles').select().eq('id', userId).maybeSingle();

    final ordersList = await _db
        .from('orders')
        .select('id')
        .eq('user_id', userId);

    final favList = await _db
        .from('favorites')
        .select('dish_id')
        .eq('user_id', userId)
        .eq('type', 'dish');

    final favDishIds = (favList as List)
        .map((e) => e['dish_id'] as String?)
        .whereType<String>()
        .toList();

    int favCount = 0;
    if (favDishIds.isNotEmpty) {
      final existing = await _db
          .from('dishes')
          .select('id')
          .filter('id', 'in', '(${favDishIds.join(',')})');
      favCount = (existing as List).length;
    }

    final ordersCount = ordersList.length;
    final points = ordersCount * 50;

    if (data == null) {
      // Trigger didn't create the row — upsert from auth metadata.
      try {
        await _db.from('profiles').upsert({
          'id': userId,
          'full_name': metaName,
          'email': email,
        });
      } catch (_) {}
      return UserModel(
        id: userId,
        fullName: metaName,
        email: email,
        phone: '',
        totalOrders: ordersCount,
        favoriteCount: favCount,
        points: points,
      );
    }

    var user = UserModel.fromJson(data);

    // Row exists but name is blank — patch from auth metadata.
    if (user.fullName.isEmpty && metaName.isNotEmpty) {
      try {
        await _db
            .from('profiles')
            .update({'full_name': metaName})
            .eq('id', userId);
      } catch (_) {}
      user = user.copyWith(fullName: metaName);
    }

    // Override with live counts — profiles table columns are never updated.
    return user.copyWith(
      totalOrders: ordersCount,
      favoriteCount: favCount,
      points: points,
    );
  }

  Future<UserModel> updateProfile({
    required String name,
    required String phone,
    String? avatarUrl,
  }) async {
    final userId = _db.auth.currentUser?.id;
    if (userId == null) throw Exception('Not logged in');
    final data = await _db
        .from('profiles')
        .update({
          'full_name': name,
          'phone': phone,
          'avatar_url': avatarUrl,
        })
        .eq('id', userId)
        .select()
        .single();
    return UserModel.fromJson(data);
  }

  Future<List<AddressModel>> getSavedAddresses() async {
    final userId = _db.auth.currentUser?.id;
    if (userId == null) return [];
    final data = await _db
        .from('addresses')
        .select()
        .eq('user_id', userId)
        .order('is_default', ascending: false);
    return (data as List).map((e) => AddressModel.fromJson(e)).toList();
  }

  Future<void> addAddress(AddressModel address) async {
    final userId = _db.auth.currentUser?.id;
    if (userId == null) return;
    final payload = Map<String, dynamic>.from(address.toJson())
      ..remove('id') // let Supabase generate the UUID
      ..['user_id'] = userId;
    await _db.from('addresses').insert(payload);
  }

  Future<void> setDefaultAddress(String addressId) async {
    final userId = _db.auth.currentUser?.id;
    if (userId == null) return;
    await _db
        .from('addresses')
        .update({'is_default': false})
        .eq('user_id', userId);
    await _db
        .from('addresses')
        .update({'is_default': true})
        .eq('id', addressId);
  }

  Future<void> deleteAddress(String addressId) async {
    await _db.from('addresses').delete().eq('id', addressId);
  }

  Future<List<PaymentMethodModel>> getPaymentMethods() async {
    final userId = _db.auth.currentUser?.id;
    if (userId == null) return [];
    final data = await _db
        .from('payment_methods')
        .select()
        .eq('user_id', userId);
    return (data as List).map((e) => PaymentMethodModel.fromJson(e)).toList();
  }

  Future<void> addPaymentMethod(PaymentMethodModel method) async {
    final userId = _db.auth.currentUser?.id;
    if (userId == null) return;
    final payload = Map<String, dynamic>.from(method.toJson())
      ..remove('id') // let Supabase generate the UUID
      ..['user_id'] = userId;
    await _db.from('payment_methods').insert(payload);
  }

  Future<void> setDefaultPayment(String paymentId) async {
    final userId = _db.auth.currentUser?.id;
    if (userId == null) return;
    await _db
        .from('payment_methods')
        .update({'is_default': false})
        .eq('user_id', userId);
    await _db
        .from('payment_methods')
        .update({'is_default': true})
        .eq('id', paymentId);
  }

  Future<void> deletePaymentMethod(String paymentId) async {
    await _db.from('payment_methods').delete().eq('id', paymentId);
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>((_) => ProfileRepository());
