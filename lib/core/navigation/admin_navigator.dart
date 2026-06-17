import 'package:flutter/material.dart';
import 'package:food_delivery/features/admin/shell/admin_shell_screen.dart';

class AdminNavigator {
  AdminNavigator._();

  static void toAdminDashboard(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AdminShellScreen()),
      (route) => false,
    );
  }

  static void back(BuildContext context) => Navigator.pop(context);
}
