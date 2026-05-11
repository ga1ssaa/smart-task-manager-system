import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'modules/auth/providers/auth_provider.dart';

import 'modules/auth/screens/splash_screen.dart';
import 'modules/auth/screens/onboarding_screen.dart';
import 'modules/auth/screens/login_screen.dart';
import 'modules/auth/screens/register_screen.dart';
import 'modules/auth/screens/profile_screen.dart';

import 'modules/tasks/screens/home_screen.dart';

import 'productivity/productivity_module.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),

      child: MaterialApp(
        debugShowCheckedModeBanner: false,

        initialRoute: '/',

        routes: {
          '/': (_) => const SplashScreen(),

          '/onboarding': (_) =>
              const OnboardingScreen(),

          '/login': (_) =>
              const LoginScreen(),

          '/register': (_) =>
              const RegisterScreen(),

          '/profile': (_) =>
              const ProfileScreen(),

          '/home': (_) =>
              const MainShell(),
        },
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() =>
      _MainShellState();
}

class _MainShellState
    extends State<MainShell> {
  int selectedIndex = 0;

  final screens = const [
    HomeScreen(),

    ProductivityApp(),

    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[selectedIndex],

      bottomNavigationBar:
          BottomNavigationBar(
        currentIndex: selectedIndex,

        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.task_alt),
            label: 'Tasks',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.timer),
            label: 'Focus',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}