import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/productivity_view_model.dart';
import '../services/productivity_service.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({Key? key}) : super(key: key);

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
          'Calendar',
          style: theme.textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add_rounded,
                color: theme.colorScheme.primary),
            onPressed: () => _showAddEventSheet(context, vm),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCalendarHeader(context, vm),
          _buildCalendarGrid(context, vm),
          const Divider(height: 1),
          Expanded(child: _buildEventsList(context, vm)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEventSheet(context, vm),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Event'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildCalendarHeader(
      BuildContext context, ProductivityViewModel vm) {
    final theme = Theme.of(context);
    final selected = vm.selectedDay;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded),
            onPressed: () {
              vm.selectDay(
                  DateTime(selected.year, selected.month - 1, 1));
            },
          ),
          GestureDetector(
            onTap: () => vm.selectDay(DateTime.now()),
            child: Text(
              _formatMonth(selected),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded),
            onPressed: () {
              vm.selectDay(
                  DateTime(selected.year, selected.month + 1, 1));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(BuildContext context, ProductivityViewModel vm) {
    final theme = Theme.of(context);
    final selected = vm.selectedDay;
    final now = DateTime.now();

    final firstDay = DateTime(selected.year, selected.month, 1);
    final startWeekday = firstDay.weekday % 7; // Sunday = 0
    final daysInMonth =
        DateTime(selected.year, selected.month + 1, 0).day;

    final weekdays = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          // Weekday headers
          Row(
            children: weekdays
                .map((d) => Expanded(
                      child: Center(
                        child: Text(
                          d,
                          style:
                              theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withOpacity(0.5),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          // Days grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemCount: startWeekday + daysInMonth,
            itemBuilder: (context, index) {
              if (index < startWeekday) return const SizedBox.shrink();

              final day = index - startWeekday + 1;
              final date =
                  DateTime(selected.year, selected.month, day);
              final isToday = date.year == now.year &&
                  date.month == now.month &&
                  date.day == now.day;
              final isSelected = date.year == selected.year &&
                  date.month == selected.month &&
                  date.day == selected.day;
              final hasEvents =
                  vm.getEventsForDay(date).isNotEmpty;

              return GestureDetector(
                onTap: () => vm.selectDay(date),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : isToday
                            ? theme.colorScheme.primary
                                .withOpacity(0.12)
                            : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        '$day',
                        style:
                            theme.textTheme.bodySmall?.copyWith(
                          fontWeight:
                              isToday || isSelected
                                  ? FontWeight.w700
                                  : FontWeight.normal,
                          color: isSelected
                              ? Colors.white
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                      if (hasEvents && !isSelected)
                        Positioned(
                          bottom: 4,
                          child: Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildEventsList(
      BuildContext context, ProductivityViewModel vm) {
    final theme = Theme.of(context);
    final events = vm.getEventsForDay(vm.selectedDay);
    final dateLabel = _formatSelectedDate(vm.selectedDay);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dateLabel,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
              Text(
                '${events.length} event${events.length != 1 ? 's' : ''}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color:
                      theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: events.isEmpty
              ? _buildEmptyState(context)
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: events.length,
                  itemBuilder: (context, i) =>
                      _buildEventCard(context, events[i], vm),
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_available_rounded,
              size: 48,
              color: theme.colorScheme.onSurface.withOpacity(0.3)),
          const SizedBox(height: 12),
          Text(
            'No events this day',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, CalendarEvent event,
      ProductivityViewModel vm) {
    final theme = Theme.of(context);
    final color = _parseColor(event.color);

    return Dismissible(
      key: Key(event.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => vm.deleteCalendarEvent(event.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        child:
            const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              theme.colorScheme.surfaceVariant.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border(left: BorderSide(color: color, width: 4)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.event_rounded, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  if (event.description.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      event.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface
                            .withOpacity(0.6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (event.startTime != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.access_time_rounded,
                            size: 12,
                            color: theme.colorScheme.onSurface
                                .withOpacity(0.5)),
                        const SizedBox(width: 4),
                        Text(
                          event.endTime != null
                              ? '${event.startTime!.format(context)} – ${event.endTime!.format(context)}'
                              : event.startTime!.format(context),
                          style:
                              theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddEventSheet(
      BuildContext context, ProductivityViewModel vm) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddEventSheet(vm: vm),
    );
  }

  String _formatMonth(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  String _formatSelectedDate(DateTime date) {
    const weekdays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday',
      'Saturday', 'Sunday'
    ];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Today';
    }
    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return Colors.blue;
    }
  }
}

class _AddEventSheet extends StatefulWidget {
  final ProductivityViewModel vm;
  const _AddEventSheet({required this.vm});

  @override
  State<_AddEventSheet> createState() => _AddEventSheetState();
}

class _AddEventSheetState extends State<_AddEventSheet> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String _selectedColor = '#4A90D9';
  bool _isAllDay = false;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  final _colors = [
    '#4A90D9', '#E74C3C', '#2ECC71', '#F39C12',
    '#9B59B6', '#1ABC9C', '#E91E63', '#FF5722',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + bottomPadding),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color:
                    theme.colorScheme.onSurface.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'New Event',
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Event title',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
              filled: true,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descController,
            decoration: InputDecoration(
              labelText: 'Description (optional)',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
              filled: true,
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('Color: '),
              const SizedBox(width: 8),
              ..._colors.map((c) {
                final color = Color(
                    int.parse(c.replaceFirst('#', '0xFF')));
                final isSelected = c == _selectedColor;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = c),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin:
                        const EdgeInsets.symmetric(horizontal: 3),
                    width: isSelected ? 28 : 22,
                    height: isSelected ? 28 : 22,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(
                              color: theme.colorScheme.onSurface,
                              width: 2)
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('All day'),
            value: _isAllDay,
            onChanged: (v) => setState(() => _isAllDay = v),
            contentPadding: EdgeInsets.zero,
          ),
          if (!_isAllDay) ...[
            Row(
              children: [
                Expanded(
                  child: _buildTimePicker(
                    context,
                    label: 'Start',
                    time: _startTime,
                    onTap: () async {
                      final t = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (t != null) {
                        setState(() => _startTime =
                            TimeOfDay(hour: t.hour, minute: t.minute));
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTimePicker(
                    context,
                    label: 'End',
                    time: _endTime,
                    onTap: () async {
                      final t = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (t != null) {
                        setState(() => _endTime =
                            TimeOfDay(hour: t.hour, minute: t.minute));
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _titleController.text.trim().isEmpty
                  ? null
                  : () => _submit(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Add Event',
                style: TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimePicker(
    BuildContext context, {
    required String label,
    required TimeOfDay? time,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(12),
          color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
        ),
        child: Row(
          children: [
            Icon(Icons.access_time_rounded, size: 18,
                color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              time != null ? time.format(context) : label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: time != null
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurface.withOpacity(0.5),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit(BuildContext context) {
    final event = CalendarEvent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      date: widget.vm.selectedDay,
      startTime: _startTime,
      endTime: _endTime,
      color: _selectedColor,
      isAllDay: _isAllDay,
    );
    widget.vm.addCalendarEvent(event);
    Navigator.pop(context);
  }
}
