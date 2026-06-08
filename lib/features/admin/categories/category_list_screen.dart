import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_delivery/core/constants/app_dimensions.dart';
import 'package:food_delivery/core/navigation/admin_navigator.dart';
import 'package:food_delivery/core/widgets/custom_search_bar.dart';
import 'package:food_delivery/core/widgets/empty_state_widget.dart';
import 'package:food_delivery/core/widgets/error_state_widget.dart';
import 'package:food_delivery/features/admin/categories/admin_categories_notifier.dart';

class CategoryListScreen extends ConsumerWidget {
  const CategoryListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminCategoriesNotifierProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppDimensions.screenPadding),
            child: CustomSearchBar(
              hint: 'Search categories...',
              onChanged: (q) => ref.read(adminCategoriesNotifierProvider.notifier).setSearch(q),
            ),
          ),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.error != null
                    ? ErrorStateWidget(
                        message: state.error!,
                        onRetry: () => ref.read(adminCategoriesNotifierProvider.notifier).fetchCategories(),
                      )
                    : state.filteredCategories.isEmpty
                        ? const EmptyStateWidget(title: 'No categories', subtitle: 'Add your first category')
                        : GridView.builder(
                            padding: const EdgeInsets.fromLTRB(
                              AppDimensions.screenPadding, 0,
                              AppDimensions.screenPadding, AppDimensions.screenPadding,
                            ),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 1.2,
                            ),
                            itemCount: state.filteredCategories.length,
                            itemBuilder: (_, i) {
                              final cat = state.filteredCategories[i];
                              return Container(
                                decoration: BoxDecoration(
                                  color: cat.bgColor,
                                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                                ),
                                child: Stack(
                                  children: [
                                    Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(cat.emoji, style: const TextStyle(fontSize: 32)),
                                          const SizedBox(height: 6),
                                          Text(cat.name, style: tt.titleSmall!.copyWith(fontWeight: FontWeight.w700)),
                                        ],
                                      ),
                                    ),
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: Row(
                                        children: [
                                          _IconBtn(
                                            icon: Icons.edit_outlined,
                                            color: cs.primary,
                                            onTap: () => AdminNavigator.toCategoryForm(context, category: cat),
                                          ),
                                          _IconBtn(
                                            icon: Icons.delete_outline,
                                            color: cs.error,
                                            onTap: () async {
                                              final confirm = await showDialog<bool>(
                                                context: context,
                                                builder: (_) => AlertDialog(
                                                  title: const Text('Delete category?'),
                                                  content: Text('Delete "${cat.name}"?'),
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
                                                await ref.read(adminCategoriesNotifierProvider.notifier).deleteCategory(cat.id);
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => AdminNavigator.toCategoryForm(context),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.8),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 14, color: color),
      ),
    );
  }
}
