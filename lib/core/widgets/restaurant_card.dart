import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery/core/constants/app_dimensions.dart';
import 'package:food_delivery/models/restaurant_model.dart';
import 'package:food_delivery/theme/app_theme.dart';

class RestaurantCard extends StatelessWidget {
  final RestaurantModel restaurant;
  final VoidCallback? onTap;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;

  const RestaurantCard({
    super.key,
    required this.restaurant,
    this.onTap,
    this.isFavorite = false,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ac = Theme.of(context).extension<AppThemeColors>()!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.sm),
        decoration: BoxDecoration(
          color: ac.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(color: ac.border, width: 0.5),
          boxShadow: ac.cardShadow,
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              child: restaurant.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: restaurant.imageUrl!,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorWidget: (_, _, _) => _placeholder(cs),
                    )
                  : _placeholder(cs),
            ),
            const SizedBox(width: AppDimensions.sm + 4),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          restaurant.name,
                          style: Theme.of(context).textTheme.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (onFavoriteToggle != null) ...[
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: onFavoriteToggle,
                          child: Icon(
                            isFavorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: isFavorite ? cs.primary : ac.primaryText,
                            size: AppDimensions.iconSm,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    restaurant.cuisineTags.join(' · '),
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      // Rating
                      const Icon(
                        Icons.star_rounded,
                        color: Color(0xFFFFB400),
                        size: 14,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        restaurant.rating.toStringAsFixed(1),
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(width: 8),
                      // Delivery time
                      Icon(
                        Icons.schedule_rounded,
                        color: ac.mutedText,
                        size: 12,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${restaurant.deliveryTimeMin} min',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(width: 8),
                      // Min order
                      Text(
                        'Min Rs ${restaurant.minOrderRs}',
                        style: Theme.of(context).textTheme.bodySmall,
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

  Widget _placeholder(ColorScheme cs) {
    return Container(
      width: 70,
      height: 70,
      color: cs.primaryContainer,
      child: const Center(
        child: Text('🍽️', style: TextStyle(fontSize: 28)),
      ),
    );
  }
}
