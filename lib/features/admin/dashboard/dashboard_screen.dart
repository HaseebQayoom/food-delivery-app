import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_delivery/core/constants/app_dimensions.dart';
import 'package:food_delivery/core/navigation/admin_navigator.dart';
import 'package:food_delivery/core/utils/helpers.dart';
import 'package:food_delivery/core/widgets/error_state_widget.dart';
import 'package:food_delivery/features/admin/dashboard/dashboard_notifier.dart';
import 'package:food_delivery/features/admin/widgets/admin_stat_card.dart';
import 'package:food_delivery/features/admin/widgets/status_chip.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminDashboardNotifierProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    if (state.isLoading) return const Center(child: CircularProgressIndicator());
    if (state.error != null) {
      return ErrorStateWidget(
        message: state.error!,
        onRetry: () => ref.read(adminDashboardNotifierProvider.notifier).fetchAll(),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(adminDashboardNotifierProvider.notifier).fetchAll(),
      child: ListView(
        padding: const EdgeInsets.all(AppDimensions.screenPadding),
        children: [
          // Stat cards — 2-col grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [
              AdminStatCard(
                title: 'Total Users',
                value: '${state.totalUsers}',
                icon: Icons.people_rounded,
                color: cs.primary,
              ),
              AdminStatCard(
                title: 'Total Orders',
                value: '${state.totalOrders}',
                icon: Icons.receipt_long_rounded,
                color: const Color(0xFF2DBE60),
              ),
              AdminStatCard(
                title: 'Revenue',
                value: Helpers.formatRs(state.totalRevenue),
                icon: Icons.payments_rounded,
                color: const Color(0xFFFFB400),
              ),
              AdminStatCard(
                title: 'Total Dishes',
                value: '${state.totalDishes}',
                icon: Icons.restaurant_menu_rounded,
                color: cs.tertiary,
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.lg),

          // Quick actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => AdminNavigator.toAdminDishForm(context),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add Dish'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => AdminNavigator.toCategoryForm(context),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add Category'),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.lg),

          // Recent orders
          Text('Recent Orders', style: tt.titleMedium),
          const SizedBox(height: AppDimensions.sm),
          if (state.recentOrders.isEmpty)
            Center(child: Text('No orders yet', style: tt.bodyMedium!.copyWith(color: cs.onSurfaceVariant)))
          else
            ...state.recentOrders.map((order) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('#${order.id.substring(0, 8)}...', style: tt.titleSmall),
                  subtitle: Text(order.restaurantName, style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(Helpers.formatRs(order.totalRs), style: tt.bodyMedium!.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(width: 8),
                      StatusChip(status: order.status),
                    ],
                  ),
                  onTap: () => AdminNavigator.toOrderDetail(context, orderId: order.id),
                )),
        ],
      ),
    );
  }
}
