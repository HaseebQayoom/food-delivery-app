import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_delivery/core/constants/app_dimensions.dart';
import 'package:food_delivery/features/favorites/providers/favorites_notifier.dart';
import 'package:food_delivery/models/dish_model.dart';
import 'package:food_delivery/theme/app_theme.dart';

class PopularMealCard extends ConsumerWidget {
  final DishModel dish;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;

  const PopularMealCard({
    super.key,
    required this.dish,
    required this.onTap,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final ac = Theme.of(context).extension<AppThemeColors>()!;

    final isFavorite = ref
        .watch(favoritesNotifierProvider)
        .dishes
        .any((d) => d.id == dish.id);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: ac.creamSurface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          boxShadow: ac.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image with badge + heart overlay
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppDimensions.radiusMd),
                  ),
                  child: dish.imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: dish.imageUrl!,
                          width: 160,
                          height: 160,
                          fit: BoxFit.cover,
                          errorWidget: (context, _, _) => _fallback(ac),
                        )
                      : _fallback(ac),
                ),
                // Tag badge (bottom-left)
                if (dish.tag.isNotEmpty)
                  Positioned(
                    top: AppDimensions.sm,
                    left: AppDimensions.sm,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.sm,
                        vertical: 3,
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
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                // Heart button (top-right)
                Positioned(
                  top: AppDimensions.sm,
                  right: AppDimensions.sm,
                  child: GestureDetector(
                    onTap: () => ref
                        .read(favoritesNotifierProvider.notifier)
                        .toggleFavoriteDish(dish),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: isFavorite ? cs.error : ac.mutedText,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Info row
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dish.name,
                          style: tt.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(Icons.star_rounded,
                                size: 11, color: ac.warning),
                            const SizedBox(width: 2),
                            Text(
                              dish.rating.toStringAsFixed(1),
                              style: tt.labelSmall
                                  ?.copyWith(color: ac.mutedText),
                            ),
                            if (dish.calories > 0) ...[
                              Text(
                                ' · ',
                                style: tt.labelSmall
                                    ?.copyWith(color: ac.mutedText),
                              ),
                              Text(
                                '${dish.calories} kcal',
                                style: tt.labelSmall
                                    ?.copyWith(color: ac.mutedText),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Rs ${dish.priceRs}',
                          style: tt.labelLarge?.copyWith(color: cs.primary),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: onAddToCart,
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: cs.primary,
                      child: Icon(Icons.add, size: 16, color: cs.onPrimary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallback(AppThemeColors ac) {
    return Container(
      width: 160,
      height: 160,
      color: ac.creamSurface,
      child: Icon(Icons.restaurant, color: ac.mutedText, size: 40),
    );
  }
}
