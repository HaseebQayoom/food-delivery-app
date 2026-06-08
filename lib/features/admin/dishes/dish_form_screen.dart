import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_delivery/core/constants/app_dimensions.dart';
import 'package:food_delivery/core/navigation/admin_navigator.dart';
import 'package:food_delivery/core/utils/helpers.dart';
import 'package:food_delivery/core/widgets/custom_text_field.dart';
import 'package:food_delivery/core/widgets/gradient_button.dart';
import 'package:food_delivery/features/admin/dishes/admin_dishes_notifier.dart';
import 'package:food_delivery/models/dish_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

class DishFormScreen extends ConsumerStatefulWidget {
  final DishModel? dish;
  const DishFormScreen({super.key, this.dish});

  @override
  ConsumerState<DishFormScreen> createState() => _DishFormScreenState();
}

class _DishFormScreenState extends ConsumerState<DishFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _nameCtrl = TextEditingController(text: widget.dish?.name);
  late final _restaurantCtrl = TextEditingController(text: widget.dish?.restaurantName);
  late final _priceCtrl = TextEditingController(text: widget.dish?.priceRs.toString());
  late final _calCtrl = TextEditingController(text: widget.dish?.calories.toString());
  late final _tagCtrl = TextEditingController(text: widget.dish?.tag);
  late final _imageCtrl = TextEditingController(text: widget.dish?.imageUrl);
  bool _isLoading = false;

  @override
  void dispose() {
    for (final c in [_nameCtrl, _restaurantCtrl, _priceCtrl, _calCtrl, _tagCtrl, _imageCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final notifier = ref.read(adminDishesNotifierProvider.notifier);
      final dish = DishModel(
        id: widget.dish?.id ?? '',
        name: _nameCtrl.text.trim(),
        restaurantId: widget.dish?.restaurantId ?? '',
        restaurantName: _restaurantCtrl.text.trim(),
        priceRs: int.parse(_priceCtrl.text.trim()),
        calories: int.parse(_calCtrl.text.trim()),
        tag: _tagCtrl.text.trim().toUpperCase(),
        imageUrl: _imageCtrl.text.trim().isEmpty ? null : _imageCtrl.text.trim(),
      );
      if (widget.dish == null) {
        await notifier.addDish(dish);
      } else {
        await notifier.updateDish(dish);
      }
      if (mounted) {
        Helpers.showSuccessSnackBar(context, widget.dish == null ? 'Dish added!' : 'Dish updated!');
        AdminNavigator.back(context);
      }
    } catch (e) {
      if (mounted) Helpers.showErrorSnackBar(context, 'Failed to save dish.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final imageUrl = _imageCtrl.text.trim();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.dish == null ? 'Add Dish' : 'Edit Dish', style: tt.titleLarge),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => AdminNavigator.back(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.screenPadding),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image preview
                if (imageUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      height: 200,
                      fit: BoxFit.cover,
                      errorWidget: (_, _, _) => Container(
                        height: 200,
                        color: cs.surfaceContainerLowest,
                        child: const Icon(Icons.broken_image_outlined, size: 40),
                      ),
                    ),
                  ),

                const SizedBox(height: AppDimensions.md),
                CustomTextField(
                  label: 'Dish Name *',
                  hint: 'e.g. Crispy Chicken Burger',
                  controller: _nameCtrl,
                  validator: (v) => (v?.trim().isEmpty ?? true) ? 'Dish name required' : null,
                ),
                const SizedBox(height: AppDimensions.sm),
                CustomTextField(
                  label: 'Restaurant Name *',
                  hint: 'e.g. Burger Lab',
                  controller: _restaurantCtrl,
                  validator: (v) => (v?.trim().isEmpty ?? true) ? 'Restaurant name required' : null,
                ),
                const SizedBox(height: AppDimensions.sm),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Price (Rs) *',
                        hint: '350',
                        controller: _priceCtrl,
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          final n = int.tryParse(v ?? '');
                          if (n == null || n <= 0) return 'Enter valid price';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        label: 'Calories *',
                        hint: '450',
                        controller: _calCtrl,
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          final n = int.tryParse(v ?? '');
                          if (n == null || n <= 0) return 'Enter calories';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.sm),
                CustomTextField(
                  label: 'Tag / Badge',
                  hint: 'BESTSELLER',
                  controller: _tagCtrl,
                ),
                const SizedBox(height: AppDimensions.sm),
                CustomTextField(
                  label: 'Image URL',
                  hint: 'https://example.com/image.jpg',
                  controller: _imageCtrl,
                  keyboardType: TextInputType.url,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: AppDimensions.lg),
                GradientButton(text: 'Save Dish', isLoading: _isLoading, onPressed: _submit),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
