import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_delivery/core/constants/app_dimensions.dart';
import 'package:food_delivery/features/favorites/providers/favorites_notifier.dart';
import 'package:food_delivery/models/dish_model.dart';
import 'package:food_delivery/theme/app_theme.dart';

class MealListRow extends ConsumerWidget {
  final DishModel dish;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;

  const MealListRow({
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

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              child: dish.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: dish.imageUrl!,
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                      errorWidget: (context, _, _) => _fallback(ac),
                    )
                  : _fallback(ac),
            ),
            const SizedBox(width: AppDimensions.md),
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
                  Text(
                    dish.description.isNotEmpty
                        ? dish.description
                        : dish.restaurantName,
                    style: tt.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.star_rounded, size: 12, color: ac.warning),
                      const SizedBox(width: 3),
                      Text(
                        dish.rating > 0
                            ? '${dish.rating.toStringAsFixed(1)} · ${dish.prepTimeMin} min'
                            : '${dish.prepTimeMin} min',
                        style: tt.bodySmall?.copyWith(
                          color: ac.mutedText,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.xs),
                  Text(
                    'Rs ${dish.priceRs}',
                    style: tt.labelLarge?.copyWith(color: cs.primary),
                  ),
                ],
              ),
            ),
            // Favourite toggle
            IconButton(
              icon: Icon(
                isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: isFavorite ? cs.error : ac.mutedText,
                size: 20,
              ),
              onPressed: () => ref
                  .read(favoritesNotifierProvider.notifier)
                  .toggleFavoriteDish(dish),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: isFavorite ? 'Remove from favourites' : 'Save',
            ),
            const SizedBox(width: AppDimensions.sm),
            // Add to cart
            IconButton(
              icon: Icon(Icons.add_circle_outline, color: cs.primary),
              onPressed: onAddToCart,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: 'Add to cart',
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallback(AppThemeColors ac) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: ac.creamSurface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      ),
      child: Icon(Icons.restaurant, color: ac.mutedText),
    );
  }
}
