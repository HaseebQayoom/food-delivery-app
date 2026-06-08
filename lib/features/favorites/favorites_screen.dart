import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_delivery/core/constants/app_dimensions.dart';
import 'package:food_delivery/core/widgets/dish_card.dart';
import 'package:food_delivery/core/widgets/empty_state_widget.dart';
import 'package:food_delivery/core/widgets/error_state_widget.dart';
import 'package:food_delivery/core/widgets/restaurant_card.dart';
import 'package:food_delivery/core/widgets/skeleton_loader.dart';
import 'package:food_delivery/features/favorites/providers/favorites_notifier.dart';
import 'package:food_delivery/theme/app_theme.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(favoritesNotifierProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final ac = Theme.of(context).extension<AppThemeColors>()!;

    final showDishes = state.filter != FavoritesFilter.restaurants;
    final showRestaurants = state.filter != FavoritesFilter.dishes;

    final isEmpty = (showDishes ? state.dishes.isEmpty : true) &&
        (showRestaurants ? state.restaurants.isEmpty : true);

    return Scaffold(
      backgroundColor: ac.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App bar
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.screenPadding, AppDimensions.md,
                AppDimensions.screenPadding, 0,
              ),
              child: Text('Your favorites', style: tt.headlineSmall),
            ),

            // Filter chips
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.screenPadding, AppDimensions.md,
                AppDimensions.screenPadding, 0,
              ),
              child: Row(
                children: [
                  _FilterChip(
                    label: 'All',
                    selected: state.filter == FavoritesFilter.all,
                    onTap: () => ref.read(favoritesNotifierProvider.notifier).setFilter(FavoritesFilter.all),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Dishes',
                    selected: state.filter == FavoritesFilter.dishes,
                    onTap: () => ref.read(favoritesNotifierProvider.notifier).setFilter(FavoritesFilter.dishes),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Restaurants',
                    selected: state.filter == FavoritesFilter.restaurants,
                    onTap: () => ref.read(favoritesNotifierProvider.notifier).setFilter(FavoritesFilter.restaurants),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: state.isLoading
                  ? ListView.separated(
                      padding: const EdgeInsets.all(AppDimensions.screenPadding),
                      itemCount: 4,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (_, _) => const RestaurantCardSkeleton(),
                    )
                  : state.error != null
                      ? ErrorStateWidget(
                          message: state.error!,
                          onRetry: () => ref.read(favoritesNotifierProvider.notifier).fetchFavorites(),
                        )
                      : isEmpty
                          ? EmptyStateWidget(
                              title: 'Nothing saved yet',
                              subtitle: 'Heart dishes and restaurants to save them here',
                              actionLabel: 'Explore food',
                              onAction: () {},
                            )
                          : RefreshIndicator(
                              color: cs.primary,
                              onRefresh: () => ref.read(favoritesNotifierProvider.notifier).fetchFavorites(),
                              child: ListView(
                                padding: const EdgeInsets.fromLTRB(
                                  AppDimensions.screenPadding, AppDimensions.md,
                                  AppDimensions.screenPadding, 104,
                                ),
                                children: [
                                  if (showRestaurants && state.restaurants.isNotEmpty) ...[
                                    ...state.restaurants.map(
                                      (r) => Padding(
                                        padding: const EdgeInsets.only(bottom: 12),
                                        child: RestaurantCard(
                                          restaurant: r,
                                          onTap: () {},
                                          isFavorite: true,
                                          onFavoriteToggle: () => ref
                                              .read(favoritesNotifierProvider.notifier)
                                              .removeFavoriteRestaurant(r.id),
                                        ),
                                      ),
                                    ),
                                  ],
                                  if (showDishes && state.dishes.isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    GridView.count(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 12,
                                      mainAxisSpacing: 12,
                                      childAspectRatio: 0.75,
                                      children: state.dishes
                                          .map((d) => DishCard(
                                                dish: d,
                                                isFavorite: true,
                                                onFavoriteToggle: () => ref
                                                    .read(favoritesNotifierProvider.notifier)
                                                    .removeFavoriteDish(d.id),
                                              ))
                                          .toList(),
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

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? cs.primary : cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: selected ? cs.onPrimary : cs.onSurface,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }
}
