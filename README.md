# Student Academic Platform

A Flutter mobile application designed to help ALU students manage their academic responsibilities.

## Features

### 1. Dashboard
- **Overview**: View today's date, current academic week, and attendance status.
- **At Risk Warning**: Visual alert if attendance drops below 75%.
- **Quick Stats**: Real-time attendance percentage and pending assignment count.
- **Today's Schedule**: List of academic sessions scheduled for the current day.
- **Upcoming Assignments**: Assignments due within the next 7 days.

### 2. Assignment Management
- **Create**: Add assignments with title, course, due date, and priority level.
- **Track**: Mark assignments as completed.
- **Manage**: Edit or delete assignments.
- **Sort/Filter**: Assignments are sorted by due date. High priority items are visually distinct.

### 3. Academic Schedule
- **Planning**: Schedule sessions (Classes, Mastery Sessions, Study Groups, PSL Meetings).
- **Attendance**: Toggle attendance (Present/Absent) for each session to track engagement.
- **Edit/Remove**: Modify session details as schedules change.

### 4. Persistence
- Data is stored locally using `shared_preferences`, ensuring that assignments and sessions persist across app restarts.

## Architecture

This project follows a clean architecture pattern separating UI from Business Logic:

- **`lib/screens`**: Contains the UI logic for each screen (Dashboard, Assignments, Schedule).
- **`lib/providers`**: Contains `AppState`, a `ChangeNotifier` that manages the application state and business logic. It handles data manipulation and persistence.
- **`lib/models`**: Data models (`Assignment`, `AcademicSession`) with JSON serialization support.
- **`lib/theme`**: centralized color palette and theme definitions.
- **`lib/utils`**: Helper extensions and constants.

## Setup Instructions

1.  **Prerequisites**: Ensure you have Flutter SDK installed (version >=3.0.0).
2.  **Dependencies**: Run `flutter pub get` to install required packages (`provider`, `intl`, `shared_preferences`, `uuid`).
3.  **Run**: Connect a device or emulator and run `flutter run`.

## Team and Contribution
[Insert Link to Group Contribution Tracker Here]

## Technical Challenges & Solutions
- **State Management**: We chose `Provider` for its simplicity and effectiveness in propagating changes (like attendance updates) across the app immediately.
- **Persistence**: `SharedPreferences` was used for quick serialization of JSON data, allowing for a lightweight "database" without the overhead of SQLite for this scale.

