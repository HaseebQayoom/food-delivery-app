import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_delivery/core/constants/env.dart';
import 'package:food_delivery/core/navigation/app_navigator.dart';
import 'package:food_delivery/core/utils/validators.dart';
import 'package:food_delivery/features/auth/providers/auth_notifier.dart';
import 'package:food_delivery/features/auth/widgets/auth_text.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true;
  bool _obscurePassword = true;

  String _name = '';
  String _email = '';
  // String _phone = '';
  String _password = '';

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    bool success;
    if (_isLogin) {
      success = await ref
          .read(authNotifierProvider.notifier)
          .login(_email, _password);
    } else {
      success = await ref.read(authNotifierProvider.notifier).signup(
            name: _name,
            email: _email,
            // phone: _phone,
            password: _password,
          );
    }

    if (success && mounted) {
      final adminEmail = Env.adminEmail;
      if (adminEmail.isNotEmpty && _email.trim() == adminEmail) {
        AppNavigator.toAdminShell(context);
      } else {
        AppNavigator.toHome(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.isLoading;

    ref.listen<AuthState>(authNotifierProvider, (_, next) {
      if (next.error != null) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Login Failed'),
            content: const Text('Your entered email or password is wrong. Please try again.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    });

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: _isLogin
                    ? const AuthText(
                        loginText: 'Welcome back.',
                        loginText2: 'Log in to pick up where you left off.',
                      )
                    : const AuthText(
                        loginText: "Let's get you fed.",
                        loginText2: 'Create an account in under a minute.',
                      ),
              ),

              const SizedBox(height: 30),

              // Login / Sign Up toggle
              Padding(
                padding: const EdgeInsets.only(left: 24),
                child: SizedBox(
                  width: double.infinity,
                  child: AnimatedToggleSwitch<bool>.size(
                    current: _isLogin,
                    values: const [true, false],
                    height: 52,
                    indicatorSize: const Size.fromWidth(200),
                    padding: const EdgeInsets.all(6),
                    borderWidth: 1.5,
                    animationDuration: const Duration(milliseconds: 300),
                    style: ToggleStyle(
                      backgroundColor: cs.surface,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(99),
                        bottomLeft: Radius.circular(99),
                      ),
                    ),
                    styleBuilder: (value) => ToggleStyle(
                      indicatorColor: cs.onSurface,
                      borderColor: cs.outlineVariant,
                      indicatorBorderRadius: BorderRadius.circular(99),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(99),
                        bottomLeft: Radius.circular(99),
                      ),
                    ),
                    iconBuilder: (value) => Text(
                      value ? 'Log In' : 'Sign Up',
                      style: TextStyle(
                        color: value == _isLogin ? cs.surface : cs.onSurface,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                    onChanged: (value) => setState(() {
                      _isLogin = value;
                      _formKey.currentState?.reset();
                    }),
                  ),
                ),
              ),

              // Form
              Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Name field — signup only
                      if (!_isLogin) ...[
                        _buildField(
                          cs: cs,
                          label: 'NAME',
                          hint: 'John Doe',
                          validator: Validators.name,
                          onSaved: (v) => _name = v!,
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Email field
                      _buildField(
                        cs: cs,
                        label: 'EMAIL',
                        hint: 'hello@crave.app',
                        keyboardType: TextInputType.emailAddress,
                        validator: Validators.email,
                        onSaved: (v) => _email = v!,
                      ),
                      const SizedBox(height: 16),

                      // Phone field — signup only
                      // if (!_isLogin) ...[
                      //   _buildField(
                      //     cs: cs,
                      //     label: 'PHONE',
                      //     hint: '+92 300 1234567',
                      //     keyboardType: TextInputType.phone,
                      //     validator: (v) => (v == null || v.trim().length < 7)
                      //         ? 'Enter a valid phone number'
                      //         : null,
                      //     onSaved: (v) => _phone = v!,
                      //   ),
                      //   const SizedBox(height: 16),
                      // ],
// 
                      // Password field
                      _buildField(
                        cs: cs,
                        label: 'PASSWORD',
                        hint: '••••••••',
                        obscureText: _obscurePassword,
                        validator: Validators.password,
                        onSaved: (v) => _password = v!,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                            size: 20,
                            color: cs.onSurfaceVariant,
                          ),
                          onPressed: () =>
                              setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),

                      SizedBox(
                        height: _isLogin
                            ? MediaQuery.of(context).size.height / 5.92
                            : MediaQuery.of(context).size.height / 11,
                      ),


                      // Submit button
                      ElevatedButton.icon(
                        onPressed: isLoading ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          elevation: 3,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shadowColor: cs.primary.withValues(alpha: 0.4),
                          backgroundColor: cs.primary,
                          foregroundColor: cs.onPrimary,
                          disabledBackgroundColor:
                              cs.primary.withValues(alpha: 0.6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                        label: isLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: cs.onPrimary,
                                ),
                              )
                            : Text(
                                _isLogin ? 'Log in' : 'Create account',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                        icon: isLoading
                            ? const SizedBox.shrink()
                            : const Icon(Icons.keyboard_arrow_right),
                      ),

                      const SizedBox(height: 50),

                      // Divider
                      Row(
                        children: [
                          Expanded(
                              child: Divider(color: cs.outlineVariant)),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'or continue with',
                              style: TextStyle(
                                color: cs.onSurfaceVariant,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                              child: Divider(color: cs.outlineVariant)),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Google / OAuth button
                      OutlinedButton.icon(

                        onPressed: () => AppNavigator.toHome(context),
                        icon: const Icon(Icons.email_outlined),
                        label: const Text(
                          'Continue with Google',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: cs.surface,
                          foregroundColor: cs.onSurface,
                          side: BorderSide(color: cs.outlineVariant),
                          minimumSize: const Size(double.infinity, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required ColorScheme cs,
    required String label,
    required String hint,
    required String? Function(String?) validator,
    required void Function(String?) onSaved,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        onSaved: onSaved,
        style: TextStyle(
          fontSize: 16,
          color: cs.onSurface,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          filled: false,
          labelText: label,
          hintText: hint,
          hintStyle:
              TextStyle(color: cs.onSurfaceVariant.withValues(alpha: 0.6)),
          labelStyle: TextStyle(
            fontSize: 15,
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
          suffixIcon: suffixIcon,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          errorStyle: const TextStyle(height: 0.8, fontSize: 12),
        ),
      ),
    );
  }
}
