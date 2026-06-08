import 'package:flutter/material.dart';
import 'package:food_delivery/features/home/home_screen.dart';
import 'package:food_delivery/features/favorites/favorites_screen.dart';
import 'package:food_delivery/features/cart/cart_screen.dart';
import 'package:food_delivery/features/chat/chat_screen.dart';
import 'package:food_delivery/features/profile/profile_screen.dart';
import 'package:food_delivery/core/widgets/custom_bottom_nav_bar.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    FavoritesScreen(),
    CartScreen(),
    ChatScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
