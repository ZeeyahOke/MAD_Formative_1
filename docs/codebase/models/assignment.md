# Assignment Model - Complete Technical Documentation
**File Location**: [`lib/models/assignment.dart`](../../../lib/models/assignment.dart)  
**Purpose**: Defines the data structure for academic assignments  
**Dependencies**: `package:uuid/uuid.dart`

---

## Table of Contents
1. [Overview](#overview)
2. [Enumerations](#enumerations)
3. [Class Structure](#class-structure)
4. [Constructor Logic](#constructor-logic)
5. [JSON Serialization](#json-serialization)
6. [Use Cases](#use-cases)

---

## Overview
The `Assignment` class is a **pure data model** in the MVVM architecture. It represents a single piece of academic work with attributes like title, due date, and priority level. This class has **no UI logic** and **no business logic** — it only describes what an assignment "looks like".

### Key Responsibilities
- Store assignment properties (title, dueDate, priority, etc.)
- Convert to/from JSON for persistence
- Generate unique IDs for database operations

---

## Enumerations

### 1. `PriorityLevel`
```dart
enum PriorityLevel { low, medium, high }
```

**Purpose**: Type-safe representation of task priority.

**Why Not Strings?**  
Using strings like `"High"` is error-prone:
- Typos: `"high"` vs `"High"` vs `"HIGH"`
- No autocomplete
- Runtime errors instead of compile-time safety

**How It Works**:
- Enums are internally stored as integers: `low = 0`, `medium = 1`, `high = 2`
- You access them like: `PriorityLevel.high`
- Compiler ensures you can't typo it

**Practical Usage**:
```dart
Assignment task = Assignment(
  title: "Study for Exam",
  priority: PriorityLevel.high, // ✅ Type-safe
);
```

---

### 2. `AssignmentType`
```dart
enum AssignmentType { all, formative, summative }
```

**Purpose**: Categorizes assignments by academic weight.

**Definitions**:
- **Formative**: Practice work, low-stakes feedback
- **Summative**: Graded exams, major projects
- **All**: Used in UI filtering logic (not stored on objects)

---

## Class Structure

### Properties
```dart
class Assignment {
  final String id;              // Unique identifier (UUID)
  String title;                 // "Build Flutter App"
  DateTime dueDate;             // 2026-02-14 23:59:00
  String courseName;            // "Introduction to Linux"
  PriorityLevel priority;       // low/medium/high
  AssignmentType type;          // formative/summative
  bool isCompleted;             // Task completion status
}
```

### Property Analysis

#### `final String id`
- **Type**: `final` — Cannot be changed after creation
- **Why?**: An assignment's identity is permanent. Changing the ID would make it a different object.
- **Value**: Random UUID string (e.g., `1b9d6bcd-bbfd-4b2d-9b5d-ab8dfbbd4bed`)
- **Use Case**: Keying in Flutter widgets (`Key(id)`), database lookups

#### `String title`
-**Type**: Mutable
- **Why?**: Users might want to edit typos or rename tasks
- **Validation**: Should be enforced in UI layer (not empty)

#### `DateTime dueDate`
- **Type**: Dart's built-in DateTime object
- **Why Not String?**: We can do math operations:
  ```dart
  if (assignment.dueDate.isBefore(DateTime.now())) {
    print("Overdue!");
  }
  ```
- **Storage**: Converted to ISO-8601 string for JSON

#### `PriorityLevel priority`
- **Default**: `medium` (set in constructor)
- **UI Impact**: Determines badge color (red/yellow/green)

#### `AssignmentType type`
- **Default**: `formative`
- **UI Impact**: Tab filtering in AssignmentsScreen

#### `bool isCompleted`
- **Default**: `false`
- **Behavior**: When true, UI shows checkmark and strikethrough text

---

## Constructor Logic

### Full Constructor
```dart
Assignment({
  String? id,
  required this.title,
  required this.dueDate,
  required this.courseName,
  this.priority = PriorityLevel.medium,
  this.type = AssignmentType.formative,
  this.isCompleted = false,
}) : id = id ?? const Uuid().v4();
```

### Parameter Breakdown

#### `String? id`
- **Nullable** (`?` symbol)
- **Logic**: If `null`, generate new ID. If provided, use it.
- **Use Cases**:
  - Creating new assignment: Pass `null` → Auto-generates UUID
  - Loading from disk: Pass saved ID → Preserves identity

#### `required this.title`
- **`required`**: Compiler error if you forget it
- **`this.`**: Shorthand that auto-assigns to the property

#### Default Values
```dart
this.priority = PriorityLevel.medium
```
If you don't specify priority, it defaults to medium.

### Initializer List (The `: ` Part)
```dart
}) : id = id ?? const Uuid().v4();
```

**What is this?**  
Code that runs **before** the constructor body executes.

**The `??` Operator**:
- Called "if-null" operator
- `a ?? b` means "If `a` is null, use `b` instead"

**Step-by-Step Execution**:
1. Check if `id` parameter is null
2. **If null**: Call `Uuid().v4()` to generate random string
3. **If not null**: Use the provided ID
4. Assign result to `this.id`

**Why `const Uuid()`?**  
The `const` keyword creates a compile-time constant. It's a minor optimization.

---

## JSON Serialization

### Why Do We Need This?
**Problem**: Dart objects live in RAM. When the app closes, RAM is cleared.  
**Solution**: Convert objects to text (JSON) and save to disk using `SharedPreferences`.

### `toJson()` Method
```dart
Map<String, dynamic> toJson() {
  return {
    'id': id,
    'title': title,
    'dueDate': dueDate.toIso8601String(),
    'courseName': courseName,
    'priority': priority.index,
    'type': type.index,
    'isCompleted': isCompleted,
  };
}
```

**Returns**: `Map<String, dynamic>` (Dictionary/Object)

#### Field-by-Field Conversion

| Dart Property | JSON Value | Transformation |
|---------------|------------|----------------|
| `id` (String) | `"abc123"` | Direct copy |
| `title` (String) | `"Study"` | Direct copy |
| `dueDate` (DateTime) | `"2026-02-14T23:59:00.000"` | `.toIso8601String()` |
| `priority` (Enum) | `2` | `.index` converts to integer |
| `type` (Enum) | `1` | `.index` converts to integer |
| `isCompleted` (bool) | `true`/`false` | Direct copy |

**Example Output**:
```json
{
  "id": "1b9d6bcd-bbfd-4b2d-9b5d-ab8dfbbd4bed",
  "title": "Linux Lab Assignment",
  "dueDate": "2026-02-12T23:59:00.000",
  "courseName": "Introduction to Linux",
  "priority": 0,
  "type": 1,
  "isCompleted": false
}
```

**Why `.index` for Enums?**  
Enums are stored as integers internally:
- `PriorityLevel.low.index` → `0`
- `PriorityLevel.medium.index` → `1`
- `PriorityLevel.high.index` → `2`

This saves space in storage.

---

### `fromJson()` Factory Constructor
```dart
factory Assignment.fromJson(Map<String, dynamic> json) {
  return Assignment(
    id: json['id'],
    title: json['title'],
    dueDate: DateTime.parse(json['dueDate']),
    courseName: json['courseName'],
    priority: PriorityLevel.values[json['priority'] ?? 1],
    type: AssignmentType.values[json['type'] ?? 1],
    isCompleted: json['isCompleted'] ?? false,
  );
}
```

**`factory` Keyword**: Special constructor that doesn't necessarily return a new instance (though in this case it does).

#### Reverse Transformations

| JSON Value | Dart Property | Transformation |
|------------|---------------|----------------|
| `"abc123"` (String) | `id` | Direct assignment |
| `"Study"` (String) | `title` | Direct assignment |
| `"2026-02-14T23:59:00.000"` | `dueDate` | `DateTime.parse(...)` |
| `2` (int) | `priority` | `PriorityLevel.values[2]` → `high` |
| `1` (int) | `type` | `AssignmentType.values[1]` → `formative` |
| `true` (bool) | `isCompleted` | Direct assignment |

**Enum Reconstruction**:
```dart
Priorit  PriorityLevel.values[json['priority']]
```
- `.values` gives all enum options: `[low, medium, high]`
- Array index retrieves the correct one

**Null Safety (`??` operator)**:
```dart
json['priority'] ?? 1
```
If the JSON is corrupted and `priority` is missing, default to `1` (medium).

---

## Use Cases

### Creating a New Assignment (User Action)
```dart
final newTask = Assignment(
  title: titleController.text,
  dueDate: selectedDate,
  courseName: "Python Programming",
  priority: PriorityLevel.high,
);

appState.addAssignment(newTask); // → Provider saves it
```

### Loading from Disk (App Startup)
```dart
final json = jsonDecode(savedString); // String → Map
final task = Assignment.fromJson(json); // Map → Object
```

### Displaying in UI
```dart
Text(assignment.title);
Text(DateFormat('MMM d').format(assignment.dueDate));
Icon(
  Icons.priority_high,
  color: assignment.priority == PriorityLevel.high 
    ? Colors.red 
    : Colors.grey
);
```

---

## Deep Dive: UUID Generation

### What is a UUID?
**Universally Unique Identifier**: A 128-bit number displayed as 36 characters.

**Example**: `550e8400-e29b-41d4-a716-446655440000`

**Why Use It?**
- **Uniqueness**: Probability of collision is astronomically low
- **No Central Authority**: Can generate IDs offline without database
- **Flutter Keys**: Required for widget identity in lists

### The `uuid` Package
```yaml
# pubspec.yaml
dependencies:
  uuid: ^4.0.0
```

**Usage**:
```dart
import 'package:uuid/uuid.dart';

const uuid = Uuid();
final id = uuid.v4(); // Random UUID
```

**Version 4 (v4)**: Uses random number generation (RNG).

---

## Common Pitfalls & Solutions

### ❌ Problem: Modifying ID After Creation
```dart
assignment.id = "newId"; // Compile error: id is final
```
**Solution**: Don't. IDs should be immutable.

### ❌ Problem: Comparing Enums as Strings
```dart
if (assignment.priority == "high") // ❌ Won't compile
```
**Solution**:
```dart
if (assignment.priority == PriorityLevel.high) // ✅ Correct
```

### ❌ Problem: Forgetting to Parse DateTime
```dart
DateTime.parse("2026-02-14") // ✅ Works
DateTime.parse("Feb 14, 2026") // ❌ Throws FormatException
```
**Solution**: Always use ISO-8601 format in JSON.

---

## Testing & Validation

### Unit Test Example
```dart
test('Assignment should generate unique IDs', () {
  final task1 = Assignment(title: "Task 1", dueDate: DateTime.now(), courseName: "CS101");
  final task2 = Assignment(title: "Task 2", dueDate: DateTime.now(), courseName: "CS101");
  
  expect(task1.id, isNot(equals(task2.id))); // IDs should differ
});

test('Assignment should serialize to JSON', () {
  final task = Assignment(
    title: "Test",
    dueDate: DateTime(2026, 2, 14),
    courseName: "CS101",
  );
  
  final json = task.toJson();
  expect(json['title'], "Test");
  expect(json['priority'], 1); // Default medium
});

test('Assignment should deserialize from JSON', () {
  final json = {'id': '123', 'title': 'Test', 'dueDate': '2026-02-14T00:00:00.000', 'courseName': 'CS101', 'priority': 2, 'type': 1, 'isCompleted': false};
  final task = Assignment.fromJson(json);
  
  expect(task.title, 'Test');
  expect(task.priority, PriorityLevel.high);
});
```

---

## Summary

- **Purpose**: Pure data structure for assignments
- **Key Feature**: Auto-generating UUIDs for unique identity
- **Serialization**: Converts enums to integers, dates to strings
- **MVVM Role**: The "Model" — no UI, no logic, just data
