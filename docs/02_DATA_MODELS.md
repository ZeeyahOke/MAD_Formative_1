# Module 2: Datatypes & Modeling
*Duration: ~25 Minutes*

In this module, we explore how we define the "Mental Model" of our data before we write any logic.

## 1. The Assignment Model
Open [`../lib/models/assignment.dart`](../lib/models/assignment.dart).

### The Class Definition
```dart
class Assignment {
  final String id;
  String title;
  DateTime dueDate;
  //...
}
```
*   **`final` vs Non-final**: `id` is `final`. An assignment's unique ID identifies it forever. If you change its ID, it becomes a different object. The `title` is not final because a user might want to edit a typo.

### Enums (Enumerations)
```dart
enum PriorityLevel { low, medium, high }
```
**Concept**: Enums are "Safe Strings".
*   **Bad**: `String priority = "High";` (What if I typo "Hihg"?)
*   **Good**: `PriorityLevel priority = PriorityLevel.high;` ( The compiler prevents typos).

### The Constructor Logic
```dart
Assignment({
  String? id,
  required this.title,
  // ...
}) : id = id ?? const Uuid().v4();
```
This is an **Initializer List**.
*   **Scenario A (Creating New)**: You call `Assignment(title: "Homework")`. `id` is passed as `null`. The code `id ?? const Uuid().v4()` sees null, and executes the UUID generator to make a new random ID like "a1b2-c3d4...".
*   **Scenario B (Loading from Disk)**: You call `Assignment(id: "existing-id", ...)`. The code sees `id` is NOT null, so it uses the existing ID. This is crucial for loading saved data.

---

## 2. JSON Serialization (The Translation Layer)
Computers have two ways of remembering things:
1.  **RAM (Memory)**: Fast, works with "Living Objects" (Classes, Functions). Deleted when app closes.
2.  **Disk (Storage)**: Slow, only works with "Dead Text" (Strings, Bytes). Persists forever.

To save our `Assignment` objects, we must translate them into text. This is **Serialization**.

### `toJson()` (Object -> Map)
```dart
Map<String, dynamic> toJson() {
  return {
    'id': id,
    'title': title,
    'dueDate': dueDate.toIso8601String(), // Date times must be strings!
    'priority': priority.index, // We save the integer index (0, 1, 2) instead of the name.
  };
}
```
This prepares the data to be turned into a text string by `json.encode()`.

### `Assignment.fromJson` (Map -> Object)
```dart
factory Assignment.fromJson(Map<String, dynamic> json) {
  return Assignment(
    id: json['id'],
    dueDate: DateTime.parse(json['dueDate']), // String back to DateTime object
    priority: PriorityLevel.values[json['priority']], // integer back to Enum
  );
}
```
*   **`factory`**: A simplified constructor pattern used when creating an instance isn't just setting variables, but involves logic (like parsing).

---

## 3. The Session Model
Open [`../lib/models/session.dart`](../lib/models/session.dart).
Similar to assignment, but includes `bool isPresent`. This boolean is the key to our attendance calculation later.
