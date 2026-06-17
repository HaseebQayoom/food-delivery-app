import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_delivery/core/constants/app_dimensions.dart';
import 'package:food_delivery/core/navigation/app_navigator.dart';
import 'package:food_delivery/features/orders/providers/active_order_notifier.dart';
import 'package:food_delivery/models/order_model.dart';
import 'package:food_delivery/theme/app_theme.dart';

class ActiveOrdersScreen extends ConsumerWidget {
  const ActiveOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(activeOrderNotifierProvider);
    final tt = Theme.of(context).textTheme;
    final ac = Theme.of(context).extension<AppThemeColors>()!;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Active Orders', style: tt.titleLarge),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => AppNavigator.back(context),
        ),
      ),
      body: orders.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.receipt_long_outlined,
                      size: 56, color: ac.mutedText),
                  const SizedBox(height: AppDimensions.md),
                  Text('No active orders',
                      style: tt.titleMedium?.copyWith(color: ac.mutedText)),
                ],
              ),
            )
          : RefreshIndicator(
              color: cs.primary,
              onRefresh: () =>
                  ref.read(activeOrderNotifierProvider.notifier).refresh(),
              child: ListView.separated(
                padding: const EdgeInsets.all(AppDimensions.screenPadding),
                itemCount: orders.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppDimensions.sm),
                itemBuilder: (_, i) => _ActiveOrderCard(order: orders[i]),
              ),
            ),
    );
  }
}

class _ActiveOrderCard extends StatelessWidget {
  const _ActiveOrderCard({required this.order});
  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final ac = Theme.of(context).extension<AppThemeColors>()!;
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => AppNavigator.toTracking(context, orderId: order.id),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.md),
        decoration: BoxDecoration(
          color: ac.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(color: cs.primary.withValues(alpha: 0.25)),
          boxShadow: ac.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                order.status == OrderStatus.onTheWay
                    ? Icons.delivery_dining_rounded
                    : Icons.restaurant_rounded,
                color: cs.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: AppDimensions.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.restaurantName,
                    style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    order.status.label,
                    style:
                        tt.bodySmall?.copyWith(color: cs.primary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${order.items.fold(0, (s, e) => s + e.quantity)} items  ·  Rs ${order.totalRs}',
                    style: tt.bodySmall?.copyWith(color: ac.mutedText),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: ac.mutedText),
          ],
        ),
      ),
    );
  }
}
