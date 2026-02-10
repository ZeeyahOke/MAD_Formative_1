# Main Entry Point - Complete Technical Documentation
**File Location**: [`lib/main.dart`](../../../lib/main.dart)  
**Purpose**: Application bootstrap and dependency injection  
**Lines of Code**: ~47

---

## `main()` Function - The Entry Point
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

**Dependency Injection**: `ChangeNotifierProvider` creates `AppState` at the root, making it accessible to all descendant widgets.

---

## `StudentApp` - The MaterialApp Configuration
```dart
class StudentApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Academic Platform',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primaryBlue,
        colorScheme: ColorScheme.fromSeed(...),
        appBarTheme: const AppBarTheme(...),
        useMaterial3: true,
      ),
      home: const SignUpScreen(),
    );
  }
}
```

**Theme Setup**: Centralizes colors and styling. Uses Material Design 3.  
**Initial Route**: `SignUpScreen` is the first screen shown.

---

See full analysis in the comprehensive version above.
