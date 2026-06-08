import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_delivery/core/constants/app_dimensions.dart';
import 'package:food_delivery/core/navigation/app_navigator.dart';
import 'package:food_delivery/core/utils/helpers.dart';
import 'package:food_delivery/core/widgets/empty_state_widget.dart';
import 'package:food_delivery/core/widgets/error_state_widget.dart';
import 'package:food_delivery/core/widgets/gradient_button.dart';
import 'package:food_delivery/features/profile/address/providers/address_notifier.dart';
import 'package:food_delivery/models/address_model.dart';
import 'package:food_delivery/theme/app_theme.dart';

class AddressScreen extends ConsumerWidget {
  const AddressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(addressNotifierProvider);
    final notifier = ref.read(addressNotifierProvider.notifier);
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Addresses', style: tt.titleLarge),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => AppNavigator.back(context),
        ),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? ErrorStateWidget(message: state.error!, onRetry: notifier.fetchAddresses)
              : state.addresses.isEmpty
                  ? const EmptyStateWidget(
                      title: 'No saved addresses',
                      subtitle: 'Add an address to speed up checkout',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(AppDimensions.screenPadding),
                      itemCount: state.addresses.length,
                      separatorBuilder: (_, _) => const SizedBox(height: AppDimensions.sm),
                      itemBuilder: (_, i) {
                        final address = state.addresses[i];
                        return Dismissible(
                          key: Key(address.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: cs.error,
                              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                            ),
                            child: Icon(Icons.delete_outline, color: cs.onError),
                          ),
                          onDismissed: (_) => notifier.delete(address.id),
                          child: _AddressTile(
                            address: address,
                            onSetDefault: () => notifier.setDefault(address.id),
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddAddressSheet(context, ref),
        icon: const Icon(Icons.add_location_alt_rounded),
        label: const Text('Add Address'),
      ),
    );
  }

  void _showAddAddressSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusLg)),
      ),
      builder: (_) => _AddAddressSheet(ref: ref),
    );
  }
}

class _AddressTile extends StatelessWidget {
  final AddressModel address;
  final VoidCallback onSetDefault;
  const _AddressTile({required this.address, required this.onSetDefault});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final ac = Theme.of(context).extension<AppThemeColors>()!;
    final cs = Theme.of(context).colorScheme;

    final icon = switch (address.label.toLowerCase()) {
      'home' => Icons.home_rounded,
      'work' => Icons.work_rounded,
      _ => Icons.location_on_rounded,
    };

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: address.isDefault ? cs.primaryContainer.withValues(alpha: 0.3) : ac.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(
          color: address.isDefault ? cs.primary : ac.border,
          width: address.isDefault ? 1.5 : 0.5,
        ),
        boxShadow: ac.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: cs.onPrimaryContainer, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(address.label, style: tt.titleSmall!.copyWith(fontWeight: FontWeight.w700)),
                    if (address.isDefault) ...[
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
                const SizedBox(height: 2),
                Text(
                  address.fullAddress,
                  style: tt.bodySmall!.copyWith(color: ac.secondaryText),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (!address.isDefault)
            TextButton(
              onPressed: onSetDefault,
              child: Text('Set default', style: tt.labelSmall!.copyWith(color: cs.primary)),
            ),
        ],
      ),
    );
  }
}

class _AddAddressSheet extends StatefulWidget {
  final WidgetRef ref;
  const _AddAddressSheet({required this.ref});

  @override
  State<_AddAddressSheet> createState() => _AddAddressSheetState();
}

class _AddAddressSheetState extends State<_AddAddressSheet> {
  final _formKey = GlobalKey<FormState>();
  final _addressCtrl = TextEditingController();
  String _label = 'Home';
  bool _isLoading = false;

  @override
  void dispose() {
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await widget.ref.read(addressNotifierProvider.notifier).addAddress(
            AddressModel(
              id: '',
              label: _label,
              fullAddress: _addressCtrl.text.trim(),
              lat: 0,
              lng: 0,
            ),
          );
      if (mounted) {
        Helpers.showSuccessSnackBar(context, 'Address saved!');
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) Helpers.showErrorSnackBar(context, 'Failed to save address.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppDimensions.screenPadding, AppDimensions.screenPadding,
        AppDimensions.screenPadding,
        AppDimensions.screenPadding + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Add Address', style: tt.titleMedium!.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: AppDimensions.md),

            // Label chips
            Row(
              children: ['Home', 'Work', 'Other'].map((l) {
                final selected = _label == l;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(l),
                    selected: selected,
                    onSelected: (_) => setState(() => _label = l),
                    selectedColor: cs.primaryContainer,
                    labelStyle: tt.labelMedium!.copyWith(
                      color: selected ? cs.onPrimaryContainer : null,
                      fontWeight: selected ? FontWeight.w700 : null,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppDimensions.sm),

            TextFormField(
              controller: _addressCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Full Address *',
                hintText: 'e.g. House 12, Block C, DHA Lahore',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMd)),
              ),
              validator: (v) => (v?.trim().isEmpty ?? true) ? 'Address required' : null,
            ),
            const SizedBox(height: AppDimensions.md),
            GradientButton(text: 'Save Address', isLoading: _isLoading, onPressed: _submit),
            const SizedBox(height: AppDimensions.sm),
          ],
        ),
      ),
    );
  }
}
