import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/productivity_view_model.dart';

class PomodoroScreen extends StatelessWidget {
  const PomodoroScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProductivityViewModel>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        title: Text(
          'Pomodoro Timer',
          style: theme.textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.skip_next_rounded),
            tooltip: 'Skip session',
            onPressed: vm.timerState != TimerState.idle
                ? vm.skipSession
                : null,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 24),
              _buildSessionTypeTabs(context, vm),
              const SizedBox(height: 48),
              _buildTimerRing(context, vm),
              const SizedBox(height: 40),
              _buildControls(context, vm),
              const SizedBox(height: 32),
              _buildSessionDots(context, vm),
              const SizedBox(height: 32),
              _buildSessionInfo(context, vm),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSessionTypeTabs(
      BuildContext context, ProductivityViewModel vm) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _buildTypeTab(context, vm, SessionType.work, 'Focus'),
          _buildTypeTab(
              context, vm, SessionType.shortBreak, 'Short Break'),
          _buildTypeTab(
              context, vm, SessionType.longBreak, 'Long Break'),
        ],
      ),
    );
  }

  Widget _buildTypeTab(BuildContext context, ProductivityViewModel vm,
      SessionType type, String label) {
    final theme = Theme.of(context);
    final isSelected = vm.currentSessionType == type;

    return Expanded(
      child: GestureDetector(
        onTap: () => vm.setSessionType(type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? theme.colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: isSelected
                  ? Colors.white
                  : theme.colorScheme.onSurface.withOpacity(0.7),
              fontWeight:
                  isSelected ? FontWeight.w700 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimerRing(BuildContext context, ProductivityViewModel vm) {
    final colorScheme = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size.width * 0.72;

    Color ringColor;
    switch (vm.currentSessionType) {
      case SessionType.work:
        ringColor = colorScheme.primary;
        break;
      case SessionType.shortBreak:
        ringColor = Colors.green;
        break;
      case SessionType.longBreak:
        ringColor = Colors.teal;
        break;
    }

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background ring
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: 10,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(
                  ringColor.withOpacity(0.1)),
            ),
          ),
          // Progress ring
          SizedBox(
            width: size,
            height: size,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: vm.timerProgress),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
              builder: (context, value, _) {
                return CustomPaint(
                  painter: _ArcPainter(
                    progress: value,
                    color: ringColor,
                    strokeWidth: 10,
                  ),
                );
              },
            ),
          ),
          // Center content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                vm.formattedTime,
                style: TextStyle(
                  fontSize: size * 0.22,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.onBackground,
                  letterSpacing: -2,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: ringColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  vm.sessionTypeLabel,
                  style: TextStyle(
                    color: ringColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          // State indicator
          if (vm.timerState == TimerState.completed)
            Positioned(
              top: size * 0.1,
              child: const Text('🎉', style: TextStyle(fontSize: 28)),
            ),
        ],
      ),
    );
  }

  Widget _buildControls(BuildContext context, ProductivityViewModel vm) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Reset button
        _buildIconButton(
          icon: Icons.refresh_rounded,
          onTap: vm.resetTimer,
          size: 52,
          color: colorScheme.onSurface.withOpacity(0.6),
          bgColor: colorScheme.surfaceVariant.withOpacity(0.6),
        ),
        const SizedBox(width: 20),
        // Main action button
        _buildMainButton(context, vm),
        const SizedBox(width: 20),
        // Skip button
        _buildIconButton(
          icon: Icons.skip_next_rounded,
          onTap: vm.skipSession,
          size: 52,
          color: colorScheme.onSurface.withOpacity(0.6),
          bgColor: colorScheme.surfaceVariant.withOpacity(0.6),
        ),
      ],
    );
  }

  Widget _buildMainButton(BuildContext context, ProductivityViewModel vm) {
    final colorScheme = Theme.of(context).colorScheme;

    IconData icon;
    VoidCallback onTap;
    Color bgColor = colorScheme.primary;

    switch (vm.timerState) {
      case TimerState.idle:
      case TimerState.completed:
        icon = Icons.play_arrow_rounded;
        onTap = vm.startTimer;
        break;
      case TimerState.running:
        icon = Icons.pause_rounded;
        onTap = vm.pauseTimer;
        break;
      case TimerState.paused:
        icon = Icons.play_arrow_rounded;
        onTap = vm.resumeTimer;
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 76,
        height: 76,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: bgColor.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 36),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
    required double size,
    required Color color,
    required Color bgColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: size * 0.45),
      ),
    );
  }

  Widget _buildSessionDots(
      BuildContext context, ProductivityViewModel vm) {
    final colorScheme = Theme.of(context).colorScheme;
    final total = vm.settings.sessionsBeforeLongBreak;
    final completed = vm.completedSessionsInCycle;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final done = i < completed;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: done ? 24 : 10,
          height: 10,
          decoration: BoxDecoration(
            color: done
                ? colorScheme.primary
                : colorScheme.primary.withOpacity(0.25),
            borderRadius: BorderRadius.circular(5),
          ),
        );
      }),
    );
  }

  Widget _buildSessionInfo(BuildContext context, ProductivityViewModel vm) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          'Session ${vm.completedSessionsInCycle + 1} of ${vm.settings.sessionsBeforeLongBreak}',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Today: ${vm.todayPomodoros} pomodoros · ${vm.todayFocusFormatted} focused',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
      ],
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _ArcPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_ArcPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
