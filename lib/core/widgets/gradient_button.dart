import 'package:flutter/material.dart';
import 'package:food_delivery/core/constants/app_colors.dart';
import 'package:food_delivery/core/constants/app_dimensions.dart';
import 'package:food_delivery/theme/app_theme.dart';

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double height;

  const GradientButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.height = AppDimensions.buttonHeight,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ac = Theme.of(context).extension<AppThemeColors>()!;
    final isDisabled = onPressed == null || isLoading;

    return GestureDetector(
      onTap: isDisabled ? null : onPressed,
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: isDisabled ? null : AppGradients.primary,
          color: isDisabled ? cs.onSurface.withValues(alpha: 0.12) : null,
          borderRadius: BorderRadius.circular(AppDimensions.radiusCircle),
          boxShadow: isDisabled ? null : ac.buttonShadow,
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  text,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: isDisabled
                            ? cs.onSurface.withValues(alpha: 0.38)
                            : Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
        ),
      ),
    );
  }
}
