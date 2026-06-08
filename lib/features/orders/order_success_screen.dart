import 'package:flutter/material.dart';
import 'package:food_delivery/core/constants/app_colors.dart';
import 'package:food_delivery/core/constants/app_dimensions.dart';
import 'package:food_delivery/core/navigation/app_navigator.dart';
import 'package:food_delivery/core/utils/helpers.dart';
import 'package:food_delivery/core/widgets/gradient_button.dart';
import 'package:food_delivery/core/widgets/outlined_pill_button.dart';
import 'package:food_delivery/models/order_model.dart';
import 'package:food_delivery/theme/app_theme.dart';

class OrderSuccessScreen extends StatefulWidget {
  final OrderModel order;
  const OrderSuccessScreen({super.key, required this.order});

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _fade = CurvedAnimation(parent: _ctrl, curve: const Interval(0.4, 1.0));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final ac = Theme.of(context).extension<AppThemeColors>()!;
    final cs = Theme.of(context).colorScheme;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.screenPadding),
            child: Column(
              children: [
                const Spacer(),

                // Animated checkmark
                ScaleTransition(
                  scale: _scale,
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: const BoxDecoration(
                      gradient: AppGradients.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_rounded, color: Colors.white, size: 56),
                  ),
                ),

                const SizedBox(height: AppDimensions.lg),

                FadeTransition(
                  opacity: _fade,
                  child: Column(
                    children: [
                      Text(
                        'Order Placed!',
                        style: tt.headlineSmall!.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your order from ${widget.order.restaurantName} is confirmed.',
                        style: tt.bodyMedium!.copyWith(color: ac.secondaryText),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppDimensions.xl),

                // Order summary card
                FadeTransition(
                  opacity: _fade,
                  child: Container(
                    padding: const EdgeInsets.all(AppDimensions.md),
                    decoration: BoxDecoration(
                      color: ac.surface,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                      border: Border.all(color: ac.border, width: 0.5),
                      boxShadow: ac.cardShadow,
                    ),
                    child: Column(
                      children: [
                        _Row(
                          label: 'Order ID',
                          value: '#${widget.order.id.substring(0, 8).toUpperCase()}',
                        ),
                        const Divider(height: 20),
                        _Row(label: 'Restaurant', value: widget.order.restaurantName),
                        const SizedBox(height: 8),
                        _Row(
                          label: 'Items',
                          value: '${widget.order.items.fold(0, (s, e) => s + e.quantity)}',
                        ),
                        const SizedBox(height: 8),
                        _Row(
                          label: 'Total',
                          value: Helpers.formatRs(widget.order.totalRs),
                          valueBold: true,
                          valueColor: cs.primary,
                        ),
                        const Divider(height: 20),
                        Row(
                          children: [
                            Icon(Icons.location_on_rounded, size: 14, color: ac.mutedText),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                widget.order.deliveryAddress,
                                style: tt.bodySmall!.copyWith(color: ac.secondaryText),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.access_time_rounded, size: 14, color: ac.mutedText),
                            const SizedBox(width: 4),
                            Text(
                              'Est. delivery: 30–45 min',
                              style: tt.bodySmall!.copyWith(color: ac.secondaryText),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // Action buttons
                GradientButton(
                  text: 'Track Order',
                  onPressed: () {
                    AppNavigator.toTracking(context, orderId: widget.order.id);
                  },
                ),
                const SizedBox(height: AppDimensions.sm),
                OutlinedPillButton(
                  text: 'Back to Home',
                  onPressed: () => AppNavigator.toHome(context),
                ),
                const SizedBox(height: AppDimensions.sm),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool valueBold;
  final Color? valueColor;
  const _Row({required this.label, required this.value, this.valueBold = false, this.valueColor});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final ac = Theme.of(context).extension<AppThemeColors>()!;
    return Row(
      children: [
        Text(label, style: tt.bodySmall!.copyWith(color: ac.mutedText)),
        const Spacer(),
        Text(
          value,
          style: tt.bodyMedium!.copyWith(
            fontWeight: valueBold ? FontWeight.w700 : FontWeight.w500,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
