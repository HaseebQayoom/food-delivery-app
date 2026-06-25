import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:food_delivery/core/constants/env.dart';

class StripeService {
  StripeService._();

  static final _dio = Dio();

  static final _headers = {
    'Authorization': 'Bearer ${Env.stripeSecretKey}',
    'Content-Type': 'application/x-www-form-urlencoded',
  };

  /// Charges [amountRs]. If both IDs are provided the card is confirmed
  /// silently (no UI). Otherwise presents the full payment sheet.
  /// Throws [StripeException] if the user cancels, or [Exception] on failure.
  static Future<void> processPayment({
    required int amountRs,
    String? stripePaymentMethodId,
    String? stripeCustomerId,
  }) async {
    if (stripePaymentMethodId != null && stripeCustomerId != null) {
      await _confirmWithSavedCard(amountRs, stripePaymentMethodId, stripeCustomerId);
    } else {
      final clientSecret = await _createPaymentIntent(amountRs);
      await _initPaymentSheet(clientSecret);
      await Stripe.instance.presentPaymentSheet();
    }
  }

  /// Opens the Stripe card form WITHOUT charging — saves the card.
  /// Creates a Stripe Customer, attaches the PM to it, then returns
  /// (lastFour, stripePaymentMethodId, stripeCustomerId).
  /// Throws [StripeException] if the user cancels.
  static Future<({
    String? lastFour,
    String? stripePaymentMethodId,
    String? stripeCustomerId,
  })> setupCard() async {
    const empty = (lastFour: null, stripePaymentMethodId: null, stripeCustomerId: null);

    // 1. Create a Stripe Customer to attach the card to
    final custRes = await _dio.post(
      'https://api.stripe.com/v1/customers',
      options: Options(headers: _headers),
    );
    final customerId = custRes.data['id'] as String;

    // 2. Create a SetupIntent tied to the customer
    final siRes = await _dio.post(
      'https://api.stripe.com/v1/setup_intents',
      data: 'payment_method_types[]=card&customer=$customerId',
      options: Options(headers: _headers),
    );
    final setupIntentId = siRes.data['id'] as String;
    final clientSecret = siRes.data['client_secret'] as String;

    // 3. Present the card form
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        setupIntentClientSecret: clientSecret,
        merchantDisplayName: 'crave.',
        style: ThemeMode.system,
        appearance: const PaymentSheetAppearance(
          colors: PaymentSheetAppearanceColors(primary: Color(0xFFFF5A1F)),
        ),
      ),
    );
    await Stripe.instance.presentPaymentSheet();

    // 4. Retrieve PM ID + last4 from the completed SetupIntent
    try {
      final siResult = await _dio.get(
        'https://api.stripe.com/v1/setup_intents/$setupIntentId',
        options: Options(headers: {'Authorization': 'Bearer ${Env.stripeSecretKey}'}),
      );
      final pmId = siResult.data['payment_method'] as String?;
      if (pmId == null) return empty;

      final pmResult = await _dio.get(
        'https://api.stripe.com/v1/payment_methods/$pmId',
        options: Options(headers: {'Authorization': 'Bearer ${Env.stripeSecretKey}'}),
      );
      final lastFour = pmResult.data['card']?['last4'] as String?;
      return (lastFour: lastFour, stripePaymentMethodId: pmId, stripeCustomerId: customerId);
    } catch (_) {
      return empty;
    }
  }

  static Future<void> _confirmWithSavedCard(
    int amountRs,
    String pmId,
    String customerId,
  ) async {
    final response = await _dio.post(
      'https://api.stripe.com/v1/payment_intents',
      data: 'amount=${amountRs * 100}&currency=pkr'
          '&payment_method_types[]=card'
          '&customer=$customerId'
          '&payment_method=$pmId'
          '&confirm=true',
      options: Options(headers: _headers),
    );
    final status = response.data['status'] as String;
    if (status != 'succeeded') {
      throw Exception('Payment failed: $status');
    }
  }

  static Future<String> _createPaymentIntent(int amountRs) async {
    final response = await _dio.post(
      'https://api.stripe.com/v1/payment_intents',
      data: 'amount=${amountRs * 100}&currency=pkr&payment_method_types[]=card',
      options: Options(headers: _headers),
    );
    return response.data['client_secret'] as String;
  }

  static Future<void> _initPaymentSheet(String clientSecret) async {
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: 'crave.',
        style: ThemeMode.system,
        appearance: const PaymentSheetAppearance(
          colors: PaymentSheetAppearanceColors(primary: Color(0xFFFF5A1F)),
        ),
      ),
    );
  }
}
