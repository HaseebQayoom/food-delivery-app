import 'package:flutter/material.dart';
import 'package:food_delivery/core/constants/app_colors.dart';
import 'package:food_delivery/core/constants/app_dimensions.dart';
import 'package:food_delivery/models/order_model.dart';
import 'package:food_delivery/theme/app_theme.dart';

class StatusPill extends StatelessWidget {
  final OrderStatus status;
  final bool small;

  const StatusPill({super.key, required this.status, this.small = false});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ac = Theme.of(context).extension<AppThemeColors>()!;
    final colors = _colors(cs, ac);
    final hPad = small ? 9.0 : 12.0;
    final vPad = small ? 3.0 : 5.0;
    final fs = small ? 11.0 : 12.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      decoration: BoxDecoration(
        color: colors.bg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCircle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: colors.fg, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            status.label,
            style: TextStyle(
              fontSize: fs,
              fontWeight: FontWeight.w700,
              color: colors.fg,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }

  ({Color bg, Color fg}) _colors(ColorScheme cs, AppThemeColors ac) =>
      switch (status) {
        OrderStatus.newOrder  => (bg: AppColors.statusNewBg,      fg: AppColors.statusNewFg),
        OrderStatus.preparing => (bg: AppColors.statusPreparingBg, fg: AppColors.statusPreparingFg),
        OrderStatus.onTheWay  => (bg: ac.softAccentSurface,        fg: cs.primary),
        OrderStatus.delivered => (bg: AppColors.statusDeliveredBg, fg: AppColors.statusDeliveredFg),
        OrderStatus.cancelled => (bg: AppColors.statusCancelledBg, fg: AppColors.statusCancelledFg),
      };
}
