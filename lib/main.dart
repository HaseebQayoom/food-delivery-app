import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:food_delivery/core/constants/env.dart';
import 'package:food_delivery/core/providers/shared_prefs_provider.dart';
import 'package:food_delivery/features/splash/splash_screen.dart';
import 'package:food_delivery/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env before anything reads Env.*
  await dotenv.load(fileName: '.env');

  // Initialize Stripe with publishable key from .env
  Stripe.publishableKey = Env.stripePublishableKey;

  // Initialize Supabase — session is then available synchronously everywhere
  await Supabase.initialize(
    url: Env.supabaseUrl,
    publishableKey: Env.supabaseAnonKey,
  );

  // Initialize SharedPreferences once here — injected into providers via override
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        // Plain Provider<SharedPreferences> — no FutureProvider needed
        sharedPrefsProvider.overrideWithValue(prefs),
      ],
      child: const CraveApp(),
    ),
  );
}

class CraveApp extends StatelessWidget {
  const CraveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'crave.',
      theme: AppTheme.lightTheme(),
      // darkTheme: AppTheme.darkTheme(),
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}
