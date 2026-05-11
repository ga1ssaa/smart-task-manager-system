// Student 1 — User & Profile Module
// Exports all public components of the auth module for integration by team leader.
//
// Required pubspec.yaml dependencies:
//   firebase_auth: ^5.0.0
//   cloud_firestore: ^5.0.0
//   firebase_storage: ^12.0.0
//   shared_preferences: ^2.3.0
//   image_picker: ^1.1.0
//   provider: ^6.1.0
//
// Required routes in main.dart:
//   '/splash'      → SplashScreen
//   '/onboarding'  → OnboardingScreen
//   '/login'       → LoginScreen
//   '/register'    → RegisterScreen
//   '/profile'     → ProfileScreen
//
// Required in main.dart ChangeNotifierProvider:
//   ChangeNotifierProvider(create: (_) => AuthProvider())

export 'models/user_model.dart';
export 'services/auth_service.dart';
export 'providers/auth_provider.dart';
export 'screens/splash_screen.dart';
export 'screens/onboarding_screen.dart';
export 'screens/login_screen.dart';
export 'screens/register_screen.dart';
export 'screens/profile_screen.dart';
export 'widgets/auth_text_field.dart';
export 'widgets/primary_button.dart';
export 'widgets/avatar_widget.dart';
