import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_delivery/core/constants/app_dimensions.dart';
import 'package:food_delivery/core/navigation/admin_navigator.dart';
import 'package:food_delivery/core/utils/helpers.dart';
import 'package:food_delivery/core/widgets/custom_search_bar.dart';
import 'package:food_delivery/core/widgets/empty_state_widget.dart';
import 'package:food_delivery/core/widgets/error_state_widget.dart';
import 'package:food_delivery/features/admin/orders/admin_orders_notifier.dart';
import 'package:food_delivery/features/admin/widgets/status_chip.dart';
import 'package:food_delivery/models/order_model.dart';

class OrderListScreen extends ConsumerWidget {
  const OrderListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminOrdersNotifierProvider);
    final notifier = ref.read(adminOrdersNotifierProvider.notifier);
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.screenPadding, AppDimensions.screenPadding,
              AppDimensions.screenPadding, 0,
            ),
            child: CustomSearchBar(hint: 'Search by order ID...', onChanged: notifier.setSearch),
          ),

          // Status filter chips
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(AppDimensions.screenPadding, 8, AppDimensions.screenPadding, 0),
              children: [
                _FilterPill(label: 'All', selected: state.statusFilter == null, onTap: () => notifier.setStatusFilter(null)),
                ...OrderStatus.values.map((s) => _FilterPill(
                      label: s.label,
                      selected: state.statusFilter == s,
                      onTap: () => notifier.setStatusFilter(s),
                    )),
              ],
            ),
          ),

          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.error != null
                    ? ErrorStateWidget(message: state.error!, onRetry: notifier.fetchOrders)
                    : state.filteredOrders.isEmpty
                        ? const EmptyStateWidget(title: 'No orders found', subtitle: 'Try adjusting your filters')
                        : RefreshIndicator(
                            onRefresh: notifier.fetchOrders,
                            child: ListView.separated(
                              padding: const EdgeInsets.all(AppDimensions.screenPadding),
                              itemCount: state.filteredOrders.length,
                              separatorBuilder: (_, _) => const Divider(height: 1),
                              itemBuilder: (_, i) {
                                final order = state.filteredOrders[i];
                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(vertical: 4),
                                  title: Row(
                                    children: [
                                      Text('#${order.id.substring(0, 8)}', style: tt.titleSmall),
                                      const SizedBox(width: 8),
                                      StatusChip(status: order.status),
                                    ],
                                  ),
                                  subtitle: Text(
                                    order.restaurantName,
                                    style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(Helpers.formatRs(order.totalRs),
                                          style: tt.bodyMedium!.copyWith(fontWeight: FontWeight.w700)),
                                      const Icon(Icons.chevron_right_rounded),
                                    ],
                                  ),
                                  onTap: () => AdminNavigator.toOrderDetail(context, orderId: order.id),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterPill({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? cs.primary : cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: selected ? cs.onPrimary : cs.onSurface,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }
}
