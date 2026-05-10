import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'modules/auth/auth_module.dart';
import 'productivity/productivity_module.dart';
import 'productivity/services/productivity_service.dart';
import 'productivity/viewmodels/productivity_view_model.dart';

void main() {
  runApp(const SmartTaskApp());
}

class SmartTaskApp extends StatelessWidget {
  const SmartTaskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Student 1 — Auth
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // Student 4 — Productivity
        ChangeNotifierProvider(create: (_) => ProductivityService()..initialize()),
        ChangeNotifierProxyProvider<ProductivityService, ProductivityViewModel>(
          create: (ctx) =>
              ProductivityViewModel(ctx.read<ProductivityService>()),
          update: (_, service, prev) =>
              prev ?? ProductivityViewModel(service),
        ),
      ],
      child: Consumer<ProductivityViewModel>(
        builder: (context, vm, _) {
          return MaterialApp(
            title: 'SmartTask',
            debugShowCheckedModeBanner: false,
            themeMode: vm.settings.darkMode ? ThemeMode.dark : ThemeMode.light,
            theme: _lightTheme(),
            darkTheme: _darkTheme(),
            initialRoute: '/splash',
            routes: {
              // ── Student 1: Auth & Profile ──
              '/splash': (_) => const SplashScreen(),
              '/onboarding': (_) => const OnboardingScreen(),
              '/login': (_) => const LoginScreen(),
              '/register': (_) => const RegisterScreen(),
              '/profile': (_) => const ProfileScreen(),
              // ── Student 4: Productivity ──
              '/productivity': (_) => const ProductivityModule(),
            },
          );
        },
      ),
    );
  }

  ThemeData _lightTheme() {
    const primary = Color(0xFF6C63FF);
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
      ).copyWith(primary: primary, secondary: const Color(0xFF48BB78)),
    );
  }

  ThemeData _darkTheme() {
    const primary = Color(0xFF7B8FF8);
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.dark,
      ).copyWith(
        primary: primary,
        secondary: const Color(0xFF68D391),
        surface: const Color(0xFF1E1E2E),
      ),
    );
  }
}
