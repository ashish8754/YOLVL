# Requirements Document

## Introduction

The YOLO Leveling app is a personal gamification tool inspired by the Solo Leveling webtoon/manhwa that transforms self-improvement into an RPG-like experience. Users track daily activities to level up character stats, gain EXP, and progress through levels while building positive habits and quitting bad ones. The app is designed as an offline-first, cross-platform mobile application (iOS/Android) using Flutter, starting with an MVP focused on core functionality with architecture designed for future expansion.

## Requirements

### Requirement 1

**User Story:** As a new user, I want to complete an onboarding process to set up my character profile and initial stats, so that I can start tracking my progress from a personalized baseline.

#### Acceptance Criteria

1. WHEN the app is launched for the first time THEN the system SHALL display a registration form requiring a username and optional email
2. WHEN the user completes registration THEN the system SHALL navigate to a stat setup screen with 6 stats (Strength, Agility, Vitality, Intelligence, Wisdom, Charisma)
3. WHEN the user is on the stat setup screen THEN the system SHALL allow manual entry of float values (0.0-10.0 range) for each stat with default values of 0.0, include tooltips/labels (e.g., 'Based on self-assessment'), and provide sample data as guidance
4. WHEN implementing onboarding THEN the system SHALL include placeholder architecture for future LLM/questionnaire auto-calculation of stats
5. WHEN the user saves their initial stats THEN the system SHALL set their starting level to 1, EXP to 0, and navigate to the dashboard
6. WHEN the app is relaunched after onboarding completion THEN the system SHALL skip onboarding and go directly to the dashboard
7. WHEN the user accesses settings THEN the system SHALL provide a "Reset Profile" option that clears all data and restarts onboarding

### Requirement 2

**User Story:** As a user, I want to view my current progress on a central dashboard, so that I can quickly see my level, EXP, stats, and recent activity history.

#### Acceptance Criteria

1. WHEN the user opens the dashboard THEN the system SHALL display current level, EXP progress bar showing current/next threshold, and all 6 stats with their current values
2. WHEN the dashboard loads THEN the system SHALL automatically apply skill degradation if applicable based on days since last activity
3. WHEN the dashboard displays stats THEN the system SHALL show each stat as a visual progress indicator with the numeric value overlaid and include game-like icons (e.g., sword for Strength)
4. WHEN the dashboard loads THEN the system SHALL display the most recent 10-15 activity logs in a scrollable list
5. WHEN the user taps "Log Activity" THEN the system SHALL navigate to the activity logging screen
6. WHEN the user taps "Edit Profile/Stats" THEN the system SHALL navigate back to the stat setup form for adjustments

### Requirement 3

**User Story:** As a user, I want to log activities with duration to gain EXP and improve my character stats, so that I can track my real-world progress through gamification.

#### Acceptance Criteria

1. WHEN the user accesses activity logging THEN the system SHALL display a dropdown with predefined activities: Workout-Weightlifting, Workout-Cardio, Workout-Yoga, Study-Serious, Study-Casual, Meditation, Resistance Session
2. WHEN activities are defined THEN the system SHALL use these mappings stored in configurable format: Workout-Weightlifting (+0.1 Strength, +0.05 Vitality, 20 EXP/hour, group: workout), Workout-Cardio (+0.1 Agility, +0.05 Vitality, 20 EXP/hour, group: workout), Workout-Yoga (+0.1 Agility, +0.05 Wisdom, 20 EXP/hour, group: workout), Study-Serious (+0.1 Intelligence, 15 EXP/hour, group: study), Study-Casual (+0.05 Intelligence, +0.05 Wisdom, 15 EXP/hour, group: study), Meditation (+0.1 Wisdom, 15 EXP/hour, group: none), Resistance Session (+0.1 Wisdom, 15 EXP/hour, group: none)
3. WHEN the user selects an activity THEN the system SHALL display a duration input field accepting minutes (minimum 1, maximum 1440)
4. WHEN duration exceeds 480 minutes THEN the system SHALL show a warning but allow confirmation to proceed
5. WHEN the user submits a valid activity log THEN the system SHALL calculate stat increments as (duration/60) * base_increment and EXP as (duration/60) * base_EXP
6. WHEN an activity is logged THEN the system SHALL save timestamp, activity type, and duration as a log entry
7. WHEN an activity from 'workout' or 'study' group is logged THEN the system SHALL reset the degradation streak for that group
8. WHEN stat calculations result in negative values THEN the system SHALL floor stats at 0.0

### Requirement 4

**User Story:** As a user, I want to level up by accumulating EXP through activities, so that I can feel a sense of progression and achievement.

#### Acceptance Criteria

1. WHEN the user gains EXP from activities THEN the system SHALL accumulate total EXP using the formula: base_EXP * (duration/60)
2. WHEN total EXP reaches the threshold for next level THEN the system SHALL trigger a level up process
3. WHEN calculating level thresholds THEN the system SHALL use the formula: 500 + (100 * (level-1)^2) for each level
4. WHEN a level up occurs THEN the system SHALL subtract the threshold amount from total EXP, keeping any remainder
5. WHEN a level up occurs THEN the system SHALL display a congratulatory alert and update the dashboard display
6. WHEN the user reaches higher levels THEN the system SHALL maintain the quadratic progression (Level 2: 500 EXP, Level 3: 600 EXP, Level 10: ~9,500 EXP)

### Requirement 5

**User Story:** As a user, I want my stats to degrade when I'm inactive in certain areas, so that I'm motivated to maintain consistent habits.

#### Acceptance Criteria

1. WHEN the app loads or resumes from background THEN the system SHALL check days since last activity for 'workout' and 'study' groups
2. WHEN more than 0 days have passed since last workout activity THEN the system SHALL degrade Strength and Agility stats
3. WHEN more than 0 days have passed since last study activity THEN the system SHALL degrade Intelligence stat
4. WHEN calculating degradation THEN the system SHALL use: base_degradation (-0.01) + (-0.005 * missed_days), capped at -0.05 per day
5. WHEN degradation is applied THEN the system SHALL apply total degradation as (days_missed * daily_degradation) to affected stats
6. WHEN stats are degraded THEN the system SHALL ensure stats never go below 0.0
7. WHEN degradation is calculated THEN the system SHALL NOT affect EXP or level values

### Requirement 6

**User Story:** As a user, I want all my data to be saved locally and persist between app sessions, so that my progress is never lost and I can use the app offline.

#### Acceptance Criteria

1. WHEN any data changes occur THEN the system SHALL automatically save profile, stats, EXP, level, logs, last activity dates, and streaks to local storage using Hive
2. WHEN the app starts THEN the system SHALL load all saved data from local storage
3. WHEN the user requests data export THEN the system SHALL provide both JSON and CSV format options
4. WHEN exporting data THEN the system SHALL include all user data (profile, stats, EXP, level, complete log history, streaks)
5. WHEN data corruption is detected THEN the system SHALL display an alert and reset to onboarding defaults
6. WHEN partial data recovery is possible THEN the system SHALL attempt to salvage uncorrupted profile/stats data
7. WHEN the app operates THEN the system SHALL function completely offline without requiring internet connectivity

### Requirement 7

**User Story:** As a user, I want the app to have a dark, game-like visual theme inspired by Solo Leveling, so that the experience feels immersive and motivating.

#### Acceptance Criteria

1. WHEN the app displays any screen THEN the system SHALL use primary background color #121212 (deep black)
2. WHEN displaying interactive elements THEN the system SHALL use accent color #FF0000 (vibrant red) for EXP bars and buttons
3. WHEN displaying text THEN the system SHALL use #FFFFFF (white) for primary text and #333333 (dark gray) for secondary elements
4. WHEN showing level-up notifications THEN the system SHALL use #FFD700 (gold) as accent color for achievement highlights
5. WHEN displaying progress bars THEN the system SHALL include subtle gradients and use icon-based representations for stats
6. WHEN the user interacts with the interface THEN the system SHALL maintain high contrast ratios for accessibility
7. WHEN displaying stat progress THEN the system SHALL show visual indicators that grow dynamically without fixed upper bounds

### Requirement 8

**User Story:** As a user, I want the app to handle errors gracefully and provide good performance, so that I have a reliable and smooth experience.

#### Acceptance Criteria

1. WHEN invalid inputs are entered THEN the system SHALL display clear error messages and prevent submission
2. WHEN the app loads with 1000+ activity logs THEN the system SHALL maintain quick load times under 3 seconds
3. WHEN data operations fail THEN the system SHALL provide fallback defaults and continue functioning
4. WHEN the app encounters errors THEN the system SHALL log them internally for debugging without crashing
5. WHEN the app is built THEN the system SHALL maintain total size under 50MB
6. WHEN the app runs THEN the system SHALL support both Android and iOS platforms through Flutter framework
7. WHEN accessibility features are needed THEN the system SHALL provide high contrast themes and appropriately sized touch targets