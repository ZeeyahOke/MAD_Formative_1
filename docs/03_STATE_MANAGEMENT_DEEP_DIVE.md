# Module 3: State Management (The Brain)
*Duration: ~40 Minutes*

This is the most critical technical part of the assignment. This file controls the entire application.

Open [`../lib/providers/app_state.dart`](../lib/providers/app_state.dart).

## 1. The `ChangeNotifier` Pattern
```dart
class AppState with ChangeNotifier
```
This is the core mechanic.
*   **The "Radio Station"**: `AppState` is the station.
*   **The "Listeners"**: Widgets (like Dashboard) are the radios tuned in.
*   **`notifyListeners()`**: This is the broadcast signal. Whenever data changes, we call this method. Every "radio" (widget) tuned in instantly wakes up and redraws itself.

## 2. Encapsulation (Protecting the Data)
```dart
List<Assignment> _assignments = []; // Private
List<Assignment> get assignments => List.unmodifiable(_assignments); // Public
```
*   **Why `_`?**: In Dart, variables starting with `_` are private to the file. No other file can see `_assignments`.
*   **Why `unmodifiable` getter?**: We expose a "safe copy". If a screen tries `state.assignments.add(newItem)`, the app crashes. This forces the screen to use our official function `addAssignment()`.
*   **Benefit**: This prevents bugs where data is modified in the background without updating the UI.

## 3. The Lifecycle of Data (Init -> Load -> Seed)
Look at `_initData()`:

### Step A: Loading (`SharedPreferences`)
```dart
final String? data = prefs.getString('assignments');
if (data != null) {
  final List jsonList = json.decode(data); // Text -> List of Maps
  _assignments = jsonList.map((j) => Assignment.fromJson(j)).toList(); // Maps -> Objects
}
```
We reverse the process described in Module 2.

### Step B: Seeding (The "New User" Experience)
```dart
final shouldSeed = _selectedCourses.isNotEmpty && _assignments.isEmpty;
if (shouldSeed) {
    _generateAllSampleData();
}
```
This logic checks: "Does the user have courses picked?" AND "Is the database empty?". If yes, it means they just signed up. We call `_generateAllSampleData` to fill the app with the Linux/Python/Web assignments you see.

## 4. The Modification Cycle
When you add an assignment:
```dart
void addAssignment(Assignment assignment) {
  _assignments.add(assignment);   // 1. Update Memory
  _sortAssignments();             // 2. Sort List
  _saveData();                    // 3. Persist to Disk
  notifyListeners();              // 4. Update UI
}
```
This 4-step process ensures consistency. If we skipped step 3, data would vanish on restart. If we skipped step 4, the screen wouldn't show the new item until you restarted the app.

## 5. Derived State (Computed Getters)
These functions analyze the data to give answers to the UI.
*   **`getAttendancePercentage()`**:
    *   Filters `_sessions` to remove user added ones (`SessionType.classSession`).
    *   Math: `(attended / total) * 100`.
*   **`getAssignmentsDueNext7Days()`**:
    *   Uses `DateTime.now()` and `.add(Duration(days: 7))` to create a time window.
    *   Uses `.where()` to find items inside that window.

This keeps our UI code "dumb". The UI doesn't know math; it just asks `getAttendancePercentage` for the answer.
