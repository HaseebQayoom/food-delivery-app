import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:food_delivery/core/constants/app_dimensions.dart';
import 'package:food_delivery/features/admin/orders/admin_orders_notifier.dart';
import 'package:food_delivery/features/admin/widgets/status_pill.dart';
import 'package:food_delivery/models/order_model.dart';
import 'package:food_delivery/theme/app_theme.dart';

class AdminOrdersScreen extends ConsumerWidget {
  const AdminOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminOrdersProvider);
    final notifier = ref.read(adminOrdersProvider.notifier);
    final ac = Theme.of(context).extension<AppThemeColors>()!;
    final cs = Theme.of(context).colorScheme;

    void showDetail(OrderModel order) {
      notifier.selectOrder(order.id);
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        clipBehavior: Clip.hardEdge,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimensions.radiusLg),
          ),
        ),
        builder: (sheetCtx) => SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.82,
          child: _OrderDetailCard(
            order: order,
            ac: ac,
            cs: cs,
            onAccept: (id) {
              notifier.acceptOrder(id);
              Navigator.pop(sheetCtx);
            },
            onReject: (id) {
              notifier.rejectOrder(id);
              Navigator.pop(sheetCtx);
            },
            onMarkOnTheWay: (id) {
              notifier.markOnTheWay(id);
              Navigator.pop(sheetCtx);
            },
            onMarkDelivered: (id) {
              notifier.markDelivered(id);
              Navigator.pop(sheetCtx);
            },
          ),
        ),
      );
    }

    if (state.isLoading && state.orders.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FilterTabsRow(
            state: state, ac: ac, cs: cs, onFilter: notifier.setFilter),
        const SizedBox(height: 14),
        Expanded(
          child: _OrderListCard(
            state: state,
            ac: ac,
            cs: cs,
            onTap: showDetail,
          ),
        ),
      ],
    );
  }
}

// ─── Filter Tabs ───────────────────────────────────────────────────────────

class _FilterTabsRow extends StatelessWidget {
  final AdminOrdersState state;
  final AppThemeColors ac;
  final ColorScheme cs;
  final ValueChanged<String> onFilter;

  const _FilterTabsRow({
    required this.state,
    required this.ac,
    required this.cs,
    required this.onFilter,
  });

  static const _tabs = [
    (id: 'active', label: 'Active'),
    (id: 'ontheway', label: 'On the way'),
    (id: 'delivered', label: 'Delivered'),
  ];

  int _count(String tabId) {
    return switch (tabId) {
      'active' => state.orders
          .where((o) =>
              o.status == OrderStatus.newOrder ||
              o.status == OrderStatus.preparing)
          .length,
      'ontheway' =>
        state.orders.where((o) => o.status == OrderStatus.onTheWay).length,
      'delivered' => state.orders
          .where((o) =>
              o.status == OrderStatus.delivered ||
              o.status == OrderStatus.cancelled)
          .length,
      _ => 0,
    };
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _tabs.map((t) {
          final on = state.filterTab == t.id;
          final n = _count(t.id);
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onFilter(t.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: on ? ac.primaryText : Colors.white,
                  border: Border.all(color: on ? ac.primaryText : ac.border),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      t.label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: on ? Colors.white : ac.secondaryText,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: on
                            ? Colors.white.withValues(alpha: 0.2)
                            : const Color(0xFFF0EBE3),
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusCircle),
                      ),
                      child: Text(
                        '$n',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: on ? Colors.white : ac.mutedText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Order List Card ────────────────────────────────────────────────────────

class _OrderListCard extends StatelessWidget {
  final AdminOrdersState state;
  final AppThemeColors ac;
  final ColorScheme cs;
  final ValueChanged<OrderModel> onTap;

  const _OrderListCard({
    required this.state,
    required this.ac,
    required this.cs,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final orders = state.filteredOrders;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: ac.border),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      ),
      clipBehavior: Clip.hardEdge,
      child: orders.isEmpty
          ? Center(
              child: Text(
                'No orders in this category',
                style: TextStyle(fontSize: 13, color: ac.mutedText),
              ),
            )
          : ListView.separated(
              itemCount: orders.length,
              separatorBuilder: (_, _) => Divider(height: 1, color: ac.border),
              itemBuilder: (_, i) {
                final o = orders[i];
                return _OrderListRow(
                  order: o,
                  ac: ac,
                  cs: cs,
                  onTap: () => onTap(o),
                );
              },
            ),
    );
  }
}

class _OrderListRow extends StatelessWidget {
  final OrderModel order;
  final AppThemeColors ac;
  final ColorScheme cs;
  final VoidCallback onTap;

  const _OrderListRow({
    required this.order,
    required this.ac,
    required this.cs,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final name = _customerName(order);
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'C';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: ac.creamSurface,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                initial,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: cs.primary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: ac.primaryText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_displayId(order.id)} · ${_timeAgo(order.placedAt)}',
                    style: TextStyle(fontSize: 11, color: ac.mutedText),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                StatusPill(status: order.status, small: true),
                const SizedBox(height: 4),
                Text(
                  'Rs ${order.totalRs}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: ac.primaryText,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 6),
            Icon(Icons.chevron_right, size: 16, color: ac.mutedText),
          ],
        ),
      ),
    );
  }
}

// ─── Order Detail Card ──────────────────────────────────────────────────────

class _OrderDetailCard extends StatelessWidget {
  final OrderModel? order;
  final AppThemeColors ac;
  final ColorScheme cs;
  final ValueChanged<String> onAccept;
  final ValueChanged<String> onReject;
  final ValueChanged<String> onMarkOnTheWay;
  final ValueChanged<String> onMarkDelivered;

  const _OrderDetailCard({
    required this.order,
    required this.ac,
    required this.cs,
    required this.onAccept,
    required this.onReject,
    required this.onMarkOnTheWay,
    required this.onMarkDelivered,
  });

  @override
  Widget build(BuildContext context) {
    if (order == null) {
      return Center(
        child: Text('Select an order',
            style: TextStyle(color: ac.mutedText, fontSize: 13)),
      );
    }
    final o = order!;
    final name = _customerName(o);
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'C';

    return Column(
      children: [
        // Drag handle
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 4),
          child: Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: ac.border,
              borderRadius: BorderRadius.circular(AppDimensions.radiusCircle),
            ),
          ),
        ),
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order ${_displayId(o.id)}',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: ac.primaryText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_timeAgo(o.placedAt)} · Delivery',
                      style: TextStyle(fontSize: 12, color: ac.mutedText),
                    ),
                  ],
                ),
              ),
              StatusPill(status: o.status),
            ],
          ),
        ),
        Divider(height: 1, color: ac.border),
        // Customer section
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: ac.primaryText,
                  borderRadius: BorderRadius.circular(11),
                ),
                alignment: Alignment.center,
                child: Text(
                  initial,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: ac.primaryText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      o.deliveryAddress,
                      style: TextStyle(fontSize: 12, color: ac.mutedText),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Customer contact coming soon.'),
                    duration: Duration(seconds: 2),
                  ),
                ),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: ac.border),
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusSm),
                  ),
                  child: Icon(Icons.phone_outlined, size: 17, color: ac.primaryText),
                ),
              ),
            ],
          ),
        ),
        Divider(height: 1, color: ac.border),
        // Items + summary — scrollable
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Text(
                    'ITEMS',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: ac.mutedText,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ...o.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            width: 40,
                            height: 40,
                            child: item.dish.imageUrl != null
                                ? CachedNetworkImage(
                                    imageUrl: item.dish.imageUrl!,
                                    fit: BoxFit.cover,
                                    errorWidget: (_, _, _) =>
                                        ColoredBox(color: ac.creamSurface),
                                  )
                                : ColoredBox(color: ac.creamSurface),
                          ),
                        ),
                        const SizedBox(width: 11),
                        SizedBox(
                          width: 24,
                          child: Text(
                            '${item.quantity}×',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: cs.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.dish.name,
                            style:
                                TextStyle(fontSize: 13, color: ac.primaryText),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          'Rs ${item.totalPriceRs}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: ac.primaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Divider(indent: 20, endIndent: 20, color: ac.border),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  child: Column(
                    children: [
                      _SummaryRow('Subtotal', 'Rs ${o.subtotalRs}', ac: ac),
                      const SizedBox(height: 6),
                      _SummaryRow(
                        'Delivery',
                        o.deliveryFeeRs == 0 ? 'Free' : 'Rs ${o.deliveryFeeRs}',
                        ac: ac,
                      ),
                      if (o.discountRs > 0) ...[
                        const SizedBox(height: 6),
                        _SummaryRow('Discount', '-Rs ${o.discountRs}', ac: ac),
                      ],
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: ac.primaryText,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Rs ${o.totalRs}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: ac.primaryText,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Status-based action buttons
        if (o.status == OrderStatus.newOrder)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => onReject(o.id),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: ac.border),
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusSm),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Reject',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: ac.secondaryText,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: () => onAccept(o.id),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: cs.primary,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusSm),
                        boxShadow: [
                          BoxShadow(
                            color: cs.primary.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'Accept & start cooking',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        else if (o.status == OrderStatus.preparing)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: GestureDetector(
              onTap: () => onMarkOnTheWay(o.id),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: cs.primary,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                  boxShadow: [
                    BoxShadow(
                      color: cs.primary.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.delivery_dining_rounded,
                        size: 18, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Out for Delivery',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else if (o.status == OrderStatus.onTheWay)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: GestureDetector(
              onTap: () => onMarkDelivered(o.id),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF2DBE60),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2DBE60).withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_outline_rounded,
                        size: 18, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Mark as Delivered',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final AppThemeColors ac;

  const _SummaryRow(this.label, this.value, {required this.ac});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: ac.mutedText)),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: ac.primaryText),
        ),
      ],
    );
  }
}

// ─── Helpers ────────────────────────────────────────────────────────────────

String _customerName(OrderModel o) {
  if (o.deliveryAddress.isEmpty) return 'Customer';
  return o.deliveryAddress.split(',').first.trim();
}

String _displayId(String id) {
  if (id.length <= 8) return '#${id.toUpperCase()}';
  return '#${id.substring(0, 8).toUpperCase()}';
}

String _timeAgo(DateTime dt) {
  final d = DateTime.now().difference(dt);
  if (d.inSeconds < 60) return 'Just now';
  if (d.inMinutes < 60) return '${d.inMinutes} min ago';
  if (d.inHours < 24) return '${d.inHours} hr ago';
  return '${d.inDays}d ago';
}
