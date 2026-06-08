import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_delivery/core/constants/app_dimensions.dart';
import 'package:food_delivery/core/navigation/admin_navigator.dart';
import 'package:food_delivery/core/utils/helpers.dart';
import 'package:food_delivery/core/widgets/gradient_button.dart';
import 'package:food_delivery/features/admin/categories/admin_categories_notifier.dart';
import 'package:food_delivery/features/admin/widgets/color_picker_row.dart';
import 'package:food_delivery/models/category_model.dart';

class CategoryFormScreen extends ConsumerStatefulWidget {
  final CategoryModel? category;
  const CategoryFormScreen({super.key, this.category});

  @override
  ConsumerState<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends ConsumerState<CategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _nameCtrl = TextEditingController(text: widget.category?.name);
  late final _emojiCtrl = TextEditingController(text: widget.category?.emoji);
  late Color _selectedColor;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.category?.bgColor ?? categoryPresetColors.first;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emojiCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final cat = CategoryModel(
        id: widget.category?.id ?? '',
        name: _nameCtrl.text.trim(),
        emoji: _emojiCtrl.text.trim(),
        bgColor: _selectedColor,
      );
      final notifier = ref.read(adminCategoriesNotifierProvider.notifier);
      if (widget.category == null) {
        await notifier.addCategory(cat);
      } else {
        await notifier.updateCategory(cat);
      }
      if (mounted) {
        Helpers.showSuccessSnackBar(context, widget.category == null ? 'Category added!' : 'Category updated!');
        AdminNavigator.back(context);
      }
    } catch (e) {
      if (mounted) Helpers.showErrorSnackBar(context, 'Failed to save category.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category == null ? 'Add Category' : 'Edit Category', style: tt.titleLarge),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => AdminNavigator.back(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.screenPadding),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Preview
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(color: _selectedColor, borderRadius: BorderRadius.circular(16)),
                    child: Center(
                      child: Text(
                        _emojiCtrl.text.isNotEmpty ? _emojiCtrl.text : '?',
                        style: const TextStyle(fontSize: 36),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.lg),

                TextFormField(
                  controller: _nameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Category Name *',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMd)),
                  ),
                  validator: (v) => (v?.trim().isEmpty ?? true) ? 'Name required' : null,
                ),
                const SizedBox(height: AppDimensions.sm),

                TextFormField(
                  controller: _emojiCtrl,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: 'Emoji *',
                    hintText: '🍔',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMd)),
                  ),
                  validator: (v) => (v?.trim().isEmpty ?? true) ? 'Emoji required' : null,
                ),
                const SizedBox(height: AppDimensions.lg),

                Text('Background Color', style: tt.titleSmall),
                const SizedBox(height: AppDimensions.sm),
                ColorPickerRow(
                  colors: categoryPresetColors,
                  selected: _selectedColor,
                  onSelect: (c) => setState(() => _selectedColor = c),
                ),
                const SizedBox(height: AppDimensions.xl),

                GradientButton(text: 'Save Category', isLoading: _isLoading, onPressed: _submit),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
