import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery/core/constants/app_colors.dart';
import 'package:food_delivery/core/constants/app_dimensions.dart';
import 'package:food_delivery/features/admin/widgets/availability_switch.dart';
import 'package:food_delivery/models/dish_model.dart';
import 'package:food_delivery/theme/app_theme.dart';

class MenuCard extends StatelessWidget {
  final DishModel dish;
  final String categoryName;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleAvailability;
  final VoidCallback onTogglePopular;

  const MenuCard({
    super.key,
    required this.dish,
    required this.categoryName,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleAvailability,
    required this.onTogglePopular,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ac = Theme.of(context).extension<AppThemeColors>()!;
    final tt = Theme.of(context).textTheme;
    final available = dish.isAvailable;

    return GestureDetector(
      onTap: onEdit,
      child: Opacity(
        opacity: available ? 1.0 : 0.72,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: ac.border),
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          ),
          clipBehavior: Clip.hardEdge,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ImageArea(dish: dish, available: available, ac: ac, cs: cs, onEdit: onEdit),
              Expanded(
                child: _DetailsArea(
                  dish: dish,
                  categoryName: categoryName,
                  available: available,
                  ac: ac,
                  tt: tt,
                  cs: cs,
                  onEdit: onEdit,
                  onDelete: onDelete,
                  onToggleAvailability: onToggleAvailability,
                  onTogglePopular: onTogglePopular,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImageArea extends StatelessWidget {
  final DishModel dish;
  final bool available;
  final AppThemeColors ac;
  final ColorScheme cs;
  final VoidCallback onEdit;

  const _ImageArea({
    required this.dish,
    required this.available,
    required this.ac,
    required this.cs,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background + image
          Container(color: ac.creamSurface),
          if (dish.imageUrl != null)
            CachedNetworkImage(
              imageUrl: dish.imageUrl!,
              fit: BoxFit.cover,
              errorWidget: (_, _, _) => const SizedBox.shrink(),
            ),
          // Tag badge — top left
          if (dish.tag.isNotEmpty)
            Positioned(
              top: 10,
              left: 10,
              child: _TagBadge(tag: dish.tag, ac: ac),
            ),
          // Edit overlay — top right
          Positioned(
            top: 10,
            right: 10,
            child: GestureDetector(
              onTap: onEdit,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusCircle),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.14),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit_outlined, size: 13, color: ac.primaryText),
                    const SizedBox(width: 5),
                    Text(
                      'Edit',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: ac.primaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Sold-out overlay
          if (!available)
            Positioned.fill(
              child: Container(
                color: Colors.white.withValues(alpha: 0.55),
                alignment: Alignment.center,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: ac.primaryText,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusCircle),
                  ),
                  child: Text(
                    'Sold out',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TagBadge extends StatelessWidget {
  final String tag;
  final AppThemeColors ac;

  const _TagBadge({required this.tag, required this.ac});

  @override
  Widget build(BuildContext context) {
    final isSpicy = RegExp(r'spic|hot|infern', caseSensitive: false).hasMatch(tag);
    final isSave = RegExp(r'save|combo', caseSensitive: false).hasMatch(tag);
    final Color bg;
    final Color fg;
    if (isSpicy) {
      bg = AppColors.tagSpicy;
      fg = Colors.white;
    } else if (isSave) {
      bg = ac.success;
      fg = Colors.white;
    } else {
      bg = Colors.white.withValues(alpha: 0.92);
      fg = ac.primaryText;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCircle),
      ),
      child: Text(
        tag.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
          color: fg,
        ),
      ),
    );
  }
}

class _DetailsArea extends StatelessWidget {
  final DishModel dish;
  final String categoryName;
  final bool available;
  final AppThemeColors ac;
  final TextTheme tt;
  final ColorScheme cs;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleAvailability;
  final VoidCallback onTogglePopular;

  const _DetailsArea({
    required this.dish,
    required this.categoryName,
    required this.available,
    required this.ac,
    required this.tt,
    required this.cs,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleAvailability,
    required this.onTogglePopular,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dish.name,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$categoryName · ${dish.calories} kcal',
                      style: TextStyle(fontSize: 11.5, color: ac.mutedText),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.sm),
              Text(
                'Rs ${dish.priceRs}',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: onToggleAvailability,
                behavior: HitTestBehavior.opaque,
                child: AvailabilitySwitch(value: available, onTap: onToggleAvailability),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _SmallIconButton(
                    onTap: onTogglePopular,
                    ac: ac,
                    child: Icon(
                      dish.popular ? Icons.star_rounded : Icons.star_border_rounded,
                      size: 14,
                      color: dish.popular ? const Color(0xFFFFB800) : ac.mutedText,
                    ),
                  ),
                  const SizedBox(width: 6),
                  _SmallIconButton(
                    onTap: onEdit,
                    ac: ac,
                    child: Icon(Icons.edit_outlined, size: 14, color: ac.secondaryText),
                  ),
                  const SizedBox(width: 6),
                  _SmallIconButton(
                    onTap: onDelete,
                    ac: ac,
                    child: const Icon(Icons.delete_outline, size: 14, color: AppColors.statusCancelledFg),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SmallIconButton extends StatelessWidget {
  final VoidCallback onTap;
  final AppThemeColors ac;
  final Widget child;

  const _SmallIconButton({required this.onTap, required this.ac, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: const Color(0xFFF7F4EF),
          border: Border.all(color: ac.border),
          borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
        ),
        child: Center(child: child),
      ),
    );
  }
}
