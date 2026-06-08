import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_delivery/core/constants/app_dimensions.dart';
import 'package:food_delivery/core/navigation/app_navigator.dart';
import 'package:food_delivery/core/widgets/empty_state_widget.dart';
import 'package:food_delivery/core/widgets/gradient_button.dart';
import 'package:food_delivery/core/widgets/price_row.dart';
import 'package:food_delivery/core/widgets/quantity_control.dart';
import 'package:food_delivery/features/cart/providers/cart_notifier.dart';
import 'package:food_delivery/theme/app_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  final _promoController = TextEditingController();
  bool _promoApplied = false;
  String? _promoError;

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  void _applyPromo() {
    final notifier = ref.read(cartNotifierProvider.notifier);
    final success = notifier.applyPromoCode(_promoController.text.trim());
    setState(() {
      _promoApplied = success;
      _promoError = success ? null : 'Invalid promo code';
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartNotifierProvider);
    final notifier = ref.read(cartNotifierProvider.notifier);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final ac = Theme.of(context).extension<AppThemeColors>()!;

    return Scaffold(
      backgroundColor: ac.background,
      body: SafeArea(
        child: Column(
          children: [
            // App bar
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.screenPadding, AppDimensions.md,
                AppDimensions.screenPadding, 0,
              ),
              child: Row(
                children: [
                  Text('Your cart', style: tt.headlineSmall),
                  const Spacer(),
                  if (cart.isNotEmpty)
                    TextButton(
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Clear cart?'),
                            content: const Text('Remove all items from your cart?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: Text('Clear all', style: TextStyle(color: cs.error)),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) notifier.clear();
                      },
                      child: Text('Clear all', style: TextStyle(color: cs.error, fontSize: 13)),
                    ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: cart.isEmpty
                  ? EmptyStateWidget(
                      title: 'Your cart is empty',
                      subtitle: 'Add items from restaurants to get started',
                      actionLabel: 'Browse food',
                      onAction: () {},
                    )
                  : ListView(
                      padding: const EdgeInsets.all(AppDimensions.screenPadding),
                      children: [
                        // Cart items
                        ...cart.map((item) => Dismissible(
                              key: Key(item.dish.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 16),
                                decoration: BoxDecoration(
                                  color: cs.errorContainer,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(Icons.delete_outline, color: cs.error),
                              ),
                              onDismissed: (_) => notifier.removeItem(item.dish.id),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: ac.creamSurface,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: ac.border),
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: item.dish.imageUrl != null
                                          ? CachedNetworkImage(
                                              imageUrl: item.dish.imageUrl!,
                                              width: 60,
                                              height: 60,
                                              fit: BoxFit.cover,
                                              errorWidget: (_, _, _) => _dishFallback(context, item.dish.name),
                                            )
                                          : _dishFallback(context, item.dish.name),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(item.dish.name, style: tt.titleSmall),
                                          Text(item.dish.restaurantName,
                                              style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Rs ${item.totalPriceRs}',
                                            style: tt.titleSmall!.copyWith(
                                              color: cs.primary,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    QuantityControl(
                                      quantity: item.quantity,
                                      onIncrement: () => notifier.increment(item.dish.id),
                                      onDecrement: () => notifier.decrement(item.dish.id),
                                    ),
                                  ],
                                ),
                              ),
                            )),

                        const SizedBox(height: 8),

                        // Promo code
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: ac.creamSurface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: _promoApplied ? const Color(0xFF2DBE60) : ac.border),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.local_offer_outlined, size: 16, color: cs.primary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _promoController,
                                  decoration: InputDecoration(
                                    hintText: 'Enter promo code',
                                    hintStyle: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                    errorText: _promoError,
                                  ),
                                  style: tt.bodyMedium,
                                  textCapitalization: TextCapitalization.characters,
                                ),
                              ),
                              GestureDetector(
                                onTap: _promoApplied ? null : _applyPromo,
                                child: Text(
                                  _promoApplied ? '✓ Applied' : 'Apply',
                                  style: tt.bodySmall!.copyWith(
                                    color: _promoApplied ? const Color(0xFF2DBE60) : cs.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppDimensions.md),
                        const Divider(),
                        const SizedBox(height: AppDimensions.sm),

                        // Price summary
                        PriceRow(label: 'Subtotal', amount: notifier.subtotalRs),
                        const SizedBox(height: 6),
                        PriceRow(label: 'Delivery fee', amount: notifier.deliveryFeeRs),
                        if (notifier.discountRs > 0) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Text('Discount', style: tt.bodyMedium),
                              const Spacer(),
                              Text(
                                '−Rs ${notifier.discountRs}',
                                style: tt.bodyMedium!.copyWith(color: const Color(0xFF2DBE60), fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: AppDimensions.sm),
                        const Divider(),
                        const SizedBox(height: AppDimensions.sm),
                        PriceRow(label: 'Total', amount: notifier.totalRs, isBold: true),
                        const SizedBox(height: AppDimensions.lg),

                        // Checkout button
                        GradientButton(
                          text: 'Proceed to checkout',
                          onPressed: () => AppNavigator.toCheckout(context),
                        ),

                        const SizedBox(height: 104),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dishFallback(BuildContext context, String name) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: 60,
      height: 60,
      color: cs.surfaceContainerLowest,
      child: Center(
        child: Text(name.isNotEmpty ? name[0] : '?',
            style: Theme.of(context).textTheme.titleMedium),
      ),
    );
  }
}
