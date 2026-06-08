import 'package:flutter/material.dart';
import 'package:food_delivery/core/constants/app_dimensions.dart';
import 'package:food_delivery/core/navigation/app_navigator.dart';
import 'package:food_delivery/theme/app_theme.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  int _themeIndex = 0; // 0 = System, 1 = Light, 2 = Dark
  bool _compactMode = false;
  bool _haptics = true;

  void _showSaved() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Preferences saved.'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final ac = Theme.of(context).extension<AppThemeColors>()!;

    return Scaffold(
      backgroundColor: ac.background,
      appBar: AppBar(
        backgroundColor: ac.background,
        elevation: 0,
        title: Text('Preferences', style: tt.titleLarge),
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
          // ── App Theme ───────────────────────────────────────────
          _Label(label: 'APP THEME', cs: cs),
          const SizedBox(height: AppDimensions.sm),
          Container(
            padding: const EdgeInsets.all(AppDimensions.md),
            decoration: BoxDecoration(
              color: ac.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              border: Border.all(color: ac.border, width: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Select theme',
                    style: tt.titleSmall),
                const SizedBox(height: AppDimensions.sm),
                SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(value: 0, label: Text('System'), icon: Icon(Icons.contrast_rounded, size: 16)),
                    ButtonSegment(value: 1, label: Text('Light'), icon: Icon(Icons.light_mode_rounded, size: 16)),
                    ButtonSegment(value: 2, label: Text('Dark'), icon: Icon(Icons.dark_mode_rounded, size: 16)),
                  ],
                  selected: {_themeIndex},
                  onSelectionChanged: (s) {
                    setState(() => _themeIndex = s.first);
                    _showSaved();
                  },
                  style: ButtonStyle(
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppDimensions.md),

          // ── Display ─────────────────────────────────────────────
          _Label(label: 'DISPLAY', cs: cs),
          const SizedBox(height: AppDimensions.sm),
          _PrefTile(
            icon: Icons.view_compact_rounded,
            title: 'Compact mode',
            subtitle: 'Reduce card sizes and spacing',
            value: _compactMode,
            onChanged: (v) {
              setState(() => _compactMode = v);
              _showSaved();
            },
            cs: cs,
            ac: ac,
          ),
          const SizedBox(height: 8),
          _PrefTile(
            icon: Icons.vibration_rounded,
            title: 'Haptic feedback',
            subtitle: 'Vibrate on button taps and confirmations',
            value: _haptics,
            onChanged: (v) {
              setState(() => _haptics = v);
              _showSaved();
            },
            cs: cs,
            ac: ac,
          ),

          const SizedBox(height: AppDimensions.md),

          // ── Storage ─────────────────────────────────────────────
          _Label(label: 'STORAGE', cs: cs),
          const SizedBox(height: AppDimensions.sm),
          Container(
            decoration: BoxDecoration(
              color: ac.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              border: Border.all(color: ac.border, width: 0.5),
            ),
            child: ListTile(
              leading: Icon(Icons.delete_sweep_outlined,
                  size: 20, color: cs.onSurfaceVariant),
              title: Text('Clear image cache', style: tt.bodyLarge),
              subtitle: Text('Free up device storage',
                  style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
              trailing: Icon(Icons.chevron_right_rounded,
                  color: cs.onSurfaceVariant, size: 20),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Image cache cleared.')),
                );
              },
            ),
          ),

          const SizedBox(height: AppDimensions.md),

          // ── App Info ────────────────────────────────────────────
          _Label(label: 'APP INFO', cs: cs),
          const SizedBox(height: AppDimensions.sm),
          Container(
            padding: const EdgeInsets.all(AppDimensions.md),
            decoration: BoxDecoration(
              color: ac.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              border: Border.all(color: ac.border, width: 0.5),
            ),
            child: Column(
              children: [
                _InfoRow(label: 'Version', value: '1.0.0', cs: cs, tt: tt),
                Divider(height: 20, color: cs.outlineVariant),
                _InfoRow(label: 'Build', value: '1', cs: cs, tt: tt),
                Divider(height: 20, color: cs.outlineVariant),
                _InfoRow(label: 'Platform', value: 'Flutter', cs: cs, tt: tt),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String label;
  final ColorScheme cs;
  const _Label({required this.label, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4, top: 4),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall!.copyWith(
              color: cs.onSurfaceVariant,
              letterSpacing: 1.2,
            ),
      ),
    );
  }
}

class _PrefTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final ColorScheme cs;
  final AppThemeColors ac;

  const _PrefTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.cs,
    required this.ac,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final ColorScheme cs;
  final TextTheme tt;
  const _InfoRow(
      {required this.label,
      required this.value,
      required this.cs,
      required this.tt});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: tt.bodyMedium!.copyWith(color: cs.onSurfaceVariant)),
        const Spacer(),
        Text(value,
            style: tt.bodyMedium!.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
