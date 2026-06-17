import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_delivery/core/constants/app_dimensions.dart';
import 'package:food_delivery/core/widgets/meal_list_row.dart';
import 'package:food_delivery/features/cart/providers/cart_notifier.dart';
import 'package:food_delivery/features/home/providers/home_notifier.dart';
import 'package:food_delivery/features/home/widgets/meal_detail_view.dart';
import 'package:food_delivery/models/dish_model.dart';
import 'package:food_delivery/theme/app_theme.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key, this.initialQuery = ''});

  final String initialQuery;

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery.isNotEmpty) {
      _controller.text = widget.initialQuery;
      _query = widget.initialQuery;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ac = Theme.of(context).extension<AppThemeColors>()!;
    final tt = Theme.of(context).textTheme;
    final homeState = ref.watch(homeNotifierProvider);
    final cartNotifier = ref.read(cartNotifierProvider.notifier);

    final allDishes = homeState.menuByCategory.values.expand((d) => d).toList();

    final results = _query.trim().isEmpty
        ? <DishModel>[]
        : allDishes
            .where((d) =>
                d.name.toLowerCase().contains(_query.toLowerCase()) ||
                d.description.toLowerCase().contains(_query.toLowerCase()))
            .toList();

    return Scaffold(
      backgroundColor: ac.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Search bar row ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.sm,
                AppDimensions.sm,
                AppDimensions.screenPadding,
                AppDimensions.sm,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: ac.primaryText),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(width: AppDimensions.xs),
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: ac.creamSurface,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusCircle),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: AppDimensions.md),
                          Icon(Icons.search, color: ac.mutedText, size: 20),
                          const SizedBox(width: AppDimensions.sm),
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              autofocus: true,
                              decoration: InputDecoration(
                                hintText: 'Search menu…',
                                hintStyle: tt.bodyMedium
                                    ?.copyWith(color: ac.mutedText),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                                fillColor: ac.creamSurface
                              ),
                              style: tt.bodyMedium,
                              onChanged: (value) =>
                                  setState(() => _query = value),
                            ),
                          ),
                          if (_query.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _controller.clear();
                                setState(() => _query = '');
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: AppDimensions.sm),
                                child: Icon(Icons.close,
                                    size: 18, color: ac.mutedText),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Divider(height: 1, color: ac.border),

            // ── Results ─────────────────────────────────────────────────────
            Expanded(
              child: _query.trim().isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search_rounded, size: 64, color: ac.mutedText),
                          const SizedBox(height: AppDimensions.md),
                          Text(
                            'Search dishes, ingredients…',
                            style: tt.bodyMedium?.copyWith(color: ac.mutedText),
                          ),
                        ],
                      ),
                    )
                  : results.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.search_off_rounded,
                                  size: 64, color: ac.mutedText),
                              const SizedBox(height: AppDimensions.md),
                              Text(
                                'No results for "$_query"',
                                style:
                                    tt.bodyMedium?.copyWith(color: ac.mutedText),
                              ),
                              const SizedBox(height: AppDimensions.sm),
                              Text(
                                'Try a different search term',
                                style:
                                    tt.bodySmall?.copyWith(color: ac.mutedText),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.screenPadding,
                            vertical: AppDimensions.md,
                          ),
                          itemCount: results.length,
                          separatorBuilder: (context, index) =>
                              Divider(height: 1, color: ac.border),
                          itemBuilder: (context, index) {
                            final dish = results[index];
                            return MealListRow(
                              dish: dish,
                              onTap: () => showMealDetail(context, dish),
                              onAddToCart: () {
                                cartNotifier.addItem(dish);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${dish.name} added to cart'),
                                    duration: const Duration(seconds: 1),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
