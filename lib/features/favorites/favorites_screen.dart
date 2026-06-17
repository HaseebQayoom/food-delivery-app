import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_delivery/core/constants/app_dimensions.dart';
import 'package:food_delivery/core/widgets/empty_state_widget.dart';
import 'package:food_delivery/core/widgets/error_state_widget.dart';
import 'package:food_delivery/core/widgets/skeleton_loader.dart';
import 'package:food_delivery/core/navigation/app_navigator.dart';
import 'package:food_delivery/features/cart/providers/cart_notifier.dart';
import 'package:food_delivery/features/favorites/providers/favorites_notifier.dart';
import 'package:food_delivery/features/home/widgets/meal_detail_view.dart';
import 'package:food_delivery/models/dish_model.dart';
import 'package:food_delivery/theme/app_theme.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(favoritesNotifierProvider);
    final notifier = ref.read(favoritesNotifierProvider.notifier);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final ac = Theme.of(context).extension<AppThemeColors>()!;

    final showDishes = state.filter == FavoritesFilter.all ||
        state.filter == FavoritesFilter.dishes;
    final showKitchens = state.filter == FavoritesFilter.all ||
        state.filter == FavoritesFilter.kitchens;
    final showLists = state.filter == FavoritesFilter.lists;

    final isEmpty = switch (state.filter) {
      FavoritesFilter.all =>
        state.dishes.isEmpty && state.restaurants.isEmpty,
      FavoritesFilter.dishes => state.dishes.isEmpty,
      FavoritesFilter.kitchens => state.restaurants.isEmpty,
      FavoritesFilter.lists => true,
    };

    return Scaffold(
      backgroundColor: ac.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.screenPadding,
                AppDimensions.md,
                AppDimensions.screenPadding,
                0,
              ),
              child: Text('Saved & loved', style: tt.headlineSmall),
            ),

            // ── Filter pills ──────────────────────────────────────────────
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.screenPadding,
                  AppDimensions.sm,
                  AppDimensions.screenPadding,
                  0,
                ),
                children: [
                  _FilterPill(
                    label: 'All',
                    selected: state.filter == FavoritesFilter.all,
                    onTap: () => notifier.setFilter(FavoritesFilter.all),
                    cs: cs,
                    tt: tt,
                    ac: ac,
                  ),
                  const SizedBox(width: AppDimensions.sm),
                  _FilterPill(
                    label: 'Dishes',
                    selected: state.filter == FavoritesFilter.dishes,
                    onTap: () => notifier.setFilter(FavoritesFilter.dishes),
                    cs: cs,
                    tt: tt,
                    ac: ac,
                  ),
                  const SizedBox(width: AppDimensions.sm),
                  _FilterPill(
                    label: 'Kitchens',
                    selected: state.filter == FavoritesFilter.kitchens,
                    onTap: () => notifier.setFilter(FavoritesFilter.kitchens),
                    cs: cs,
                    tt: tt,
                    ac: ac,
                  ),
                  const SizedBox(width: AppDimensions.sm),
                  _FilterPill(
                    label: 'Lists',
                    selected: state.filter == FavoritesFilter.lists,
                    onTap: () => notifier.setFilter(FavoritesFilter.lists),
                    cs: cs,
                    tt: tt,
                    ac: ac,
                  ),
                ],
              ),
            ),

            // ── Content ───────────────────────────────────────────────────
            Expanded(
              child: state.isLoading
                  ? ListView.separated(
                      padding: const EdgeInsets.all(AppDimensions.screenPadding),
                      itemCount: 4,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppDimensions.md),
                      itemBuilder: (_, _) => const SkeletonBox(
                        width: double.infinity,
                        height: 80,
                        borderRadius: AppDimensions.radiusMd,
                      ),
                    )
                  : state.error != null
                      ? ErrorStateWidget(
                          message: state.error!,
                          onRetry: () => notifier.fetchFavorites(),
                        )
                      : showLists
                          ? EmptyStateWidget(
                              title: 'No lists yet',
                              subtitle: 'Save collections of your favourite meals',
                              actionLabel: 'Coming soon',
                              onAction: () => ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Lists feature coming soon.'), duration: Duration(seconds: 2)),
                              ),
                            )
                          : isEmpty
                              ? EmptyStateWidget(
                                  title: 'Nothing saved yet',
                                  subtitle:
                                      'Heart dishes to save them here',
                                  actionLabel: 'Explore food',
                                  onAction: () => AppNavigator.toHome(context),
                                )
                              : RefreshIndicator(
                                  color: cs.primary,
                                  onRefresh: () => notifier.fetchFavorites(),
                                  child: ListView(
                                    padding: const EdgeInsets.fromLTRB(
                                      AppDimensions.screenPadding,
                                      AppDimensions.md,
                                      AppDimensions.screenPadding,
                                      104,
                                    ),
                                    children: [
                                      // Kitchen rows
                                      if (showKitchens &&
                                          state.restaurants.isNotEmpty) ...[
                                        Text('Kitchens',
                                            style: tt.titleMedium?.copyWith(
                                                fontWeight: FontWeight.w700)),
                                        const SizedBox(height: AppDimensions.sm),
                                        ...state.restaurants.map(
                                          (r) => _KitchenRow(
                                            name: r.name,
                                            imageUrl: r.imageUrl,
                                            cuisineTags: r.cuisineTags,
                                            onRemove: () => notifier
                                                .removeFavoriteRestaurant(r.id),
                                            tt: tt,
                                            ac: ac,
                                            cs: cs,
                                          ),
                                        ),
                                        if (showDishes &&
                                            state.dishes.isNotEmpty)
                                          const SizedBox(
                                              height: AppDimensions.lg),
                                      ],

                                      // Dish rows
                                      if (showDishes &&
                                          state.dishes.isNotEmpty) ...[
                                        Text('Dishes',
                                            style: tt.titleMedium?.copyWith(
                                                fontWeight: FontWeight.w700)),
                                        const SizedBox(height: AppDimensions.sm),
                                        ...state.dishes.map(
                                          (d) => _FavoriteDishRow(
                                            dish: d,
                                            onRemove: () =>
                                                notifier.removeFavoriteDish(d.id),
                                            ref: ref,
                                            tt: tt,
                                            ac: ac,
                                            cs: cs,
                                            context: context,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Private widgets ────────────────────────────────────────────────────────

class _FilterPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final ColorScheme cs;
  final TextTheme tt;
  final AppThemeColors ac;

  const _FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.cs,
    required this.tt,
    required this.ac,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.md,
          vertical: AppDimensions.sm,
        ),
        decoration: BoxDecoration(
          color: selected ? cs.primary : ac.creamSurface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusCircle),
          border: Border.all(
            color: selected ? cs.primary : ac.border,
          ),
        ),
        child: Text(
          label,
          style: tt.labelMedium?.copyWith(
            color: selected ? cs.onPrimary : ac.primaryText,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _FavoriteDishRow extends StatelessWidget {
  final DishModel dish;
  final VoidCallback onRemove;
  final WidgetRef ref;
  final TextTheme tt;
  final AppThemeColors ac;
  final ColorScheme cs;
  final BuildContext context;

  const _FavoriteDishRow({
    required this.dish,
    required this.onRemove,
    required this.ref,
    required this.tt,
    required this.ac,
    required this.cs,
    required this.context,
  });

  @override
  Widget build(BuildContext _) {
    return InkWell(
      onTap: () => showMealDetail(context, dish),
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
                      errorWidget: (context, _, _) => _imageFallback(),
                    )
                  : _imageFallback(),
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
                  const SizedBox(height: AppDimensions.xs),
                  Text(
                    'Rs ${dish.priceRs}',
                    style: tt.labelLarge?.copyWith(color: cs.primary),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.favorite_rounded, color: cs.error, size: 20),
              onPressed: onRemove,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: 'Remove',
            ),
            const SizedBox(width: AppDimensions.sm),
            IconButton(
              icon: Icon(Icons.add_circle_outline, color: cs.primary, size: 22),
              onPressed: () =>
                  ref.read(cartNotifierProvider.notifier).addItem(dish),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: 'Add to cart',
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageFallback() {
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

class _KitchenRow extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final List<String> cuisineTags;
  final VoidCallback onRemove;
  final TextTheme tt;
  final AppThemeColors ac;
  final ColorScheme cs;

  const _KitchenRow({
    required this.name,
    required this.imageUrl,
    required this.cuisineTags,
    required this.onRemove,
    required this.tt,
    required this.ac,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.sm),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            child: imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: imageUrl!,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    errorWidget: (context, _, _) => _fallback(),
                  )
                : _fallback(),
          ),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: tt.titleSmall),
                if (cuisineTags.isNotEmpty)
                  Text(
                    cuisineTags.join(' · '),
                    style: tt.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.favorite_rounded, color: cs.error, size: 20),
            onPressed: onRemove,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'Remove',
          ),
        ],
      ),
    );
  }

  Widget _fallback() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: ac.creamSurface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      ),
      child: Icon(Icons.storefront_outlined, color: ac.mutedText),
    );
  }
}
