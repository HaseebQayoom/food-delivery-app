import 'package:flutter/material.dart';
import 'package:food_delivery/core/constants/app_colors.dart';
import 'package:food_delivery/core/constants/app_dimensions.dart';
import 'package:food_delivery/theme/app_theme.dart';

// Static notification items matching JSX notifications data
const _kNotifications = [
  _NotifItem(
    icon: Icons.receipt_long_outlined,
    tintBg: AppColors.statusNewBg,
    tintFg: AppColors.statusNewFg,
    title: 'New order · #CR-8231',
    body: 'Ayla Reyes · 3 items · Rs 2,800',
    when: 'Just now',
    unread: true,
  ),
  _NotifItem(
    icon: Icons.receipt_long_outlined,
    tintBg: AppColors.statusNewBg,
    tintFg: AppColors.statusNewFg,
    title: 'New order · #CR-8230',
    body: 'Marcus Lee · 3 items · Rs 2,600',
    when: '3 min ago',
    unread: true,
  ),
  _NotifItem(
    icon: Icons.check_rounded,
    tintBg: AppColors.statusDeliveredBg,
    tintFg: AppColors.statusDeliveredFg,
    title: 'Order delivered · #CR-8226',
    body: 'Sam Patel · delivered in 22 min',
    when: '26 min ago',
    unread: false,
  ),
  _NotifItem(
    icon: Icons.star_rounded,
    tintBg: AppColors.statusPreparingBg,
    tintFg: AppColors.statusPreparingFg,
    title: 'New 5-star review',
    body: '"Best burger in town." — Hana K.',
    when: '40 min ago',
    unread: false,
  ),
  _NotifItem(
    icon: Icons.kitchen_outlined,
    tintBg: null, // uses softAccentSurface
    tintFg: null, // uses cs.primary
    title: 'Low stock · Loaded Smoke Fries',
    body: 'Only a few portions left for today',
    when: '1 hr ago',
    unread: false,
  ),
];

class NotificationsPanel extends StatelessWidget {
  final VoidCallback onClose;

  const NotificationsPanel({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final ac = Theme.of(context).extension<AppThemeColors>()!;
    final cs = Theme.of(context).colorScheme;
    final unreadCount = _kNotifications.where((n) => n.unread).length;

    return Container(
      constraints: BoxConstraints(
        maxWidth: 380,
        maxHeight: MediaQuery.of(context).size.height - 110,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: ac.border),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 50,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
            child: Row(
              children: [
                Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: ac.primaryText,
                  ),
                ),
                if (unreadCount > 0) ...[
                  const SizedBox(width: 9),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: cs.primary,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusCircle),
                    ),
                    child: Text(
                      '$unreadCount',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                GestureDetector(
                  onTap: onClose,
                  child: Text(
                    'Mark all read',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: cs.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: ac.border),
          // Items
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: _kNotifications.length,
              separatorBuilder: (_, _) => Divider(height: 1, color: ac.border),
              itemBuilder: (_, i) {
                final n = _kNotifications[i];
                final itemBg = n.tintBg ?? ac.softAccentSurface;
                final itemFg = n.tintFg ?? cs.primary;
                return _NotifRow(
                  item: n,
                  iconBg: itemBg,
                  iconFg: itemFg,
                  ac: ac,
                );
              },
            ),
          ),
          Divider(height: 1, color: ac.border),
          // Footer
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: GestureDetector(
                onTap: onClose,
                child: Text(
                  'View all activity',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: ac.primaryText,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotifRow extends StatelessWidget {
  final _NotifItem item;
  final Color iconBg;
  final Color iconFg;
  final AppThemeColors ac;

  const _NotifRow({
    required this.item,
    required this.iconBg,
    required this.iconFg,
    required this.ac,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: item.unread ? const Color(0xFFFBF7F2) : Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
            ),
            child: Center(child: Icon(item.icon, size: 18, color: iconFg)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: ac.primaryText,
                        ),
                      ),
                    ),
                    if (item.unread)
                      Container(
                        width: 7,
                        height: 7,
                        margin: const EdgeInsets.only(left: 7),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  item.body,
                  style: TextStyle(fontSize: 12.5, color: ac.secondaryText),
                ),
                const SizedBox(height: 4),
                Text(
                  item.when,
                  style: TextStyle(fontSize: 11, color: ac.mutedText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotifItem {
  final IconData icon;
  final Color? tintBg;
  final Color? tintFg;
  final String title;
  final String body;
  final String when;
  final bool unread;

  const _NotifItem({
    required this.icon,
    required this.tintBg,
    required this.tintFg,
    required this.title,
    required this.body,
    required this.when,
    required this.unread,
  });
}
