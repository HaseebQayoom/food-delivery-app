import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_delivery/models/address_model.dart';
import 'package:food_delivery/models/payment_method_model.dart';
import 'package:food_delivery/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileRepository {
  final _db = Supabase.instance.client;

  Future<UserModel> getProfile() async {
    final userId = _db.auth.currentUser?.id;
    if (userId == null) throw Exception('Not logged in');
    final data = await _db.from('profiles').select().eq('id', userId).single();
    return UserModel.fromJson(data);
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
    await _db.from('addresses').insert({
      ...address.toJson(),
      'user_id': userId,
    });
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
    await _db.from('payment_methods').insert({
      ...method.toJson(),
      'user_id': userId,
    });
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
