# Module 1: Architecture & Setup
*Duration: ~20 Minutes*

## 1. The "Clean Architecture" Concept
This project is built using a simplified **MVVM (Model-View-ViewModel)** pattern. This is an industry-standard way to write apps that are easy to test and maintain.

### The Big Picture
Imagine a restaurant:
1.  **The View (UI/Screens)**: The Waiter. They present the menu (data) to the customer and take orders (user input). They don't cook the food.
2.  **The ViewModel (Providers)**: The Kitchen Manager. They receive the order, tell the chefs what to do, decide when the food is ready, and ring the bell (`notifyListeners`) for the waiter to pick it up.
3.  **The Model (Data Classes)**: The Ingredients. A raw steak (Data) doesn't know how to cook itself or how to be served. It just *is*.

### Directory Structure Explanation
We organized the files to match this pattern exactly:
*   `lib/models/` -> **The Ingredients**. Pure Dart classes defining data structures.
*   `lib/providers/` -> **The Kitchen Manager**. Business logic, state holding, saves/loads data.
*   `lib/screens/` -> **The Waiter**. Visual widgets that show data and capture taps.

---

## 2. Dependency Injection (The "Provider" Setup)
Open [`../lib/main.dart`](../lib/main.dart).

This file is the "Entry Point".
```dart
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState(),
      child: const StudentApp(),
    ),
  );
}
```

### Why do we do this?
This is called **State Elevation**.
By wrapping the entire `StudentApp` inside a `ChangeNotifierProvider`, we are creating the "Brain" (`AppState`) at the very top of the widget tree.

*   **Benefit**: This means `AppState` is created *once* when the app starts and lives forever.
*   **Benefit**: *Any* screen, anywhere in the app, can reach up and access this single instance of `AppState`. If the Dashboard updates it, the Schedule screen sees the change immediately.

---

## 3. The Theme System
In `StudentApp` widget:
```dart
theme: ThemeData(
  primaryColor: AppColors.primaryBlue,
  // ...
),
```
We centralized colors in `lib/theme/colors.dart`. This is a best practice. Instead of hardcoding `Colors.blue` in 50 different files, we use `AppColors.primaryBlue`. If we want to rebrand the app to Red later, we change it in *one* file.
