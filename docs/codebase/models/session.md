# Academic Session Model - Complete Technical Documentation
**File Location**: [`lib/models/session.dart`](../../../lib/models/session.dart)  
**Purpose**: Represents a calendar event or class meeting  
**Dependencies**: `package:uuid/uuid.dart`

---

## Table of Contents
1. [Overview](#overview)
2. [Enumeration](#enumeration)
3. [Class Structure](#class-structure)
4. [Constructor Analysis](#constructor-analysis)
5. [JSON Serialization](#json-serialization)
6. [Attendance Logic](#attendance-logic)

---

## Overview
The `AcademicSession` class models a time-bound event in a student's schedule (lectures, labs, study groups). Unlike `Assignment` which has deadlines, Sessions have **start and end times**.

### Key Differences from Assignment
| Feature | Assignment | Session |
|---------|-----------|---------|
| Time | Single deadline | Start + End time |
| Completion | Boolean (`isCompleted`) | Attendance (`isPresent`) |
| Recurring | No | Yes (generated in Provider) |
| User Creation | Yes | Mostly system-generated |

---

## Enumeration

### `SessionType`
```dart
enum SessionType { 
  classSession,      // Regular lectures
  masterySession,    // Tutoring/remedial
  studyGroup,        // Peer study
  pslMeeting         // Personal study/labs
}
```

**Purpose**: Distinguish between mandatory vs optional events.

**Critical Logic**: In `app_state.dart`, attendance percentage **only counts `classSession`** types:
```dart
final classSessions = sessions.where((s) => s.type == SessionType.classSession);
```

**Why?**  
The user shouldn't be penalized for missing a personal study group they added themselves.

---

## Class Structure

### Properties
```dart
class AcademicSession {
  final String id;           // UUID
  String title;              // "Linux Lecture (10/2)"
  DateTime startTime;        // 2026-02-10 10:00:00
  DateTime endTime;          // 2026-02-10 11:30:00
  String location;           // "Lab 1"
  SessionType type;          // classSession/masterySession/etc
  bool isPresent;            // Attendance status
  String? courseName;        // "Introduction to Linux" (nullable)
}
```

### Property Analysis

#### `DateTime startTime` & `endTime`
**Use Cases**:
1. **Time Display**: "10:00 - 11:30"
2. **Past/Future Logic**:
   ```dart
   if (session.endTime.isBefore(DateTime.now())) {
     print("This class is over");
   }
   ```
3. **Duration Calculation**:
   ```dart
   final duration = session.endTime.difference(session.startTime);
   print("$duration minutes"); // 90 minutes
   ```

#### `bool isPresent`
**Default**: `true` (for future sessions)  
**Behavior**:
- User can toggle it in Risk Status screen
- Provider calculates attendance % from this field
- Past sessions default to a pattern (~75% attendance in seeder)

#### `String? courseName`
**Nullable** (`?`): Some sessions (like personal study) might not be linked to a course.

**Usage in Filtering**:
```dart
if (session.courseName == selectedCourse) {
  // Show this session
}
```

---

## Constructor Analysis

```dart
AcademicSession({
  String? id,
  required this.title,
  required this.startTime,
  required this.endTime,
  this.location = '',
  required this.type,
  this.isPresent = true,
  this.courseName,
}) : id = id ?? const Uuid().v4();
```

### Default Values
- `location = ''`: Empty string if not provided
- `isPresent = true`: Assume attendance unless marked absent

### Optional Parameters
- `courseName`: Can be null for user-added events

---

## JSON Serialization

### `toJson()`
```dart
Map<String, dynamic> toJson() {
  return {
    'id': id,
    'title': title,
    'startTime': startTime.toIso8601String(),
    'endTime': endTime.toIso8601String(),
    'location': location,
    'type': type.index,                 // Enum to integer
    'isPresent': isPresent,
    'courseName': courseName,            // Can be null
  };
}
```

**Example JSON**:
```json
{
  "id": "abc-123",
  "title": "Python Programming (14/2)",
  "startTime": "2026-02-14T12:00:00.000",
  "endTime": "2026-02-14T13:30:00.000",
  "location": "Lab 3",
  "type": 0,
  "isPresent": true,
  "courseName": "Introduction to Python Programming"
}
```

### `fromJson()`
```dart
factory AcademicSession.fromJson(Map<String, dynamic> json) {
  return AcademicSession(
    id: json['id'],
    title: json['title'],
    startTime: DateTime.parse(json['startTime']),
    endTime: DateTime.parse(json['endTime']),
    location: json['location'] ?? '',
    type: SessionType.values[json['type'] ?? 0],
    isPresent: json['isPresent'] ?? true,
    courseName: json['courseName'],
  );
}
```

**Null Fallbacks:**
- `location ?? ''`: Default to empty string
- `type ?? 0`: Default to `classSession`
- `isPresent ?? true`: Assume present

---

## Attendance Logic

### How It's Used in Risk Calculation
From `app_state.dart`:
```dart
double getAttendancePercentage() {
  // Only count class sessions
  final classes = _sessions.where((s) => 
    s.type == SessionType.classSession
  );
  
  // Only past sessions count
  final pastClasses = classes.where((s) => 
    s.endTime.isBefore(DateTime.now())
  );
  
  final presentCount = pastClasses.where((s) => s.isPresent).length;
  return (presentCount / pastClasses.length) * 100;
}
```

### Seeding Pattern
In data generation (`_addRecurringSessions`):
```dart
final isPresent = (date.day % 4 != 0); // ~75% attendance
```
This creates a realistic pattern where you miss 1 out of 4 classes.

---

## Use Cases

### Displaying in Schedule
```dart
Text(session.title);
Text("${DateFormat('HH:mm').format(session.startTime)} - ${DateFormat('HH:mm').format(session.endTime)}");
Icon(
  session.isPresent ? Icons.check_circle : Icons.cancel,
  color: session.isPresent ? Colors.green : Colors.red,
);
```

### Toggling Attendance
```dart
void _toggleAttendance(String sessionId) {
  appState.toggleAttendance(sessionId);
}
```

### Filtering Today's Sessions
```dart
List<AcademicSession> getTodaysSessions() {
  final now = DateTime.now();
  return sessions.where((s) =>
    s.startTime.year == now.year &&
    s.startTime.month == now.month &&
    s.startTime.day == now.day
  ).toList();
}
```

---

## Edge Cases & Validation

### ❌ End Before Start
**Problem**: User accidentally sets endTime before startTime.  
**Solution**: Validate in UI:
```dart
if (_endTime.isBefore(_startTime)) {
  showError("End time must be after start time");
}
```

### ❌ Negative Duration
```dart
final duration = endTime.difference(startTime);
if (duration.isNegative) {
  // Handle error
}
```

### ❌ Null Course Filter
When `courseName` is null, filtering breaks.  
**Solution**: Fallback to title/location matching (see `app_state.dart`).

---

## Summary
- **Purpose**: Models time-bound calendar events
- **Key Feature**: `isPresent` drives attendance calculations
- **Type System**: `SessionType` distinguishes mandatory vs optional
- **Integration**: Works with Dashboard (today's view) and Schedule (weekly view)
