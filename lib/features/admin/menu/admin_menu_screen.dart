import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_delivery/core/constants/app_dimensions.dart';
import 'package:food_delivery/features/admin/dishes/admin_dishes_notifier.dart';
import 'package:food_delivery/features/admin/widgets/menu_card.dart';
import 'package:food_delivery/theme/app_theme.dart';

class AdminMenuScreen extends ConsumerWidget {
  const AdminMenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminDishesProvider);
    final ac = Theme.of(context).extension<AppThemeColors>()!;
    final notifier = ref.read(adminDishesProvider.notifier);

    if (state.isLoading && state.dishes.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.dishes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 40, color: ac.mutedText),
              const SizedBox(height: 12),
              Text(
                'Failed to load menu',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: ac.primaryText,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                state.error!,
                style: TextStyle(fontSize: 12, color: ac.mutedText),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => notifier.fetchDishes(),
                child: Text(
                  'Retry',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CategoryFilterRow(
          state: state,
          ac: ac,
          onSetCategory: notifier.setCategory,
        ),
        const SizedBox(height: 20),
        Expanded(
          child: state.displayedDishes.isEmpty
              ? Center(
                  child: Text(
                    'No items in this category',
                    style: TextStyle(color: ac.mutedText, fontSize: 14),
                  ),
                )
              : GridView.builder(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    mainAxisExtent: 288,
                  ),
                  itemCount: state.displayedDishes.length,
                  itemBuilder: (_, i) {
                    final dish = state.displayedDishes[i];
                    final catName = state.categories
                        .where((c) => c.id == dish.categoryId)
                        .map((c) => c.name)
                        .firstOrNull ??
                        '';
                    return MenuCard(
                      dish: dish,
                      categoryName: catName,
                      onEdit: () => notifier.openEditor(dish.id),
                      onDelete: () => notifier.deleteDish(dish.id),
                      onToggleAvailability: () => notifier.toggleAvailability(
                        dish.id,
                        !dish.isAvailable,
                      ),
                      onTogglePopular: () => notifier.togglePopular(
                        dish.id,
                        !dish.popular,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _CategoryFilterRow extends StatelessWidget {
  final AdminDishesState state;
  final AppThemeColors ac;
  final void Function(String) onSetCategory;

  const _CategoryFilterRow({
    required this.state,
    required this.ac,
    required this.onSetCategory,
  });

  @override
  Widget build(BuildContext context) {
    final cats = <({String id, String name})>[
      (id: 'all', name: 'All items'),
      ...state.categories,
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (int i = 0; i < cats.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            _FilterPill(
              id: cats[i].id,
              label: cats[i].name,
              count: cats[i].id == 'all'
                  ? state.dishes.length
                  : state.dishes
                      .where((d) => d.categoryId == cats[i].id)
                      .length,
              active: state.selectedCategoryId == cats[i].id,
              ac: ac,
              onTap: () => onSetCategory(cats[i].id),
            ),
          ],
        ],
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  final String id;
  final String label;
  final int count;
  final bool active;
  final AppThemeColors ac;
  final VoidCallback onTap;

  const _FilterPill({
    required this.id,
    required this.label,
    required this.count,
    required this.active,
    required this.ac,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: active ? ac.primaryText : Colors.white,
          border: Border.all(color: active ? ac.primaryText : ac.border),
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: active ? Colors.white : ac.secondaryText,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: active
                    ? Colors.white.withValues(alpha: 0.18)
                    : const Color(0xFFF0EBE3),
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusCircle),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: active ? Colors.white : ac.secondaryText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
