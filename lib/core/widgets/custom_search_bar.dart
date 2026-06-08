import 'package:flutter/material.dart';
import 'package:food_delivery/core/constants/app_dimensions.dart';
import 'package:food_delivery/theme/app_theme.dart';

class CustomSearchBar extends StatelessWidget {
  final String hint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onFilterTap;
  final bool readOnly;
  final VoidCallback? onTap;

  const CustomSearchBar({
    super.key,
    this.hint = 'Search restaurants or dishes',
    this.onChanged,
    this.onSubmitted,
    this.onFilterTap,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ac = Theme.of(context).extension<AppThemeColors>()!;

    return Row(
      children: [
        Expanded(
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: ac.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              border: Border.all(color: ac.border),
            ),
            child: TextField(
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              readOnly: readOnly,
              onTap: onTap,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(color: ac.primaryText),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: ac.mutedText, fontSize: 14),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: ac.mutedText,
                  size: 18,
                ),
                suffixIcon: Icon(
                  Icons.mic_rounded,
                  color: ac.mutedText,
                  size: 18,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                isDense: true,
                filled: false,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Filter button
        GestureDetector(
          onTap: onFilterTap,
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: ac.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              border: Border.all(color: ac.border),
            ),
            child: Icon(Icons.tune_rounded, color: ac.primaryText, size: 20),
          ),
        ),
      ],
    );
  }
}
