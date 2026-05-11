import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/pomodoro_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/statistics_screen.dart';
import 'screens/settings_screen.dart';
import 'viewmodels/productivity_view_model.dart';
import 'services/productivity_service.dart';

class ProductivityApp extends StatelessWidget {
  const ProductivityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProductivityService()..initialize(),

      child: Builder(
        builder: (context) {
          final service =
              context.read<ProductivityService>();

          return ChangeNotifierProvider(
            create: (_) =>
                ProductivityViewModel(service),

            child: Builder(
              builder: (context) {
                final vm = context.watch<
                    ProductivityViewModel>();

                return Theme(
                  data: vm.settings.darkMode
                      ? _buildDarkTheme()
                      : _buildLightTheme(),

                  child:
                      const ProductivityShell(),
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
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    const primary = Color(0xFF7B8FF8);

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.dark,
      ),
    );
  }
}
class ProductivityModule extends StatelessWidget {
  const ProductivityModule({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProductivityApp();
  }
}

class ProductivityShell extends StatelessWidget {
  const ProductivityShell({super.key});

  static const _screens = [
    DashboardScreen(),
    PomodoroScreen(),
    CalendarScreen(),
    StatisticsScreen(),
    SettingsScreen(),
  ];

  static const _tabs = [
    Tab(text: 'Dashboard'),
    Tab(text: 'Focus'),
    Tab(text: 'Calendar'),
    Tab(text: 'Stats'),
    Tab(text: 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _screens.length,

      child: Column(
        children: [
          const SizedBox(height: 50),

          const TabBar(
            isScrollable: true,
            tabs: _tabs,
          ),

          Expanded(
            child: TabBarView(
              children: _screens,
            ),
          ),
        ],
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
    final isSelected =
        currentIndex == index;

    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration:
            const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
                  .withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius:
              BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme
                          .onSurface
                          .withValues(
                            alpha: 0.45,
                          ),
                ),
                if (badge != null)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: badge!,
                  ),
              ],
            ),

            const SizedBox(height: 4),

            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected
                    ? FontWeight.w700
                    : FontWeight.normal,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme
                        .onSurface
                        .withValues(
                          alpha: 0.45,
                        ),
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
  State<_PulsingDot> createState() =>
      _PulsingDotState();
}

class _PulsingDotState
    extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration:
          const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    animation = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(controller);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, __) {
        return Opacity(
          opacity: animation.value,
          child: Container(
            width: 7,
            height: 7,
            decoration:
                const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}