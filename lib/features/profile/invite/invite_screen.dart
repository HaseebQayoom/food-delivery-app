import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_delivery/core/constants/app_colors.dart';
import 'package:food_delivery/core/constants/app_dimensions.dart';
import 'package:food_delivery/core/navigation/app_navigator.dart';
import 'package:food_delivery/features/profile/providers/profile_notifier.dart';
import 'package:food_delivery/theme/app_theme.dart';

class InviteScreen extends ConsumerWidget {
  const InviteScreen({super.key});

  String _referralCode(String userId) =>
      'CRAVE-${userId.substring(0, 6).toUpperCase()}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(profileNotifierProvider).user;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final ac = Theme.of(context).extension<AppThemeColors>()!;
    final code = user != null ? _referralCode(user.id) : '—';

    return Scaffold(
      backgroundColor: ac.background,
      appBar: AppBar(
        backgroundColor: ac.background,
        elevation: 0,
        title: Text('Invite & Earn', style: tt.titleLarge),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => AppNavigator.back(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.screenPadding),
        children: [
          // Hero banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              vertical: AppDimensions.xl,
              horizontal: AppDimensions.lg,
            ),
            decoration: BoxDecoration(
              gradient: AppGradients.primary,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            ),
            child: Column(
              children: [
                const Icon(Icons.card_giftcard_rounded,
                    color: Colors.white, size: 48),
                const SizedBox(height: AppDimensions.sm),
                Text(
                  'Give Rs 200, Get Rs 200',
                  style: tt.titleLarge!.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.xs),
                Text(
                  'Invite friends to crave. and you both earn\nRs 200 off your next order.',
                  style: tt.bodySmall!
                      .copyWith(color: Colors.white.withValues(alpha: 0.9)),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppDimensions.xl),

          Text(
            'YOUR REFERRAL CODE',
            style: tt.labelSmall!.copyWith(
              color: cs.onSurfaceVariant,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppDimensions.sm),

          // Code card
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.lg,
              vertical: AppDimensions.md,
            ),
            decoration: BoxDecoration(
              color: ac.creamSurface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              border: Border.all(color: ac.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    code,
                    style: tt.titleMedium!.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 3,
                      color: cs.primary,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy_rounded, size: 20),
                  color: cs.primary,
                  tooltip: 'Copy code',
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: code));
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Code $code copied to clipboard.')),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: AppDimensions.lg),

          // How it works
          Text(
            'HOW IT WORKS',
            style: tt.labelSmall!.copyWith(
              color: cs.onSurfaceVariant,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppDimensions.sm),
          ...[
            ('Share your code', 'Send it to a friend via WhatsApp or SMS.'),
            ('Friend signs up', 'They create an account using your code.'),
            ('Both earn Rs 200',
                'Credit applied after their first order is delivered.'),
          ].asMap().entries.map((e) => _StepTile(
                step: e.key + 1,
                title: e.value.$1,
                subtitle: e.value.$2,
                cs: cs,
                ac: ac,
              )),

          const SizedBox(height: AppDimensions.xl),

          // Share button
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Share: Use code $code on crave.'),
                ),
              );
            },
            icon: const Icon(Icons.share_rounded),
            label: const Text('Share invite code'),
            style: ElevatedButton.styleFrom(
              backgroundColor: cs.primary,
              foregroundColor: cs.onPrimary,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(99)),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  final int step;
  final String title;
  final String subtitle;
  final ColorScheme cs;
  final AppThemeColors ac;

  const _StepTile({
    required this.step,
    required this.title,
    required this.subtitle,
    required this.cs,
    required this.ac,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$step',
                style: Theme.of(context).textTheme.labelSmall!.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall!
                        .copyWith(fontWeight: FontWeight.w600)),
                Text(subtitle,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .copyWith(color: cs.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
