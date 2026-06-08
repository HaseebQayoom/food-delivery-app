import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:food_delivery/core/constants/app_dimensions.dart';
import 'package:food_delivery/core/navigation/app_navigator.dart';
import 'package:food_delivery/features/tracking/providers/tracking_notifier.dart';
import 'package:food_delivery/models/order_model.dart';
import 'package:food_delivery/theme/app_theme.dart';
import 'package:latlong2/latlong.dart';

class TrackingScreen extends ConsumerStatefulWidget {
  final String orderId;
  const TrackingScreen({super.key, required this.orderId});

  @override
  ConsumerState<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends ConsumerState<TrackingScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        ref.read(trackingNotifierProvider.notifier).startTracking(widget.orderId));
  }

  String _computeEta(DateTime? placedAt, OrderStatus status) {
    if (status == OrderStatus.delivered) return 'Delivered!';
    if (placedAt == null) return 'Arriving soon';
    final etaTime = placedAt.add(const Duration(minutes: 35));
    final remaining = etaTime.difference(DateTime.now()).inMinutes;
    if (remaining <= 0) return 'Arriving any moment';
    return 'Arriving in ~$remaining min';
  }

  Future<void> _onPhoneTap(BuildContext context, OrderModel? order) async {
    if (order == null) return;
    if (order.courierPhone != null) {
      await Clipboard.setData(ClipboardData(text: order.courierPhone!));
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "Courier number copied: ${order.courierPhone}"),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Contacting ${order.courierName ?? 'courier'} via support chat…'),
          action: SnackBarAction(
            label: 'Open chat',
            onPressed: () => AppNavigator.toChat(context),
          ),
        ),
      );
    }
  }

  Future<void> _onOrderIdCopy(BuildContext context, String orderId) async {
    await Clipboard.setData(ClipboardData(text: orderId));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order ID copied — share with support.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(trackingNotifierProvider);
    final order = state.order;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final ac = Theme.of(context).extension<AppThemeColors>()!;

    return Scaffold(
      body: state.isLoading && order == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // Map — top 55 % of screen
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.55,
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(
                        order?.courierLat ?? 31.5204,
                        order?.courierLng ?? 74.3587,
                      ),
                      initialZoom: 14,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.crave.app',
                      ),
                      if (order?.courierLat != null)
                        MarkerLayer(markers: [
                          Marker(
                            point: LatLng(
                                order!.courierLat!, order.courierLng!),
                            child: Icon(Icons.delivery_dining_rounded,
                                color: cs.primary, size: 32),
                          ),
                        ]),
                    ],
                  ),
                ),

                // Back button
                Positioned(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 12,
                  child: Container(
                    decoration: BoxDecoration(
                      color: cs.surface,
                      shape: BoxShape.circle,
                      boxShadow: ac.cardShadow,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 18),
                      onPressed: () => AppNavigator.back(context),
                    ),
                  ),
                ),

                // Bottom info card
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.52,
                    decoration: BoxDecoration(
                      color: cs.surface,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(28)),
                      boxShadow: ac.navbarShadow,
                    ),
                    child: Column(
                      children: [
                        // Handle bar
                        Container(
                          margin:
                              const EdgeInsets.only(top: 10, bottom: 16),
                          width: 36,
                          height: 4,
                          decoration: BoxDecoration(
                            color: cs.outlineVariant,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.screenPadding),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ETA — dynamic
                              Row(
                                children: [
                                  Text(
                                    _computeEta(
                                      order?.placedAt,
                                      order?.status ?? OrderStatus.placed,
                                    ),
                                    style: tt.titleLarge!.copyWith(
                                        fontWeight: FontWeight.w800),
                                  ),
                                  const Spacer(),
                                  _StatusBadge(
                                      status: order?.status ??
                                          OrderStatus.placed),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                order?.restaurantName ?? '—',
                                style: tt.bodyMedium!.copyWith(
                                    color: cs.onSurfaceVariant),
                              ),

                              const SizedBox(height: AppDimensions.lg),

                              // Order status timeline
                              _Timeline(
                                  status: order?.status ??
                                      OrderStatus.placed),

                              const SizedBox(height: AppDimensions.lg),

                              // Courier row
                              if (order?.courierName != null)
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: ac.creamSurface,
                                    borderRadius: BorderRadius.circular(
                                        AppDimensions.radiusMd),
                                    border:
                                        Border.all(color: ac.border),
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundColor: cs.primary,
                                        child: Text(
                                          (order?.courierName ?? '?')
                                                  .isNotEmpty
                                              ? (order?.courierName ??
                                                  '?')[0]
                                              : '?',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight:
                                                  FontWeight.w700),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(order?.courierName ?? '',
                                                style: tt.titleSmall),
                                            Text('Your courier',
                                                style: tt.bodySmall!
                                                    .copyWith(
                                                        color: cs
                                                            .onSurfaceVariant)),
                                          ],
                                        ),
                                      ),
                                      // Phone — copies courierPhone or opens chat
                                      _CircleIconBtn(
                                        icon: Icons.phone_outlined,
                                        onTap: () => _onPhoneTap(context, order),
                                      ),
                                      const SizedBox(width: 8),
                                      // Chat — navigates to support chat
                                      _CircleIconBtn(
                                        icon: Icons.chat_bubble_outline_rounded,
                                        onTap: () =>
                                            AppNavigator.toChat(context),
                                      ),
                                    ],
                                  ),
                                ),

                              // Copy order ID when no courier assigned yet
                              if (order?.courierName == null &&
                                  order != null)
                                GestureDetector(
                                  onTap: () =>
                                      _onOrderIdCopy(context, order.id),
                                  child: Row(
                                    children: [
                                      Icon(Icons.copy_rounded,
                                          size: 14,
                                          color: cs.onSurfaceVariant),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Copy order ID for support',
                                        style: tt.bodySmall!.copyWith(
                                            color: cs.onSurfaceVariant),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final OrderStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ac = Theme.of(context).extension<AppThemeColors>()!;
    final color = status == OrderStatus.delivered
        ? ac.success
        : status == OrderStatus.picked
            ? cs.tertiary
            : cs.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999)),
      child: Text(status.label,
          style: Theme.of(context)
              .textTheme
              .labelSmall!
              .copyWith(color: color, fontWeight: FontWeight.w700)),
    );
  }
}

class _Timeline extends StatelessWidget {
  final OrderStatus status;
  const _Timeline({required this.status});

  @override
  Widget build(BuildContext context) {
    final steps = OrderStatus.values
        .where((s) => s != OrderStatus.delivered)
        .toList()
      ..add(OrderStatus.delivered);
    final current = steps.indexOf(status);
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: List.generate(steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          final stepIdx = i ~/ 2;
          return Expanded(
            child: Container(
              height: 2,
              color: stepIdx < current ? cs.primary : cs.outlineVariant,
            ),
          );
        }
        final stepIdx = i ~/ 2;
        final done = stepIdx <= current;
        return Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done ? cs.primary : cs.surfaceContainerLowest,
                border: Border.all(
                    color: done ? cs.primary : cs.outlineVariant,
                    width: 2),
              ),
              child: done
                  ? const Icon(Icons.check_rounded,
                      size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(height: 4),
            Text(steps[stepIdx].label,
                style: Theme.of(context)
                    .textTheme
                    .labelSmall!
                    .copyWith(fontSize: 9)),
          ],
        );
      }),
    );
  }
}

class _CircleIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleIconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: cs.outline)),
        child: Icon(icon, size: 16, color: cs.onSurface),
      ),
    );
  }
}
