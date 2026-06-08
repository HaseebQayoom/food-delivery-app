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
}

class AppGradients {
  AppGradients._();

  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primaryGradientStart, AppColors.primaryGradientEnd],
  );
}
