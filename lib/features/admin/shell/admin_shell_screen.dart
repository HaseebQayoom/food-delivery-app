import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_delivery/core/constants/app_colors.dart';
import 'package:food_delivery/core/constants/app_dimensions.dart';
import 'package:food_delivery/core/navigation/app_navigator.dart';
import 'package:food_delivery/features/admin/dishes/admin_dishes_notifier.dart';
import 'package:food_delivery/features/admin/menu/admin_menu_screen.dart';
import 'package:food_delivery/features/admin/menu/meal_editor_drawer.dart';
import 'package:food_delivery/features/admin/orders/admin_orders_notifier.dart';
import 'package:food_delivery/features/admin/orders/admin_orders_screen.dart';
import 'package:food_delivery/features/admin/widgets/notifications_panel.dart';
import 'package:food_delivery/models/order_model.dart';
import 'package:food_delivery/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminShellScreen extends ConsumerStatefulWidget {
  const AdminShellScreen({super.key});

  @override
  ConsumerState<AdminShellScreen> createState() => _AdminShellScreenState();
}

class _AdminShellScreenState extends ConsumerState<AdminShellScreen> {
  int _tabIndex = 0;
  bool _showNotif = false; // desktop notifications overlay

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      ref.read(adminOrdersProvider.notifier).fetchOrders();
      ref.read(adminDishesProvider.notifier).fetchDishes();
    });
  }

  Future<void> _logout() async {
    await Supabase.instance.client.auth.signOut();
    if (!mounted) return;
    AppNavigator.toAuth(context);
  }

  void _showMobileNotifications() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => NotificationsPanel(onClose: () => Navigator.pop(context)),
    );
  }

  String get _tab => _tabIndex == 0 ? 'orders' : 'menu';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ac = Theme.of(context).extension<AppThemeColors>()!;
    final dishesState = ref.watch(adminDishesProvider);
    final ordersState = ref.watch(adminOrdersProvider);
    final newOrderCount = ordersState.orders
        .where((o) => o.status == OrderStatus.newOrder)
        .length;

    final drawerOpen = dishesState.editingDishId != null;

    Widget drawerBackdrop = Positioned.fill(
      child: GestureDetector(
        onTap: () => ref.read(adminDishesProvider.notifier).closeEditor(),
        behavior: HitTestBehavior.opaque,
        child: ColoredBox(color: Colors.black.withValues(alpha: 0.32)),
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 600;

        // ── Desktop layout ─────────────────────────────────────────────
        if (isDesktop) {
          return Scaffold(
            backgroundColor: AppColors.adminBackground,
            body: Stack(
              children: [
                Row(
                  children: [
                    _AdminSidebar(
                      activeTab: _tab,
                      onTabSelected: (t) => setState(
                          () => _tabIndex = t == 'orders' ? 0 : 1),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          _AdminTopBar(
                            tab: _tab,
                            showNotif: _showNotif,
                            onBellTap: () =>
                                setState(() => _showNotif = !_showNotif),
                          ),
                          Expanded(
                            child: ColoredBox(
                              color: AppColors.adminBackground,
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(28, 24, 28, 24),
                                child: IndexedStack(
                                  index: _tabIndex,
                                  children: const [
                                    AdminOrdersScreen(),
                                    AdminMenuScreen(),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Desktop notifications overlay
                if (_showNotif) ...[
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () => setState(() => _showNotif = false),
                      behavior: HitTestBehavior.translucent,
                    ),
                  ),
                  Positioned(
                    top: 76,
                    right: 0,
                    child: NotificationsPanel(
                        onClose: () => setState(() => _showNotif = false)),
                  ),
                ],
                // Desktop drawer (440px from right)
                if (drawerOpen) ...[
                  drawerBackdrop,
                  Positioned(
                    top: 0,
                    bottom: 0,
                    right: 0,
                    child: SizedBox(
                      width: 440,
                      child: MealEditorDrawer(
                        key: ValueKey(dishesState.editingDishId),
                        dishId: dishesState.editingDishId!,
                        onClose: () => ref
                            .read(adminDishesProvider.notifier)
                            .closeEditor(),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        }

        // ── Mobile layout ──────────────────────────────────────────────
        final isMenu = _tabIndex == 1;

        return Scaffold(
          backgroundColor: AppColors.adminBackground,
          appBar: AppBar(
            backgroundColor: ac.navbarBackground,
            toolbarHeight: 64,
            titleSpacing: AppDimensions.md,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isMenu ? 'Menu' : 'Orders',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    height: 1.1,
                  ),
                ),
                Text(
                  isMenu
                      ? '${dishesState.dishes.length} items · ${dishesState.availableCount} available'
                      : 'Manage incoming orders',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
            actions: [
              if (isMenu)
                Padding(
                  padding: const EdgeInsets.only(right: AppDimensions.xs),
                  child: GestureDetector(
                    onTap: () => ref
                        .read(adminDishesProvider.notifier)
                        .openEditor('new'),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: cs.primary,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusXs),
                      ),
                      child: const Icon(Icons.add, color: Colors.white, size: 18),
                    ),
                  ),
                ),
              Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.notifications_outlined,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                    onPressed: _showMobileNotifications,
                  ),
                  Positioned(
                    top: 12,
                    right: 10,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: cs.primary,
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: ac.navbarBackground, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(Icons.logout,
                    size: 20, color: Colors.white.withValues(alpha: 0.7)),
                onPressed: _logout,
              ),
              const SizedBox(width: AppDimensions.xs),
            ],
          ),
          body: Stack(
            children: [
              IndexedStack(
                index: _tabIndex,
                children: const [
                  Padding(
                    padding: EdgeInsets.all(AppDimensions.md),
                    child: AdminOrdersScreen(),
                  ),
                  Padding(
                    padding: EdgeInsets.all(AppDimensions.md),
                    child: AdminMenuScreen(),
                  ),
                ],
              ),
              // Mobile drawer (full screen)
              if (drawerOpen) ...[
                drawerBackdrop,
                Positioned.fill(
                  child: MealEditorDrawer(
                    key: ValueKey(dishesState.editingDishId),
                    dishId: dishesState.editingDishId!,
                    onClose: () =>
                        ref.read(adminDishesProvider.notifier).closeEditor(),
                  ),
                ),
              ],
            ],
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: ac.navbarBackground,
              border: Border(
                  top: BorderSide(
                      color: Colors.white.withValues(alpha: 0.08))),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.md, vertical: AppDimensions.sm),
                child: Row(
                  children: [
                    _BottomNavItem(
                      icon: Icons.receipt_long_outlined,
                      label: 'Orders',
                      active: _tabIndex == 0,
                      badge: newOrderCount,
                      cs: cs,
                      onTap: () => setState(() => _tabIndex = 0),
                    ),
                    _BottomNavItem(
                      icon: Icons.kitchen_outlined,
                      label: 'Menu',
                      active: _tabIndex == 1,
                      cs: cs,
                      onTap: () => setState(() => _tabIndex = 1),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Mobile bottom nav item ─────────────────────────────────────────────────

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final int badge;
  final ColorScheme cs;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.active,
    this.badge = 0,
    required this.cs,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active
                ? cs.primary.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Icon(icon,
                      size: 22,
                      color: active
                          ? cs.primary
                          : Colors.white.withValues(alpha: 0.55)),
                  if (badge > 0)
                    Positioned(
                      top: -5,
                      right: -10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: cs.primary,
                          borderRadius: BorderRadius.circular(
                              AppDimensions.radiusCircle),
                          border:
                              Border.all(color: Colors.black, width: 1.5),
                        ),
                        child: Text(
                          '$badge',
                          style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  color: active
                      ? cs.primary
                      : Colors.white.withValues(alpha: 0.55),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Desktop sidebar ────────────────────────────────────────────────────────

class _AdminSidebar extends ConsumerWidget {
  final String activeTab;
  final ValueChanged<String> onTabSelected;

  const _AdminSidebar(
      {required this.activeTab, required this.onTabSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final ac = Theme.of(context).extension<AppThemeColors>()!;
    final ordersState = ref.watch(adminOrdersProvider);
    final newOrderCount = ordersState.orders
        .where((o) => o.status == OrderStatus.newOrder)
        .length;
    final user = Supabase.instance.client.auth.currentUser;
    final email = user?.email ?? '';
    final initial = email.isNotEmpty ? email[0].toUpperCase() : 'A';
    final displayName = email.split('@').first;

    return Container(
      width: 248,
      color: ac.navbarBackground,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 24),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: cs.primary,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusSm),
                  ),
                  alignment: Alignment.center,
                  child: const Text('S',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                ),
                const SizedBox(width: 11),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Smoke & Stack',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -0.3)),
                    Text('Merchant console',
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.45))),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: Text('MANAGE',
                style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: 0.35),
                    letterSpacing: 0.6)),
          ),
          _NavItem(
            id: 'orders',
            icon: Icons.receipt_long_outlined,
            label: 'Orders',
            badge: newOrderCount > 0 ? newOrderCount : null,
            active: activeTab == 'orders',
            cs: cs,
            onTap: () => onTabSelected('orders'),
          ),
          const SizedBox(height: 4),
          _NavItem(
            id: 'menu',
            icon: Icons.kitchen_outlined,
            label: 'Menu',
            active: activeTab == 'menu',
            cs: cs,
            onTap: () => onTabSelected('menu'),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
            child: Row(
              children: [
                Icon(Icons.settings_outlined,
                    size: 19,
                    color: Colors.white.withValues(alpha: 0.65)),
                const SizedBox(width: 12),
                Text('Settings',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.65))),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                      color: cs.primary, shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: Text(initial,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(displayName,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      Text('Manager',
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.45))),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    await Supabase.instance.client.auth.signOut();
                    if (context.mounted) AppNavigator.toAuth(context);
                  },
                  child: Icon(Icons.logout,
                      size: 17,
                      color: Colors.white.withValues(alpha: 0.5)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String id;
  final IconData icon;
  final String label;
  final int? badge;
  final bool active;
  final ColorScheme cs;
  final VoidCallback onTap;

  const _NavItem({
    required this.id,
    required this.icon,
    required this.label,
    this.badge,
    required this.active,
    required this.cs,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
        decoration: BoxDecoration(
          color: active ? cs.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 19,
                color: active
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.65)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          active ? FontWeight.w600 : FontWeight.w500,
                      color: active
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.65))),
            ),
            if (badge != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: active
                      ? Colors.white.withValues(alpha: 0.25)
                      : cs.primary,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusCircle),
                ),
                child: Text('$badge',
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Desktop top bar ────────────────────────────────────────────────────────

class _AdminTopBar extends ConsumerWidget {
  final String tab;
  final bool showNotif;
  final VoidCallback onBellTap;

  const _AdminTopBar({
    required this.tab,
    required this.showNotif,
    required this.onBellTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final ac = Theme.of(context).extension<AppThemeColors>()!;
    final dishesState = ref.watch(adminDishesProvider);

    final title = tab == 'menu' ? 'Menu' : 'Orders';
    final subtitle = tab == 'menu'
        ? '${dishesState.dishes.length} items · ${dishesState.availableCount} available'
        : 'Manage incoming orders in real time';
    const unreadCount = 2;

    return Container(
      height: 76,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: ac.border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: ac.primaryText,
                        letterSpacing: -0.5,
                        height: 1.1)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style:
                        TextStyle(fontSize: 13, color: ac.mutedText)),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Container(
            width: 260,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.adminBackground,
              border: Border.all(color: ac.border),
              borderRadius:
                  BorderRadius.circular(AppDimensions.radiusSm),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                Icon(Icons.search, size: 17, color: ac.mutedText),
                const SizedBox(width: 9),
                Text('Search orders, items…',
                    style:
                        TextStyle(fontSize: 13, color: ac.mutedText)),
              ],
            ),
          ),
          const SizedBox(width: 20),
          if (tab == 'menu') ...[
            GestureDetector(
              onTap: () =>
                  ref.read(adminDishesProvider.notifier).openEditor('new'),
              child: Container(
                height: 42,
                padding:
                    const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  color: cs.primary,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusSm),
                  boxShadow: [
                    BoxShadow(
                        color: cs.primary.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8)),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 18, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Add item',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 20),
          ],
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.statusDeliveredBg,
              border: Border.all(color: AppColors.storeOpenBorder),
              borderRadius:
                  BorderRadius.circular(AppDimensions.radiusSm),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 8,
                  height: 8,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                        color: AppColors.statusDeliveredFg,
                        shape: BoxShape.circle),
                  ),
                ),
                SizedBox(width: 9),
                Text('Store open',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.statusDeliveredFg)),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Stack(
            clipBehavior: Clip.none,
            children: [
              GestureDetector(
                onTap: onBellTap,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: showNotif ? ac.primaryText : Colors.white,
                    border: Border.all(color: ac.border),
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusSm),
                  ),
                  child: Icon(Icons.notifications_outlined,
                      size: 19,
                      color: showNotif ? Colors.white : ac.primaryText),
                ),
              ),
              if (unreadCount > 0)
                Positioned(
                  top: 7,
                  right: 7,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: cs.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
