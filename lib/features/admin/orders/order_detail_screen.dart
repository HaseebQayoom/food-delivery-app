import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_delivery/core/constants/app_dimensions.dart';
import 'package:food_delivery/core/navigation/admin_navigator.dart';
import 'package:food_delivery/core/utils/helpers.dart';
import 'package:food_delivery/core/widgets/gradient_button.dart';
import 'package:food_delivery/core/widgets/outlined_pill_button.dart';
import 'package:food_delivery/core/widgets/price_row.dart';
import 'package:food_delivery/features/admin/orders/admin_orders_notifier.dart';
import 'package:food_delivery/features/admin/widgets/status_chip.dart';
import 'package:food_delivery/models/order_model.dart';

class OrderDetailScreen extends ConsumerStatefulWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  OrderStatus? _selectedStatus;
  bool _isUpdating = false;

  OrderModel? get _order {
    final orders = ref.read(adminOrdersNotifierProvider).orders;
    try {
      return orders.firstWhere((o) => o.id == widget.orderId);
    } catch (_) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _selectedStatus = _order?.status;
    });
  }

  Future<void> _updateStatus() async {
    if (_selectedStatus == null) return;
    setState(() => _isUpdating = true);
    await ref.read(adminOrdersNotifierProvider.notifier).updateStatus(widget.orderId, _selectedStatus!);
    setState(() => _isUpdating = false);
    if (mounted) Helpers.showSuccessSnackBar(context, 'Status updated!');
  }

  @override
  Widget build(BuildContext context) {
    final order = ref.watch(adminOrdersNotifierProvider).orders.cast<OrderModel?>().firstWhere(
          (o) => o?.id == widget.orderId,
          orElse: () => null,
        );
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    _selectedStatus ??= order?.status;

    if (order == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${order.id.substring(0, 8)}', style: tt.titleLarge),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => AdminNavigator.back(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.screenPadding),
        children: [
          // Status chip
          Row(
            children: [
              Text('Current Status: ', style: tt.bodyMedium),
              StatusChip(status: order.status),
            ],
          ),
          const SizedBox(height: AppDimensions.lg),

          // Delivery address
          _Section(label: 'DELIVERY ADDRESS'),
          Text(order.deliveryAddress, style: tt.bodyMedium),
          const SizedBox(height: AppDimensions.lg),

          // Order items
          _Section(label: 'ORDER ITEMS'),
          ...order.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(child: Text('${item.dish.name} × ${item.quantity}', style: tt.bodyMedium)),
                    Text(Helpers.formatRs(item.totalPriceRs), style: tt.bodyMedium!.copyWith(fontWeight: FontWeight.w700)),
                  ],
                ),
              )),
          const SizedBox(height: AppDimensions.md),
          const Divider(),
          const SizedBox(height: AppDimensions.sm),
          PriceRow(label: 'Subtotal', amount: order.subtotalRs),
          const SizedBox(height: 4),
          PriceRow(label: 'Delivery Fee', amount: order.deliveryFeeRs),
          if (order.discountRs > 0) ...[
            const SizedBox(height: 4),
            PriceRow(label: 'Discount', amount: -order.discountRs),
          ],
          const SizedBox(height: 4),
          const Divider(),
          const SizedBox(height: 4),
          PriceRow(label: 'Total', amount: order.totalRs, isBold: true),

          const SizedBox(height: AppDimensions.lg),

          // Update status
          _Section(label: 'UPDATE STATUS'),
          DropdownMenu<OrderStatus>(
            initialSelection: _selectedStatus,
            expandedInsets: EdgeInsets.zero,
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMd)),
            ),
            dropdownMenuEntries: OrderStatus.values
                .map((s) => DropdownMenuEntry(value: s, label: s.label))
                .toList(),
            onSelected: (s) => setState(() => _selectedStatus = s),
          ),
          const SizedBox(height: AppDimensions.sm),
          GradientButton(text: 'Update Status', isLoading: _isUpdating, onPressed: _updateStatus),
          const SizedBox(height: AppDimensions.sm),
          OutlinedPillButton(
            text: 'Cancel Order',
            onPressed: () async {
              final nav = Navigator.of(context);
              final errorColor = cs.error;
              final confirm = await showDialog<bool>(
                context: context,
                builder: (dialogCtx) => AlertDialog(
                  title: const Text('Cancel order?'),
                  content: const Text('This action cannot be undone.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(dialogCtx, false), child: const Text('Keep')),
                    TextButton(onPressed: () => Navigator.pop(dialogCtx, true), child: Text('Cancel order', style: TextStyle(color: errorColor))),
                  ],
                ),
              );
              if (confirm == true) {
                await ref.read(adminOrdersNotifierProvider.notifier).updateStatus(widget.orderId, OrderStatus.placed);
                nav.pop();
              }
            },
            borderColor: cs.error,
            textColor: cs.error,
          ),
          const SizedBox(height: AppDimensions.xl),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String label;
  const _Section({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall!.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              letterSpacing: 1.2,
            ),
      ),
    );
  }
}
