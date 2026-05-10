import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/productivity_view_model.dart';
import '../services/productivity_service.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProductivityViewModel>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: colorScheme.surface,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Dashboard',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              titlePadding:
                  const EdgeInsets.only(left: 20, bottom: 16),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  icon: Icon(
                    vm.settings.darkMode
                        ? Icons.light_mode_rounded
                        : Icons.dark_mode_rounded,
                    color: colorScheme.primary,
                  ),
                  onPressed: () {
                    vm.updateSettings(
                        vm.settings.copyWith(darkMode: !vm.settings.darkMode));
                  },
                ),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildGreeting(context),
                const SizedBox(height: 20),
                _buildScoreCard(context, vm),
                const SizedBox(height: 16),
                _buildStatsRow(context, vm),
                const SizedBox(height: 20),
                _buildSectionTitle(context, 'Today\'s Focus'),
                const SizedBox(height: 12),
                _buildPomodoroProgress(context, vm),
                const SizedBox(height: 20),
                _buildSectionTitle(context, 'Upcoming Events'),
                const SizedBox(height: 12),
                _buildUpcomingEvents(context, vm),
                const SizedBox(height: 20),
                _buildSectionTitle(context, 'Weekly Trend'),
                const SizedBox(height: 12),
                _buildWeeklyMiniChart(context, vm),
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGreeting(BuildContext context) {
    final hour = DateTime.now().hour;
    String greeting;
    String emoji;
    if (hour < 12) {
      greeting = 'Good morning';
      emoji = '☀️';
    } else if (hour < 17) {
      greeting = 'Good afternoon';
      emoji = '🌤️';
    } else {
      greeting = 'Good evening';
      emoji = '🌙';
    }

    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 28)),
        const SizedBox(width: 8),
        Text(
          '$greeting!',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }

  Widget _buildScoreCard(BuildContext context, ProductivityViewModel vm) {
    final score = vm.todayScore;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.primary.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Productivity Score',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${score.toStringAsFixed(0)}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getScoreMessage(score),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          _buildScoreRing(context, score),
        ],
      ),
    );
  }

  Widget _buildScoreRing(BuildContext context, double score) {
    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: score / 100,
            strokeWidth: 6,
            backgroundColor: Colors.white.withOpacity(0.2),
            valueColor:
                const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
          Text(
            score >= 100 ? '🏆' : _getScoreEmoji(score),
            style: const TextStyle(fontSize: 24),
          ),
        ],
      ),
    );
  }

  String _getScoreMessage(double score) {
    if (score >= 90) return 'Outstanding performance!';
    if (score >= 70) return 'Keep up the great work!';
    if (score >= 50) return 'Making good progress.';
    if (score >= 25) return 'Every session counts!';
    return 'Start your first session today.';
  }

  String _getScoreEmoji(double score) {
    if (score >= 75) return '🔥';
    if (score >= 50) return '💪';
    if (score >= 25) return '🌱';
    return '⭐';
  }

  Widget _buildStatsRow(BuildContext context, ProductivityViewModel vm) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.timer_rounded,
            label: 'Focus Time',
            value: vm.todayFocusFormatted,
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.local_fire_department_rounded,
            label: 'Pomodoros',
            value: '${vm.todayPomodoros}',
            color: Colors.red,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.trending_up_rounded,
            label: 'Week Avg',
            value: '${vm.weeklyAverageScore.toStringAsFixed(0)}%',
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
    );
  }

  Widget _buildPomodoroProgress(
      BuildContext context, ProductivityViewModel vm) {
    final goal = int.tryParse(vm.settings.dailyGoalHours) ?? 4;
    final goalPomodoros = (goal * 60 / vm.settings.workDuration).round();
    final completed = vm.todayPomodoros;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$completed / $goalPomodoros sessions',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${(completed / (goalPomodoros > 0 ? goalPomodoros : 1) * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: goalPomodoros > 0
                  ? (completed / goalPomodoros).clamp(0.0, 1.0)
                  : 0.0,
              minHeight: 8,
              backgroundColor:
                  theme.colorScheme.primary.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(goalPomodoros, (i) {
              final done = i < completed;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: done
                      ? theme.colorScheme.primary
                      : theme.colorScheme.primary.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: done
                    ? const Icon(Icons.check_rounded,
                        size: 16, color: Colors.white)
                    : null,
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingEvents(
      BuildContext context, ProductivityViewModel vm) {
    final today = DateTime.now();
    final upcomingEvents = vm.getEventsForDay(today);
    final theme = Theme.of(context);

    if (upcomingEvents.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(Icons.event_available_rounded,
                color: theme.colorScheme.primary.withOpacity(0.6)),
            const SizedBox(width: 12),
            Text(
              'No events scheduled for today',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: upcomingEvents
          .take(3)
          .map((e) => _buildEventTile(context, e))
          .toList(),
    );
  }

  Widget _buildEventTile(BuildContext context, CalendarEvent event) {
    final theme = Theme.of(context);
    final color = _parseColor(event.color);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                if (event.startTime != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    event.startTime!.format(context),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded,
              size: 14,
              color: theme.colorScheme.onSurface.withOpacity(0.4)),
        ],
      ),
    );
  }

  Widget _buildWeeklyMiniChart(
      BuildContext context, ProductivityViewModel vm) {
    final stats = vm.weeklyStats;
    final theme = Theme.of(context);
    final days = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(stats.length, (i) {
          final stat = stats[i];
          final isToday = stat.date.day == DateTime.now().day;
          final height = (stat.productivityScore / 100 * 60).clamp(4.0, 60.0);

          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOut,
                width: 30,
                height: height,
                decoration: BoxDecoration(
                  color: isToday
                      ? theme.colorScheme.primary
                      : theme.colorScheme.primary.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                days[stat.date.weekday - 1],
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isToday
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withOpacity(0.5),
                  fontWeight:
                      isToday ? FontWeight.w700 : FontWeight.normal,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return Colors.blue;
    }
  }
}
