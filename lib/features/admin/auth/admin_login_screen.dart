import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_delivery/core/constants/app_dimensions.dart';
import 'package:food_delivery/core/navigation/admin_navigator.dart';
import 'package:food_delivery/core/widgets/custom_text_field.dart';
import 'package:food_delivery/core/widgets/gradient_button.dart';
import 'package:food_delivery/features/admin/auth/admin_auth_notifier.dart';

class AdminLoginScreen extends ConsumerStatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  ConsumerState<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends ConsumerState<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await ref.read(adminAuthNotifierProvider.notifier).login(
          _emailCtrl.text.trim(),
          _passwordCtrl.text,
        );
    if (success && mounted) AdminNavigator.toAdminDashboard(context);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminAuthNotifierProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.screenPadding),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo
                    Center(
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [const Color(0xFFEF9F27), cs.primary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Center(
                          child: Text('🍕', style: TextStyle(fontSize: 32)),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.lg),
                    Text('Admin Login', style: tt.headlineSmall, textAlign: TextAlign.center),
                    Text('crave. management panel', style: tt.bodyMedium!.copyWith(color: cs.onSurfaceVariant), textAlign: TextAlign.center),
                    const SizedBox(height: AppDimensions.xl),

                    CustomTextField(
                      label: 'Email',
                      hint: 'admin@crave.app',
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icon(Icons.email_outlined, size: AppDimensions.iconSm),
                      validator: (v) => (v?.isEmpty ?? true) ? 'Enter email' : null,
                    ),
                    const SizedBox(height: AppDimensions.md),
                    CustomTextField(
                      label: 'Password',
                      hint: '••••••••',
                      controller: _passwordCtrl,
                      obscureText: true,
                      prefixIcon: Icon(Icons.lock_outline_rounded, size: AppDimensions.iconSm),
                      validator: (v) => (v?.isEmpty ?? true) ? 'Enter password' : null,
                    ),

                    if (state.error != null) ...[
                      const SizedBox(height: AppDimensions.sm),
                      Text(state.error!, style: tt.bodySmall!.copyWith(color: cs.error), textAlign: TextAlign.center),
                    ],

                    const SizedBox(height: AppDimensions.lg),
                    GradientButton(text: 'Login', isLoading: state.isLoading, onPressed: _submit),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
