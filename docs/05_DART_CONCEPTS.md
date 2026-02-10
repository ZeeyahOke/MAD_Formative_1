# Module 5: Advanced Dart Concepts
*Duration: ~15 Minutes*

This module explains the specific Dart language features that make the app work. These are great talking points for your Viva/Interview.

## 1. Asynchronous Programming (`Future`, `async`, `await`)
Used heavily in `app_state.dart` for saving data.

### The Concept
Storage happens on the disk, which is "far away" from the CPU. Writing a file takes milliseconds—an eternity for a CPU running at 3GHz.
*   **Without Async**: The app would freeze (hang) while waiting for the save to finish. Users hate this.
*   **With Async**: The app says "Okay, start saving. I'll keep drawing the UI. Call me when you're done."

### The Syntax
```dart
Future<void> _saveData() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(...);
}
```
*   **`async`**: Marks a function as one that might take time.
*   **`await`**: "Pause *this* function specifically right here until the task finishes, but let the rest of the app keep running."

## 2. List Manipulation (Functional Programming)
We process data lists constantly.

### `.map()`
```dart
jsonList.map((j) => Assignment.fromJson(j))
```
*   **Analogy**: A factory assembly line.
*   Input: `[Map1, Map2, Map3]`
*   Operation: "Turn this Map into an Assignment Object"
*   Output: `[Assignment1, Assignment2, Assignment3]`

### `.where()` (Filtering)
```dart
assignments.where((a) => a.type == AssignmentType.formative)
```
*   **Analogy**: A bouncer at a club.
*   Logic: Iterates through every item. If the arrow function returns `true`, keep it. If `false`, throw it out.

### `.sort()`
```dart
assignments.sort((a, b) => a.dueDate.compareTo(b.dueDate))
```
*   **Logic**: Compares two items (`a` and `b`) at a time.
    *   Result < 0: `a` comes before `b`.
    *   Result > 0: `b` comes before `a`.
    *   This reorganizes the list in place by Date.

## 3. Null Safety (`?` and `??`)
Dart ensures variables can't be null unless you say so.
*   `String? filter`: Can be "Linux" or `null`.
*   `filter ?? "All"`: If `filter` is null, use "All" instead.
This prevents the billion-dollar mistake: `NullReferenceException`.
