import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../viewmodels/productivity_view_model.dart';
import '../services/productivity_service.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProductivityViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        title: Text(
          'Statistics',
          style: theme.textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWeeklySummary(context, vm),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Weekly Focus Time'),
            const SizedBox(height: 12),
            _buildBarChart(context, vm),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Productivity Score'),
            const SizedBox(height: 12),
            _buildLineChart(context, vm),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Session Distribution'),
            const SizedBox(height: 12),
            _buildPieChart(context, vm),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Daily Breakdown'),
            const SizedBox(height: 12),
            _buildDailyBreakdown(context, vm),
            const SizedBox(height: 80),
          ],
        ),
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

  Widget _buildWeeklySummary(
      BuildContext context, ProductivityViewModel vm) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withOpacity(0.75),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This Week',
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildWeekStat('Focus Time', vm.weeklyTotalFocusFormatted,
                  Icons.timer_rounded),
              _buildWeekStat('Pomodoros',
                  '${vm.weeklyTotalPomodoros}', Icons.local_fire_department_rounded),
              _buildWeekStat(
                  'Avg Score',
                  '${vm.weeklyAverageScore.toStringAsFixed(0)}%',
                  Icons.trending_up_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeekStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.85), size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.75),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart(BuildContext context, ProductivityViewModel vm) {
    final stats = vm.weeklyStats;
    final theme = Theme.of(context);
    final days = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];

    final maxY = stats
            .map((s) => s.totalFocusMinutes.toDouble())
            .reduce((a, b) => a > b ? a : b)
            .clamp(60.0, double.infinity);

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: BarChart(
        BarChartData(
          maxY: maxY + 30,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final minutes = rod.toY.toInt();
                final h = minutes ~/ 60;
                final m = minutes % 60;
                return BarTooltipItem(
                  h > 0 ? '${h}h ${m}m' : '${m}m',
                  TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= stats.length)
                    return const SizedBox.shrink();
                  final isToday =
                      stats[idx].date.day == DateTime.now().day;
                  return Text(
                    days[stats[idx].date.weekday - 1],
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isToday
                          ? FontWeight.w700
                          : FontWeight.normal,
                      color: isToday
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                getTitlesWidget: (value, meta) {
                  if (value == 0) return const SizedBox.shrink();
                  final h = value.toInt() ~/ 60;
                  return Text(
                    '${h}h',
                    style: TextStyle(
                      fontSize: 10,
                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                    ),
                  );
                },
              ),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: theme.colorScheme.onSurface.withOpacity(0.08),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(stats.length, (i) {
            final isToday = stats[i].date.day == DateTime.now().day;
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: stats[i].totalFocusMinutes.toDouble(),
                  color: isToday
                      ? theme.colorScheme.primary
                      : theme.colorScheme.primary.withOpacity(0.45),
                  width: 22,
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(6)),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildLineChart(BuildContext context, ProductivityViewModel vm) {
    final stats = vm.weeklyStats;
    final theme = Theme.of(context);

    return Container(
      height: 180,
      padding: const EdgeInsets.fromLTRB(12, 16, 16, 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: 110,
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (spots) => spots.map((spot) {
                return LineTooltipItem(
                  '${spot.y.toStringAsFixed(0)}%',
                  TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }).toList(),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: theme.colorScheme.onSurface.withOpacity(0.08),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            bottomTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                getTitlesWidget: (value, meta) {
                  if (value % 25 != 0) return const SizedBox.shrink();
                  return Text(
                    '${value.toInt()}%',
                    style: TextStyle(
                      fontSize: 10,
                      color:
                          theme.colorScheme.onSurface.withOpacity(0.4),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(
                  stats.length,
                  (i) => FlSpot(
                      i.toDouble(), stats[i].productivityScore)),
              isCurved: true,
              color: theme.colorScheme.primary,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, bar, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: theme.colorScheme.primary,
                    strokeWidth: 2,
                    strokeColor: theme.colorScheme.surface,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: theme.colorScheme.primary.withOpacity(0.12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart(BuildContext context, ProductivityViewModel vm) {
    final theme = Theme.of(context);
    final allSessions = vm.sessions;

    final workCount =
        allSessions.where((s) => s.type == 'work' && s.completed).length;
    final shortCount = allSessions
        .where((s) => s.type == 'short_break' && s.completed)
        .length;
    final longCount = allSessions
        .where((s) => s.type == 'long_break' && s.completed)
        .length;
    final total = workCount + shortCount + longCount;

    if (total == 0) {
      return Container(
        height: 140,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          'No sessions yet',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            height: 140,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 36,
                sections: [
                  if (workCount > 0)
                    PieChartSectionData(
                      value: workCount.toDouble(),
                      color: theme.colorScheme.primary,
                      title: '$workCount',
                      radius: 36,
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  if (shortCount > 0)
                    PieChartSectionData(
                      value: shortCount.toDouble(),
                      color: Colors.green,
                      title: '$shortCount',
                      radius: 36,
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  if (longCount > 0)
                    PieChartSectionData(
                      value: longCount.toDouble(),
                      color: Colors.teal,
                      title: '$longCount',
                      radius: 36,
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(context, theme.colorScheme.primary,
                    'Focus', workCount, total),
                const SizedBox(height: 10),
                _buildLegendItem(
                    context, Colors.green, 'Short Break', shortCount, total),
                const SizedBox(height: 10),
                _buildLegendItem(
                    context, Colors.teal, 'Long Break', longCount, total),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, Color color,
      String label, int count, int total) {
    final pct = total > 0 ? (count / total * 100).toStringAsFixed(0) : '0';
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodySmall,
          ),
        ),
        Text(
          '$pct%',
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildDailyBreakdown(
      BuildContext context, ProductivityViewModel vm) {
    final stats = vm.weeklyStats.reversed.toList();
    final theme = Theme.of(context);

    return Column(
      children: stats.map((s) {
        final isToday = s.date.day == DateTime.now().day &&
            s.date.month == DateTime.now().month;
        final h = s.totalFocusMinutes ~/ 60;
        final m = s.totalFocusMinutes % 60;
        final timeStr =
            s.totalFocusMinutes == 0 ? '—' : (h > 0 ? '${h}h ${m}m' : '${m}m');

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isToday
                ? theme.colorScheme.primary.withOpacity(0.08)
                : theme.colorScheme.surfaceVariant.withOpacity(0.4),
            borderRadius: BorderRadius.circular(14),
            border: isToday
                ? Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.3))
                : null,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 80,
                child: Text(
                  _formatDate(s.date, isToday),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight:
                        isToday ? FontWeight.w700 : FontWeight.normal,
                    color: isToday
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: s.productivityScore / 100,
                        minHeight: 6,
                        backgroundColor:
                            theme.colorScheme.primary.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.primary.withOpacity(
                              isToday ? 1.0 : 0.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    timeStr,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${s.completedPomodoros} 🍅',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color:
                          theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _formatDate(DateTime date, bool isToday) {
    if (isToday) return 'Today';
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[date.weekday - 1]} ${date.day}';
  }
}
