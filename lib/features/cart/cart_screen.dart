import 'package:cached_network_image/cached_network_image.dart';
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

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  final _promoController = TextEditingController();
  bool _promoApplied = false;
  String? _promoError;
  bool _promoExpanded = false;
  late String _paymentMethod;

  @override
  void initState() {
    super.initState();
    _paymentMethod =
        ref.read(cartNotifierProvider.notifier).selectedPaymentMethod;
  }

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  void _applyPromo() {
    final success = ref
        .read(cartNotifierProvider.notifier)
        .applyPromoCode(_promoController.text.trim());
    setState(() {
      _promoApplied = success;
      _promoError = success ? null : 'Invalid promo code';
      if (success) _promoExpanded = false;
    });
  }

  void _selectPaymentMethod(String method) {
    setState(() => _paymentMethod = method);
    ref.read(cartNotifierProvider.notifier).setPaymentMethod(method);
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
            // ── App bar ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.screenPadding,
                AppDimensions.md,
                AppDimensions.screenPadding,
                0,
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
                            content: const Text(
                                'Remove all items from your cart?'),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, true),
                                child: Text('Clear all',
                                    style: TextStyle(color: cs.error)),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) notifier.clear();
                      },
                      child: Text('Clear all',
                          style: TextStyle(color: cs.error, fontSize: 13)),
                    ),
                ],
              ),
            ),

            // ── Content ───────────────────────────────────────────────────
            Expanded(
              child: cart.isEmpty
                  ? EmptyStateWidget(
                      title: 'Your cart is empty',
                      subtitle: 'Add items to get started',
                      actionLabel: 'Browse food',
                      onAction: () => AppNavigator.toHome(context),
                    )
                  : ListView(
                      padding: const EdgeInsets.all(AppDimensions.screenPadding),
                      children: [
                        // ── Delivery address row ────────────────────────
                        Container(
                          padding: const EdgeInsets.all(AppDimensions.md),
                          decoration: BoxDecoration(
                            color: ac.creamSurface,
                            borderRadius: BorderRadius.circular(
                                AppDimensions.radiusMd),
                            border: Border.all(color: ac.border),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.location_on_outlined,
                                  size: 18, color: cs.primary),
                              const SizedBox(width: AppDimensions.sm),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Deliver to',
                                      style: tt.bodySmall?.copyWith(
                                          color: ac.mutedText),
                                    ),
                                    Text(
                                      notifier.deliveryAddress,
                                      style: tt.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                              TextButton(
                                onPressed: () =>
                                    AppNavigator.toAddresses(context),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text('Change'),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppDimensions.md),

                        // ── Cart items ─────────────────────────────────
                        ...cart.map((item) => Dismissible(
                              key: Key(item.dish.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(
                                    right: AppDimensions.md),
                                decoration: BoxDecoration(
                                  color: cs.errorContainer,
                                  borderRadius: BorderRadius.circular(
                                      AppDimensions.radiusMd),
                                ),
                                child: Icon(Icons.delete_outline,
                                    color: cs.error),
                              ),
                              onDismissed: (_) =>
                                  notifier.removeItem(item.dish.id),
                              child: Container(
                                margin: const EdgeInsets.only(
                                    bottom: AppDimensions.sm),
                                padding: const EdgeInsets.all(AppDimensions.sm),
                                decoration: BoxDecoration(
                                  color: ac.creamSurface,
                                  borderRadius: BorderRadius.circular(
                                      AppDimensions.radiusMd),
                                  border: Border.all(color: ac.border),
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                          AppDimensions.radiusXs),
                                      child: item.dish.imageUrl != null
                                          ? CachedNetworkImage(
                                              imageUrl: item.dish.imageUrl!,
                                              width: 60,
                                              height: 60,
                                              fit: BoxFit.cover,
                                              errorWidget: (_, _, _) =>
                                                  _dishFallback(
                                                      context, item.dish.name),
                                            )
                                          : _dishFallback(
                                              context, item.dish.name),
                                    ),
                                    const SizedBox(width: AppDimensions.sm),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(item.dish.name,
                                              style: tt.titleSmall),
                                          if (item.selectedSize != null)
                                            Text(
                                              '${item.selectedSize}'
                                              '${item.addonNames.isNotEmpty ? ' · ${item.addonNames.length} extra${item.addonNames.length > 1 ? 's' : ''}' : ''}',
                                              style: tt.bodySmall?.copyWith(
                                                  color: ac.mutedText,
                                                  fontSize: 11),
                                            )
                                          else
                                            Text(
                                              item.dish.restaurantName,
                                              style: tt.bodySmall?.copyWith(
                                                  color: ac.mutedText),
                                            ),
                                          const SizedBox(
                                              height: AppDimensions.xs),
                                          Text(
                                            'Rs ${item.totalPriceRs}',
                                            style: tt.titleSmall?.copyWith(
                                              color: cs.primary,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    QuantityControl(
                                      quantity: item.quantity,
                                      minQuantity: 0,
                                      onIncrement: () =>
                                          notifier.increment(item.dish.id),
                                      onDecrement: () =>
                                          notifier.decrement(item.dish.id),
                                    ),
                                  ],
                                ),
                              ),
                            )),

                        const SizedBox(height: AppDimensions.sm),

                        // ── Promo code (collapsed) ──────────────────────
                        Container(
                          decoration: BoxDecoration(
                            color: ac.creamSurface,
                            borderRadius: BorderRadius.circular(
                                AppDimensions.radiusMd),
                            border: Border.all(
                              color: _promoApplied ? ac.success : ac.border,
                            ),
                          ),
                          child: Column(
                            children: [
                              InkWell(
                                onTap: _promoApplied
                                    ? null
                                    : () => setState(() =>
                                        _promoExpanded = !_promoExpanded),
                                borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusMd),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.all(AppDimensions.md),
                                  child: Row(
                                    children: [
                                      Icon(Icons.local_offer_outlined,
                                          size: 16, color: cs.primary),
                                      const SizedBox(width: AppDimensions.sm),
                                      Expanded(
                                        child: Text(
                                          _promoApplied
                                              ? '✓ ${_promoController.text} applied'
                                              : 'Have a promo code?',
                                          style: tt.bodySmall?.copyWith(
                                            color: _promoApplied
                                                ? ac.success
                                                : ac.primaryText,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      if (!_promoApplied)
                                        Icon(
                                          _promoExpanded
                                              ? Icons.expand_less
                                              : Icons.chevron_right,
                                          size: 16,
                                          color: ac.mutedText,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              if (_promoExpanded && !_promoApplied)
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    AppDimensions.md,
                                    0,
                                    AppDimensions.md,
                                    AppDimensions.md,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: _promoController,
                                          decoration: InputDecoration(
                                            hintText: 'Enter promo code',
                                            hintStyle: tt.bodySmall?.copyWith(
                                                color: ac.mutedText),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      AppDimensions.radiusSm),
                                              borderSide:
                                                  BorderSide(color: ac.border),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      AppDimensions.radiusSm),
                                              borderSide:
                                                  BorderSide(color: ac.border),
                                            ),
                                            isDense: true,
                                            errorText: _promoError,
                                          ),
                                          style: tt.bodyMedium,
                                          textCapitalization:
                                              TextCapitalization.characters,
                                        ),
                                      ),
                                      const SizedBox(width: AppDimensions.sm),
                                      GestureDetector(
                                        onTap: _applyPromo,
                                        child: Text(
                                          'Apply',
                                          style: tt.bodySmall?.copyWith(
                                            color: cs.primary,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppDimensions.md),
                        const Divider(),
                        const SizedBox(height: AppDimensions.sm),

                        // ── Price summary ───────────────────────────────
                        PriceRow(
                            label: 'Subtotal', amount: notifier.subtotalRs),
                        const SizedBox(height: AppDimensions.xs),
                        PriceRow(
                            label: 'Delivery fee',
                            amount: notifier.deliveryFeeRs),
                        if (notifier.discountRs > 0) ...[
                          const SizedBox(height: AppDimensions.xs),
                          Row(
                            children: [
                              Text('Discount', style: tt.bodyMedium),
                              const Spacer(),
                              Text(
                                '−Rs ${notifier.discountRs}',
                                style: tt.bodyMedium?.copyWith(
                                  color: ac.success,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: AppDimensions.sm),
                        const Divider(),
                        const SizedBox(height: AppDimensions.sm),
                        PriceRow(
                            label: 'Total',
                            amount: notifier.totalRs,
                            isBold: true),

                        const SizedBox(height: AppDimensions.lg),

                        // ── Pay with ────────────────────────────────────
                        Text('Pay with',
                            style: tt.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: AppDimensions.sm),
                        Row(
                          children: ['Visa', 'Apple Pay', 'Wallet']
                              .map((method) {
                            final isSelected = _paymentMethod == method;
                            return Padding(
                              padding: const EdgeInsets.only(
                                  right: AppDimensions.sm),
                              child: GestureDetector(
                                onTap: () => _selectPaymentMethod(method),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppDimensions.md,
                                    vertical: AppDimensions.sm,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? cs.primary
                                        : ac.creamSurface,
                                    borderRadius: BorderRadius.circular(
                                        AppDimensions.radiusCircle),
                                    border: Border.all(
                                      color: isSelected
                                          ? cs.primary
                                          : ac.border,
                                    ),
                                  ),
                                  child: Text(
                                    method,
                                    style: tt.labelMedium?.copyWith(
                                      color: isSelected
                                          ? cs.onPrimary
                                          : ac.primaryText,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: AppDimensions.lg),

                        // ── Place order button ──────────────────────────
                        GradientButton(
                          text: 'Place order',
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
    final ac = Theme.of(context).extension<AppThemeColors>()!;
    final tt = Theme.of(context).textTheme;
    return Container(
      width: 60,
      height: 60,
      color: ac.creamSurface,
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0] : '?',
          style: tt.titleMedium,
        ),
      ),
    );
  }
}
