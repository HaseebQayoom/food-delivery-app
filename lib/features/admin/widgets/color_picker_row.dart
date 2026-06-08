import 'package:flutter/material.dart';

class ColorPickerRow extends StatelessWidget {
  final List<Color> colors;
  final Color? selected;
  final void Function(Color) onSelect;

  const ColorPickerRow({
    super.key,
    required this.colors,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: colors.map((color) {
        final isSelected = selected == color;
        return GestureDetector(
          onTap: () => onSelect(color),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 36,
            height: 36,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? cs.primary : Colors.transparent,
                width: 2.5,
              ),
            ),
            child: isSelected
                ? Icon(Icons.check_rounded, size: 16, color: cs.primary)
                : null,
          ),
        );
      }).toList(),
    );
  }
}
