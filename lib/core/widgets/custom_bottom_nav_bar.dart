import 'package:flutter/material.dart';
import 'package:food_delivery/theme/app_theme.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const List<_NavItem> _items = [
    _NavItem(icon: Icons.home_rounded, label: 'Home'),
    _NavItem(icon: Icons.favorite_rounded, label: 'Saved'),
    _NavItem(icon: Icons.shopping_bag_rounded, label: 'Cart'),
    _NavItem(icon: Icons.smart_toy_rounded, label: 'AI Chat'),
    _NavItem(icon: Icons.person_rounded, label: 'Account'),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ac = Theme.of(context).extension<AppThemeColors>()!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
      height: 68,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        color: ac.navbarBackground,
        boxShadow: ac.navbarShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_items.length, (i) {
          final isActive = i == currentIndex;
          return GestureDetector(
            onTap: () => onTap(i),
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: isActive
                    ? cs.primary.withValues(alpha: 0.14)
                    : Colors.transparent,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _items[i].icon,
                    color: isActive
                        ? cs.primary
                        : Colors.white.withValues(alpha: 0.6),
                    size: 22,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _items[i].label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isActive
                          ? cs.primary
                          : Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
