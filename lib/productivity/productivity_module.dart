import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/pomodoro_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/statistics_screen.dart';
import 'screens/settings_screen.dart';
import 'viewmodels/productivity_view_model.dart';
import 'services/productivity_service.dart';

/// Entry point widget for the Productivity module.
/// 
/// Usage:
/// ```dart
/// runApp(ProductivityApp());
/// ```
/// or embed into existing app:
/// ```dart
/// ProductivityModule()
/// ```
class ProductivityApp extends StatelessWidget {
  const ProductivityApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ProductivityService>(
      create: (_) => ProductivityService()..initialize(),
      child: Consumer<ProductivityService>(
        builder: (context, service, _) {
          return ChangeNotifierProvider<ProductivityViewModel>(
            create: (_) => ProductivityViewModel(service),
            child: Consumer<ProductivityViewModel>(
              builder: (context, vm, _) {
                return MaterialApp(
                  title: 'Productivity',
                  debugShowCheckedModeBanner: false,
                  themeMode: vm.settings.darkMode
                      ? ThemeMode.dark
                      : ThemeMode.light,
                  theme: _buildLightTheme(),
                  darkTheme: _buildDarkTheme(),
                  home: const ProductivityShell(),
                );
              },
            ),
          );
        },
      ),
    );
  }

  ThemeData _buildLightTheme() {
    const primary = Color(0xFF5B6BF8);
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
      ).copyWith(
        primary: primary,
        secondary: const Color(0xFF48BB78),
      ),
      fontFamily: 'SF Pro Display',
    );
  }

  ThemeData _buildDarkTheme() {
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
        background: const Color(0xFF14141F),
        surfaceVariant: const Color(0xFF2A2A3E),
      ),
      fontFamily: 'SF Pro Display',
    );
  }
}

/// Shell widget — can be embedded without MaterialApp wrapper.
/// Provide [ProductivityService] and [ProductivityViewModel] above this.
class ProductivityModule extends StatelessWidget {
  const ProductivityModule({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const ProductivityShell();
  }
}

class ProductivityShell extends StatelessWidget {
  const ProductivityShell({Key? key}) : super(key: key);

  static const _screens = [
    DashboardScreen(),
    PomodoroScreen(),
    CalendarScreen(),
    StatisticsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProductivityViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      body: IndexedStack(
        index: vm.selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.dashboard_rounded,
                  label: 'Dashboard',
                  index: 0,
                  currentIndex: vm.selectedIndex,
                  onTap: vm.setSelectedIndex,
                ),
                _NavItem(
                  icon: Icons.timer_rounded,
                  label: 'Focus',
                  index: 1,
                  currentIndex: vm.selectedIndex,
                  onTap: vm.setSelectedIndex,
                  badge: vm.timerState == TimerState.running
                      ? const _PulsingDot()
                      : null,
                ),
                _NavItem(
                  icon: Icons.calendar_month_rounded,
                  label: 'Calendar',
                  index: 2,
                  currentIndex: vm.selectedIndex,
                  onTap: vm.setSelectedIndex,
                ),
                _NavItem(
                  icon: Icons.bar_chart_rounded,
                  label: 'Stats',
                  index: 3,
                  currentIndex: vm.selectedIndex,
                  onTap: vm.setSelectedIndex,
                ),
                _NavItem(
                  icon: Icons.settings_rounded,
                  label: 'Settings',
                  index: 4,
                  currentIndex: vm.selectedIndex,
                  onTap: vm.setSelectedIndex,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Widget? badge;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = currentIndex == index;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withOpacity(0.45),
                  size: 24,
                ),
                if (badge != null)
                  Positioned(top: -2, right: -2, child: badge!),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.normal,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withOpacity(0.45),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot();

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _animation =
        Tween<double>(begin: 0.4, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) => Opacity(
        opacity: _animation.value,
        child: Container(
          width: 7,
          height: 7,
          decoration: const BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
