import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_delivery/core/constants/app_colors.dart';
import 'package:food_delivery/core/constants/app_dimensions.dart';
import 'package:food_delivery/core/navigation/app_navigator.dart';
import 'package:food_delivery/core/utils/helpers.dart';
import 'package:food_delivery/core/widgets/error_state_widget.dart';
import 'package:food_delivery/core/widgets/skeleton_loader.dart';
import 'package:food_delivery/features/cart/providers/cart_notifier.dart';
import 'package:food_delivery/features/restaurant/providers/restaurant_detail_notifier.dart';
import 'package:food_delivery/models/dish_model.dart';
import 'package:food_delivery/theme/app_theme.dart';

class RestaurantDetailScreen extends ConsumerWidget {
  final String restaurantId;
  const RestaurantDetailScreen({super.key, required this.restaurantId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(restaurantDetailProvider(restaurantId));
    final cartItems = ref.watch(cartNotifierProvider);
    final cartNotifier = ref.read(cartNotifierProvider.notifier);
    final ac = Theme.of(context).extension<AppThemeColors>()!;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final cartItemCount = cartNotifier.itemCount;
    final cartTotal = cartNotifier.totalRs;

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Collapsing hero header
              SliverAppBar(
                expandedHeight: 260,
                pinned: true,
                leading: Padding(
                  padding: const EdgeInsets.all(8),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
                      color: ac.primaryText,
                      onPressed: () => AppNavigator.back(context),
                    ),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (state.restaurant?.imageUrl != null)
                        CachedNetworkImage(
                          imageUrl: state.restaurant!.imageUrl!,
                          fit: BoxFit.cover,
                          errorWidget: (_, _, _) => Container(color: ac.creamSurface),
                        )
                      else
                        Container(color: ac.creamSurface),
                      // Dark gradient at bottom for text legibility
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black87],
                            stops: [0.4, 1.0],
                          ),
                        ),
                      ),
                      if (state.restaurant != null)
                        Positioned(
                          left: 20,
                          right: 20,
                          bottom: 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                state.restaurant!.name,
                                style: tt.headlineSmall!.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 6,
                                children: state.restaurant!.cuisineTags
                                    .map((t) => _CuisineTag(label: t))
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Info bar (rating, time, min order)
              SliverToBoxAdapter(
                child: state.isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(AppDimensions.screenPadding),
                        child: SkeletonBox(height: 56, borderRadius: 12),
                      )
                    : state.restaurant == null
                        ? const SizedBox.shrink()
                        : Container(
                            margin: const EdgeInsets.all(AppDimensions.screenPadding),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: ac.surface,
                              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                              border: Border.all(color: ac.border, width: 0.5),
                              boxShadow: ac.cardShadow,
                            ),
                            child: Row(
                              children: [
                                _InfoCell(
                                  icon: Icons.star_rounded,
                                  iconColor: const Color(0xFFFFB400),
                                  value: state.restaurant!.rating.toStringAsFixed(1),
                                  label: 'Rating',
                                ),
                                _Divider(),
                                _InfoCell(
                                  icon: Icons.access_time_rounded,
                                  iconColor: cs.primary,
                                  value: '${state.restaurant!.deliveryTimeMin} min',
                                  label: 'Delivery',
                                ),
                                _Divider(),
                                _InfoCell(
                                  icon: Icons.shopping_bag_outlined,
                                  iconColor: cs.tertiary,
                                  value: Helpers.formatRs(state.restaurant!.minOrderRs),
                                  label: 'Min Order',
                                ),
                              ],
                            ),
                          ),
              ),

              // Menu heading
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimensions.screenPadding, 0,
                    AppDimensions.screenPadding, AppDimensions.sm,
                  ),
                  child: Text('Menu', style: tt.titleLarge!.copyWith(fontWeight: FontWeight.w800)),
                ),
              ),

              // Error state
              if (state.error != null)
                SliverFillRemaining(
                  child: ErrorStateWidget(
                    message: state.error!,
                    onRetry: () => ref.read(restaurantDetailProvider(restaurantId).notifier).refresh(),
                  ),
                )

              // Loading skeletons
              else if (state.isLoading)
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, _) => const Padding(
                      padding: EdgeInsets.fromLTRB(
                        AppDimensions.screenPadding, 0,
                        AppDimensions.screenPadding, AppDimensions.sm,
                      ),
                      child: SkeletonBox(height: 88, borderRadius: 16),
                    ),
                    childCount: 6,
                  ),
                )

              // Dish list
              else if (state.dishes.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🍽️', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 12),
                        Text('No dishes yet', style: tt.titleMedium),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    AppDimensions.screenPadding, 0,
                    AppDimensions.screenPadding,
                    // Extra bottom padding so last item isn't hidden behind cart bar
                    cartItemCount > 0 ? 100 : AppDimensions.screenPadding,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) {
                        final dish = state.dishes[i];
                        final qtyInCart = cartItems
                            .where((e) => e.dish.id == dish.id)
                            .fold(0, (sum, e) => sum + e.quantity);
                        return _DishRow(
                          dish: dish,
                          qtyInCart: qtyInCart,
                          onAdd: () => cartNotifier.addItem(dish),
                          onRemove: () => cartNotifier.decrement(dish.id),
                        );
                      },
                      childCount: state.dishes.length,
                    ),
                  ),
                ),
            ],
          ),

          // Floating cart bar
          if (cartItemCount > 0)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _CartBar(
                itemCount: cartItemCount,
                total: cartTotal,
                onTap: () => AppNavigator.toCart(context),
              ),
            ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────
// Sub-widgets
// ──────────────────────────────────────────────────────────────────

class _CuisineTag extends StatelessWidget {
  final String label;
  const _CuisineTag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppDimensions.radiusCircle),
        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall!.copyWith(color: Colors.white),
      ),
    );
  }
}

class _InfoCell extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  const _InfoCell({required this.icon, required this.iconColor, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final ac = Theme.of(context).extension<AppThemeColors>()!;
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(height: 4),
          Text(value, style: tt.titleSmall!.copyWith(fontWeight: FontWeight.w700)),
          Text(label, style: tt.labelSmall!.copyWith(color: ac.mutedText)),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 36, color: Theme.of(context).extension<AppThemeColors>()!.border);
  }
}

class _DishRow extends StatelessWidget {
  final DishModel dish;
  final int qtyInCart;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  const _DishRow({required this.dish, required this.qtyInCart, required this.onAdd, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final ac = Theme.of(context).extension<AppThemeColors>()!;

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.sm),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ac.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: ac.border, width: 0.5),
        boxShadow: ac.cardShadow,
      ),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: dish.imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: dish.imageUrl!,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    errorWidget: (_, _, _) => _imgFallback(ac),
                  )
                : _imgFallback(ac),
          ),
          const SizedBox(width: 12),

          // Name + calories + price
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (dish.tag.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      dish.tag,
                      style: tt.labelSmall!.copyWith(
                        color: cs.onPrimaryContainer,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                Text(dish.name, style: tt.titleSmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(
                  '${dish.calories} kcal',
                  style: tt.labelSmall!.copyWith(color: ac.mutedText),
                ),
                const SizedBox(height: 4),
                Text(
                  Helpers.formatRs(dish.priceRs),
                  style: tt.titleSmall!.copyWith(fontWeight: FontWeight.w800, color: cs.primary),
                ),
              ],
            ),
          ),

          // Qty control
          if (qtyInCart == 0)
            _AddButton(onAdd: onAdd, cs: cs)
          else
            _QtyControl(qty: qtyInCart, onAdd: onAdd, onRemove: onRemove, cs: cs),
        ],
      ),
    );
  }

  Widget _imgFallback(AppThemeColors ac) {
    return Container(
      width: 72,
      height: 72,
      color: ac.creamSurface,
      child: const Center(child: Text('🍔', style: TextStyle(fontSize: 24))),
    );
  }
}

class _AddButton extends StatelessWidget {
  final VoidCallback onAdd;
  final ColorScheme cs;
  const _AddButton({required this.onAdd, required this.cs});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onAdd,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(color: cs.primary, shape: BoxShape.circle),
        child: Icon(Icons.add, color: cs.onPrimary, size: 18),
      ),
    );
  }
}

class _QtyControl extends StatelessWidget {
  final int qty;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final ColorScheme cs;
  const _QtyControl({required this.qty, required this.onAdd, required this.onRemove, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onRemove,
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              border: Border.all(color: cs.primary),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.remove, color: cs.primary, size: 16),
          ),
        ),
        SizedBox(
          width: 28,
          child: Text(
            '$qty',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall!.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        GestureDetector(
          onTap: onAdd,
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(color: cs.primary, shape: BoxShape.circle),
            child: Icon(Icons.add, color: cs.onPrimary, size: 16),
          ),
        ),
      ],
    );
  }
}

class _CartBar extends StatelessWidget {
  final int itemCount;
  final int total;
  final VoidCallback onTap;
  const _CartBar({required this.itemCount, required this.total, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppDimensions.screenPadding, 12,
        AppDimensions.screenPadding,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        gradient: AppGradients.primary,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 16, offset: const Offset(0, -4))],
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '$itemCount',
                style: tt.titleSmall!.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 12),
            Text('View Cart', style: tt.titleMedium!.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
            const Spacer(),
            Text(
              Helpers.formatRs(total),
              style: tt.titleMedium!.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
