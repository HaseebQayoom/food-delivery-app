import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_delivery/core/constants/app_colors.dart';
import 'package:food_delivery/core/constants/app_dimensions.dart';
import 'package:food_delivery/core/navigation/app_navigator.dart';
import 'package:food_delivery/core/utils/helpers.dart';
import 'package:food_delivery/features/profile/providers/profile_notifier.dart';
import 'package:food_delivery/theme/app_theme.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileNotifierProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final ac = Theme.of(context).extension<AppThemeColors>()!;
    final user = state.user;

    return Scaffold(
      backgroundColor: ac.background,
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Gradient header
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.primaryGradientStart, cs.primary],
                      ),
                    ),
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(AppDimensions.screenPadding, AppDimensions.md, AppDimensions.screenPadding, AppDimensions.xl),
                        child: Column(
                          children: [
                            // Avatar
                            Stack(
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withValues(alpha: 0.3),
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                  child: Center(
                                    child: Text(
                                      user != null ? Helpers.getInitials(user.fullName) : '?',
                                      style: tt.headlineMedium!.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(shape: BoxShape.circle, color: cs.primary, border: Border.all(color: Colors.white, width: 1.5)),
                                    child: const Icon(Icons.edit, size: 12, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppDimensions.sm),
                            Text(user?.fullName ?? 'Guest', style: tt.titleLarge!.copyWith(color: Colors.white)),
                            Text(user?.email ?? '', style: tt.bodySmall!.copyWith(color: Colors.white.withValues(alpha: 0.8))),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Stats row
                  Container(
                    color: ac.creamSurface,
                    padding: const EdgeInsets.symmetric(vertical: AppDimensions.md),
                    child: Row(
                      children: [
                        _StatItem(label: 'Orders', value: '${user?.totalOrders ?? 0}'),
                        _Vdivider(),
                        _StatItem(label: 'Favorites', value: '${user?.favoriteCount ?? 0}'),
                        _Vdivider(),
                        _StatItem(label: 'Points', value: '${user?.points ?? 0}'),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppDimensions.md),

                  // Account section
                  _SectionLabel(label: 'ACCOUNT'),
                  _MenuItem(icon: Icons.person_outline_rounded, label: 'Edit profile', onTap: () => AppNavigator.toEditProfile(context)),
                  _MenuItem(icon: Icons.receipt_long_outlined, label: 'Order history', onTap: () => AppNavigator.toOrderHistory(context)),
                  _MenuItem(icon: Icons.location_on_outlined, label: 'Saved addresses', onTap: () => AppNavigator.toAddresses(context)),
                  _MenuItem(icon: Icons.credit_card_outlined, label: 'Payment methods', onTap: () => AppNavigator.toPaymentMethods(context)),

                  const SizedBox(height: AppDimensions.md),

                  // Settings section
                  _SectionLabel(label: 'SETTINGS'),
                  _MenuItem(icon: Icons.notifications_outlined, label: 'Notifications', onTap: () => AppNavigator.toNotifications(context)),
                  _MenuItem(icon: Icons.card_giftcard_outlined, label: 'Invite & earn', onTap: () => AppNavigator.toInvite(context)),
                  _MenuItem(icon: Icons.tune_rounded, label: 'Preferences', onTap: () => AppNavigator.toPreferences(context)),

                  const SizedBox(height: AppDimensions.md),

                  // Other
                  _SectionLabel(label: 'OTHER'),
                  _MenuItem(icon: Icons.help_outline_rounded, label: 'Help & support', onTap: () => AppNavigator.toChat(context)),
                  _MenuItem(
                    icon: Icons.logout_rounded,
                    label: 'Log out',
                    isDanger: true,
                    onTap: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Log out?'),
                          content: const Text('Are you sure you want to log out?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text('Log out', style: TextStyle(color: cs.error)),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await ref.read(profileNotifierProvider.notifier).logout();
                        if (context.mounted) AppNavigator.toAuth(context);
                      }
                    },
                  ),

                  const SizedBox(height: 104),
                ],
              ),
            ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.w800)),
          Text(label, style: Theme.of(context).textTheme.labelSmall!.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _Vdivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(height: 32, width: 1, color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.4));
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimensions.screenPadding, 0, AppDimensions.screenPadding, 4),
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

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDanger;

  const _MenuItem({required this.icon, required this.label, required this.onTap, this.isDanger = false});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = isDanger ? cs.error : cs.onSurface;
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, size: 20, color: color),
      title: Text(label, style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: color)),
      trailing: isDanger ? null : Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant, size: 20),
      dense: true,
    );
  }
}
