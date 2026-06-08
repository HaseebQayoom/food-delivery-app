import 'package:flutter/material.dart';
import 'package:food_delivery/core/constants/app_dimensions.dart';
import 'package:food_delivery/core/navigation/app_navigator.dart';
import 'package:food_delivery/theme/app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _orderUpdates = true;
  bool _promotions = false;
  bool _emailNewsletters = false;
  bool _smsAlerts = true;

  void _toggle(String key, bool value) {
    setState(() {
      switch (key) {
        case 'orderUpdates':
          _orderUpdates = value;
        case 'promotions':
          _promotions = value;
        case 'email':
          _emailNewsletters = value;
        case 'sms':
          _smsAlerts = value;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notification preferences saved.'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final ac = Theme.of(context).extension<AppThemeColors>()!;

    return Scaffold(
      backgroundColor: ac.background,
      appBar: AppBar(
        backgroundColor: ac.background,
        elevation: 0,
        title: Text('Notifications', style: tt.titleLarge),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => AppNavigator.back(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.sm,
          horizontal: AppDimensions.screenPadding,
        ),
        children: [
          _SectionHeader(label: 'ORDER NOTIFICATIONS', ac: ac),
          _NotifTile(
            icon: Icons.receipt_long_outlined,
            title: 'Order updates',
            subtitle: 'Status changes, courier assignment, delivery',
            value: _orderUpdates,
            onChanged: (v) => _toggle('orderUpdates', v),
          ),
          _NotifTile(
            icon: Icons.phone_android_outlined,
            title: 'SMS alerts',
            subtitle: 'Text messages for critical order events',
            value: _smsAlerts,
            onChanged: (v) => _toggle('sms', v),
          ),
          const SizedBox(height: AppDimensions.md),
          _SectionHeader(label: 'MARKETING', ac: ac),
          _NotifTile(
            icon: Icons.local_offer_outlined,
            title: 'Promotions & deals',
            subtitle: 'Discounts, flash sales, voucher codes',
            value: _promotions,
            onChanged: (v) => _toggle('promotions', v),
          ),
          _NotifTile(
            icon: Icons.email_outlined,
            title: 'Email newsletters',
            subtitle: 'Weekly highlights and food recommendations',
            value: _emailNewsletters,
            onChanged: (v) => _toggle('email', v),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final AppThemeColors ac;
  const _SectionHeader({required this.label, required this.ac});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall!.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              letterSpacing: 1.2,
            ),
      ),
    );
  }
}

class _NotifTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotifTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ac = Theme.of(context).extension<AppThemeColors>()!;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: ac.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: ac.border, width: 0.5),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        activeThumbColor: cs.primary,
        secondary: Icon(icon, size: 20, color: cs.onSurfaceVariant),
        title: Text(title, style: Theme.of(context).textTheme.titleSmall),
        subtitle: Text(
          subtitle,
          style: Theme.of(context)
              .textTheme
              .bodySmall!
              .copyWith(color: cs.onSurfaceVariant),
        ),
      ),
    );
  }
}
