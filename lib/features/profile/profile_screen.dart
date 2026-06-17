import 'package:cached_network_image/cached_network_image.dart';
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
          : RefreshIndicator(
              onRefresh: () => ref.read(profileNotifierProvider.notifier).fetchProfile(),
              child: SingleChildScrollView(
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
                            GestureDetector(
                              onTap: () => _showAvatarPicker(context, ref, cs, user?.avatarUrl),
                              child: Stack(
                                children: [
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _resolveAvatarColor(user?.avatarUrl, cs),
                                      border: Border.all(color: Colors.white, width: 2),
                                    ),
                                    child: ClipOval(
                                      child: _isImageUrl(user?.avatarUrl)
                                          ? CachedNetworkImage(
                                              imageUrl: user!.avatarUrl!,
                                              fit: BoxFit.cover,
                                              errorWidget: (context, _, _) =>
                                                  _initialsWidget(user.fullName, tt),
                                            )
                                          : _initialsWidget(
                                              user?.fullName ?? '', tt),
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
          ),
    );
  }


  static bool _isImageUrl(String? url) =>
      url != null &&
      (url.startsWith('http://') || url.startsWith('https://'));

  static Widget _initialsWidget(String name, TextTheme tt) => Center(
        child: Text(
          name.isNotEmpty ? Helpers.getInitials(name) : '?',
          style: tt.headlineMedium!
              .copyWith(color: Colors.white, fontWeight: FontWeight.w800),
        ),
      );

  static Color _resolveAvatarColor(String? avatarUrl, ColorScheme cs) {
    if (avatarUrl == null || _isImageUrl(avatarUrl)) {
      return Colors.white.withValues(alpha: 0.3);
    }
    // Legacy avatar:N codes or unrecognised values — use a generic tint
    return cs.primaryContainer;
  }

  // Animated avatar presets — DiceBear API (free, no key, PNG output)
  static const _kPresetAvatars = [
    'https://api.dicebear.com/9.x/fun-emoji/png?seed=crave1&size=200',
    'https://api.dicebear.com/9.x/fun-emoji/png?seed=crave2&size=200',
    'https://api.dicebear.com/9.x/fun-emoji/png?seed=crave3&size=200',
    'https://api.dicebear.com/9.x/fun-emoji/png?seed=crave4&size=200',
    'https://api.dicebear.com/9.x/bottts/png?seed=crave1&size=200',
    'https://api.dicebear.com/9.x/bottts/png?seed=crave2&size=200',
    'https://api.dicebear.com/9.x/bottts/png?seed=crave3&size=200',
    'https://api.dicebear.com/9.x/bottts/png?seed=crave4&size=200',
    'https://api.dicebear.com/9.x/thumbs/png?seed=crave1&size=200',
    'https://api.dicebear.com/9.x/thumbs/png?seed=crave2&size=200',
    'https://api.dicebear.com/9.x/thumbs/png?seed=crave3&size=200',
    'https://api.dicebear.com/9.x/thumbs/png?seed=crave4&size=200',
  ];

  void _showAvatarPicker(
      BuildContext context, WidgetRef ref, ColorScheme cs, String? current) {
    final ac = Theme.of(context).extension<AppThemeColors>()!;
    final tt = Theme.of(context).textTheme;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimensions.radiusLg)),
      ),
      builder: (sheetContext) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (_, scrollCtrl) => Padding(
          padding: const EdgeInsets.fromLTRB(
              AppDimensions.lg, AppDimensions.md, AppDimensions.lg, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppDimensions.md),
                  decoration: BoxDecoration(
                    color: ac.border,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              Text('Choose avatar', style: tt.titleMedium),
              const SizedBox(height: AppDimensions.md),
              // Photo source buttons
              Row(
                children: [
                  Expanded(
                    child: _SourceButton(
                      icon: Icons.photo_library_outlined,
                      label: 'Gallery',
                      cs: cs,
                      onTap: () {
                        Navigator.pop(sheetContext);
                        ref
                            .read(profileNotifierProvider.notifier)
                            .uploadAvatarFromGallery();
                      },
                    ),
                  ),
                  const SizedBox(width: AppDimensions.sm),
                  Expanded(
                    child: _SourceButton(
                      icon: Icons.camera_alt_outlined,
                      label: 'Camera',
                      cs: cs,
                      onTap: () {
                        Navigator.pop(sheetContext);
                        ref
                            .read(profileNotifierProvider.notifier)
                            .uploadAvatarFromCamera();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.lg),
              Text('Animated avatars',
                  style: tt.labelMedium?.copyWith(color: ac.mutedText)),
              const SizedBox(height: AppDimensions.sm),
              Expanded(
                child: GridView.builder(
                  controller: scrollCtrl,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: AppDimensions.sm,
                    mainAxisSpacing: AppDimensions.sm,
                    childAspectRatio: 1,
                  ),
                  itemCount: _kPresetAvatars.length,
                  itemBuilder: (_, i) {
                    final url = _kPresetAvatars[i];
                    final isSelected = current == url;
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(sheetContext);
                        ref
                            .read(profileNotifierProvider.notifier)
                            .updateAvatar(url);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? cs.primary
                                : Colors.transparent,
                            width: 3,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: cs.primary.withValues(alpha: 0.35),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  )
                                ]
                              : null,
                        ),
                        child: ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: url,
                            fit: BoxFit.cover,
                            placeholder: (_, _) => Container(
                              color: ac.creamSurface,
                              child: Icon(Icons.person_rounded,
                                  color: ac.mutedText, size: 28),
                            ),
                            errorWidget: (_, _, _) => Container(
                              color: ac.creamSurface,
                              child: Icon(Icons.person_rounded,
                                  color: ac.mutedText, size: 28),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppDimensions.xl),
            ],
          ),
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

class _SourceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final ColorScheme cs;
  final VoidCallback onTap;

  const _SourceButton({
    required this.icon,
    required this.label,
    required this.cs,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: cs.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(color: cs.primary.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: cs.primary, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: cs.primary,
              ),
            ),
          ],
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
