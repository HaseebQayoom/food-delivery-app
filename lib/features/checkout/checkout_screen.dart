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
import 'package:food_delivery/models/address_model.dart';
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

    final addresses = addressState.addresses;
    final payments = paymentState.methods;

    // Auto-select defaults the first time data arrives
    if (checkoutState.selectedAddress == null && addresses.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final def = addresses.firstWhere(
          (a) => a.isDefault,
          orElse: () => addresses.first,
        );
        ref.read(checkoutNotifierProvider.notifier).selectAddress(def);
      });
    }
    if (checkoutState.selectedPayment == null && payments.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final def = payments.firstWhere(
          (p) => p.isDefault,
          orElse: () => payments.first,
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

          if (addressState.isLoading)
            _LoadingRow(label: 'Loading addresses…', ac: ac)
          else if (addresses.isEmpty)
            _EmptySection(
              message: 'No saved addresses yet.',
              actionLabel: 'Add address',
              onAction: () => AppNavigator.toAddresses(context),
              cs: cs,
              ac: ac,
            )
          else
            ...addresses.map((addr) => _AddressTile(
                  address: addr,
                  isSelected: checkoutState.selectedAddress?.id == addr.id,
                  onTap: () =>
                      ref.read(checkoutNotifierProvider.notifier).selectAddress(addr),
                )),

          const SizedBox(height: AppDimensions.lg),

          // ── Payment Method ────────────────────────────────────────
          _SectionLabel(label: 'PAYMENT METHOD'),
          const SizedBox(height: AppDimensions.sm),

          if (paymentState.isLoading)
            _LoadingRow(label: 'Loading payment methods…', ac: ac)
          else if (payments.isEmpty)
            _EmptySection(
              message: 'No payment methods saved.',
              actionLabel: 'Add payment method',
              onAction: () => AppNavigator.toPaymentMethods(context),
              cs: cs,
              ac: ac,
            )
          else
            ...payments.map((pm) => _PaymentTile(
                  method: pm,
                  isSelected: checkoutState.selectedPayment?.id == pm.id,
                  onTap: () =>
                      ref.read(checkoutNotifierProvider.notifier).selectPayment(pm),
                )),

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
            onChanged: ref.read(checkoutNotifierProvider.notifier).setInstructions,
            decoration: InputDecoration(
              hintText: 'Any special requests for the kitchen?',
              hintStyle:
                  tt.bodySmall!.copyWith(color: cs.onSurfaceVariant),
              filled: true,
              fillColor: ac.creamSurface,
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusMd),
                borderSide: BorderSide(color: ac.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusMd),
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
              final order =
                  await ref.read(checkoutNotifierProvider.notifier).placeOrder();
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
}

// ── Shared section label ──────────────────────────────────────────────────────

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

// ── Loading placeholder ───────────────────────────────────────────────────────

class _LoadingRow extends StatelessWidget {
  final String label;
  final AppThemeColors ac;
  const _LoadingRow({required this.label, required this.ac});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ac.creamSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall!
                  .copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

// ── Empty section with add CTA ────────────────────────────────────────────────

class _EmptySection extends StatelessWidget {
  final String message;
  final String actionLabel;
  final VoidCallback onAction;
  final ColorScheme cs;
  final AppThemeColors ac;
  const _EmptySection({
    required this.message,
    required this.actionLabel,
    required this.onAction,
    required this.cs,
    required this.ac,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: ac.creamSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ac.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(message,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall!
                    .copyWith(color: cs.onSurfaceVariant)),
          ),
          TextButton(
            onPressed: onAction,
            child: Text(actionLabel,
                style: TextStyle(color: cs.primary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// ── Address tile ──────────────────────────────────────────────────────────────

class _AddressTile extends StatelessWidget {
  final AddressModel address;
  final bool isSelected;
  final VoidCallback onTap;

  const _AddressTile(
      {required this.address, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ac = Theme.of(context).extension<AppThemeColors>()!;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? cs.primaryContainer : ac.creamSurface,
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: isSelected ? cs.primary : ac.border),
        ),
        child: Row(
          children: [
            Icon(Icons.location_on_outlined,
                size: 18,
                color: isSelected ? cs.primary : cs.onSurfaceVariant),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(address.label,
                      style: Theme.of(context).textTheme.titleSmall),
                  Text(address.fullAddress,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall!
                          .copyWith(color: cs.onSurfaceVariant)),
                ],
              ),
            ),
            if (isSelected) Icon(Icons.check_circle, color: cs.primary, size: 18),
          ],
        ),
      ),
    );
  }
}

// ── Payment tile ──────────────────────────────────────────────────────────────

class _PaymentTile extends StatelessWidget {
  final PaymentMethodModel method;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentTile(
      {required this.method, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ac = Theme.of(context).extension<AppThemeColors>()!;
    final icon = method.type == PaymentType.cash
        ? Icons.payments_outlined
        : method.type == PaymentType.card
            ? Icons.credit_card_outlined
            : Icons.account_balance_wallet_outlined;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? cs.primaryContainer : ac.creamSurface,
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: isSelected ? cs.primary : ac.border),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 18,
                color: isSelected ? cs.primary : cs.onSurfaceVariant),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                method.lastFour != null
                    ? '${method.label} ••••${method.lastFour}'
                    : method.label,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            if (isSelected) Icon(Icons.check_circle, color: cs.primary, size: 18),
          ],
        ),
      ),
    );
  }
}
