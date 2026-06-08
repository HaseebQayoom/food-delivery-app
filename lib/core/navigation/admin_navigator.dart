import 'package:flutter/material.dart';
import 'package:food_delivery/features/admin/auth/admin_login_screen.dart';
import 'package:food_delivery/features/admin/categories/category_form_screen.dart';
import 'package:food_delivery/features/admin/dishes/dish_form_screen.dart';
import 'package:food_delivery/features/admin/orders/order_detail_screen.dart';
import 'package:food_delivery/features/admin/shell/admin_shell_screen.dart';
import 'package:food_delivery/models/category_model.dart';
import 'package:food_delivery/models/dish_model.dart';

class AdminNavigator {
  AdminNavigator._();

  static void toAdminLogin(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
      (route) => false,
    );
  }

  static void toAdminDashboard(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AdminShellScreen()),
      (route) => false,
    );
  }

  static void toAdminDishForm(BuildContext context, {DishModel? dish}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DishFormScreen(dish: dish)),
    );
  }

  static void toCategoryForm(BuildContext context, {CategoryModel? category}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CategoryFormScreen(category: category)),
    );
  }

  static void toOrderDetail(BuildContext context, {required String orderId}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: orderId)),
    );
  }

  static void back(BuildContext context) => Navigator.pop(context);
}
