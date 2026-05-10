import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/productivity_service.dart';

enum TimerState { idle, running, paused, completed }
enum SessionType { work, shortBreak, longBreak }

class ProductivityViewModel extends ChangeNotifier {
  final ProductivityService _service;

  ProductivityViewModel(this._service) {
    _service.addListener(_onServiceChanged);
    _resetTimer();
  }

  // ─── Timer State ──────────────────────────────────────────────────────────

  TimerState _timerState = TimerState.idle;
  SessionType _currentSessionType = SessionType.work;
  int _remainingSeconds = 0;
  int _totalSeconds = 0;
  int _completedSessionsInCycle = 0;
  String? _currentSessionId;
  Timer? _timer;

  TimerState get timerState => _timerState;
  SessionType get currentSessionType => _currentSessionType;
  int get remainingSeconds => _remainingSeconds;
  int get totalSeconds => _totalSeconds;
  int get completedSessionsInCycle => _completedSessionsInCycle;

  double get timerProgress =>
      _totalSeconds > 0 ? 1.0 - (_remainingSeconds / _totalSeconds) : 0.0;

  String get formattedTime {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String get sessionTypeLabel {
    switch (_currentSessionType) {
      case SessionType.work:
        return 'Focus Time';
      case SessionType.shortBreak:
        return 'Short Break';
      case SessionType.longBreak:
        return 'Long Break';
    }
  }

  // ─── Service Delegates ───────────────────────────────────────────────────

  List<PomodoroSession> get sessions => _service.sessions;
  List<CalendarEvent> get events => _service.events;
  ProductivitySettings get settings => _service.settings;

  double get todayScore => _service.getTodayProductivityScore();
  int get todayPomodoros => _service.getTodayCompletedPomodoros();
  int get todayFocusMinutes => _service.getTodayFocusMinutes();
  List<DailyStats> get weeklyStats => _service.getWeeklyStats();

  List<CalendarEvent> getEventsForDay(DateTime day) =>
      _service.getEventsForDay(day);

  // ─── Navigation State ────────────────────────────────────────────────────

  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  // ─── Selected Calendar Day ───────────────────────────────────────────────

  DateTime _selectedDay = DateTime.now();
  DateTime get selectedDay => _selectedDay;

  void selectDay(DateTime day) {
    _selectedDay = day;
    notifyListeners();
  }

  // ─── Timer Controls ──────────────────────────────────────────────────────

  void _resetTimer() {
    _timer?.cancel();
    _timerState = TimerState.idle;
    _setDurationForCurrentSession();
  }

  void _setDurationForCurrentSession() {
    switch (_currentSessionType) {
      case SessionType.work:
        _totalSeconds = settings.workDuration * 60;
        break;
      case SessionType.shortBreak:
        _totalSeconds = settings.shortBreakDuration * 60;
        break;
      case SessionType.longBreak:
        _totalSeconds = settings.longBreakDuration * 60;
        break;
    }
    _remainingSeconds = _totalSeconds;
  }

  void startTimer() {
    if (_timerState == TimerState.running) return;

    if (_timerState == TimerState.idle || _timerState == TimerState.completed) {
      _currentSessionId = DateTime.now().millisecondsSinceEpoch.toString();
      _service.addSession(PomodoroSession(
        id: _currentSessionId!,
        startTime: DateTime.now(),
        durationMinutes: _totalSeconds ~/ 60,
        completed: false,
        type: _sessionTypeString(_currentSessionType),
      ));
    }

    _timerState = TimerState.running;
    _timer = Timer.periodic(const Duration(seconds: 1), _onTick);
    notifyListeners();
  }

  void pauseTimer() {
    if (_timerState != TimerState.running) return;
    _timer?.cancel();
    _timerState = TimerState.paused;
    notifyListeners();
  }

  void resumeTimer() {
    if (_timerState != TimerState.paused) return;
    _timerState = TimerState.running;
    _timer = Timer.periodic(const Duration(seconds: 1), _onTick);
    notifyListeners();
  }

  void resetTimer() {
    _timer?.cancel();
    _resetTimer();
    notifyListeners();
  }

  void skipSession() {
    _timer?.cancel();
    _advanceToNextSession();
  }

  void _onTick(Timer timer) {
    if (_remainingSeconds <= 0) {
      timer.cancel();
      _onSessionComplete();
    } else {
      _remainingSeconds--;
      notifyListeners();
    }
  }

  Future<void> _onSessionComplete() async {
    _timerState = TimerState.completed;

    if (_currentSessionId != null) {
      await _service.completeSession(_currentSessionId!);
    }

    if (_currentSessionType == SessionType.work) {
      _completedSessionsInCycle++;
    }

    await _service.showTimerCompleteNotification(
        _sessionTypeString(_currentSessionType));

    notifyListeners();

    if (settings.autoStartBreaks && _currentSessionType == SessionType.work) {
      await Future.delayed(const Duration(seconds: 1));
      _advanceToNextSession();
      startTimer();
    } else if (settings.autoStartPomodoros &&
        _currentSessionType != SessionType.work) {
      await Future.delayed(const Duration(seconds: 1));
      _advanceToNextSession();
      startTimer();
    }
  }

  void _advanceToNextSession() {
    if (_currentSessionType == SessionType.work) {
      if (_completedSessionsInCycle >= settings.sessionsBeforeLongBreak) {
        _currentSessionType = SessionType.longBreak;
        _completedSessionsInCycle = 0;
      } else {
        _currentSessionType = SessionType.shortBreak;
      }
    } else {
      _currentSessionType = SessionType.work;
    }
    _resetTimer();
    notifyListeners();
  }

  void setSessionType(SessionType type) {
    _timer?.cancel();
    _currentSessionType = type;
    _resetTimer();
    notifyListeners();
  }

  String _sessionTypeString(SessionType type) {
    switch (type) {
      case SessionType.work:
        return 'work';
      case SessionType.shortBreak:
        return 'short_break';
      case SessionType.longBreak:
        return 'long_break';
    }
  }

  // ─── Calendar Actions ─────────────────────────────────────────────────────

  Future<void> addCalendarEvent(CalendarEvent event) async {
    await _service.addEvent(event);
    if (event.startTime != null) {
      await _service.scheduleEventReminder(event, 15);
    }
  }

  Future<void> deleteCalendarEvent(String eventId) async {
    await _service.deleteEvent(eventId);
  }

  // ─── Settings Actions ────────────────────────────────────────────────────

  Future<void> updateSettings(ProductivitySettings newSettings) async {
    await _service.updateSettings(newSettings);
    _resetTimer();
  }

  // ─── Statistics Helpers ──────────────────────────────────────────────────

  double get weeklyAverageScore {
    final stats = weeklyStats;
    if (stats.isEmpty) return 0;
    return stats.map((s) => s.productivityScore).reduce((a, b) => a + b) /
        stats.length;
  }

  int get weeklyTotalPomodoros {
    return weeklyStats.fold(0, (sum, s) => sum + s.completedPomodoros);
  }

  int get weeklyTotalFocusMinutes {
    return weeklyStats.fold(0, (sum, s) => sum + s.totalFocusMinutes);
  }

  String get weeklyTotalFocusFormatted {
    final total = weeklyTotalFocusMinutes;
    final hours = total ~/ 60;
    final minutes = total % 60;
    if (hours == 0) return '${minutes}m';
    if (minutes == 0) return '${hours}h';
    return '${hours}h ${minutes}m';
  }

  String get todayFocusFormatted {
    final minutes = todayFocusMinutes;
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  void _onServiceChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _service.removeListener(_onServiceChanged);
    super.dispose();
  }
}
