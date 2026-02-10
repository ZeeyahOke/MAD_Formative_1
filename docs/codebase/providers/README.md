# Providers Directory

The `lib/providers/` directory contains the **State Management** logic.
In MVVM context, this is the **ViewModel**.

## What is a Provider?
A Provider is a class that:
1.  Holds data (`List<Assignment>`).
2.  Manipulates data (`addAssignment()`, `removeAssignment()`).
3.  Notifies the UI when data changes (`notifyListeners`).

## Files
*   [`app_state.dart`](app_state.md): The gigantic "Brain" of the application. It manages User Profile, Assignments, and Sessions all in one place.
