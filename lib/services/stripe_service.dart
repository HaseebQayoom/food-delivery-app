import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:food_delivery/core/constants/env.dart';

class StripeService {
  StripeService._();

  static final _dio = Dio();

  /// Presents the Stripe payment sheet and charges [amountRs].
  /// Throws [StripeException] if the user cancels or payment fails.
  /// Throws [Exception] on network/API errors.
  static Future<void> processPayment({required int amountRs}) async {
    final clientSecret = await _createPaymentIntent(amountRs);
    await _initPaymentSheet(clientSecret);
    await Stripe.instance.presentPaymentSheet();
  }

  static Future<String> _createPaymentIntent(int amountRs) async {
    final response = await _dio.post(
      'https://api.stripe.com/v1/payment_intents',
      // Stripe PKR amounts are in paisa (1 Rs = 100 paisa)
      data: 'amount=${amountRs * 100}&currency=pkr',
      options: Options(
        headers: {
          'Authorization': 'Bearer ${Env.stripeSecretKey}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      ),
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
