import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery/core/constants/app_dimensions.dart';
import 'package:food_delivery/models/dish_model.dart';
import 'package:food_delivery/theme/app_theme.dart';

class DishCard extends StatelessWidget {
  final DishModel dish;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onAddToCart;
  final VoidCallback? onTap;

  const DishCard({
    super.key,
    required this.dish,
    this.isFavorite = false,
    this.onFavoriteToggle,
    this.onAddToCart,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final ac = Theme.of(context).extension<AppThemeColors>()!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(color: ac.border, width: 0.5),
          boxShadow: ac.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image floats inside the card with its own 18px radius on all corners
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: SizedBox(
                    height: 130,
                    width: double.infinity,
                    child: dish.imageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: dish.imageUrl!,
                            fit: BoxFit.cover,
                            errorWidget: (_, _, _) => _imageFallback(ac),
                          )
                        : _imageFallback(ac),
                  ),
                ),

                // Tag badge — top left
                if (dish.tag.isNotEmpty)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: ac.primaryText.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusCircle),
                      ),
                      child: Text(
                        dish.tag.toUpperCase(),
                        style: tt.labelSmall!.copyWith(
                          color: Colors.white,
                          fontSize: 9,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),

                // Favorite button — top right
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: onFavoriteToggle,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        size: AppDimensions.iconSm,
                        color: isFavorite ? cs.primary : ac.primaryText,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Details
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dish.name,
                    style: tt.titleSmall!.copyWith(fontSize: 15),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${dish.restaurantName} · ${dish.calories} kcal',
                    style: tt.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'Rs ${_fmt(dish.priceRs)}',
                        style: tt.titleMedium!.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: onAddToCart,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: cs.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.add,
                            color: cs.onPrimary,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageFallback(AppThemeColors ac) {
    return Container(
      color: ac.creamSurface,
      child: const Center(
        child: Text('🍔', style: TextStyle(fontSize: 36)),
      ),
    );
  }

  String _fmt(int n) {
    if (n >= 1000) {
      return n.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+$)'),
        (m) => '${m[1]},',
      );
    }
    return n.toString();
  }
}
