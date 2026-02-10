# Screens Directory

The `lib/screens/` directory contains the **Views** (UI).
These files should be mostly visual. They shouldn't contain complex math or data saving logic.

## Architecture Pattern
*   **StatefulWidget**: Used when the screen has local temporary state (like a text field controller or a checkbox that hasn't been saved yet).
*   **StatelessWidget**: Used when the screen just displays data from the Provider.

## Files
*   [`dashboard_screen.dart`](dashboard_screen.md): Main summary view.
*   [`assignments_screen.dart`](assignments_screen.md): List of tasks.
*   [`signup_screen.dart`](signup_screen.md): Onboarding form.
