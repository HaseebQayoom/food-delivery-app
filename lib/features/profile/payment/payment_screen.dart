import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_delivery/core/constants/app_dimensions.dart';
import 'package:food_delivery/core/navigation/app_navigator.dart';
import 'package:food_delivery/core/utils/helpers.dart';
import 'package:food_delivery/core/widgets/empty_state_widget.dart';
import 'package:food_delivery/core/widgets/error_state_widget.dart';
import 'package:food_delivery/core/widgets/gradient_button.dart';
import 'package:food_delivery/features/profile/payment/providers/payment_notifier.dart';
import 'package:food_delivery/models/payment_method_model.dart';
import 'package:food_delivery/theme/app_theme.dart';

class PaymentScreen extends ConsumerWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(paymentNotifierProvider);
    final notifier = ref.read(paymentNotifierProvider.notifier);
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Methods', style: tt.titleLarge),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => AppNavigator.back(context),
        ),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? ErrorStateWidget(message: state.error!, onRetry: notifier.fetchMethods)
              : state.methods.isEmpty
                  ? const EmptyStateWidget(
                      title: 'No payment methods',
                      subtitle: 'Add a card or enable cash on delivery',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(AppDimensions.screenPadding),
                      itemCount: state.methods.length,
                      separatorBuilder: (_, _) => const SizedBox(height: AppDimensions.sm),
                      itemBuilder: (_, i) => _PaymentTile(
                        method: state.methods[i],
                        onSetDefault: () => notifier.setDefault(state.methods[i].id),
                        onDelete: () { notifier.deleteMethod(state.methods[i].id); },
                      ),
                    ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSheet(context, ref),
        icon: const Icon(Icons.add_card_rounded),
        label: const Text('Add Method'),
      ),
    );
  }

  void _showAddSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusLg)),
      ),
      builder: (_) => _AddPaymentSheet(ref: ref),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  final PaymentMethodModel method;
  final VoidCallback onSetDefault;
  final VoidCallback onDelete;
  const _PaymentTile({required this.method, required this.onSetDefault, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final ac = Theme.of(context).extension<AppThemeColors>()!;
    final cs = Theme.of(context).colorScheme;

    final icon = switch (method.type) {
      PaymentType.card => Icons.credit_card_rounded,
      PaymentType.cash => Icons.payments_rounded,
      PaymentType.wallet => Icons.account_balance_wallet_rounded,
    };

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: method.isDefault ? cs.primaryContainer.withValues(alpha: 0.3) : ac.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(
          color: method.isDefault ? cs.primary : ac.border,
          width: method.isDefault ? 1.5 : 0.5,
        ),
        boxShadow: ac.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: cs.secondaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: cs.onSecondaryContainer, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(method.label, style: tt.titleSmall!.copyWith(fontWeight: FontWeight.w700)),
                    if (method.isDefault) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: cs.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Default',
                          style: tt.labelSmall!.copyWith(color: cs.onPrimary, fontSize: 9),
                        ),
                      ),
                    ],
                  ],
                ),
                if (method.lastFour != null)
                  Text(
                    '•••• •••• •••• ${method.lastFour}',
                    style: tt.bodySmall!.copyWith(color: ac.mutedText),
                  ),
              ],
            ),
          ),
          if (!method.isDefault)
            TextButton(
              onPressed: onSetDefault,
              child: Text('Set default', style: tt.labelSmall!.copyWith(color: cs.primary)),
            ),
          IconButton(
            icon: Icon(Icons.delete_outline_rounded, color: cs.error, size: 20),
            tooltip: 'Remove',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Remove payment method?'),
                  content: Text('Remove "${method.label}"?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text('Remove', style: TextStyle(color: cs.error)),
                    ),
                  ],
                ),
              );
              if (confirm == true) onDelete();
            },
          ),
        ],
      ),
    );
  }
}

class _AddPaymentSheet extends StatefulWidget {
  final WidgetRef ref;
  const _AddPaymentSheet({required this.ref});

  @override
  State<_AddPaymentSheet> createState() => _AddPaymentSheetState();
}

class _AddPaymentSheetState extends State<_AddPaymentSheet> {
  final _lastFourCtrl = TextEditingController();
  PaymentType _type = PaymentType.card;
  bool _isLoading = false;

  @override
  void dispose() {
    _lastFourCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
      final label = switch (_type) {
        PaymentType.card => 'Card ending ${_lastFourCtrl.text.trim()}',
        PaymentType.cash => 'Cash on Delivery',
        PaymentType.wallet => 'Crave Wallet',
      };
      await widget.ref.read(paymentNotifierProvider.notifier).addMethod(
            PaymentMethodModel(
              id: '',
              type: _type,
              label: label,
              lastFour: _type == PaymentType.card ? _lastFourCtrl.text.trim() : null,
            ),
          );
      if (mounted) {
        Helpers.showSuccessSnackBar(context, 'Payment method added!');
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) Helpers.showErrorSnackBar(context, 'Failed to add payment method.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppDimensions.screenPadding, AppDimensions.screenPadding,
        AppDimensions.screenPadding,
        AppDimensions.screenPadding + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Add Payment Method', style: tt.titleMedium!.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: AppDimensions.md),

          // Type selector
          SegmentedButton<PaymentType>(
            segments: const [
              ButtonSegment(
                value: PaymentType.card,
                icon: Icon(Icons.credit_card_rounded, size: 18),
                label: Text('Card'),
              ),
              ButtonSegment(
                value: PaymentType.cash,
                icon: Icon(Icons.payments_rounded, size: 18),
                label: Text('Cash'),
              ),
              ButtonSegment(
                value: PaymentType.wallet,
                icon: Icon(Icons.account_balance_wallet_rounded, size: 18),
                label: Text('Wallet'),
              ),
            ],
            selected: {_type},
            onSelectionChanged: (s) => setState(() => _type = s.first),
          ),

          if (_type == PaymentType.card) ...[
            const SizedBox(height: AppDimensions.sm),
            TextFormField(
              controller: _lastFourCtrl,
              keyboardType: TextInputType.number,
              maxLength: 4,
              decoration: InputDecoration(
                labelText: 'Last 4 digits',
                hintText: '1234',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMd)),
              ),
            ),
          ],

          const SizedBox(height: AppDimensions.md),
          GradientButton(text: 'Add Method', isLoading: _isLoading, onPressed: _submit),
          const SizedBox(height: AppDimensions.sm),
        ],
      ),
    );
  }
}
