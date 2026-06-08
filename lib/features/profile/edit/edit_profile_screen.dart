import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_delivery/core/constants/app_dimensions.dart';
import 'package:food_delivery/core/navigation/app_navigator.dart';
import 'package:food_delivery/core/widgets/gradient_button.dart';
import 'package:food_delivery/features/profile/providers/profile_notifier.dart';
import 'package:food_delivery/theme/app_theme.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;

  @override
  void initState() {
    super.initState();
    final user = ref.read(profileNotifierProvider).user;
    _nameCtrl = TextEditingController(text: user?.fullName ?? '');
    _phoneCtrl = TextEditingController(text: user?.phone ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await ref.read(profileNotifierProvider.notifier).updateProfile(
          name: _nameCtrl.text.trim(),
          phone: _phoneCtrl.text.trim(),
        );
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated.')),
      );
      AppNavigator.back(context);
    } else {
      final error = ref.read(profileNotifierProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? 'Update failed.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileNotifierProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final ac = Theme.of(context).extension<AppThemeColors>()!;

    return Scaffold(
      backgroundColor: ac.background,
      appBar: AppBar(
        backgroundColor: ac.background,
        elevation: 0,
        title: Text('Edit Profile', style: tt.titleLarge),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => AppNavigator.back(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppDimensions.screenPadding),
          children: [
            // Avatar placeholder
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: cs.primaryContainer,
                    child: Text(
                      _nameCtrl.text.isNotEmpty
                          ? _nameCtrl.text[0].toUpperCase()
                          : '?',
                      style: tt.headlineMedium!.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: cs.primary,
                        border: Border.all(color: cs.surface, width: 2),
                      ),
                      child:
                          Icon(Icons.edit, size: 13, color: cs.onPrimary),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.xl),

            // Full name
            _FieldLabel(label: 'FULL NAME', cs: cs),
            const SizedBox(height: AppDimensions.xs),
            TextFormField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              onChanged: (_) => setState(() {}),
              validator: (v) => (v == null || v.trim().length < 2)
                  ? 'Enter at least 2 characters'
                  : null,
              decoration: _inputDecoration(
                  hint: 'Your full name', cs: cs, ac: ac),
            ),

            const SizedBox(height: AppDimensions.md),

            // Phone
            _FieldLabel(label: 'PHONE', cs: cs),
            const SizedBox(height: AppDimensions.xs),
            TextFormField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              validator: (v) => (v == null || v.trim().length < 7)
                  ? 'Enter a valid phone number'
                  : null,
              decoration: _inputDecoration(
                  hint: '+92 300 1234567', cs: cs, ac: ac),
            ),

            const SizedBox(height: AppDimensions.xs),
            Text(
              'Email cannot be changed after registration.',
              style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant),
            ),

            const SizedBox(height: AppDimensions.xl),

            GradientButton(
              text: 'Save changes',
              isLoading: profileState.isLoading,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required ColorScheme cs,
    required AppThemeColors ac,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: cs.onSurfaceVariant),
      filled: true,
      fillColor: ac.inputFill,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        borderSide: BorderSide(color: ac.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        borderSide: BorderSide(color: ac.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        borderSide: BorderSide(color: cs.primary, width: 1.5),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  final ColorScheme cs;
  const _FieldLabel({required this.label, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelSmall!.copyWith(
            color: cs.onSurfaceVariant,
            letterSpacing: 1.2,
          ),
    );
  }
}
