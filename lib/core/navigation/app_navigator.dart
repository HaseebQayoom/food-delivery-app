import 'package:flutter/material.dart';
import 'package:food_delivery/features/auth/auth_screen.dart';
import 'package:food_delivery/features/cart/cart_screen.dart';
import 'package:food_delivery/features/chat/chat_screen.dart';
import 'package:food_delivery/features/checkout/checkout_screen.dart';
import 'package:food_delivery/features/onboarding/onboarding_screen.dart';
import 'package:food_delivery/features/orders/order_history_screen.dart';
import 'package:food_delivery/features/orders/order_success_screen.dart';
import 'package:food_delivery/features/profile/address/address_screen.dart';
import 'package:food_delivery/features/profile/edit/edit_profile_screen.dart';
import 'package:food_delivery/features/profile/invite/invite_screen.dart';
import 'package:food_delivery/features/profile/notifications/notifications_screen.dart';
import 'package:food_delivery/features/profile/payment/payment_screen.dart';
import 'package:food_delivery/features/profile/preferences/preferences_screen.dart';
import 'package:food_delivery/features/restaurant/restaurant_detail_screen.dart';
import 'package:food_delivery/features/shell/shell_screen.dart';
import 'package:food_delivery/features/tracking/tracking_screen.dart';
import 'package:food_delivery/models/order_model.dart';

// Centralises all navigation so screens never call Navigator.push directly.
// Usage:  AppNavigator.toHome(context);
class AppNavigator {
  AppNavigator._();

  // Splash → Onboarding  (one-way, no back)
  static void toOnboarding(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const OnboardingScreen()),
    );
  }

  // Onboarding / Splash → Auth  (one-way, no back)
  static void toAuth(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AuthScreen()),
    );
  }

  // Auth → Home shell  (clears entire back stack — user cannot go back to auth)
  static void toHome(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const ShellScreen()),
      (route) => false,
    );
  }

  // Home → Checkout  (push on top, user can go back)
  static void toCheckout(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CheckoutScreen()),
    );
  }

  // Checkout → Order Tracking  (push on top)
  static void toTracking(BuildContext context, {required String orderId}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TrackingScreen(orderId: orderId)),
    );
  }

  // Home → Restaurant Detail  (push on top)
  static void toRestaurantDetail(BuildContext context, {required String restaurantId}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RestaurantDetailScreen(restaurantId: restaurantId)),
    );
  }

  // Anywhere → Cart  (push on top)
  static void toCart(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CartScreen()),
    );
  }

  // Anywhere → Chat Support  (push on top)
  static void toChat(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ChatScreen()),
    );
  }

  // Checkout → Order Success
  static void toOrderSuccess(BuildContext context, {required OrderModel order}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => OrderSuccessScreen(order: order)),
    );
  }

  // Profile → Order History
  static void toOrderHistory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
    );
  }

  // Profile → Saved Addresses
  static void toAddresses(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddressScreen()),
    );
  }

  // Profile → Payment Methods
  static void toPaymentMethods(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PaymentScreen()),
    );
  }

  // Profile → Edit Profile
  static void toEditProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
    );
  }

  // Profile → Notifications
  static void toNotifications(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
    );
  }

  // Profile → Invite & Earn
  static void toInvite(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const InviteScreen()),
    );
  }

  // Profile → Preferences
  static void toPreferences(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PreferencesScreen()),
    );
  }

  // Generic pop — use instead of Navigator.pop directly for consistency
  static void back(BuildContext context) => Navigator.pop(context);
}
