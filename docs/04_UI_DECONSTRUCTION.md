# Module 4: UI & Widgets
*Duration: ~30 Minutes*

How do we turn data into pixels? This module covers the View layer.

## 1. Connecting to State (`Provider.of` vs `Consumer`)
Open [`../lib/screens/dashboard_screen.dart`](../lib/screens/dashboard_screen.dart).

```dart
final appState = Provider.of<AppState>(context);
```
*   **What it does**: Looks up the widget tree, finds the `AppState` we created in `main.dart`, and grabs it.
*   **The "Watch"**: By default, `Provider.of` also subscribes. If `AppState` changes, the `build()` method runs entirely from start to finish again.

In [`../lib/screens/assignments_screen.dart`](../lib/screens/assignments_screen.dart), we see a different approach: `Consumer<AppState>`.
*   **`Consumer`**: Helps optimize performance. Only the widgets *inside* the Consumer builder rebuild when data changes, not the whole screen.

## 2. Listing Data (`ListView.builder`)
In `AssignmentsScreen`:
```dart
ListView.builder(
  itemCount: assignments.length,
  itemBuilder: (context, index) {
     final assignment = assignments[index];
     return ListTile(...);
  }
)
```
*   **Lazy Rendering**: If you have 1,000 assignments, `ListView` only draws the 8 that fit on the screen. As you scroll, it recycles the widgets. This makes Flutter extremely fast.

## 3. Conditional Rendering (The Logic of Showing Things)
In `DashboardScreen` (The Risk Status box):
```dart
if (attendancePercent < 75)
  Container(...) // The Warning Box
```
This is a standard Dart feature called "Collection If". You can put `if` statements directly inside a list of widgets (like inside a Column's `children`).
*   **Logic**: If the attendance is 80%, the code inside the `if` is skipped entirely. The generic widgets list physically does not contain that Warning Box container.

## 4. Input Handling
Input widgets drive the changes in our app.
*   **Checkbox**: Updates `assignment.isCompleted`.
*   **Dismissible**: The "Swipe to Delete" gesture.
    *   **Key**: Requires a `Key(id)`. Flutter creates animations based on keys. If you don't provide a unique key, Flutter gets confused about *which* row is being swiped off screen.

## 5. Navigation
```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => NewScreen()),
);
```
Flutter manages screens like a stack of cards.
*   **Push**: Put a new card on top.
*   **Pop**: Take the top card off (Go Back).
*   **PushAndRemoveUntil** (Used in Sign Out): Throw away all cards and start a fresh deck with the Login Screen.
