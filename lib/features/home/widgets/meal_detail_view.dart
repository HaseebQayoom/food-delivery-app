import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_delivery/core/constants/app_dimensions.dart';
import 'package:food_delivery/features/cart/providers/cart_notifier.dart';
import 'package:food_delivery/models/dish_model.dart';
import 'package:food_delivery/theme/app_theme.dart';

// Static design data
const _kSizes = ['Single', 'Double', 'Triple'];
const _kSizeMultipliers = [1.0, 1.5, 2.0];
const _kSpiceLevels = ['Mild 🌶', 'Medium 🌶🌶', 'Hot 🌶🌶🌶', 'Inferno 🔥'];
const _kAddons = [
  {'name': 'Bacon Strips', 'priceRs': 120},
  {'name': 'Extra Cheese', 'priceRs': 80},
  {'name': 'Jalapeños', 'priceRs': 50},
  {'name': 'Extra Sauce', 'priceRs': 40},
];

void showMealDetail(BuildContext context, DishModel dish) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => MealDetailView(dish: dish),
  );
}

class MealDetailView extends ConsumerStatefulWidget {
  final DishModel dish;

  const MealDetailView({super.key, required this.dish});

  @override
  ConsumerState<MealDetailView> createState() => _MealDetailViewState();
}

class _MealDetailViewState extends ConsumerState<MealDetailView> {
  String _selectedSize = 'Single';
  String _spiceLevel = 'Mild 🌶';
  final Set<String> _selectedAddons = {};
  int _quantity = 1;

  int _sizePrice(int index) {
    return (widget.dish.priceRs * _kSizeMultipliers[index]).round();
  }

  int get _unitPriceRs {
    final sizeIdx = _kSizes.indexOf(_selectedSize);
    final basePrice = _sizePrice(sizeIdx);
    final addonTotal = _kAddons
        .where((a) => _selectedAddons.contains(a['name'] as String))
        .fold(0, (sum, a) => sum + (a['priceRs'] as int));
    return basePrice + addonTotal;
  }

  int get _totalPriceRs => _unitPriceRs * _quantity;

  void _addToCart() {
    ref.read(cartNotifierProvider.notifier).addItem(
      widget.dish,
      selectedSize: _selectedSize,
      addonNames: _selectedAddons.toList(),
      unitPriceRs: _unitPriceRs,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final dish = widget.dish;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final ac = Theme.of(context).extension<AppThemeColors>()!;
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: ac.background,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppDimensions.radiusLg),
            ),
          ),
          child: Stack(
            children: [
              // ── Scrollable content ──────────────────────────────────────
              SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero image
                    dish.imageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: dish.imageUrl!,
                            height: 320,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorWidget: (context, _, _) =>
                                _imageFallback(ac),
                          )
                        : _imageFallback(ac),

                    // Drag handle
                    Center(
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: AppDimensions.md,
                        ),
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: ac.border,
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusCircle,
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.screenPadding,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name + price row
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(dish.name, style: tt.headlineMedium),
                              ),
                              const SizedBox(width: AppDimensions.sm),
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  'Rs ${dish.priceRs}',
                                  style: tt.titleMedium?.copyWith(
                                    color: cs.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // Tag badge (if present)
                          if (dish.tag.isNotEmpty) ...[
                            const SizedBox(height: AppDimensions.xs),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppDimensions.sm,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: cs.primary,
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusCircle,
                                ),
                              ),
                              child: Text(
                                dish.tag.toUpperCase(),
                                style: tt.labelSmall?.copyWith(
                                  color: cs.onPrimary,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: AppDimensions.sm),

                          // Meta row
                          Row(
                            children: [
                              Icon(Icons.star_rounded,
                                  size: 14, color: ac.warning),
                              const SizedBox(width: 3),
                              Text(
                                dish.rating.toStringAsFixed(1),
                                style: tt.bodySmall,
                              ),
                              Text(' · ', style: tt.bodySmall),
                              Text(
                                '${dish.prepTimeMin} min',
                                style: tt.bodySmall,
                              ),
                              Text(' · ', style: tt.bodySmall),
                              Text(
                                '${dish.calories} cal',
                                style: tt.bodySmall,
                              ),
                            ],
                          ),
                          const SizedBox(height: AppDimensions.md),

                          // Description
                          if (dish.description.isNotEmpty)
                            Text(
                              dish.description,
                              style: tt.bodyMedium,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),

                          const SizedBox(height: AppDimensions.md),
                          const Divider(),
                          const SizedBox(height: AppDimensions.md),

                          // ── Size selector ─────────────────────────────
                          Text('Choose size', style: tt.titleSmall),
                          const SizedBox(height: AppDimensions.sm),
                          Row(
                            children: List.generate(_kSizes.length, (i) {
                              final isSelected = _selectedSize == _kSizes[i];
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => _selectedSize = _kSizes[i]),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 180),
                                    margin: EdgeInsets.only(
                                      right: i < _kSizes.length - 1
                                          ? AppDimensions.sm
                                          : 0,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppDimensions.sm,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? cs.primary
                                          : ac.creamSurface,
                                      borderRadius: BorderRadius.circular(
                                        AppDimensions.radiusMd,
                                      ),
                                      border: Border.all(
                                        color: isSelected
                                            ? cs.primary
                                            : ac.border,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          _kSizes[i],
                                          style: tt.labelMedium?.copyWith(
                                            color: isSelected
                                                ? cs.onPrimary
                                                : ac.primaryText,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          'Rs ${_sizePrice(i)}',
                                          style: tt.labelSmall?.copyWith(
                                            color: isSelected
                                                ? cs.onPrimary.withValues(
                                                    alpha: 0.85)
                                                : ac.mutedText,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),

                          const SizedBox(height: AppDimensions.lg),

                          // ── Spice level ───────────────────────────────
                          Text('Spice level', style: tt.titleSmall),
                          const SizedBox(height: AppDimensions.sm),
                          Wrap(
                            spacing: AppDimensions.sm,
                            runSpacing: AppDimensions.sm,
                            children: _kSpiceLevels.map((level) {
                              final isSelected = _spiceLevel == level;
                              return GestureDetector(
                                onTap: () =>
                                    setState(() => _spiceLevel = level),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppDimensions.md,
                                    vertical: AppDimensions.sm,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? cs.primary
                                        : ac.creamSurface,
                                    borderRadius: BorderRadius.circular(
                                      AppDimensions.radiusCircle,
                                    ),
                                    border: Border.all(
                                      color: isSelected
                                          ? cs.primary
                                          : ac.border,
                                    ),
                                  ),
                                  child: Text(
                                    level,
                                    style: tt.labelMedium?.copyWith(
                                      color: isSelected
                                          ? cs.onPrimary
                                          : ac.primaryText,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: AppDimensions.lg),

                          // ── Add-ons ───────────────────────────────────
                          Text('Add-ons', style: tt.titleSmall),
                          const SizedBox(height: AppDimensions.sm),
                          ..._kAddons.map((addon) {
                            final name = addon['name'] as String;
                            final price = addon['priceRs'] as int;
                            final checked = _selectedAddons.contains(name);
                            return InkWell(
                              onTap: () => setState(() {
                                if (checked) {
                                  _selectedAddons.remove(name);
                                } else {
                                  _selectedAddons.add(name);
                                }
                              }),
                              borderRadius: BorderRadius.circular(
                                AppDimensions.sm,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppDimensions.sm,
                                ),
                                child: Row(
                                  children: [
                                    Checkbox(
                                      value: checked,
                                      onChanged: (value) => setState(() {
                                        if (value == true) {
                                          _selectedAddons.add(name);
                                        } else {
                                          _selectedAddons.remove(name);
                                        }
                                      }),
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    Expanded(
                                      child: Text(name, style: tt.bodyMedium),
                                    ),
                                    Text(
                                      '+Rs $price',
                                      style: tt.bodySmall?.copyWith(
                                        color: cs.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),

                          // Space for sticky bar
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Sticky bottom bar ────────────────────────────────────
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: ac.background,
                  padding: EdgeInsets.fromLTRB(
                    AppDimensions.screenPadding,
                    AppDimensions.md,
                    AppDimensions.screenPadding,
                    AppDimensions.md + bottomInset,
                  ),
                  child: Row(
                    children: [
                      // Quantity control
                      _QtyButton(
                        icon: Icons.remove,
                        onTap: _quantity > 1
                            ? () => setState(() => _quantity--)
                            : null,
                        ac: ac,
                        cs: cs,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.md,
                        ),
                        child: Text(
                          '$_quantity',
                          style: tt.titleMedium,
                        ),
                      ),
                      _QtyButton(
                        icon: Icons.add,
                        onTap: () => setState(() => _quantity++),
                        ac: ac,
                        cs: cs,
                      ),
                      const SizedBox(width: AppDimensions.md),
                      // Add to cart button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _addToCart,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusCircle,
                              ),
                            ),
                          ),
                          child: Text(
                            'Add to cart · Rs $_totalPriceRs',
                            style: tt.labelLarge?.copyWith(
                              color: cs.onPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _imageFallback(AppThemeColors ac) {
    return Container(
      height: 320,
      width: double.infinity,
      color: ac.creamSurface,
      child: Icon(Icons.restaurant, size: 60, color: ac.mutedText),
    );
  }
}

// Internal quantity button
class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final AppThemeColors ac;
  final ColorScheme cs;

  const _QtyButton({
    required this.icon,
    required this.onTap,
    required this.ac,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: enabled ? ac.creamSurface : ac.border,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(color: ac.border),
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? ac.primaryText : ac.mutedText,
        ),
      ),
    );
  }
}
