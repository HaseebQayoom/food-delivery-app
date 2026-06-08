import 'package:flutter/material.dart';
import 'package:food_delivery/theme/app_theme.dart';

class QuantityControl extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final int minQuantity;

  const QuantityControl({
    super.key,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    this.minQuantity = 1,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ac = Theme.of(context).extension<AppThemeColors>()!;
    final atMin = quantity <= minQuantity;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ControlButton(
          onPressed: atMin ? null : onDecrement,
          icon: Icons.remove,
          backgroundColor: ac.surface,
          borderColor: ac.border,
          iconColor: atMin ? ac.mutedText : cs.onSurface,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            '$quantity',
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        _ControlButton(
          onPressed: onIncrement,
          icon: Icons.add,
          backgroundColor: cs.primary,
          borderColor: cs.primary,
          iconColor: cs.onPrimary,
        ),
      ],
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.onPressed,
    required this.icon,
    required this.backgroundColor,
    required this.borderColor,
    required this.iconColor,
  });

  final VoidCallback? onPressed;
  final IconData icon;
  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: onPressed == null
              ? backgroundColor.withValues(alpha: 0.5)
              : backgroundColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: onPressed == null
                ? borderColor.withValues(alpha: 0.3)
                : borderColor,
          ),
        ),
        child: Icon(icon, size: 16, color: iconColor),
      ),
    );
  }
}
