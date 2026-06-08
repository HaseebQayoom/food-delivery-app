import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_delivery/core/navigation/admin_navigator.dart';
import 'package:food_delivery/features/admin/auth/admin_auth_notifier.dart';
import 'package:food_delivery/features/admin/categories/category_list_screen.dart';
import 'package:food_delivery/features/admin/dashboard/dashboard_screen.dart';
import 'package:food_delivery/features/admin/dishes/dish_list_screen.dart';
import 'package:food_delivery/features/admin/orders/order_list_screen.dart';

class AdminShellScreen extends ConsumerStatefulWidget {
  const AdminShellScreen({super.key});

  @override
  ConsumerState<AdminShellScreen> createState() => _AdminShellScreenState();
}

class _AdminShellScreenState extends ConsumerState<AdminShellScreen> {
  int _index = 0;

  final _screens = const [
    DashboardScreen(),
    DishListScreen(),
    CategoryListScreen(),
    OrderListScreen(),
  ];

  final _labels = ['Dashboard', 'Dishes', 'Categories', 'Orders'];
  final _icons = [
    Icons.dashboard_rounded,
    Icons.restaurant_menu_rounded,
    Icons.category_rounded,
    Icons.receipt_long_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 600;

        return Scaffold(
          appBar: AppBar(
            title: Text('crave. Admin', style: tt.titleLarge!.copyWith(color: cs.primary)),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout_rounded),
                tooltip: 'Logout',
                onPressed: () async {
                  await ref.read(adminAuthNotifierProvider.notifier).logout();
                  if (context.mounted) AdminNavigator.toAdminLogin(context);
                },
              ),
            ],
          ),
          body: isWide
              ? Row(
                  children: [
                    NavigationRail(
                      selectedIndex: _index,
                      onDestinationSelected: (i) => setState(() => _index = i),
                      labelType: NavigationRailLabelType.all,
                      destinations: List.generate(
                        _labels.length,
                        (i) => NavigationRailDestination(
                          icon: Icon(_icons[i]),
                          label: Text(_labels[i]),
                        ),
                      ),
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(child: IndexedStack(index: _index, children: _screens)),
                  ],
                )
              : IndexedStack(index: _index, children: _screens),
          bottomNavigationBar: isWide
              ? null
              : NavigationBar(
                  selectedIndex: _index,
                  onDestinationSelected: (i) => setState(() => _index = i),
                  destinations: List.generate(
                    _labels.length,
                    (i) => NavigationDestination(icon: Icon(_icons[i]), label: _labels[i]),
                  ),
                ),
        );
      },
    );
  }
}
