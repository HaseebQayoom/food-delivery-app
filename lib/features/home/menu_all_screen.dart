import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_delivery/core/constants/app_dimensions.dart';
import 'package:food_delivery/core/navigation/app_navigator.dart';
import 'package:food_delivery/core/widgets/error_state_widget.dart';
import 'package:food_delivery/core/widgets/meal_list_row.dart';
import 'package:food_delivery/features/cart/providers/cart_notifier.dart';
import 'package:food_delivery/features/home/providers/home_notifier.dart';
import 'package:food_delivery/features/home/widgets/meal_detail_view.dart';
import 'package:food_delivery/models/category_model.dart';
import 'package:food_delivery/theme/app_theme.dart';

class MenuAllScreen extends ConsumerStatefulWidget {
  const MenuAllScreen({super.key});

  @override
  ConsumerState<MenuAllScreen> createState() => _MenuAllScreenState();
}

class _MenuAllScreenState extends ConsumerState<MenuAllScreen> {
  String? _selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeNotifierProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final ac = Theme.of(context).extension<AppThemeColors>()!;

    final noneSelected = _selectedCategoryId == null;
    final filteredDishes = noneSelected
        ? const []
        : (homeState.menuByCategory[_selectedCategoryId] ?? []);

    return Scaffold(
      backgroundColor: ac.background,
      appBar: AppBar(
        backgroundColor: ac.background,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => AppNavigator.back(context),
        ),
        title: Text('Full Menu', style: tt.titleLarge),
      ),
      body: CustomScrollView(
        slivers: [
          // ── Category pills ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: SizedBox(
              height: 52,
              child: homeState.isLoading
                  ? const SizedBox.shrink()
                  : ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.screenPadding,
                        vertical: AppDimensions.sm,
                      ),
                      itemCount: homeState.categories.length + 1,
                      separatorBuilder: (_, _) =>
                          const SizedBox(width: AppDimensions.sm),
                      itemBuilder: (_, i) {
                        final label =
                            i == 0 ? 'All' : homeState.categories[i - 1].name;
                        final isSelected = i == 0
                            ? noneSelected
                            : _selectedCategoryId ==
                                homeState.categories[i - 1].id;

                        return GestureDetector(
                          onTap: () => setState(() {
                            _selectedCategoryId = i == 0
                                ? null
                                : homeState.categories[i - 1].id;
                          }),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.md,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected ? cs.primary : ac.creamSurface,
                              borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusCircle),
                              border: Border.all(
                                color: isSelected ? cs.primary : ac.border,
                              ),
                            ),
                            child: Text(
                              label,
                              style: tt.labelMedium?.copyWith(
                                color:
                                    isSelected ? cs.onPrimary : ac.primaryText,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),

          // ── Loading ────────────────────────────────────────────────────
          if (homeState.isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )

          // ── Error ──────────────────────────────────────────────────────
          else if (homeState.error != null)
            SliverFillRemaining(
              child: ErrorStateWidget(
                message: homeState.error!,
                onRetry: () =>
                    ref.read(homeNotifierProvider.notifier).fetchRestaurantData(),
              ),
            )

          // ── Filtered single category ───────────────────────────────────
          else if (!noneSelected) ...[
            if (filteredDishes.isEmpty)
              const SliverFillRemaining(
                child: Center(child: Text('No dishes in this category')),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.screenPadding),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) {
                      final dish = filteredDishes[i];
                      return MealListRow(
                        dish: dish,
                        onTap: () => showMealDetail(context, dish),
                        onAddToCart: () => ref
                            .read(cartNotifierProvider.notifier)
                            .addItem(dish),
                      );
                    },
                    childCount: filteredDishes.length,
                  ),
                ),
              ),
          ]

          // ── All categories ─────────────────────────────────────────────
          else
            ..._buildAllSlivers(context, homeState.categories,
                homeState.menuByCategory, tt, ac),

          // ── Bottom padding ─────────────────────────────────────────────
          const SliverToBoxAdapter(child: SizedBox(height: AppDimensions.lg)),
        ],
      ),
    );
  }

  List<Widget> _buildAllSlivers(
    BuildContext context,
    List<CategoryModel> categories,
    Map<String, List> menuByCategory,
    TextTheme tt,
    AppThemeColors ac,
  ) {
    final slivers = <Widget>[];

    for (final cat in categories) {
      final dishes = menuByCategory[cat.id] ?? [];
      if (dishes.isEmpty) continue;

      slivers.add(SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.screenPadding,
            AppDimensions.lg,
            AppDimensions.screenPadding,
            AppDimensions.sm,
          ),
          child: Text(
            '${cat.emoji} ${cat.name}',
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      ));

      slivers.add(SliverPadding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.screenPadding),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, i) {
              final dish = dishes[i];
              return MealListRow(
                dish: dish,
                onTap: () => showMealDetail(context, dish),
                onAddToCart: () =>
                    ref.read(cartNotifierProvider.notifier).addItem(dish),
              );
            },
            childCount: dishes.length,
          ),
        ),
      ));
    }

    if (slivers.isEmpty) {
      slivers.add(const SliverFillRemaining(
        child: Center(child: Text('No menu items available')),
      ));
    }

    return slivers;
  }
}
