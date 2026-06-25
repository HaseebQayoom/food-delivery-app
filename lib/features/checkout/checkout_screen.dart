import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_delivery/core/constants/app_dimensions.dart';
import 'package:food_delivery/core/navigation/app_navigator.dart';
import 'package:food_delivery/core/utils/helpers.dart';
import 'package:food_delivery/core/widgets/gradient_button.dart';
import 'package:food_delivery/core/widgets/price_row.dart';
import 'package:food_delivery/features/cart/providers/cart_notifier.dart';
import 'package:food_delivery/features/checkout/providers/checkout_notifier.dart';
import 'package:food_delivery/features/profile/address/providers/address_notifier.dart';
import 'package:food_delivery/features/profile/payment/providers/payment_notifier.dart';
import 'package:food_delivery/models/payment_method_model.dart';
import 'package:food_delivery/theme/app_theme.dart';

class CheckoutScreen extends ConsumerWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkoutState = ref.watch(checkoutNotifierProvider);
    final addressState = ref.watch(addressNotifierProvider);
    final paymentState = ref.watch(paymentNotifierProvider);
    final cartNotifier = ref.read(cartNotifierProvider.notifier);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final ac = Theme.of(context).extension<AppThemeColors>()!;

    // Auto-select defaults when data loads
    if (checkoutState.selectedAddress == null &&
        addressState.addresses.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final def = addressState.addresses.firstWhere(
          (a) => a.isDefault,
          orElse: () => addressState.addresses.first,
        );
        ref.read(checkoutNotifierProvider.notifier).selectAddress(def);
      });
    }
    if (checkoutState.selectedPayment == null &&
        paymentState.methods.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final def = paymentState.methods.firstWhere(
          (p) => p.isDefault,
          orElse: () => paymentState.methods.first,
        );
        ref.read(checkoutNotifierProvider.notifier).selectPayment(def);
      });
    }

    return Scaffold(
      backgroundColor: ac.background,
      appBar: AppBar(
        backgroundColor: ac.background,
        elevation: 0,
        title: Text('Checkout', style: tt.titleLarge),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => AppNavigator.back(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.screenPadding),
        children: [
          // ── Delivery Address ──────────────────────────────────────
          _SectionLabel(label: 'DELIVERY ADDRESS'),
          const SizedBox(height: AppDimensions.sm),
          _SummaryTile(
            icon: Icons.location_on_outlined,
            title: checkoutState.selectedAddress?.label ?? 'No address selected',
            subtitle: checkoutState.selectedAddress?.fullAddress,
            isEmpty: checkoutState.selectedAddress == null,
            emptyLabel: 'Add address',
            isLoading: addressState.isLoading,
            onChangeTap: () => AppNavigator.toAddresses(context),
            cs: cs,
            ac: ac,
          ),

          const SizedBox(height: AppDimensions.lg),

          // ── Payment Method ────────────────────────────────────────
          _SectionLabel(label: 'PAYMENT METHOD'),
          const SizedBox(height: AppDimensions.sm),
          _SummaryTile(
            icon: _paymentIcon(checkoutState.selectedPayment?.type),
            title: checkoutState.selectedPayment?.label ?? 'No payment method selected',
            isEmpty: checkoutState.selectedPayment == null,
            emptyLabel: 'Add payment method',
            isLoading: paymentState.isLoading,
            onChangeTap: () => AppNavigator.toPaymentMethods(context),
            cs: cs,
            ac: ac,
          ),

          const SizedBox(height: AppDimensions.lg),

          // ── Tip ───────────────────────────────────────────────────
          _SectionLabel(label: 'ADD A TIP FOR YOUR COURIER'),
          const SizedBox(height: AppDimensions.sm),
          Row(
            children: [0, 30, 50, 100].map((tip) {
              final selected = checkoutState.tipRs == tip;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () =>
                        ref.read(checkoutNotifierProvider.notifier).setTip(tip),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: selected ? cs.primary : ac.creamSurface,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                            color: selected ? cs.primary : ac.border),
                      ),
                      child: Center(
                        child: Text(
                          tip == 0 ? 'None' : 'Rs $tip',
                          style: tt.bodySmall!.copyWith(
                            color: selected ? cs.onPrimary : cs.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: AppDimensions.lg),

          // ── Special Instructions ──────────────────────────────────
          _SectionLabel(label: 'SPECIAL INSTRUCTIONS'),
          const SizedBox(height: AppDimensions.sm),
          TextFormField(
            maxLines: 3,
            maxLength: 200,
            onChanged:
                ref.read(checkoutNotifierProvider.notifier).setInstructions,
            decoration: InputDecoration(
              hintText: 'Any special requests for the kitchen?',
              hintStyle: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant),
              filled: true,
              fillColor: ac.creamSurface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                borderSide: BorderSide(color: ac.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                borderSide: BorderSide(color: ac.border),
              ),
            ),
          ),

          const SizedBox(height: AppDimensions.lg),
          const Divider(),
          const SizedBox(height: AppDimensions.sm),

          // ── Price Summary ─────────────────────────────────────────
          PriceRow(label: 'Subtotal', amount: cartNotifier.subtotalRs),
          const SizedBox(height: 6),
          PriceRow(label: 'Delivery fee', amount: cartNotifier.deliveryFeeRs),
          if (cartNotifier.discountRs > 0) ...[
            const SizedBox(height: 6),
            PriceRow(label: 'Discount', amount: -cartNotifier.discountRs),
          ],
          if (checkoutState.tipRs > 0) ...[
            const SizedBox(height: 6),
            PriceRow(label: 'Tip', amount: checkoutState.tipRs),
          ],
          const SizedBox(height: AppDimensions.sm),
          const Divider(),
          const SizedBox(height: AppDimensions.sm),
          PriceRow(
            label: 'Total',
            amount: cartNotifier.totalRs + checkoutState.tipRs,
            isBold: true,
          ),

          if (checkoutState.error != null) ...[
            const SizedBox(height: AppDimensions.sm),
            Text(checkoutState.error!,
                style: tt.bodySmall!.copyWith(color: cs.error)),
          ],

          const SizedBox(height: AppDimensions.lg),

          // ── Place Order ───────────────────────────────────────────
          GradientButton(
            text:
                'Place order — ${Helpers.formatRs(cartNotifier.totalRs + checkoutState.tipRs)}',
            isLoading: checkoutState.isPlacingOrder,
            onPressed: () async {
              final order = await ref
                  .read(checkoutNotifierProvider.notifier)
                  .placeOrder();
              if (order != null && context.mounted) {
                AppNavigator.toOrderSuccess(context, order: order);
              }
            },
          ),

          const SizedBox(height: AppDimensions.xl),
        ],
      ),
    );
  }

  IconData _paymentIcon(PaymentType? type) {
    return switch (type) {
      PaymentType.cash => Icons.payments_outlined,
      PaymentType.wallet => Icons.account_balance_wallet_outlined,
      _ => Icons.credit_card_outlined,
    };
  }
}

// ── Summary tile (address or payment — single row with Change button) ──────────

class _SummaryTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool isEmpty;
  final String emptyLabel;
  final bool isLoading;
  final VoidCallback onChangeTap;
  final ColorScheme cs;
  final AppThemeColors ac;

  const _SummaryTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.isEmpty,
    required this.emptyLabel,
    required this.isLoading,
    required this.onChangeTap,
    required this.cs,
    required this.ac,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onChangeTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.md),
        decoration: BoxDecoration(
          color: ac.creamSurface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(color: isEmpty ? cs.error.withValues(alpha: 0.4) : ac.border),
        ),
        child: isLoading
            ? Row(
                children: [
                  const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2)),
                  const SizedBox(width: 12),
                  Text('Loading…',
                      style: tt.bodySmall
                          ?.copyWith(color: cs.onSurfaceVariant)),
                ],
              )
            : Row(
                children: [
                  Icon(icon,
                      size: 20,
                      color: isEmpty ? cs.onSurfaceVariant : cs.primary),
                  const SizedBox(width: AppDimensions.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: tt.titleSmall?.copyWith(
                            color: isEmpty
                                ? cs.onSurfaceVariant
                                : cs.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (subtitle != null)
                          Text(
                            subtitle!,
                            style: tt.bodySmall
                                ?.copyWith(color: cs.onSurfaceVariant),
                          ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: onChangeTap,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      isEmpty ? emptyLabel : 'Change',
                      style: tt.labelMedium?.copyWith(
                          color: cs.primary, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelSmall!.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            letterSpacing: 1.2,
          ),
    );
  }
}
