import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_delivery/core/constants/app_dimensions.dart';
import 'package:food_delivery/core/navigation/app_navigator.dart';
import 'package:food_delivery/core/widgets/error_state_widget.dart';
import 'package:food_delivery/core/widgets/popular_meal_card.dart';
import 'package:food_delivery/features/cart/providers/cart_notifier.dart';
import 'package:food_delivery/features/home/providers/home_notifier.dart';
import 'package:food_delivery/features/home/widgets/meal_detail_view.dart';
import 'package:food_delivery/theme/app_theme.dart';

class CategoryGridScreen extends ConsumerStatefulWidget {
  const CategoryGridScreen({super.key});

  @override
  ConsumerState<CategoryGridScreen> createState() =>
      _CategoryGridScreenState();
}

class _CategoryGridScreenState extends ConsumerState<CategoryGridScreen> {
  String? _selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeNotifierProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final ac = Theme.of(context).extension<AppThemeColors>()!;
    final cartNotifier = ref.read(cartNotifierProvider.notifier);

    // Default to first category once data loads, without calling setState
    final effectiveId = _selectedCategoryId ??
        (homeState.categories.isNotEmpty
            ? homeState.categories.first.id
            : null);

    final dishes = homeState.menuByCategory[effectiveId] ?? [];

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
        title: Text('Browse Menu', style: tt.titleLarge),
      ),
      body: homeState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : homeState.error != null
              ? ErrorStateWidget(
                  message: homeState.error!,
                  onRetry: () => ref
                      .read(homeNotifierProvider.notifier)
                      .fetchRestaurantData(),
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Left category rail ────────────────────────────────
                    SizedBox(
                      width: 80,
                      child: ListView.builder(
                        itemCount: homeState.categories.length,
                        itemBuilder: (_, i) {
                          final cat = homeState.categories[i];
                          final isSelected = effectiveId == cat.id;

                          return GestureDetector(
                            onTap: () =>
                                setState(() => _selectedCategoryId = cat.id),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                vertical: AppDimensions.md,
                                horizontal: AppDimensions.sm,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? cs.primary.withValues(alpha: 0.08)
                                    : Colors.transparent,
                                border: Border(
                                  left: BorderSide(
                                    color: isSelected
                                        ? cs.primary
                                        : Colors.transparent,
                                    width: 3,
                                  ),
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    cat.emoji,
                                    style: const TextStyle(fontSize: 22),
                                  ),
                                  const SizedBox(height: AppDimensions.xs),
                                  Text(
                                    cat.name,
                                    style: tt.labelSmall?.copyWith(
                                      color: isSelected
                                          ? cs.primary
                                          : ac.secondaryText,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.normal,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // ── Vertical divider ──────────────────────────────────
                    VerticalDivider(width: 1, color: ac.border),

                    // ── Right dish grid ───────────────────────────────────
                    Expanded(
                      child: dishes.isEmpty
                          ? Center(
                              child: Text(
                                'No dishes in this category',
                                style: tt.bodyMedium,
                              ),
                            )
                          : GridView.builder(
                              padding: const EdgeInsets.all(AppDimensions.md),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: AppDimensions.md,
                                mainAxisSpacing: AppDimensions.md,
                                childAspectRatio: 0.70,
                              ),
                              itemCount: dishes.length,
                              itemBuilder: (_, i) {
                                final dish = dishes[i];
                                return PopularMealCard(
                                  dish: dish,
                                  onTap: () => showMealDetail(context, dish),
                                  onAddToCart: () =>
                                      cartNotifier.addItem(dish),
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }
}
