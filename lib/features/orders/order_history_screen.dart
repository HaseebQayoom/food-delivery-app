import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_delivery/core/constants/app_dimensions.dart';
import 'package:food_delivery/core/navigation/app_navigator.dart';
import 'package:food_delivery/core/utils/helpers.dart';
import 'package:food_delivery/core/widgets/empty_state_widget.dart';
import 'package:food_delivery/core/widgets/error_state_widget.dart';
import 'package:food_delivery/features/admin/widgets/status_chip.dart';
import 'package:food_delivery/features/orders/providers/order_history_notifier.dart';
import 'package:food_delivery/models/order_model.dart';
import 'package:food_delivery/theme/app_theme.dart';
import 'package:intl/intl.dart';

class OrderHistoryScreen extends ConsumerWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(orderHistoryNotifierProvider);
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('My Orders', style: tt.titleLarge),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => AppNavigator.back(context),
        ),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? ErrorStateWidget(
                  message: state.error!,
                  onRetry: () => ref.read(orderHistoryNotifierProvider.notifier).fetchOrders(),
                )
              : state.orders.isEmpty
                  ? const EmptyStateWidget(
                      title: 'No orders yet',
                      subtitle: 'Your past orders will appear here',
                    )
                  : RefreshIndicator(
                      onRefresh: () => ref.read(orderHistoryNotifierProvider.notifier).fetchOrders(),
                      child: ListView.separated(
                        padding: const EdgeInsets.all(AppDimensions.screenPadding),
                        itemCount: state.orders.length,
                        separatorBuilder: (_, _) => const SizedBox(height: AppDimensions.sm),
                        itemBuilder: (_, i) => _OrderCard(order: state.orders[i]),
                      ),
                    ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final ac = Theme.of(context).extension<AppThemeColors>()!;
    final cs = Theme.of(context).colorScheme;
    final date = DateFormat('MMM d, y · h:mm a').format(order.placedAt);

    return GestureDetector(
      onTap: order.status != OrderStatus.delivered &&
              order.status != OrderStatus.cancelled
          ? () => AppNavigator.toTracking(context, orderId: order.id)
          : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ac.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(color: ac.border, width: 0.5),
          boxShadow: ac.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(order.restaurantName, style: tt.titleSmall!.copyWith(fontWeight: FontWeight.w700)),
                ),
                StatusChip(status: order.status),
              ],
            ),
            const SizedBox(height: 4),
            Text(date, style: tt.bodySmall!.copyWith(color: ac.mutedText)),
            const SizedBox(height: 10),
            // Items summary
            Text(
              order.items.map((e) => '${e.dish.name} ×${e.quantity}').join(', '),
              style: tt.bodySmall!.copyWith(color: ac.secondaryText),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  '${order.items.fold(0, (s, e) => s + e.quantity)} items',
                  style: tt.bodySmall!.copyWith(color: ac.mutedText),
                ),
                const Spacer(),
                Text(
                  Helpers.formatRs(order.totalRs),
                  style: tt.titleSmall!.copyWith(fontWeight: FontWeight.w800, color: cs.primary),
                ),
              ],
            ),
            if (order.status != OrderStatus.delivered &&
                order.status != OrderStatus.cancelled) ...[
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.location_on_rounded, size: 14, color: cs.primary),
                  const SizedBox(width: 4),
                  Text(
                    'Track order',
                    style: tt.labelMedium!.copyWith(color: cs.primary, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
