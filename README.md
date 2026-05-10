# modules/productivity

A self-contained Flutter productivity module built with **Provider**, **null safety**, and **Material Design 3**.

## Structure

```
modules/productivity/
├── productivity_module.dart          ← Entry point (ProductivityApp / ProductivityModule)
├── pubspec_dependencies.yaml         ← Required packages to add to your pubspec.yaml
│
├── services/
│   └── productivity_service.dart     ← Data layer: persistence, notifications, stats
│
├── viewmodels/
│   └── productivity_view_model.dart  ← State management via ChangeNotifier + Provider
│
└── screens/
    ├── dashboard_screen.dart         ← Overview: score card, stats, events, mini-chart
    ├── pomodoro_screen.dart          ← Animated timer ring, session controls
    ├── calendar_screen.dart          ← Month grid, events list, add/delete events
    ├── statistics_screen.dart        ← Bar, line, pie charts via fl_chart
    └── settings_screen.dart          ← All settings with live preview
```

## Features

| Feature | Details |
|---|---|
| ⏱ Pomodoro Timer | Animated arc ring, work/short-break/long-break modes, auto-start |
| 🔔 Local Notifications | Session complete + calendar event reminders (15 min prior) |
| 📊 Charts | Weekly bar chart, productivity line chart, session pie chart |
| 🌙 Dark Mode | Full light/dark theme with Material 3 color schemes |
| 📅 Calendar | Monthly grid with event CRUD, color labels, time picker |
| 📈 Weekly Statistics | 7-day rolling stats, average score, total focus time |
| 🏆 Productivity Score | Daily % vs. configurable hour goal |

## Quick Start

### Standalone app
```dart
import 'modules/productivity/productivity_module.dart';

void main() => runApp(const ProductivityApp());
```

### Embedded in existing app
```dart
import 'modules/productivity/productivity_module.dart';
import 'modules/productivity/services/productivity_service.dart';
import 'modules/productivity/viewmodels/productivity_view_model.dart';

// In your widget tree (above MaterialApp or in a route):
ChangeNotifierProvider<ProductivityService>(
  create: (_) => ProductivityService()..initialize(),
  child: Consumer<ProductivityService>(
    builder: (ctx, svc, _) => ChangeNotifierProvider(
      create: (_) => ProductivityViewModel(svc),
      child: const ProductivityModule(), // no MaterialApp wrapper
    ),
  ),
)
```

## Dependencies

Add to your `pubspec.yaml`:

```yaml
dependencies:
  provider: ^6.1.2
  fl_chart: ^0.68.0
  flutter_local_notifications: ^17.2.3
  shared_preferences: ^2.3.2
  timezone: ^0.9.4
```

See `pubspec_dependencies.yaml` for full Android/iOS platform setup notes.

## Architecture

```
UI (Screens)
    ↓  watch<ProductivityViewModel>()
ViewModel (ProductivityViewModel)
    ↓  delegates to / listens to
Service (ProductivityService)
    ↓  persists via
SharedPreferences  +  FlutterLocalNotificationsPlugin
```

- **ProductivityService** — single source of truth; handles persistence (SharedPreferences), notification scheduling, and statistics calculation.
- **ProductivityViewModel** — owns timer state machine (idle → running → paused → completed), navigation index, selected calendar day; orchestrates service calls.
- **Screens** — purely reactive (`context.watch`); no business logic.
