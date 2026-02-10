# Models Directory

The `lib/models/` directory contains the **Data Structures** of your application.
In Clean Architecture, these are "Entities". They represent the raw information the app deals with.

## Characteristics of a Model File
1.  **No Logic**: Models do not calculations, no saving to disk, and no drawing to screen.
2.  **Serializable**: They typically have `toJson` and `fromJson` methods to convert them into text for storage.
3.  **Immutable-ish**: We prefer `final` fields where possible, though in this app some fields (like `title`) are mutable for editing.

## Files in this Directory
*   [`assignment.dart`](assignment.md): Represents a piece of work (`title`, `dueDate`, `priority`).
*   [`session.dart`](session.md): Represents a class or meeting on the schedule.
