import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_delivery/core/navigation/app_navigator.dart';
import 'package:food_delivery/core/providers/shared_prefs_provider.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    // Read SharedPreferences from the injected provider (initialized in main())
    final prefs = ref.read(sharedPrefsProvider);
    final seen = prefs.getBool(StorageKeys.onboardingSeen) ?? false;
    final session = Supabase.instance.client.auth.currentSession;

    if (!seen) {
      AppNavigator.toOnboarding(context);
    } else if (session == null) {
      AppNavigator.toAuth(context);
    } else {
      AppNavigator.toHome(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFEF9F27), Color(0xFFD85A30)],
          ),
        ),
        child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            // Logo card
            Transform.rotate(
              angle: -0.12,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.6),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'C',
                    style: Theme.of(context).textTheme.displaySmall!.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.w900,
                          fontSize: 50,
                          height: 1,
                        ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            // App name
            Text(
              'crave.',
              style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 80,
                    color: cs.onPrimary,
                    letterSpacing: -5,
                  ),
            ),
            const SizedBox(height: 16),
            // Tagline
            Text(
              'EAT WHAT YOU CRAVE',
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: cs.onPrimary.withValues(alpha: 0.8),
                    letterSpacing: 1.5,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Spacer(),
            // Loading indicator
            LoadingAnimationWidget.inkDrop(
              color: cs.onPrimary.withValues(alpha: 0.7),
              size: 50,
            ),
            const SizedBox(height: 50),
          ],
        ),
        ),
      ),
    );
  }
}
