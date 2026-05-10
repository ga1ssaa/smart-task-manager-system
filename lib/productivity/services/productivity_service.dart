import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';


class PomodoroSession {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final int durationMinutes;
  final bool completed;
  final String type; // 'work' | 'short_break' | 'long_break'

  PomodoroSession({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.durationMinutes,
    required this.completed,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime?.toIso8601String(),
        'durationMinutes': durationMinutes,
        'completed': completed,
        'type': type,
      };

  factory PomodoroSession.fromJson(Map<String, dynamic> json) =>
      PomodoroSession(
        id: json['id'],
        startTime: DateTime.parse(json['startTime']),
        endTime:
            json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
        durationMinutes: json['durationMinutes'],
        completed: json['completed'],
        type: json['type'],
      );
}

class CalendarEvent {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final String color;
  final bool isAllDay;

  CalendarEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    this.startTime,
    this.endTime,
    required this.color,
    this.isAllDay = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'date': date.toIso8601String(),
        'startHour': startTime?.hour,
        'startMinute': startTime?.minute,
        'endHour': endTime?.hour,
        'endMinute': endTime?.minute,
        'color': color,
        'isAllDay': isAllDay,
      };

  factory CalendarEvent.fromJson(Map<String, dynamic> json) => CalendarEvent(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        date: DateTime.parse(json['date']),
        startTime: json['startHour'] != null
            ? TimeOfDay(hour: json['startHour'], minute: json['startMinute'])
            : null,
        endTime: json['endHour'] != null
            ? TimeOfDay(hour: json['endHour'], minute: json['endMinute'])
            : null,
        color: json['color'],
        isAllDay: json['isAllDay'] ?? false,
      );
}

class ProductivitySettings {
  final int workDuration;
  final int shortBreakDuration;
  final int longBreakDuration;
  final int sessionsBeforeLongBreak;
  final bool notificationsEnabled;
  final bool darkMode;
  final bool autoStartBreaks;
  final bool autoStartPomodoros;
  final String dailyGoalHours;

  ProductivitySettings({
    this.workDuration = 25,
    this.shortBreakDuration = 5,
    this.longBreakDuration = 15,
    this.sessionsBeforeLongBreak = 4,
    this.notificationsEnabled = true,
    this.darkMode = false,
    this.autoStartBreaks = false,
    this.autoStartPomodoros = false,
    this.dailyGoalHours = '4',
  });

  ProductivitySettings copyWith({
    int? workDuration,
    int? shortBreakDuration,
    int? longBreakDuration,
    int? sessionsBeforeLongBreak,
    bool? notificationsEnabled,
    bool? darkMode,
    bool? autoStartBreaks,
    bool? autoStartPomodoros,
    String? dailyGoalHours,
  }) {
    return ProductivitySettings(
      workDuration: workDuration ?? this.workDuration,
      shortBreakDuration: shortBreakDuration ?? this.shortBreakDuration,
      longBreakDuration: longBreakDuration ?? this.longBreakDuration,
      sessionsBeforeLongBreak:
          sessionsBeforeLongBreak ?? this.sessionsBeforeLongBreak,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      darkMode: darkMode ?? this.darkMode,
      autoStartBreaks: autoStartBreaks ?? this.autoStartBreaks,
      autoStartPomodoros: autoStartPomodoros ?? this.autoStartPomodoros,
      dailyGoalHours: dailyGoalHours ?? this.dailyGoalHours,
    );
  }

  Map<String, dynamic> toJson() => {
        'workDuration': workDuration,
        'shortBreakDuration': shortBreakDuration,
        'longBreakDuration': longBreakDuration,
        'sessionsBeforeLongBreak': sessionsBeforeLongBreak,
        'notificationsEnabled': notificationsEnabled,
        'darkMode': darkMode,
        'autoStartBreaks': autoStartBreaks,
        'autoStartPomodoros': autoStartPomodoros,
        'dailyGoalHours': dailyGoalHours,
      };

  factory ProductivitySettings.fromJson(Map<String, dynamic> json) =>
      ProductivitySettings(
        workDuration: json['workDuration'] ?? 25,
        shortBreakDuration: json['shortBreakDuration'] ?? 5,
        longBreakDuration: json['longBreakDuration'] ?? 15,
        sessionsBeforeLongBreak: json['sessionsBeforeLongBreak'] ?? 4,
        notificationsEnabled: json['notificationsEnabled'] ?? true,
        darkMode: json['darkMode'] ?? false,
        autoStartBreaks: json['autoStartBreaks'] ?? false,
        autoStartPomodoros: json['autoStartPomodoros'] ?? false,
        dailyGoalHours: json['dailyGoalHours'] ?? '4',
      );
}

class DailyStats {
  final DateTime date;
  final int completedPomodoros;
  final int totalFocusMinutes;
  final double productivityScore;

  DailyStats({
    required this.date,
    required this.completedPomodoros,
    required this.totalFocusMinutes,
    required this.productivityScore,
  });
}

class ProductivityService extends ChangeNotifier {
  static const String _sessionsKey = 'pomodoro_sessions';
  static const String _eventsKey = 'calendar_events';
  static const String _settingsKey = 'productivity_settings';

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  List<PomodoroSession> _sessions = [];
  List<CalendarEvent> _events = [];
  ProductivitySettings _settings = ProductivitySettings();

  List<PomodoroSession> get sessions => List.unmodifiable(_sessions);
  List<CalendarEvent> get events => List.unmodifiable(_events);
  ProductivitySettings get settings => _settings;

  Future<void> initialize() async {
    await _initNotifications();
    await _loadData();
  }

  Future<void> _initNotifications() async {
    const androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings =
        InitializationSettings(android: androidInit, iOS: iosInit);

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {},
    );
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    final sessionsJson = prefs.getString(_sessionsKey);
    if (sessionsJson != null) {
      final List decoded = jsonDecode(sessionsJson);
      _sessions = decoded
          .map((e) => PomodoroSession.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    final eventsJson = prefs.getString(_eventsKey);
    if (eventsJson != null) {
      final List decoded = jsonDecode(eventsJson);
      _events = decoded
          .map((e) => CalendarEvent.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    final settingsJson = prefs.getString(_settingsKey);
    if (settingsJson != null) {
      _settings =
          ProductivitySettings.fromJson(jsonDecode(settingsJson));
    }

    notifyListeners();
  }

  Future<void> _saveSessions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _sessionsKey, jsonEncode(_sessions.map((s) => s.toJson()).toList()));
  }

  Future<void> _saveEvents() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _eventsKey, jsonEncode(_events.map((e) => e.toJson()).toList()));
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, jsonEncode(_settings.toJson()));
  }

  // ─── Pomodoro Sessions ───────────────────────────────────────────────────

  Future<void> addSession(PomodoroSession session) async {
    _sessions.add(session);
    await _saveSessions();
    notifyListeners();
  }

  Future<void> completeSession(String sessionId) async {
    final idx = _sessions.indexWhere((s) => s.id == sessionId);
    if (idx != -1) {
      final old = _sessions[idx];
      _sessions[idx] = PomodoroSession(
        id: old.id,
        startTime: old.startTime,
        endTime: DateTime.now(),
        durationMinutes: old.durationMinutes,
        completed: true,
        type: old.type,
      );
      await _saveSessions();
      notifyListeners();
    }
  }

  // ─── Calendar Events ─────────────────────────────────────────────────────

  Future<void> addEvent(CalendarEvent event) async {
    _events.add(event);
    await _saveEvents();
    notifyListeners();
  }

  Future<void> deleteEvent(String eventId) async {
    _events.removeWhere((e) => e.id == eventId);
    await _saveEvents();
    notifyListeners();
  }

  List<CalendarEvent> getEventsForDay(DateTime day) {
    return _events.where((e) {
      return e.date.year == day.year &&
          e.date.month == day.month &&
          e.date.day == day.day;
    }).toList();
  }

  // ─── Settings ────────────────────────────────────────────────────────────

  Future<void> updateSettings(ProductivitySettings settings) async {
    _settings = settings;
    await _saveSettings();
    notifyListeners();
  }

  // ─── Statistics ──────────────────────────────────────────────────────────

  List<DailyStats> getWeeklyStats() {
    final now = DateTime.now();
    final stats = <DailyStats>[];

    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final daySessions = _sessions.where((s) {
        return s.startTime.year == day.year &&
            s.startTime.month == day.month &&
            s.startTime.day == day.day &&
            s.completed &&
            s.type == 'work';
      }).toList();

      final completed = daySessions.length;
      final totalMinutes = daySessions.fold<int>(
          0, (sum, s) => sum + s.durationMinutes);

      final goalMinutes =
          (double.tryParse(_settings.dailyGoalHours) ?? 4) * 60;
      final score = goalMinutes > 0
          ? (totalMinutes / goalMinutes * 100).clamp(0.0, 100.0)
          : 0.0;

      stats.add(DailyStats(
        date: day,
        completedPomodoros: completed,
        totalFocusMinutes: totalMinutes,
        productivityScore: score,
      ));
    }
    return stats;
  }

  double getTodayProductivityScore() {
    final today = DateTime.now();
    final todaySessions = _sessions.where((s) =>
        s.startTime.year == today.year &&
        s.startTime.month == today.month &&
        s.startTime.day == today.day &&
        s.completed &&
        s.type == 'work').toList();

    final totalMinutes =
        todaySessions.fold<int>(0, (sum, s) => sum + s.durationMinutes);
    final goalMinutes =
        (double.tryParse(_settings.dailyGoalHours) ?? 4) * 60;

    return goalMinutes > 0
        ? (totalMinutes / goalMinutes * 100).clamp(0.0, 100.0)
        : 0.0;
  }

  int getTodayCompletedPomodoros() {
    final today = DateTime.now();
    return _sessions.where((s) =>
        s.startTime.year == today.year &&
        s.startTime.month == today.month &&
        s.startTime.day == today.day &&
        s.completed &&
        s.type == 'work').length;
  }

  int getTodayFocusMinutes() {
    final today = DateTime.now();
    return _sessions
        .where((s) =>
            s.startTime.year == today.year &&
            s.startTime.month == today.month &&
            s.startTime.day == today.day &&
            s.completed &&
            s.type == 'work')
        .fold<int>(0, (sum, s) => sum + s.durationMinutes);
  }

  // ─── Notifications ───────────────────────────────────────────────────────

  Future<void> showTimerCompleteNotification(String type) async {
    if (!_settings.notificationsEnabled) return;

    final title = type == 'work' ? '🎉 Focus session complete!' : '⏰ Break is over!';
    final body = type == 'work'
        ? 'Great work! Time for a well-deserved break.'
        : 'Ready to focus again? Let\'s go!';

    const androidDetails = AndroidNotificationDetails(
      'productivity_channel',
      'Productivity Notifications',
      channelDescription: 'Pomodoro timer notifications',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _notificationsPlugin.show(0, title, body, details);
  }

  Future<void> scheduleEventReminder(
      CalendarEvent event, int minutesBefore) async {
    if (!_settings.notificationsEnabled) return;

    final eventDateTime = event.startTime != null
        ? DateTime(event.date.year, event.date.month, event.date.day,
            event.startTime!.hour, event.startTime!.minute)
        : DateTime(
            event.date.year, event.date.month, event.date.day, 0, 0);

    final reminderTime =
        eventDateTime.subtract(Duration(minutes: minutesBefore));

    if (reminderTime.isBefore(DateTime.now())) return;

    const androidDetails = AndroidNotificationDetails(
      'event_channel',
      'Event Reminders',
      channelDescription: 'Calendar event reminders',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _notificationsPlugin.zonedSchedule(
      event.id.hashCode,
      '📅 Upcoming: ${event.title}',
      'Starting in $minutesBefore minutes',
      _toTZDateTime(reminderTime),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  dynamic _toTZDateTime(DateTime dateTime) {
    // In real implementation, use timezone package
    return dateTime;
  }
}
