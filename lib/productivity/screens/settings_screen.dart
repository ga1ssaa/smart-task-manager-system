import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/productivity_view_model.dart';
import '../services/productivity_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late ProductivitySettings _localSettings;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _localSettings =
          context.read<ProductivityViewModel>().settings;
      _initialized = true;
    }
  }

  Future<void> _save() async {
    await context
        .read<ProductivityViewModel>()
        .updateSettings(_localSettings);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Settings saved'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        title: Text(
          'Settings',
          style: theme.textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text(
              'Save',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              context,
              title: 'Appearance',
              icon: Icons.palette_rounded,
              children: [
                _buildSwitchTile(
                  context,
                  title: 'Dark Mode',
                  subtitle: 'Switch between light and dark theme',
                  value: _localSettings.darkMode,
                  onChanged: (v) =>
                      setState(() => _localSettings =
                          _localSettings.copyWith(darkMode: v)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              title: 'Timer',
              icon: Icons.timer_rounded,
              children: [
                _buildSliderTile(
                  context,
                  title: 'Focus Duration',
                  value: _localSettings.workDuration.toDouble(),
                  min: 5,
                  max: 60,
                  divisions: 11,
                  label: '${_localSettings.workDuration} min',
                  onChanged: (v) =>
                      setState(() => _localSettings = _localSettings
                          .copyWith(workDuration: v.toInt())),
                ),
                _buildDivider(context),
                _buildSliderTile(
                  context,
                  title: 'Short Break',
                  value: _localSettings.shortBreakDuration.toDouble(),
                  min: 1,
                  max: 30,
                  divisions: 29,
                  label: '${_localSettings.shortBreakDuration} min',
                  onChanged: (v) =>
                      setState(() => _localSettings = _localSettings
                          .copyWith(shortBreakDuration: v.toInt())),
                ),
                _buildDivider(context),
                _buildSliderTile(
                  context,
                  title: 'Long Break',
                  value: _localSettings.longBreakDuration.toDouble(),
                  min: 5,
                  max: 60,
                  divisions: 11,
                  label: '${_localSettings.longBreakDuration} min',
                  onChanged: (v) =>
                      setState(() => _localSettings = _localSettings
                          .copyWith(longBreakDuration: v.toInt())),
                ),
                _buildDivider(context),
                _buildSliderTile(
                  context,
                  title: 'Sessions Before Long Break',
                  value: _localSettings.sessionsBeforeLongBreak
                      .toDouble(),
                  min: 2,
                  max: 8,
                  divisions: 6,
                  label:
                      '${_localSettings.sessionsBeforeLongBreak} sessions',
                  onChanged: (v) => setState(() =>
                      _localSettings = _localSettings.copyWith(
                          sessionsBeforeLongBreak: v.toInt())),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              title: 'Automation',
              icon: Icons.auto_mode_rounded,
              children: [
                _buildSwitchTile(
                  context,
                  title: 'Auto-start Breaks',
                  subtitle: 'Automatically start break after focus',
                  value: _localSettings.autoStartBreaks,
                  onChanged: (v) =>
                      setState(() => _localSettings =
                          _localSettings.copyWith(autoStartBreaks: v)),
                ),
                _buildDivider(context),
                _buildSwitchTile(
                  context,
                  title: 'Auto-start Pomodoros',
                  subtitle: 'Automatically start focus after break',
                  value: _localSettings.autoStartPomodoros,
                  onChanged: (v) =>
                      setState(() => _localSettings = _localSettings
                          .copyWith(autoStartPomodoros: v)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              title: 'Notifications',
              icon: Icons.notifications_rounded,
              children: [
                _buildSwitchTile(
                  context,
                  title: 'Enable Notifications',
                  subtitle: 'Get notified when sessions complete',
                  value: _localSettings.notificationsEnabled,
                  onChanged: (v) => setState(() =>
                      _localSettings = _localSettings.copyWith(
                          notificationsEnabled: v)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              title: 'Goals',
              icon: Icons.flag_rounded,
              children: [
                _buildGoalSelector(context),
              ],
            ),
            const SizedBox(height: 16),
            _buildAboutSection(context),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Row(
            children: [
              Icon(icon,
                  size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    )),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildSliderTile(
    BuildContext context, {
    required String title,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String label,
    required ValueChanged<double> onChanged,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: theme.colorScheme.primary,
              inactiveTrackColor:
                  theme.colorScheme.primary.withOpacity(0.2),
              thumbColor: theme.colorScheme.primary,
              overlayColor:
                  theme.colorScheme.primary.withOpacity(0.12),
              trackHeight: 4,
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalSelector(BuildContext context) {
    final theme = Theme.of(context);
    final goals = ['2', '3', '4', '6', '8'];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily Focus Goal',
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: goals.map((g) {
              final isSelected = _localSettings.dailyGoalHours == g;
              return GestureDetector(
                onTap: () => setState(() => _localSettings =
                    _localSettings.copyWith(dailyGoalHours: g)),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        g,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : theme.colorScheme.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'hrs',
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white.withOpacity(0.8)
                              : theme.colorScheme.primary.withOpacity(0.7),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.timer_rounded,
                color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Productivity Module',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  'Version 1.0.0',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color:
                        theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(
      indent: 16,
      endIndent: 16,
      height: 1,
      color:
          Theme.of(context).colorScheme.onSurface.withOpacity(0.08),
    );
  }
}
