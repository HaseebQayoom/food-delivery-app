import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_delivery/core/constants/app_dimensions.dart';
import 'package:food_delivery/core/navigation/app_navigator.dart';
import 'package:food_delivery/core/widgets/error_state_widget.dart';
import 'package:food_delivery/core/widgets/meal_list_row.dart';
import 'package:food_delivery/core/widgets/popular_meal_card.dart';
import 'package:food_delivery/core/widgets/section_header.dart';
import 'package:food_delivery/core/widgets/skeleton_loader.dart';
import 'package:food_delivery/features/cart/providers/cart_notifier.dart';
import 'package:food_delivery/features/home/providers/home_notifier.dart';
import 'package:food_delivery/features/home/widgets/meal_detail_view.dart';
import 'package:food_delivery/features/orders/providers/active_order_notifier.dart';
import 'package:food_delivery/main.dart';
import 'package:food_delivery/models/category_model.dart';
import 'package:food_delivery/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

// Hardcoded review data for FYP demo
const _kReviews = [
  {
    'name': 'Ahmed R.',
    'stars': 5,
    'text': 'The smash burger is absolutely fire, crispy edges and perfect smash. Will order again.',
    'date': '2 days ago',
  },
  {
    'name': 'Sara M.',
    'stars': 5,
    'text': 'Best BBQ in Lahore. The ribs fall off the bone and the sides are generous.',
    'date': '1 week ago',
  },
  {
    'name': 'Bilal K.',
    'stars': 4,
    'text': 'Great food, fast delivery. The smoke flavour is authentic. Packaging could be better.',
    'date': '2 weeks ago',
  },
];

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with RouteAware {
  final _scrollController = ScrollController();
  final _categoryKeys = <String, GlobalKey>{};
  String? _scrollSpyCategoryId;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    Future.microtask(
      () => ref.read(activeOrderNotifierProvider.notifier).refresh(),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void didPopNext() {
    ref.read(activeOrderNotifierProvider.notifier).refresh();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_categoryKeys.isEmpty) return;
    final threshold = MediaQuery.of(context).padding.top + 52;
    String? found;
    for (final entry in _categoryKeys.entries) {
      final ctx = entry.value.currentContext;
      if (ctx == null) continue;
      final box = ctx.findRenderObject() as RenderBox?;
      if (box == null) continue;
      if (box.localToGlobal(Offset.zero).dy <= threshold) found = entry.key;
    }
    if (found != _scrollSpyCategoryId) setState(() => _scrollSpyCategoryId = found);
  }

  void _scrollToCategory(String? categoryId) {
    if (categoryId == null) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOut,
      );
      return;
    }
    final key = _categoryKeys[categoryId];
    if (key == null) return;
    final ctx = key.currentContext;
    if (ctx == null) return;
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null) return;
    final topPadding = MediaQuery.of(context).padding.top;
    final targetOffset = (_scrollController.offset +
            box.localToGlobal(Offset.zero).dy -
            (topPadding + 52))
        .clamp(0.0, _scrollController.position.maxScrollExtent);
    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeNotifierProvider);
    final activeOrder = ref.watch(activeOrderNotifierProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final ac = Theme.of(context).extension<AppThemeColors>()!;
    final topPadding = MediaQuery.of(context).padding.top;
    final notifier = ref.read(homeNotifierProvider.notifier);
    final cartNotifier = ref.read(cartNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: ac.background,
      body: RefreshIndicator(
        color: cs.primary,
        onRefresh: () => notifier.fetchRestaurantData(),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // ── Sliver 1: Hero ─────────────────────────────────────────────
            SliverToBoxAdapter(
              child: SizedBox(
                height: 280,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background image
                    homeState.restaurant?.imageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: homeState.restaurant!.imageUrl!,
                            fit: BoxFit.cover,
                            errorWidget: (context, _, _) =>
                                _heroFallback(ac),
                          )
                        : _heroFallback(ac),

                    // Gradient overlay
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.35),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.65),
                          ],
                        ),
                      ),
                    ),

                    // Top bar row (location + notification)
                    Positioned(
                      top: topPadding + 12,
                      left: AppDimensions.screenPadding,
                      right: AppDimensions.screenPadding,
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => AppNavigator.toAddresses(context),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Deliver to',
                                  style: tt.bodySmall?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.8),
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.location_pin,
                                        size: 14, color: Colors.white),
                                    const SizedBox(width: AppDimensions.xs),
                                    Text(
                                      'Lahore, Punjab',
                                      style: tt.titleSmall?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      size: 16,
                                      color: Colors.white.withValues(alpha: 0.9),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () =>
                                AppNavigator.toNotifications(context),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.3),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.notifications_outlined,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Restaurant name + cuisine tag at bottom
                    Positioned(
                      bottom: AppDimensions.md,
                      left: AppDimensions.screenPadding,
                      right: AppDimensions.screenPadding,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            homeState.restaurant?.name ?? 'Smoke & Stack',
                            style: GoogleFonts.bricolageGrotesque(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.xs),
                          if (homeState.restaurant?.cuisineTags.isNotEmpty == true)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppDimensions.sm,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusCircle),
                              ),
                              child: Text(
                                homeState.restaurant!.cuisineTags.join(' · '),
                                style: tt.labelSmall?.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Sliver 2: Meta strip ───────────────────────────────────────
            SliverToBoxAdapter(
              child: Container(
                color: ac.background,
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.screenPadding,
                  AppDimensions.md,
                  AppDimensions.screenPadding,
                  AppDimensions.sm,
                ),
                child: Row(
                  children: [
                    Icon(Icons.star_rounded, size: 16, color: ac.warning),
                    const SizedBox(width: AppDimensions.xs),
                    Text(
                      homeState.restaurant?.rating.toStringAsFixed(1) ?? '4.8',
                      style: tt.bodySmall?.copyWith(
                        color: ac.primaryText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(' · ', style: tt.bodySmall),
                    Text(
                      '${homeState.restaurant?.deliveryTimeMin ?? 30} min',
                      style: tt.bodySmall,
                    ),
                    Text(' · ', style: tt.bodySmall),
                    Text('Free delivery', style: tt.bodySmall),
                    const Spacer(),
                    TextButton(
                      onPressed: () => AppNavigator.toMenuAll(context),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('See menu →'),
                    ),
                  ],
                ),
              ),
            ),

            // ── Sliver 2b: Search bar ─────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.screenPadding,
                  0,
                  AppDimensions.screenPadding,
                  AppDimensions.sm,
                ),
                child: GestureDetector(
                  onTap: () => AppNavigator.toSearch(context),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: ac.creamSurface,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusCircle),
                      border: Border.all(color: ac.border),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: AppDimensions.md),
                        Icon(Icons.search, color: ac.mutedText, size: 20),
                        const SizedBox(width: AppDimensions.sm),
                        Text(
                          'Search menu…',
                          style: tt.bodyMedium?.copyWith(color: ac.mutedText),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Sliver 2c: Offer strip ────────────────────────────────────
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(
                  AppDimensions.screenPadding,
                  0,
                  AppDimensions.screenPadding,
                  AppDimensions.sm,
                ),
                padding: const EdgeInsets.all(AppDimensions.md),
                decoration: BoxDecoration(
                  color: ac.primaryText,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'The Stack Combo',
                            style: tt.titleSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.xs),
                          Text(
                            'Burger + fries + drink  ·  Save Rs 250',
                            style: tt.bodySmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppDimensions.md),
                    GestureDetector(
                      onTap: () => AppNavigator.toSearch(context, query: 'burger'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.md,
                          vertical: AppDimensions.sm,
                        ),
                        decoration: BoxDecoration(
                          color: cs.primary,
                          borderRadius: BorderRadius.circular(
                              AppDimensions.radiusCircle),
                        ),
                        child: Text(
                          'Order',
                          style: tt.labelMedium?.copyWith(
                            color: cs.onPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Sliver 2d: Active order banner ────────────────────────────
            if (activeOrder.isNotEmpty)
              SliverToBoxAdapter(
                child: _ActiveOrderBanner(
                  count: activeOrder.length,
                  ac: ac,
                  cs: cs,
                  tt: tt,
                ),
              ),

            // ── Sliver 3: Category pills (sticky) ─────────────────────────
            SliverPersistentHeader(
              pinned: true,
              delegate: _CategoryPillsDelegate(
                categories: homeState.categories,
                scrollSpyCategoryId: _scrollSpyCategoryId,
                onSelect: _scrollToCategory,
                topPadding: topPadding,
                ac: ac,
                cs: cs,
                tt: tt,
              ),
            ),

            // ── Sliver 4: Popular cards row ───────────────────────────────
            SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppDimensions.screenPadding,
                        AppDimensions.lg,
                        AppDimensions.screenPadding,
                        AppDimensions.sm,
                      ),
                      child: SectionHeader(
                        title: 'Popular right now 🔥',
                        actionLabel: 'See all',
                        onAction: () => AppNavigator.toMenuAll(context),
                      ),
                    ),
                    SizedBox(
                      height: 260,
                      child: homeState.isLoading
                          ? ListView.separated(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppDimensions.screenPadding),
                              itemCount: 3,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(width: AppDimensions.radiusSm),
                              itemBuilder: (_, _) => const DishCardSkeleton(),
                            )
                          : homeState.popularDishes.isEmpty
                              ? const Center(child: Text('No popular dishes'))
                              : ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: AppDimensions.screenPadding),
                                  itemCount: homeState.popularDishes.length,
                                  separatorBuilder: (_, _) =>
                                      const SizedBox(width: AppDimensions.radiusSm),
                                  itemBuilder: (_, i) {
                                    final dish = homeState.popularDishes[i];
                                    return PopularMealCard(
                                      dish: dish,
                                      onTap: () =>
                                          showMealDetail(context, dish),
                                      onAddToCart: () =>
                                          cartNotifier.addItem(dish),
                                    );
                                  },
                                ),
                    ),
                  ],
                ),
              ),

            // ── Sliver 5: Full menu ────────────────────────────────────────
            if (homeState.isLoading)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(AppDimensions.lg),
                  child: Center(child: CircularProgressIndicator()),
                ),
              )
            else if (homeState.error != null)
              SliverToBoxAdapter(
                child: ErrorStateWidget(
                  message: homeState.error!,
                  onRetry: () => notifier.fetchRestaurantData(),
                ),
              )
            else ...[
              // All categories view
              ..._buildAllMenuSlivers(
                context,
                homeState,
                cartNotifier,
                tt,
                ac,
              ),
            ],

            // ── Sliver 6: Ratings & Reviews ────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.screenPadding,
                  AppDimensions.xl,
                  AppDimensions.screenPadding,
                  AppDimensions.sm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader(
                      title: 'Ratings & Reviews',
                      actionLabel: 'See all',
                      onAction: () => ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(
                        content: Text('All reviews coming soon'),
                        duration: Duration(seconds: 2),
                      )),
                    ),
                    const SizedBox(height: AppDimensions.md),
                    // Average rating display
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '4.8',
                          style: GoogleFonts.bricolageGrotesque(
                            fontSize: 56,
                            fontWeight: FontWeight.w800,
                            color: ac.primaryText,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.md),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: List.generate(
                                5,
                                (i) => Icon(Icons.star_rounded,
                                    size: 20, color: ac.warning),
                              ),
                            ),
                            const SizedBox(height: AppDimensions.xs),
                            Text('128 ratings', style: tt.bodySmall),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.md),
                    // Review cards
                    ..._kReviews.map((review) => _buildReviewCard(
                          review,
                          context,
                          tt,
                          ac,
                          cs,
                        )),
                  ],
                ),
              ),
            ),

            // ── Sliver 7: Restaurant Info ──────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.screenPadding,
                  AppDimensions.lg,
                  AppDimensions.screenPadding,
                  AppDimensions.sm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Restaurant Info', style: tt.titleLarge),
                    const SizedBox(height: AppDimensions.md),
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.md),
                      decoration: BoxDecoration(
                        color: ac.creamSurface,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusMd),
                        border: Border.all(color: ac.border),
                      ),
                      child: Column(
                        children: [
                          _infoRow(
                            Icons.location_on_outlined,
                            'DHA Phase 5, Lahore, Punjab',
                            tt,
                            ac,
                            cs,
                          ),
                          Divider(height: 1, color: ac.border),
                          _infoRow(
                            Icons.access_time_outlined,
                            '11:00 AM – 11:00 PM',
                            tt,
                            ac,
                            cs,
                          ),
                          Divider(height: 1, color: ac.border),
                          _infoRow(
                            Icons.phone_outlined,
                            '+92 300 1234567',
                            tt,
                            ac,
                            cs,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Sliver 8: Bottom padding ───────────────────────────────────
            const SliverToBoxAdapter(child: SizedBox(height: 104)),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildAllMenuSlivers(
    BuildContext context,
    HomeState homeState,
    CartNotifier cartNotifier,
    TextTheme tt,
    AppThemeColors ac,
  ) {
    final slivers = <Widget>[];
    for (final entry in homeState.menuByCategory.entries) {
      final dishes = entry.value;
      if (dishes.isEmpty) continue;

      final category = homeState.categories.firstWhere(
        (c) => c.id == entry.key,
        orElse: () => CategoryModel(
          id: entry.key,
          name: 'More',
          emoji: '🍽',
          bgColor: ac.creamSurface,
        ),
      );

      _categoryKeys.putIfAbsent(entry.key, () => GlobalKey());
      slivers.add(SliverToBoxAdapter(
        child: Padding(
          key: _categoryKeys[entry.key],
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.screenPadding,
            AppDimensions.lg,
            AppDimensions.screenPadding,
            AppDimensions.sm,
          ),
          child: Text(
            '${category.emoji} ${category.name}',
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      ));

      slivers.add(SliverPadding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.screenPadding),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, i) => MealListRow(
              dish: dishes[i],
              onTap: () => showMealDetail(context, dishes[i]),
              onAddToCart: () => cartNotifier.addItem(dishes[i]),
            ),
            childCount: dishes.length,
          ),
        ),
      ));
    }
    return slivers;
  }

  Widget _buildReviewCard(
    Map<String, Object> review,
    BuildContext context,
    TextTheme tt,
    AppThemeColors ac,
    ColorScheme cs,
  ) {
    final name = review['name'] as String;
    final stars = review['stars'] as int;
    final text = review['text'] as String;
    final date = review['date'] as String;
    final initials = name.isNotEmpty ? name[0] : '?';

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.md),
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: ac.creamSurface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: ac.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: cs.primary.withValues(alpha: 0.15),
                child: Text(
                  initials,
                  style: tt.titleSmall?.copyWith(color: cs.primary),
                ),
              ),
              const SizedBox(width: AppDimensions.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: tt.titleSmall),
                    Text(date, style: tt.bodySmall),
                  ],
                ),
              ),
              Row(
                children: List.generate(
                  stars,
                  (i) =>
                      Icon(Icons.star_rounded, size: 14, color: ac.warning),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.sm),
          Text(text, style: tt.bodyMedium),
        ],
      ),
    );
  }

  Widget _infoRow(
    IconData icon,
    String text,
    TextTheme tt,
    AppThemeColors ac,
    ColorScheme cs,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.sm),
      child: Row(
        children: [
          Icon(icon, size: 18, color: cs.primary),
          const SizedBox(width: AppDimensions.md),
          Expanded(child: Text(text, style: tt.bodyMedium)),
        ],
      ),
    );
  }

  Widget _heroFallback(AppThemeColors ac) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A0A06), Color(0xFF3B1A0A), Color(0xFF6B2D0F)],
        ),
      ),
      child: Stack(
        children: [
          // Subtle pattern circles
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.03),
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            left: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.03),
              ),
            ),
          ),
          // Content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.07),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                        width: 1.5),
                  ),
                  child: const Icon(
                    Icons.restaurant_rounded,
                    size: 42,
                    color: Colors.white54,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Smoke & Stack',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white.withValues(alpha: 0.35),
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Burgers · Grills · Fries',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.2),
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sticky category pills delegate ─────────────────────────────────────────

class _CategoryPillsDelegate extends SliverPersistentHeaderDelegate {
  final List<CategoryModel> categories;
  final String? scrollSpyCategoryId;
  final void Function(String?) onSelect;
  final double topPadding;
  final AppThemeColors ac;
  final ColorScheme cs;
  final TextTheme tt;

  const _CategoryPillsDelegate({
    required this.categories,
    this.scrollSpyCategoryId,
    required this.onSelect,
    required this.topPadding,
    required this.ac,
    required this.cs,
    required this.tt,
  });

  @override
  double get minExtent => 52.0 + topPadding;

  @override
  double get maxExtent => 52.0 + topPadding;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final pillLabels = ['Popular', ...categories.map((c) => c.name)];

    return Container(
      color: ac.background,
      height: 52 + topPadding,
      padding: EdgeInsets.only(top: topPadding),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.screenPadding,
          vertical: AppDimensions.sm,
        ),
        itemCount: pillLabels.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppDimensions.sm),
        itemBuilder: (_, i) {
          final label = pillLabels[i];
          final isSelected = i == 0
              ? scrollSpyCategoryId == null
              : scrollSpyCategoryId == categories[i - 1].id;

          return GestureDetector(
            onTap: () => onSelect(i == 0 ? null : categories[i - 1].id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.md,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: isSelected ? cs.primary : ac.creamSurface,
                borderRadius: BorderRadius.circular(AppDimensions.radiusCircle),
                border: Border.all(
                  color: isSelected ? cs.primary : ac.border,
                ),
              ),
              child: Text(
                label,
                style: tt.labelMedium?.copyWith(
                  color: isSelected ? cs.onPrimary : ac.primaryText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  bool shouldRebuild(_CategoryPillsDelegate oldDelegate) {
    return oldDelegate.scrollSpyCategoryId != scrollSpyCategoryId ||
        oldDelegate.categories != categories ||
        oldDelegate.topPadding != topPadding;
  }
}

// ── Active order re-entry banner ────────────────────────────────────────────

class _ActiveOrderBanner extends StatelessWidget {
  const _ActiveOrderBanner({
    required this.count,
    required this.ac,
    required this.cs,
    required this.tt,
  });

  final int count;
  final AppThemeColors ac;
  final ColorScheme cs;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => AppNavigator.toActiveOrders(context),
      child: Container(
        margin: const EdgeInsets.fromLTRB(
          AppDimensions.screenPadding,
          0,
          AppDimensions.screenPadding,
          AppDimensions.sm,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.md,
          vertical: AppDimensions.sm + 2,
        ),
        decoration: BoxDecoration(
          color: cs.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(color: cs.primary.withValues(alpha: 0.35)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: cs.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delivery_dining_rounded,
                size: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: AppDimensions.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    count == 1 ? 'You have an active order' : 'You have $count active orders',
                    style: tt.labelMedium?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Tap to track',
                    style: tt.bodySmall?.copyWith(color: ac.mutedText),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 12, color: cs.primary),
          ],
        ),
      ),
    );
  }
}
