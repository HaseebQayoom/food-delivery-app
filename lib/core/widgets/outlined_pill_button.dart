import 'package:flutter/material.dart';
import 'package:food_delivery/core/constants/app_dimensions.dart';
import 'package:food_delivery/theme/app_theme.dart';

class OutlinedPillButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Widget? icon;
  final Color? borderColor;
  final Color? textColor;

  const OutlinedPillButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.borderColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ac = Theme.of(context).extension<AppThemeColors>()!;
    final effectiveBorder = borderColor ?? ac.border;
    final effectiveText = textColor ?? cs.onSurface;

    return SizedBox(
      height: AppDimensions.buttonHeight,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: effectiveText,
          side: BorderSide(color: effectiveBorder),
          minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusCircle),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[icon!, const SizedBox(width: 8)],
            Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: effectiveText,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
