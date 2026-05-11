import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const _pages = [
    _PageData(
      icon: Icons.checklist_rounded,
      title: 'Organize Your Tasks',
      description:
          'Create, manage, and prioritize all your tasks in one place. '
          'Stay on top of your daily goals effortlessly.',
      colors: [Color(0xFF6C63FF), Color(0xFF3B37C8)],
    ),
    _PageData(
      icon: Icons.insights_rounded,
      title: 'Track Your Progress',
      description:
          'Monitor your productivity with beautiful analytics and charts. '
          'Understand your work patterns and improve every day.',
      colors: [Color(0xFF43A3F5), Color(0xFF0066CC)],
    ),
    _PageData(
      icon: Icons.rocket_launch_rounded,
      title: 'Stay Productive',
      description:
          'Use the AI assistant, Pomodoro timer, and smart suggestions '
          'to maximize focus and achieve more every single day.',
      colors: [Color(0xFF56AB2F), Color(0xFF1A7A00)],
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    await AuthService().markOnboardingComplete();
    if (mounted) Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_currentPage];

    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (_, i) => _OnboardingPage(data: _pages[i]),
          ),
          SafeArea(
            child: Column(
              children: [
                // Skip button
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16, top: 8),
                    child: AnimatedOpacity(
                      opacity: _currentPage < _pages.length - 1 ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: TextButton(
                        onPressed: _finish,
                        child: const Text(
                          'Skip',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                // Page indicator dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_pages.length, (i) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == i ? 28 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white
                            .withValues(alpha: _currentPage == i ? 1.0 : 0.4),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 32),
                // Next / Get Started button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: SizedBox(
                      key: ValueKey(_currentPage == _pages.length - 1),
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: page.colors[0],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          _currentPage < _pages.length - 1
                              ? 'Next'
                              : 'Get Started',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PageData {
  final IconData icon;
  final String title;
  final String description;
  final List<Color> colors;

  const _PageData({
    required this.icon,
    required this.title,
    required this.description,
    required this.colors,
  });
}

class _OnboardingPage extends StatelessWidget {
  final _PageData data;

  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: data.colors,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Illustration container
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Icon(data.icon, size: 88, color: Colors.white),
              ),
              const SizedBox(height: 56),
              Text(
                data.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                data.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white.withValues(alpha: 0.85),
                  height: 1.65,
                ),
              ),
              const SizedBox(height: 130),
            ],
          ),
        ),
      ),
    );
  }
}
