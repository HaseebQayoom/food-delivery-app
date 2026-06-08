import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_delivery/core/constants/app_dimensions.dart';
import 'package:food_delivery/core/widgets/category_chip.dart';
import 'package:food_delivery/core/widgets/custom_search_bar.dart';
import 'package:food_delivery/core/widgets/dish_card.dart';
import 'package:food_delivery/core/widgets/error_state_widget.dart';
import 'package:food_delivery/core/widgets/restaurant_card.dart';
import 'package:food_delivery/core/widgets/section_header.dart';
import 'package:food_delivery/core/widgets/skeleton_loader.dart';
import 'package:food_delivery/core/navigation/app_navigator.dart';
import 'package:food_delivery/features/cart/providers/cart_notifier.dart';
import 'package:food_delivery/features/home/providers/home_notifier.dart';
import 'package:food_delivery/theme/app_theme.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeNotifierProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final ac = Theme.of(context).extension<AppThemeColors>()!;

    return Scaffold(
      backgroundColor: ac.background,
      body: RefreshIndicator(
        color: cs.primary,
        onRefresh: () => ref.read(homeNotifierProvider.notifier).fetchAll(),
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimensions.screenPadding,
                    AppDimensions.md,
                    AppDimensions.screenPadding,
                    0,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => AppNavigator.toAddresses(context),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Deliver to',
                              style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant),
                            ),
                            Row(
                              children: [
                                Icon(Icons.location_pin, size: 14, color: cs.error),
                                const SizedBox(width: 4),
                                Text(
                                  'Lahore, Punjab',
                                  style: tt.titleSmall!.copyWith(fontWeight: FontWeight.w600),
                                ),
                                Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: cs.onSurface),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: ac.creamSurface,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.notifications_outlined, size: 18, color: cs.onSurface),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Greeting + search
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.screenPadding, AppDimensions.md,
                  AppDimensions.screenPadding, AppDimensions.sm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hey there,\nwhat are you craving? 🍕',
                      style: tt.headlineMedium!.copyWith(height: 1.2),
                    ),
                    const SizedBox(height: AppDimensions.md),
                    CustomSearchBar(
                      hint: 'Search restaurants or dishes',
                      onChanged: (_) {},
                      onFilterTap: () {
                        final notifier = ref.read(homeNotifierProvider.notifier);
                        final cats = homeState.categories;
                        final selected = homeState.selectedCategoryId;
                        showModalBottomSheet(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                          ),
                          builder: (ctx) => Padding(
                            padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: Container(
                                    width: 36,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: ac.border,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text('Filter by Category', style: tt.titleMedium),
                                const SizedBox(height: 16),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    FilterChip(
                                      label: const Text('All'),
                                      selected: selected == null || selected.isEmpty,
                                      onSelected: (_) {
                                        notifier.selectCategory(null);
                                        Navigator.pop(ctx);
                                      },
                                    ),
                                    ...cats.map(
                                      (cat) => FilterChip(
                                        label: Text('${cat.emoji} ${cat.name}'),
                                        selected: selected == cat.id,
                                        onSelected: (_) {
                                          notifier.selectCategory(
                                            selected == cat.id ? null : cat.id,
                                          );
                                          Navigator.pop(ctx);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Hero promo card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.screenPadding),
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [const Color(0xFFEF9F27), cs.primary],
                    ),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                  ),
                  padding: const EdgeInsets.all(AppDimensions.md),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                "TODAY'S DEAL",
                                style: tt.labelSmall!.copyWith(
                                  color: Colors.white,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Get 20% off',
                              style: tt.headlineSmall!.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              'On orders above Rs 500',
                              style: tt.bodySmall!.copyWith(
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Order now',
                          style: tt.labelMedium!.copyWith(color: cs.primary, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Categories
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppDimensions.screenPadding, AppDimensions.lg,
                      AppDimensions.screenPadding, AppDimensions.sm,
                    ),
                    child: SectionHeader(
                      title: 'Categories',
                      actionLabel: 'See all',
                      onAction: () => ref.read(homeNotifierProvider.notifier).selectCategory(null),
                    ),
                  ),
                  SizedBox(
                    height: 90,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.screenPadding),
                      itemCount: homeState.categories.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 12),
                      itemBuilder: (_, i) {
                        final cat = homeState.categories[i];
                        return CategoryChip(
                          label: cat.name,
                          icon: Text(cat.emoji, style: const TextStyle(fontSize: 26)),
                          bgColor: cat.bgColor,
                          isSelected: homeState.selectedCategoryId == cat.id,
                          onTap: () => ref
                              .read(homeNotifierProvider.notifier)
                              .selectCategory(
                                homeState.selectedCategoryId == cat.id ? null : cat.id,
                              ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Hot right now
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppDimensions.screenPadding, AppDimensions.lg,
                      AppDimensions.screenPadding, AppDimensions.sm,
                    ),
                    child: SectionHeader(
                      title: 'Hot right now 🔥',
                      actionLabel: 'See all',
                      onAction: () {
                        ref.read(homeNotifierProvider.notifier).selectCategory(null);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Showing all ${homeState.dishes.length} dishes'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    height: 250,
                    child: homeState.isLoading
                        ? ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.screenPadding),
                            itemCount: 3,
                            separatorBuilder: (_, _) => const SizedBox(width: 12),
                            itemBuilder: (_, _) => const DishCardSkeleton(),
                          )
                        : homeState.dishes.isEmpty
                            ? const Center(child: Text('No dishes found'))
                            : ListView.separated(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.screenPadding),
                                itemCount: homeState.dishes.length,
                                separatorBuilder: (_, _) => const SizedBox(width: 12),
                                itemBuilder: (_, i) {
                                  final dish = homeState.dishes[i];
                                  return DishCard(
                                    dish: dish,
                                    isFavorite: dish.isFavorite,
                                    onTap: () => AppNavigator.toRestaurantDetail(
                                      context,
                                      restaurantId: dish.restaurantId,
                                    ),
                                    onFavoriteToggle: () => ref
                                        .read(homeNotifierProvider.notifier)
                                        .toggleDishFavorite(i),
                                    onAddToCart: () =>
                                        ref.read(cartNotifierProvider.notifier).addItem(dish),
                                  );
                                },
                              ),
                  ),
                ],
              ),
            ),

            // Popular restaurants header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.screenPadding, AppDimensions.lg,
                  AppDimensions.screenPadding, AppDimensions.sm,
                ),
                child: SectionHeader(
                  title: 'Popular restaurants',
                  actionLabel: 'See all',
                  onAction: () => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Showing all ${homeState.restaurants.length} restaurants'),
                      duration: const Duration(seconds: 2),
                    ),
                  ),
                ),
              ),
            ),

            // Restaurant list
            if (homeState.isLoading)
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, _) => const Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppDimensions.screenPadding, 0,
                      AppDimensions.screenPadding, AppDimensions.sm,
                    ),
                    child: RestaurantCardSkeleton(),
                  ),
                  childCount: 3,
                ),
              )
            else if (homeState.error != null)
              SliverToBoxAdapter(
                child: ErrorStateWidget(
                  message: homeState.error!,
                  onRetry: () => ref.read(homeNotifierProvider.notifier).fetchAll(),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) {
                    final r = homeState.restaurants[i];
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppDimensions.screenPadding, 0,
                        AppDimensions.screenPadding, AppDimensions.sm,
                      ),
                      child: RestaurantCard(
                        restaurant: r,
                        onTap: () => AppNavigator.toRestaurantDetail(context, restaurantId: r.id),
                      ),
                    );
                  },
                  childCount: homeState.restaurants.length,
                ),
              ),

            // Bottom padding for floating nav bar
            const SliverToBoxAdapter(child: SizedBox(height: 104)),
          ],
        ),
      ),
    );
  }
}
