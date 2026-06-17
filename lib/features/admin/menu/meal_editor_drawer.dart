import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_delivery/core/constants/app_dimensions.dart';
import 'package:food_delivery/features/admin/dishes/admin_dishes_notifier.dart';
import 'package:food_delivery/features/admin/widgets/availability_switch.dart';
import 'package:food_delivery/theme/app_theme.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _kBadges = ['', 'Bestseller', 'Spicy', 'Chef pick', 'Hot', 'New'];

class MealEditorDrawer extends ConsumerStatefulWidget {
  final String dishId; // 'new' or a dish UUID
  final VoidCallback onClose;

  const MealEditorDrawer({
    super.key,
    required this.dishId,
    required this.onClose,
  });

  @override
  ConsumerState<MealEditorDrawer> createState() => _MealEditorDrawerState();
}

class _MealEditorDrawerState extends ConsumerState<MealEditorDrawer> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _caloriesCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _imageUrlCtrl;
  String _categoryId = '';
  String _badge = '';
  bool _isAvailable = true;
  bool _isUploading = false;

  bool get _isNew => widget.dishId == 'new';

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _priceCtrl = TextEditingController();
    _caloriesCtrl = TextEditingController();
    _descCtrl = TextEditingController();
    _imageUrlCtrl = TextEditingController();

    final state = ref.read(adminDishesProvider);
    if (_isNew) {
      _categoryId =
          state.categories.isNotEmpty ? state.categories.first.id : '';
    } else {
      final dish =
          state.dishes.where((d) => d.id == widget.dishId).firstOrNull;
      if (dish != null) {
        _nameCtrl.text = dish.name;
        _priceCtrl.text = dish.priceRs.toString();
        _caloriesCtrl.text = dish.calories == 0 ? '' : dish.calories.toString();
        _descCtrl.text = dish.description;
        _imageUrlCtrl.text = dish.imageUrl ?? '';
        _categoryId = dish.categoryId;
        _badge = dish.tag;
        _isAvailable = dish.isAvailable;
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _caloriesCtrl.dispose();
    _descCtrl.dispose();
    _imageUrlCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAndUpload() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );
    if (file == null) return;
    setState(() => _isUploading = true);
    try {
      final bytes = await file.readAsBytes();
      final ext = file.name.split('.').last.toLowerCase();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$ext';
      await Supabase.instance.client.storage
          .from('dish-images')
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: FileOptions(contentType: 'image/$ext', upsert: true),
          );
      final url = Supabase.instance.client.storage
          .from('dish-images')
          .getPublicUrl(fileName);
      setState(() {
        _imageUrlCtrl.text = url;
        _isUploading = false;
      });
    } catch (e) {
      setState(() => _isUploading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    }
  }

  void _handleSave() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item name is required')),
      );
      return;
    }
    final state = ref.read(adminDishesProvider);
    final fields = <String, dynamic>{
      'name': name,
      'price_rs': int.tryParse(_priceCtrl.text.trim()) ?? 0,
      'calories': int.tryParse(_caloriesCtrl.text.trim()) ?? 0,
      'category_id': _categoryId,
      'tag': _badge,
      'description': _descCtrl.text.trim(),
      'is_available': _isAvailable,
      'image_url': _imageUrlCtrl.text.trim().isEmpty ? null : _imageUrlCtrl.text.trim(),
    };
    if (_isNew) {
      final restId = state.restaurantId;
      if (restId != null) fields['restaurant_id'] = restId;
      fields['restaurant_name'] = 'Smoke & Stack';
      ref.read(adminDishesProvider.notifier).createDish(fields);
    } else {
      ref.read(adminDishesProvider.notifier).updateDish(widget.dishId, fields);
    }
  }

  InputDecoration _fieldDec(
    AppThemeColors ac,
    ColorScheme cs, {
    String hint = '',
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: ac.mutedText, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: ac.border, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: ac.border, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: cs.primary, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ac = Theme.of(context).extension<AppThemeColors>()!;
    final state = ref.watch(adminDishesProvider);

    ref.listen<AdminDishesState>(adminDishesProvider, (prev, next) {
      if (next.error != null && next.error != prev?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!)),
        );
      }
    });

    final saving = state.isLoading;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 60,
            offset: const Offset(-8, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 20, 20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isNew ? 'Add menu item' : 'Edit item',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: ac.primaryText,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _isNew
                            ? 'Fill in the details below'
                            : 'Update the item details',
                        style: TextStyle(fontSize: 12.5, color: ac.mutedText),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: widget.onClose,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F4EF),
                      border: Border.all(color: ac.border),
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusXs),
                    ),
                    child: Icon(Icons.close, size: 17, color: ac.primaryText),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: ac.border),

          // ── Scrollable body ──────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image preview
                  _FieldLabel('PHOTO', ac: ac),
                  GestureDetector(
                    onTap: _isUploading ? null : _pickAndUpload,
                    child: Stack(
                      children: [
                        _ImageArea(
                          imageUrl: _imageUrlCtrl.text.trim().isEmpty
                              ? null
                              : _imageUrlCtrl.text.trim(),
                          ac: ac,
                        ),
                        if (_isUploading)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.45),
                                borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusSm),
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        if (!_isUploading)
                          Positioned(
                            bottom: 10,
                            right: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.55),
                                borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusCircle),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.photo_library_outlined,
                                      size: 13, color: Colors.white),
                                  SizedBox(width: 5),
                                  Text('Choose photo',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white)),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _imageUrlCtrl,
                    style: TextStyle(fontSize: 12, color: ac.mutedText),
                    decoration: _fieldDec(ac, cs, hint: 'Or paste an image URL…'),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 20),

                  // Item name
                  _FieldLabel('ITEM NAME', ac: ac),
                  TextField(
                    controller: _nameCtrl,
                    style: TextStyle(fontSize: 14, color: ac.primaryText),
                    decoration: _fieldDec(ac, cs, hint: 'e.g. Smoke Stack Burger'),
                  ),
                  const SizedBox(height: 16),

                  // Price + Calories
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _FieldLabel('PRICE (RS)', ac: ac),
                            TextField(
                              controller: _priceCtrl,
                              style: TextStyle(fontSize: 14, color: ac.primaryText),
                              keyboardType: TextInputType.number,
                              decoration: _fieldDec(ac, cs, hint: '0'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _FieldLabel('CALORIES (KCAL)', ac: ac),
                            TextField(
                              controller: _caloriesCtrl,
                              style: TextStyle(fontSize: 14, color: ac.primaryText),
                              keyboardType: TextInputType.number,
                              decoration: _fieldDec(ac, cs, hint: '0'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Category chips
                  _FieldLabel('CATEGORY', ac: ac),
                  _ChipGroup(
                    opts: state.categories
                        .map((c) => (value: c.id, label: c.name))
                        .toList(),
                    selected: _categoryId,
                    onChanged: (v) => setState(() => _categoryId = v),
                    ac: ac,
                    cs: cs,
                  ),
                  const SizedBox(height: 16),

                  // Badge chips
                  _FieldLabel('BADGE', ac: ac),
                  _ChipGroup(
                    opts: _kBadges
                        .map((b) => (value: b, label: b.isEmpty ? 'None' : b))
                        .toList(),
                    selected: _badge,
                    onChanged: (v) => setState(() => _badge = v),
                    ac: ac,
                    cs: cs,
                  ),
                  const SizedBox(height: 16),

                  // Description
                  _FieldLabel('DESCRIPTION', ac: ac),
                  TextField(
                    controller: _descCtrl,
                    maxLines: 3,
                    style: TextStyle(fontSize: 14, color: ac.primaryText),
                    decoration: _fieldDec(
                      ac,
                      cs,
                      hint: 'Brief description of the item…',
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Availability toggle
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: ac.border)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Availability',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: ac.primaryText,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Item will ${_isAvailable ? '' : 'not '}be shown to customers',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: ac.mutedText,
                                ),
                              ),
                            ],
                          ),
                        ),
                        AvailabilitySwitch(
                          value: _isAvailable,
                          onTap: () =>
                              setState(() => _isAvailable = !_isAvailable),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          // ── Footer ──────────────────────────────────────────────────
          Divider(height: 1, color: ac.border),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: widget.onClose,
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: ac.border),
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusSm),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: ac.primaryText,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: saving ? null : _handleSave,
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: saving
                            ? cs.primary.withValues(alpha: 0.5)
                            : cs.primary,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusSm),
                        boxShadow: saving
                            ? null
                            : [
                                BoxShadow(
                                  color: cs.primary.withValues(alpha: 0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                      ),
                      alignment: Alignment.center,
                      child: saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _isNew ? 'Add to menu' : 'Save changes',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _ImageArea extends StatelessWidget {
  final String? imageUrl;
  final AppThemeColors ac;

  const _ImageArea({required this.imageUrl, required this.ac});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 168,
      decoration: BoxDecoration(
        color: ac.creamSurface,
        border: Border.all(color: ac.border, width: 1.5),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      ),
      clipBehavior: Clip.hardEdge,
      child: imageUrl != null
          ? CachedNetworkImage(
              imageUrl: imageUrl!,
              fit: BoxFit.cover,
              errorWidget: (_, _, _) => _ImagePlaceholder(ac: ac),
            )
          : _ImagePlaceholder(ac: ac),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  final AppThemeColors ac;
  const _ImagePlaceholder({required this.ac});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.8),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.camera_alt_outlined, size: 22, color: ac.mutedText),
        ),
        const SizedBox(height: 10),
        Text(
          'Upload photo',
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: ac.secondaryText,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'PNG, JPG · max 3 MB',
          style: TextStyle(fontSize: 12, color: ac.mutedText),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  final AppThemeColors ac;

  const _FieldLabel(this.text, {required this.ac});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: ac.mutedText,
        ),
      ),
    );
  }
}

class _ChipGroup extends StatelessWidget {
  final List<({String value, String label})> opts;
  final String selected;
  final ValueChanged<String> onChanged;
  final AppThemeColors ac;
  final ColorScheme cs;

  const _ChipGroup({
    required this.opts,
    required this.selected,
    required this.onChanged,
    required this.ac,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: opts.map((o) {
        final on = selected == o.value;
        return GestureDetector(
          onTap: () => onChanged(o.value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: on ? ac.softAccentSurface : Colors.white,
              border: Border.all(
                color: on ? cs.primary : ac.border,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
            ),
            child: Text(
              o.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: on ? cs.primary : ac.secondaryText,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
