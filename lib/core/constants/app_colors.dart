import 'package:flutter/material.dart';

// Only define colors here that have NO equivalent in the seed-generated ColorScheme.
// For all standard colors, use Theme.of(context).colorScheme.X in widgets.
class AppColors {
  AppColors._();

  // Gradient colors (no direct ColorScheme equivalent)
  static const Color primaryGradientStart = Colors.deepOrange;
  static const Color primaryGradientEnd = Colors.deepOrangeAccent;

  // Status colors (not part of standard Material 3 scheme)
  static const Color success = Color(0xFF2DBE60);
  static const Color warning = Color(0xFFFFB400);

  // Admin status pill — exact JSX statusMeta values
  static const Color statusNewBg = Color(0xFFE1F0FF);
  static const Color statusNewFg = Color(0xFF2563EB);
  static const Color statusPreparingBg = Color(0xFFFFF1D6);
  static const Color statusPreparingFg = Color(0xFFB7791F);
  static const Color statusDeliveredBg = Color(0xFFE2F6E9);
  static const Color statusDeliveredFg = Color(0xFF1F8A4C);
  static const Color statusCancelledBg = Color(0xFFFBEAEA);
  static const Color statusCancelledFg = Color(0xFFDC2626);

  // Admin misc
  static const Color switchOff = Color(0xFFD8D0C6);
  static const Color tagSpicy = Color(0xFFE14B3B);
  static const Color adminBackground = Color(0xFFF7F4EF);
  static const Color storeOpenBorder = Color(0xFFBFE8CD);
}

class AppGradients {
  AppGradients._();

  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primaryGradientStart, AppColors.primaryGradientEnd],
  );
}
