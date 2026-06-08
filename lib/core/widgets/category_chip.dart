import 'package:flutter/material.dart';
import 'package:food_delivery/theme/app_theme.dart';

class CategoryChip extends StatefulWidget {
  final String label;
  final Widget icon;
  final bool isSelected;
  final VoidCallback? onTap;
  final Color bgColor;

  const CategoryChip({
    super.key,
    required this.label,
    required this.icon,
    required this.bgColor,
    this.isSelected = false,
    this.onTap,
  });

  @override
  State<CategoryChip> createState() => _CategoryChipState();
}

class _CategoryChipState extends State<CategoryChip> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ac = Theme.of(context).extension<AppThemeColors>()!;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: widget.bgColor,
                borderRadius: BorderRadius.circular(12),
                border: widget.isSelected
                    ? Border.all(color: cs.primary, width: 2)
                    : Border.all(color: Colors.transparent),
              ),
              child: Center(child: widget.icon),
            ),
            const SizedBox(height: 6),
            Text(
              widget.label,
              style: Theme.of(context).textTheme.labelSmall!.copyWith(
                    color: widget.isSelected ? cs.primary : ac.mutedText,
                    fontWeight: widget.isSelected
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
