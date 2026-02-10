# AppState Provider - Complete Technical Documentation
**File Location**: [`lib/providers/app_state.dart`](../../../lib/providers/app_state.dart)  
**Purpose**: The central state manager (ViewModel in MVVM)  
**Dependencies**: `flutter/material.dart`, `shared_preferences`, `dart:convert`  
**Lines of Code**: ~400

---

## Table of Contents
1. [Architecture Role](#architecture-role)
2. [Class Structure](#class-structure)
3. [Initialization Flow](#initialization-flow)
4. [Data Seeding Logic](#data-seeding-logic)
5. [CRUD Operations](#crud-operations)
6. [Derived State (Getters)](#derived-state-getters)
7. [Course Filtering](#course-filtering)
8. [Persistence Logic](#persistence-logic)
9. [Sign Out Flow](#sign-out-flow)

---

## Architecture Role

### The "Brain" of the Application
```
View (Screens) → ViewModel (AppState) → Model (Assignment/Session)
                      ↕
                  Disk Storage (SharedPreferences)
```

**Responsibilities**:
1. Hold application data (`_assignments`, `_sessions`)
2. Expose read-only access (`get assignments`)
3. Handle mutations (`addAssignment()`, `removeSession()`)
4. Persist to disk automatically
5. Notify UI of changes (`notifyListeners`)

---

## Class Structure

### Class Declaration
```dart
class AppState with ChangeNotifier
```

**`with ChangeNotifier`**: A mixin that provides:
- `addListener()` method
- `notifyListeners()` method  
- Lifecycle management

**How It Works**:
1. Widgets "subscribe" using `Provider.of<AppState>(context)`
2. AppState calls `notifyListeners()` when data changes
3. Subscribed widgets rebuild automatically

### Private State
```dart
List<Assignment> _assignments = [];
List<AcademicSession> _sessions = [];
String _username = 'Student';
List<String> _selectedCourses = [];
String? _filteredCourse;
bool _isLoaded = false;
bool _userInitialized = false;
```

**Why Private (`_`)?**  
Encapsulation. No other file can directly modify these lists. They must use official methods like `addAssignment()`.

### Public Getters
```dart
List<Assignment> get assignments => List.unmodifiable(_assignments);
```

**`List.unmodifiable(...)`**: Returns a read-only wrapper.  
**Why?**: Prevents accidental bugs:
```dart
// ❌ This would throw an error:
appState.assignments.add(newItem); // UnsupportedError

// ✅ This is the correct way:
appState.addAssignment(newItem);
```

---

## Initialization Flow

### Constructor
```dart
AppState() {
  _initData();
}
```

**Executes**: As soon as `ChangeNotifierProvider` creates the instance.

### `_initData()` Method
**Purpose**: Load saved data on app startup.

```dart
Future<void> _initData() async {
  final prefs = await SharedPreferences.getInstance();

  // Guard against duplicate initialization
  if (_userInitialized) return;
  
  // Load user profile
  _username = prefs.getString('username') ?? 'Student';
  _selectedCourses = prefs.getStringList('courses') ?? [];

  // Load assignments
  final assignmentsString = prefs.getString('assignments');
  if (assignmentsString != null && assignmentsString.isNotEmpty) {
    try {
      final List<dynamic> jsonList = json.decode(assignmentsString);
      _assignments = jsonList.map((j) => Assignment.fromJson(j)).toList();
    } catch (_) {
      _assignments = [];
    }
  }

  // Load sessions
  final sessionsString = prefs.getString('sessions');
  if (sessionsString != null && sessionsString.isNotEmpty) {
    try {
      final List<dynamic> jsonList = json.decode(sessionsString);
      _sessions = jsonList.map((j) => AcademicSession.fromJson(j)).toList();
    } catch (_) {
      _sessions = [];
    }
  }

  // Sort data
  _sortAssignments();
  _sortSessions();

  // Seed data if needed
  final shouldSeed = _selectedCourses.isNotEmpty && 
                     _assignments.isEmpty && 
                     _sessions.isEmpty;
  if (shouldSeed) {
    _generateAllSampleData();
    _sortAssignments();
    _sortSessions();
    await _saveData();
  }

  _isLoaded = true;
  notifyListeners();
}
```

### Step-by-Step Breakdown

#### Step 1: Access Persistent Storage
```dart
final prefs = await SharedPreferences.getInstance();
```
**`SharedPreferences`**: Key-value storage on device.  
**`await`**: This is async (takes milliseconds). We pause execution until it's ready.

#### Step 2: Load User Profile
```dart
_username = prefs.getString('username') ?? 'Student';
```
**`??` Operator**: If `username` key doesn't exist, use default `'Student'`.

#### Step 3: Parse JSON to Objects
```dart
final jsonList = json.decode(assignmentsString); // String → List<Map>
_assignments = jsonList.map((j) => Assignment.fromJson(j)).toList(); // Maps → Objects
```

**The Pipeline**:
1. JSON string: `"[{\"id\":\"123\", ...}, {...}]"`
2. `json.decode()`: Converts to Dart List
3. `.map()`: Transform each Map into an Assignment object
4. `.toList()`: Convert from Iterable to List

#### Step 4: Seeding Logic
```dart
final shouldSeed = _selectedCourses.isNotEmpty && 
                   _assignments.isEmpty && 
                   _sessions.isEmpty;
```

**Decision Tree**:
- User has courses selected?
- AND database is empty?
- → Must be a new user. Generate sample data.

**Why?**: Better UX. A blank app on first launch is confusing.

---

## Data Seeding Logic

### `_generateAllSampleData()`
**Purpose**: Populate the app with realistic fake data for Lin ux, Python, and Web Dev courses.

```dart
void _generateAllSampleData() {
  final now = DateTime.now();
  final courses = _selectedCourses;

  // Linux Course
  if (courses.any((c) => c.toLowerCase().contains('linux'))) {
    const cn = 'Introduction to Linux';
    
    // 10 Assignments
    _assignments.addAll([
      Assignment(title: 'Linux File Permissions', courseName: cn, 
        dueDate: now.add(const Duration(days: 2)), priority: PriorityLevel.high),
      // ... 9 more
    ]);

    // Recurring Sessions
    _addRecurringSessions(cn, 'Linux Lecture', 'Lab 1', [1, 3, 5], 10, 0, now);
  }

  // ... Similar blocks for Python and Web Dev
}
```

### `_addRecurringSessions()` Helper
**Generates**: Past 4 weeks + Next 4 weeks of sessions.

```dart
void _addRecurringSessions(
  String courseName,
  String baseTitle,
  String location,
  List<int> daysOfWeek,  // [1, 3, 5] = Monday, Wednesday, Friday
  int hour,
  int minute,
  DateTime now
) {
  // Past 4 weeks
  for (int i = 1; i <= 28; i++) {
    final date = now.subtract(Duration(days: i));
    if (daysOfWeek.contains(date.weekday)) {
      final isPresent = (date.day % 4 != 0); // ~75% attendance
      _sessions.add(AcademicSession(...));
    }
  }
  
  // Future 4 weeks
  for (int i = 0; i <= 28; i++) {
    final date = now.add(Duration(days: i));
    if (daysOfWeek.contains(date.weekday)) {
      _sessions.add(AcademicSession(...));
    }
  }
}
```

**Key Logic**:
- `date.weekday`: Returns 1-7 (Monday-Sunday)
- `daysOfWeek.contains(date.weekday)`: Only create session on matching days
- `date.day % 4 != 0`: Attendance pattern (miss every 4th class)

---

## CRUD Operations

### Create: `addAssignment()`
```dart
void addAssignment(Assignment assignment) {
  _assignments.add(assignment);        // 1. Update memory
  _sortAssignments();                  // 2. Maintain order
  _saveData();                         // 3. Persist to disk
  notifyListeners();                   // 4. Update UI
}
```

**The 4-Step Pattern**: Every mutation follows this template.

### Read: Public Getters
```dart
List<Assignment> get assignments => List.unmodifiable(_assignments);
```

### Update: `updateAssignment()`
```dart
void updateAssignment(Assignment assignment) {
  final index = _assignments.indexWhere((a) => a.id == assignment.id);
  if (index != -1) {
    _assignments[index] = assignment;  // Replace in-place
    _sortAssignments();
    _saveData();
    notifyListeners();
  }
}
```

### Delete: `removeAssignment()`
```dart
void removeAssignment(String id) {
  _assignments.removeWhere((a) => a.id == id);
  _saveData();
  notifyListeners();
}
```

**`.removeWhere()`**: Filters out all items matching the condition.

### Toggle: `toggleAssignmentCompletion()`
```dart
void toggleAssignmentCompletion(String id) {
  final index = _assignments.indexWhere((a) => a.id == id);
  if (index != -1) {
    _assignments[index].isCompleted = !_assignments[index].isCompleted;
    _saveData();
    notifyListeners();
  }
}
```

**Why `!` operator**: Logical NOT. Flips `true` to `false` and vice versa.

---

## Derived State (Getters)

###` getTodaysSessions()`
```dart
List<AcademicSession> getTodaysSessions() {
  final now = DateTime.now();
  return _sessions.where((s) {
    // Course filter logic
    if (_filteredCourse != null && _filteredCourse != 'All Selected Courses') {
      if (s.courseName != null) {
        if (s.courseName != _filteredCourse) return false;
      } else {
        if (!s.title.contains(_filteredCourse!) && 
            !s.location.contains(_filteredCourse!)) return false;
      }
    }
    
    // Date matching
    return s.startTime.year == now.year &&
           s.startTime.month == now.month &&
           s.startTime.day == now.day;
  }).toList();
}
```

**Logic Breakdown**:
1. Apply course filter first
2. Check if date matches today
3. Return filtered list

### `getAttendancePercentage()`
```dart
double getAttendancePercentage() {
  // Filter by active course
  final filteredSessions = _sessions.where((s) {
    if (_filteredCourse != null && _filteredCourse != 'All Selected Courses') {
      if (s.courseName != null) {
        if (s.courseName != _filteredCourse) return false;
      } else {
        if (!s.title.contains(_filteredCourse!) && 
            !s.location.contains(_filteredCourse!)) return false;
      }
    }
    return true;
  }).toList();

  if (filteredSessions.isEmpty) return 100.0;
  
  // Only count past sessions
  final pastSessions = filteredSessions.where((s) => 
    s.endTime.isBefore(DateTime.now())
  ).toList();
  
  if (pastSessions.isEmpty) return 100.0;
  
  final presentCount = pastSessions.where((s) => s.isPresent).length;
  return (presentCount / pastSessions.length) * 100;
}
```

**Why Filter Course?**: If user selects "Linux" in dropdown, they only want Linux attendance %.

**Why Check `endTime.isBefore`?**: Future sessions don't count yet.

### `getAssignmentsDueNext7Days()`
```dart
List<Assignment> getAssignmentsDueNext7Days() {
  final now = DateTime.now();
  final nextWeek = now.add(const Duration(days: 7));
  return _assignments.where((a) {
    if (_filteredCourse != null && 
        _filteredCourse != 'All Selected Courses' && 
        a.courseName != _filteredCourse) return false;
    
    return a.dueDate.isAfter(now.subtract(const Duration(days: 1))) && 
           a.dueDate.isBefore(nextWeek) && 
           !a.isCompleted;
  }).toList();
}
```

**Time Window**: now - 1 day to now + 7 days.  
**Why `-1 day`?**: Includes items due "today" that might have passed midnight.

---

## Course Filtering

### `setCourseFilter()`
```dart
void setCourseFilter(String? course) {
  _filteredCourse = course;
  notifyListeners();
}
```

**When Called**: User changes dropdown in Dashboard AppBar.

**Effect**: All getters (`getTodaysSessions`, `getAttendancePercentage`) automatically respect the new filter.

---

## Persistence Logic

### `_saveData()`
```dart
Future<void> _saveData() async {
  final prefs = await SharedPreferences.getInstance();
  
  // Assignments
  final assignmentsString = json.encode(
    _assignments.map((a) => a.toJson()).toList()
  );
  await prefs.setString('assignments', assignmentsString);

  // Sessions
  final sessionsString = json.encode(
    _sessions.map((s) => s.toJson()).toList()
  );
  await prefs.setString('sessions', sessionsString);
}
```

**The Pipeline**:
1. Convert each object to Map (`.toJson()`)
2. Collect all Maps into a List
3. Encode List to JSON string (`json.encode()`)
4. Save string to disk (`.setString()`)

**Result**: Data survives app restarts.

---

## Sign Out Flow

```dart
Future<void> signOut() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();  // Delete all keys

  // Reset memory
  _assignments = [];
  _sessions = [];
  _username = 'Student';
  _selectedCourses = [];
  _filteredCourse = null;
  _isLoaded = false;
  _userInitialized = false;

  notifyListeners();
}
```

**Purpose**: Factory reset for testing.  
**UI Trigger**: "Sign Out" button in Dashboard AppBar menu.

---

## Edge Cases & Safeguards

### Race Condition Prevention
```dart
bool _userInitialized = false;

if (_userInitialized) return; // Guard in _initData
```

**Problem**: If initialization runs twice, data duplicates.  
**Solution**: Boolean flag prevents re-entry.

### JSON Parse Errors
```dart
try {
  _assignments = jsonList.map((j) => Assignment.fromJson(j)).toList();
} catch (_) {
  _assignments = []; // Safeguard: start fresh
}
```

**Why?**: Corrupted storage shouldn't crash the app.

### Null Checks in Filtering
```dart
if (_filteredCourse != null && _filteredCourse != 'All Selected Courses') {
  // Apply filter
}
```

**Why `!= 'All'`?**: Dropdown has a special "All" option that means "show everything".

---

## Performance Optimizations

### Synchronous Seeding
```dart
void _generateAllSampleData() { // NOT async
  _assignments.addAll([...]); // Direct additions
}
```

**Why Not Async?**: Reduces complexity. All data is generated in one frame.

### Sort Once, Not Every Query
```dart
void _sortAssignments() {
  _assignments.sort((a, b) => a.dueDate.compareTo(b.dueDate));
}
```

**Called**: After every mutation, not every read.

---

## Testing Strategies

### Unit Test Example
```dart
test('addAssignment should increase count', () {
  final state = AppState();
  final task = Assignment(
    title: "Test",
    dueDate: DateTime.now(),
    courseName: "CS101",
  );
  
  state.addAssignment(task);
  
  expect(state.assignments.length, 1);
  expect(state.assignments.first.title, "Test");
});

test('attendance should be 100% for new users', () {
  final state = AppState();
  expect(state.getAttendancePercentage(), 100.0);
});
```

---

## Summary
- **Purpose**: Centralized state management
- **Pattern**: Encapsulation + Observer Pattern (ChangeNotifier)
- **Key Operations**: CRUD + Filtering + Persistence
- **Integration**: Connects Models to Views and Disk Storage
