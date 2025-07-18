# Design Document: YOLO Leveling App

## Overview

The YOLO Leveling app is a gamified self-improvement tracker inspired by the Solo Leveling webtoon/manhwa. It transforms daily activities into an RPG-like experience where users can level up their character stats through real-world activities. This document outlines the technical design and architecture for implementing the app as specified in the requirements.

The app will be built using Flutter for cross-platform compatibility (iOS/Android), with an offline-first approach using Hive for local data persistence. The design follows MVVM architecture to ensure modularity and extensibility for future features.

## Architecture

### High-Level Architecture

The app will follow the MVVM (Model-View-ViewModel) architecture pattern with the following layers:

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│                 │     │                 │     │                 │     │                 │
│      Views      │◄────┤   ViewModels    │◄────┤    Services     │◄────┤    Models       │
│   (UI Widgets)  │     │  (State Logic)  │     │ (Business Logic)│     │  (Data Classes) │
│                 │     │                 │     │                 │     │                 │
└─────────────────┘     └─────────────────┘     └─────────────────┘     └─────────────────┘
                                                        │
                                                        ▼
                                               ┌─────────────────┐
                                               │                 │
                                               │  Repositories   │
                                               │ (Data Access)   │
                                               │                 │
                                               └─────────────────┘
                                                        │
                                                        ▼
                                               ┌─────────────────┐
                                               │                 │
                                               │  Local Storage  │
                                               │     (Hive)      │
                                               │                 │
                                               └─────────────────┘
```

### Key Components

1. **Views**: Flutter widgets that render the UI and handle user interactions
2. **ViewModels**: Manage UI state and business logic, using Provider for state management
3. **Services**: Handle core business logic like stat calculations, leveling, and degradation
4. **Repositories**: Abstract data access operations
5. **Models**: Define data structures for the application
6. **Local Storage**: Hive database for persistent storage

### Dependency Injection

We'll use a simple service locator pattern for dependency injection to maintain loose coupling between components. This will make it easier to replace implementations and add new features in the future.

```dart
// Example service locator
class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();
  
  final Map<Type, dynamic> _services = {};
  
  void register<T>(T service) {
    _services[T] = service;
  }
  
  T get<T>() {
    return _services[T] as T;
  }
}
```

### State Management

The app will use Provider for reactive state management through ViewModels. This will ensure UI components automatically update when the underlying data changes.

```dart
// Example provider setup
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => OnboardingViewModel(serviceLocator.get())),
        ChangeNotifierProvider(create: (_) => DashboardViewModel(
          serviceLocator.get(), 
          serviceLocator.get(),
          serviceLocator.get(),
          serviceLocator.get(),
        )),
        // Other providers...
      ],
      child: MyApp(),
    ),
  );
}
```

### Dependencies

The app will maintain minimal external dependencies, managed via pubspec.yaml:

```yaml
dependencies:
  flutter:
    sdk: flutter
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  provider: ^6.0.5
  intl: ^0.18.0
  logger: ^1.3.0
  path_provider: ^2.0.15
  csv: ^5.0.1
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  hive_generator: ^2.0.0
  build_runner: ^2.3.3
  mockito: ^5.4.0
```
```

## Components and Interfaces

### Core Services

#### UserService

Responsible for managing user profile data and stats.

```dart
abstract class UserService {
  Future<User> getUser();
  Future<void> saveUser(User user);
  Future<void> updateStats(Map<String, double> statChanges);
  Future<void> resetProfile();
}

class UserServiceImpl implements UserService {
  final UserRepository _repository;
  
  UserServiceImpl(this._repository);
  
  // Implementation details...
}
```

#### ActivityService

Handles activity logging and related stat updates.

```dart
abstract class ActivityService {
  Future<void> logActivity(ActivityType type, int durationMinutes);
  Future<List<ActivityLog>> getRecentLogs(int count);
  Future<void> exportLogs(ExportFormat format);
}

class ActivityServiceImpl implements ActivityService {
  final ActivityRepository _repository;
  final UserService _userService;
  
  ActivityServiceImpl(this._repository, this._userService);
  
  // Implementation details...
}
```

#### LevelingService

Manages EXP calculations and level progression.

```dart
abstract class LevelingService {
  Future<int> getCurrentLevel();
  Future<int> getCurrentExp();
  Future<int> getNextLevelThreshold();
  Future<void> addExp(int amount);
  Future<bool> checkAndProcessLevelUp();
}

class LevelingServiceImpl implements LevelingService {
  final LevelRepository _repository;
  
  LevelingServiceImpl(this._repository);
  
  // Implementation details
  
  @override
  Future<int> getNextLevelThreshold() async {
    final level = await getCurrentLevel();
    // Quadratic progression formula: 500 + (100 * (level-1)^2)
    return 500 + (100 * pow(level - 1, 2)).toInt();
  }
  
  @override
  Future<bool> checkAndProcessLevelUp() async {
    final currentExp = await getCurrentExp();
    final threshold = await getNextLevelThreshold();
    
    if (currentExp >= threshold) {
      final level = await getCurrentLevel();
      await _repository.updateLevel(level + 1);
      await _repository.updateExp(currentExp - threshold);
      return true;
    }
    
    return false;
  }
}
```

#### DegradationService

Handles stat degradation based on inactivity.

```dart
abstract class DegradationService {
  Future<void> checkAndApplyDegradation();
  Future<void> resetDegradationStreak(String activityGroup);
}

class DegradationServiceImpl implements DegradationService {
  final UserService _userService;
  final ActivityService _activityService;
  
  DegradationServiceImpl(this._userService, this._activityService);
  
  // Implementation details...
}
```

### ViewModels

#### OnboardingViewModel

```dart
class OnboardingViewModel extends ChangeNotifier {
  final UserService _userService;
  
  String username = '';
  String email = '';
  Map<String, double> stats = {
    'Strength': 3.4,
    'Agility': 2.8,
    'Vitality': 3.0,
    'Intelligence': 4.2,
    'Wisdom': 3.5,
    'Charisma': 2.9,
  };
  
  OnboardingViewModel(this._userService) {
    // Future: LLM integration for auto-calc from questionnaire
    initializeDefaultStats();
  }
  
  void initializeDefaultStats() {
    // Pre-populate with sample data as guidance
    stats = {
      'Strength': 3.4,
      'Agility': 2.8,
      'Vitality': 3.0,
      'Intelligence': 4.2,
      'Wisdom': 3.5,
      'Charisma': 2.9,
    };
  }
  
  Future<void> saveProfile() async {
    // Implementation details...
  }
}
```

#### DashboardViewModel

```dart
class DashboardViewModel extends ChangeNotifier {
  final UserService _userService;
  final LevelingService _levelingService;
  final ActivityService _activityService;
  final DegradationService _degradationService;
  
  User? user;
  int level = 1;
  int currentExp = 0;
  int nextLevelThreshold = 500;
  List<ActivityLog> recentLogs = [];
  
  DashboardViewModel(
    this._userService,
    this._levelingService,
    this._activityService,
    this._degradationService,
  );
  
  Future<void> loadDashboard() async {
    // Implementation details...
  }
}
```

#### ActivityLoggingViewModel

```dart
class ActivityLoggingViewModel extends ChangeNotifier {
  final ActivityService _activityService;
  
  ActivityType selectedActivity = ActivityType.workoutWeightlifting;
  int durationMinutes = 60;
  
  ActivityLoggingViewModel(this._activityService);
  
  Future<void> logActivity() async {
    // Implementation details...
  }
}
```

## Data Models

### User

```dart
@HiveType(typeId: 0)
class User {
  @HiveField(0)
  String username;
  
  @HiveField(1)
  String? email;
  
  @HiveField(2)
  Map<String, double> stats;
  
  User({
    required this.username,
    this.email,
    required this.stats,
  });
}
```

### ActivityLog

```dart
@HiveType(typeId: 1)
class ActivityLog {
  @HiveField(0)
  DateTime timestamp;
  
  @HiveField(1)
  ActivityType type;
  
  @HiveField(2)
  int durationMinutes;
  
  ActivityLog({
    required this.timestamp,
    required this.type,
    required this.durationMinutes,
  });
}
```

### ActivityType

```dart
@HiveType(typeId: 2)
enum ActivityType {
  @HiveField(0)
  workoutWeightlifting,
  
  @HiveField(1)
  workoutCardio,
  
  @HiveField(2)
  workoutYoga,
  
  @HiveField(3)
  studySerious,
  
  @HiveField(4)
  studyCasual,
  
  @HiveField(5)
  meditation,
  
  @HiveField(6)
  resistanceSession,
}
```

### LevelData

```dart
@HiveType(typeId: 3)
class LevelData {
  @HiveField(0)
  int level;
  
  @HiveField(1)
  int currentExp;
  
  @HiveField(2)
  Map<String, DateTime> lastActivityDates;
  
  LevelData({
    required this.level,
    required this.currentExp,
    required this.lastActivityDates,
  });
}
```

## Activity Configuration

The activity configuration will be stored in a constants file for the MVP, with architecture to support loading from storage in future versions:

```dart
class ActivityConfig {
  static final Map<ActivityType, ActivityDefinition> activities = {
    ActivityType.workoutWeightlifting: ActivityDefinition(
      name: 'Workout - Weightlifting',
      statChanges: {'Strength': 0.1, 'Vitality': 0.05},
      expPerHour: 20,
      group: 'workout',
    ),
    ActivityType.workoutCardio: ActivityDefinition(
      name: 'Workout - Cardio',
      statChanges: {'Agility': 0.1, 'Vitality': 0.05},
      expPerHour: 20,
      group: 'workout',
    ),
    // Other activities...
  };
}

class ActivityDefinition {
  final String name;
  final Map<String, double> statChanges;
  final int expPerHour;
  final String? group;
  
  ActivityDefinition({
    required this.name,
    required this.statChanges,
    required this.expPerHour,
    this.group,
  });
}
```

## UI Design

### Theme

The app will use a dark theme inspired by Solo Leveling with the following color scheme:

- Primary background: `#121212` (deep black)
- Accent color: `#FF0000` (vibrant red)
- Primary text: `#FFFFFF` (white)
- Secondary elements: `#333333` (dark gray)
- Achievement highlights: `#FFD700` (gold)

```dart
final ThemeData appTheme = ThemeData.dark().copyWith(
  scaffoldBackgroundColor: const Color(0xFF121212),
  primaryColor: const Color(0xFFFF0000),
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFFFF0000),
    secondary: Color(0xFFFFD700),
    surface: Color(0xFF333333),
    background: Color(0xFF121212),
    onPrimary: Color(0xFFFFFFFF),
    onSecondary: Color(0xFF000000),
    onSurface: Color(0xFFFFFFFF),
    onBackground: Color(0xFFFFFFFF),
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Color(0xFFFFFFFF)),
    bodyMedium: TextStyle(color: Color(0xFFFFFFFF)),
    titleLarge: TextStyle(color: Color(0xFFFFFFFF)),
  ),
);
```

### Screen Flow

```mermaid
graph TD
    A[App Launch] --> B{First Launch?}
    B -->|Yes| C[Registration Screen]
    B -->|No| G[Dashboard]
    C --> D[Stat Setup Screen]
    D --> G
    G --> H[Activity Logging Screen]
    G --> I[Edit Profile/Stats Screen]
    G --> J[Settings Screen]
    J -->|Reset Profile| C
    H --> G
    I --> G
```

### Key Screens

1. **Registration Screen**: Simple form with username and optional email fields
2. **Stat Setup Screen**: Form with sliders/inputs for each stat (0.0-10.0)
3. **Dashboard**: Main screen showing level, EXP bar (using LinearProgressIndicator), stats with icons (e.g., Icons.fitness_center for Strength), and recent logs. Each stat will use a CustomStatWidget with dynamic GradientProgressBar for unbounded scaling.
4. **Activity Logging Screen**: Dropdown for activity selection, input for duration
5. **Settings Screen**: Options for reset profile, export data, etc.

## Error Handling

The app will implement a comprehensive error handling strategy:

1. **Input Validation**: Client-side validation for all user inputs with clear error messages
2. **Data Corruption**: Detection and recovery mechanisms with fallback to defaults
3. **Exception Handling**: Try-catch blocks around critical operations with graceful degradation
4. **Logging**: Internal error logging for debugging purposes

```dart
class ErrorHandler {
  static void handleError(dynamic error, StackTrace? stackTrace) {
    // Log error internally
    logger.error('Error occurred: $error', stackTrace: stackTrace);
    
    // Provide user-friendly message if needed
    if (error is ValidationError) {
      // Show validation error message
    } else if (error is StorageError) {
      // Handle storage errors
    } else {
      // Generic error handling
    }
  }
}
```

## Testing Strategy

### Unit Tests

- Test all calculation logic (stat increments, EXP calculations, level thresholds)
- Test degradation algorithms
- Test data model serialization/deserialization

### Widget Tests

- Test UI components render correctly
- Test user interactions (form submissions, button presses)
- Test navigation flows

### Integration Tests

- Test complete user journeys (onboarding, logging activities, leveling up)
- Test data persistence across app restarts

### Performance Tests

- Ensure load times under 3 seconds with 1000+ activity logs
- Verify memory usage remains stable during extended use
- Test app performance on lower-end devices

### Accessibility Tests

- Verify contrast ratios meet WCAG standards
- Ensure touch targets are appropriately sized (minimum 44x44 points)
- Test with screen readers and other accessibility tools

## Data Storage

### Storage Options

#### Primary: Hive Database Structure

Hive will be the primary storage solution for the MVP due to its simplicity, speed, and pure Dart implementation.

```
┌─────────────────────┐
│ User Box            │
├─────────────────────┤
│ - user (User)       │
└─────────────────────┘

┌─────────────────────┐
│ Level Box           │
├─────────────────────┤
│ - levelData         │
│   (LevelData)       │
└─────────────────────┘

┌─────────────────────┐
│ Activity Log Box    │
├─────────────────────┤
│ - logs              │
│   (List<ActivityLog>)│
└─────────────────────┘
```

#### Alternative: SQLite (for future expansion)

The architecture will be designed to allow switching to SQLite if more complex queries are needed in future versions. This would be implemented through the repository layer without changing the service interfaces.

```sql
-- Example SQLite schema for future reference
CREATE TABLE users (
  id TEXT PRIMARY KEY,
  username TEXT NOT NULL,
  email TEXT
);

CREATE TABLE stats (
  user_id TEXT,
  stat_name TEXT,
  stat_value REAL,
  PRIMARY KEY (user_id, stat_name),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE activity_logs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id TEXT,
  activity_type TEXT,
  duration_minutes INTEGER,
  timestamp TEXT,
  FOREIGN KEY (user_id) REFERENCES users(id)
);
```

### Data Export/Import

The app will support exporting and importing data in both JSON and CSV formats:

```dart
class DataExporter {
  static Future<String> exportToJson(
    User user,
    LevelData levelData,
    List<ActivityLog> logs,
  ) async {
    // Implementation details...
  }
  
  static Future<String> exportToCsv(
    User user,
    LevelData levelData,
    List<ActivityLog> logs,
  ) async {
    // Implementation details...
  }
}

class DataImporter {
  static Future<ImportResult> importFromJson(String jsonData) async {
    // Implementation details...
    // For corruption, attempt partial load (e.g., user/stats first) before full reset
  }
  
  static Future<ImportResult> importFromCsv(String csvData) async {
    // Implementation details...
    // Validate data integrity before importing
  }
}
```

## Performance Considerations

1. **Lazy Loading**: Implement pagination for activity logs to handle large datasets
2. **Efficient Calculations**: Optimize stat calculations and degradation algorithms
3. **Minimal Dependencies**: Keep external dependencies to a minimum
4. **Asset Optimization**: Optimize images and assets for mobile devices

## Future Extensibility

The architecture is designed to support future features with minimal changes:

1. **Custom Activities**: The `ActivityConfig` can be extended to load from storage
2. **Quests System**: Add a new `QuestService` and related models
3. **Cloud Sync**: Add a remote repository implementation behind the existing interfaces
4. **Social Features**: Add new services for sharing and multiplayer functionality

## Implementation Plan

The implementation will follow a phased approach:

1. **Phase 1**: Core infrastructure (models, repositories, basic services)
2. **Phase 2**: UI implementation (screens, navigation, theme)
3. **Phase 3**: Business logic (activity logging, leveling, degradation)
4. **Phase 4**: Data persistence and export/import
5. **Phase 5**: Testing and optimization

## Conclusion

This design document outlines the technical approach for implementing the YOLO Leveling app as specified in the requirements. The MVVM architecture with clear separation of concerns will ensure the app is maintainable and extensible for future features. The use of Flutter and Hive provides a solid foundation for a cross-platform, offline-first mobile application with a responsive and visually appealing user interface.