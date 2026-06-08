import 'package:flutter/material.dart';
import 'package:food_delivery/core/constants/app_dimensions.dart';
import 'package:food_delivery/theme/app_theme.dart';
import 'package:shimmer/shimmer.dart';

// ---------------------------------------------------------------------------
// SkeletonBox — base shimmer block
// ---------------------------------------------------------------------------
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;

  const SkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade300,
      highlightColor: isDark ? const Color(0xFF3D3D3D) : Colors.grey.shade100,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// RestaurantCardSkeleton
// ---------------------------------------------------------------------------
class RestaurantCardSkeleton extends StatelessWidget {
  const RestaurantCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final ac = Theme.of(context).extension<AppThemeColors>()!;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.sm),
      decoration: BoxDecoration(
        color: ac.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: ac.border, width: 0.5),
      ),
      child: Row(
        children: [
          const SkeletonBox(width: 70, height: 70, borderRadius: 12),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonBox(height: 14, borderRadius: 6),
                const SizedBox(height: 8),
                const SkeletonBox(width: 110, height: 11, borderRadius: 6),
                const SizedBox(height: 8),
                Row(
                  children: const [
                    SkeletonBox(width: 60, height: 11, borderRadius: 6),
                    SizedBox(width: 8),
                    SkeletonBox(width: 60, height: 11, borderRadius: 6),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// DishCardSkeleton
// ---------------------------------------------------------------------------
class DishCardSkeleton extends StatelessWidget {
  const DishCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final ac = Theme.of(context).extension<AppThemeColors>()!;

    return Container(
      width: 200,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: ac.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonBox(height: 130, borderRadius: 18),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SkeletonBox(height: 14, borderRadius: 6),
                SizedBox(height: 6),
                SkeletonBox(width: 110, height: 11, borderRadius: 6),
                SizedBox(height: 8),
                SkeletonBox(width: 70, height: 16, borderRadius: 6),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// HomeHeaderSkeleton
// ---------------------------------------------------------------------------
class HomeHeaderSkeleton extends StatelessWidget {
  const HomeHeaderSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SkeletonBox(width: 120, height: 14, borderRadius: 6),
            Spacer(),
            SkeletonBox(width: 36, height: 36, borderRadius: 18),
          ],
        ),
        SizedBox(height: 16),
        SkeletonBox(width: 240, height: 28, borderRadius: 8),
        SizedBox(height: 12),
        SkeletonBox(height: 52, borderRadius: 16),
      ],
    );
  }
}
