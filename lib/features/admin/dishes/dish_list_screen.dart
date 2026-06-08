import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_delivery/core/constants/app_dimensions.dart';
import 'package:food_delivery/core/navigation/admin_navigator.dart';
import 'package:food_delivery/core/utils/helpers.dart';
import 'package:food_delivery/core/widgets/custom_search_bar.dart';
import 'package:food_delivery/core/widgets/empty_state_widget.dart';
import 'package:food_delivery/core/widgets/error_state_widget.dart';
import 'package:food_delivery/features/admin/dishes/admin_dishes_notifier.dart';
import 'package:cached_network_image/cached_network_image.dart';

class DishListScreen extends ConsumerWidget {
  const DishListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminDishesNotifierProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppDimensions.screenPadding),
            child: CustomSearchBar(
              hint: 'Search dishes...',
              onChanged: (q) => ref.read(adminDishesNotifierProvider.notifier).setSearch(q),
            ),
          ),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.error != null
                    ? ErrorStateWidget(
                        message: state.error!,
                        onRetry: () => ref.read(adminDishesNotifierProvider.notifier).fetchDishes(),
                      )
                    : state.filteredDishes.isEmpty
                        ? const EmptyStateWidget(title: 'No dishes yet', subtitle: 'Add your first dish')
                        : RefreshIndicator(
                            onRefresh: () => ref.read(adminDishesNotifierProvider.notifier).fetchDishes(),
                            child: ListView.separated(
                              padding: const EdgeInsets.fromLTRB(
                                AppDimensions.screenPadding, 0,
                                AppDimensions.screenPadding, AppDimensions.screenPadding,
                              ),
                              itemCount: state.filteredDishes.length,
                              separatorBuilder: (_, _) => const Divider(height: 1),
                              itemBuilder: (_, i) {
                                final dish = state.filteredDishes[i];
                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(vertical: 4),
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: dish.imageUrl != null
                                        ? CachedNetworkImage(
                                            imageUrl: dish.imageUrl!,
                                            width: 56,
                                            height: 56,
                                            fit: BoxFit.cover,
                                            errorWidget: (_, _, _) => _placeholder(context),
                                          )
                                        : _placeholder(context),
                                  ),
                                  title: Text(dish.name, style: tt.titleSmall),
                                  subtitle: Text(
                                    '${dish.restaurantName} · ${dish.tag}',
                                    style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(Helpers.formatRs(dish.priceRs),
                                          style: tt.bodyMedium!.copyWith(fontWeight: FontWeight.w700)),
                                      IconButton(
                                        icon: Icon(Icons.edit_outlined, size: 18, color: cs.primary),
                                        onPressed: () => AdminNavigator.toAdminDishForm(context, dish: dish),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete_outline, size: 18, color: cs.error),
                                        onPressed: () async {
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (_) => AlertDialog(
                                              title: const Text('Delete dish?'),
                                              content: Text('Delete "${dish.name}"?'),
                                              actions: [
                                                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context, true),
                                                  child: Text('Delete', style: TextStyle(color: cs.error)),
                                                ),
                                              ],
                                            ),
                                          );
                                          if (confirm == true) {
                                            await ref.read(adminDishesNotifierProvider.notifier).deleteDish(dish.id);
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => AdminNavigator.toAdminDishForm(context),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _placeholder(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      child: const Icon(Icons.restaurant_menu_rounded, size: 20),
    );
  }
}
