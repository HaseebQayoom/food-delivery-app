import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_delivery/features/home/home_screen.dart';
import 'package:food_delivery/features/favorites/favorites_screen.dart';
import 'package:food_delivery/features/cart/cart_screen.dart';
import 'package:food_delivery/features/chat/chat_screen.dart';
import 'package:food_delivery/features/profile/profile_screen.dart';
import 'package:food_delivery/features/favorites/providers/favorites_notifier.dart';
import 'package:food_delivery/features/profile/providers/profile_notifier.dart';
import 'package:food_delivery/core/widgets/custom_bottom_nav_bar.dart';

class ShellScreen extends ConsumerStatefulWidget {
  const ShellScreen({super.key});

  @override
  ConsumerState<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends ConsumerState<ShellScreen> {
  int _currentIndex = 0;

  static const _screens = [
    HomeScreen(),
    FavoritesScreen(),
    CartScreen(),
    ChatScreen(),
    ProfileScreen(),
  ];

  void _onTabTap(int index) {
    setState(() => _currentIndex = index);
    if (index == 1) {
      ref.read(favoritesNotifierProvider.notifier).fetchFavorites();
    }
    if (index == 4) {
      ref.read(profileNotifierProvider.notifier).fetchProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTap,
      ),
    );
  }
}
