# Sign Up Screen - Complete Technical Documentation
**File Location**: [`lib/screens/signup_screen.dart`](../../../lib/screens/signup_screen.dart)  
**Purpose**: Onboarding flow for new users  
**Type**: `StatefulWidget`  
**Lines of Code**: ~215

---

## Architecture Role
This screen acts as the **gatekeeper**. It collects two critical pieces of information:
1. User's email (for name extraction)
2. Selected courses (for data seeding)

---

## Local State

```dart
final _emailController = TextEditingController();
final Set<String> _selectedCourses = {};

final List<String> _courses = [
  'Introduction to Linux',
  'Introduction to Python Programming',
  'Front End Web Development',
];
```

### Why `Set` for Selected Courses?
- **Uniqueness**: Can't select the same course twice
- **Performance**: O(1) lookup for `.contains()`

### Why `TextEditingController`?
- **Access**: Read text value at any time
- **Manipulation**: Can programmatically change text
- **Memory**: Must dispose in `dispose()` method

---

## Form Validation

```dart
onPressed: () async {
  if (_emailController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please enter your email')),
    );
    return;
  }
  
  if (_selectedCourses.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please select at least one course')),
    );
    return;
  }

  // Proceed with sign up
}
```

**Guard Clauses**: Early returns prevent execution if validation fails.  
**UI Feedback**: `SnackBar` shows non-intrusive error message.

---

## User Profile Creation

```dart
final appState = Provider.of<AppState>(context, listen: false);
await appState.setUser(_emailController.text, _selectedCourses.toList());
```

### `listen: false`
**Critical Optimization**: We're only calling a method, not reading state.  
**Without `false`**: This callback would rebuild whenever `AppState` changes.

### `setUser()` Flow
1. Extract name from email (`"john.doe@uni.com"` → `"John"`)
2. Save profile to `SharedPreferences`
3. Clear existing data (fresh start)
4. Call `_generateAllSampleData()` for selected courses
5. Save generated data
6. Call `notifyListeners()`

---

## Course Selection UI

```dart
Widget _buildCourseOption(String course) {
  final isSelected = _selectedCourses.contains(course);
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: InkWell(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedCourses.remove(course);
          } else {
            _selectedCourses.add(course);
          }
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primaryBlue),
        ),
        child: Text(
          course,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.primaryBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
  );
}
```

### Toggle Logic
```dart
if (isSelected) {
  _selectedCourses.remove(course);
} else {
  _selectedCourses.add(course);
}
```

**Set Operations**: Add if not present, remove if present.

### Visual States
- **Selected**: Blue background, white text
- **Unselected**: White background, blue text

---

## Navigation to Home

```dart
if (context.mounted) {
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(builder: (context) => const HomeScreen()),
  );
}
```

### `pushReplacement` vs `push`
- **`push`**: Adds to navigation stack (back button works)
- **`pushReplacement`**: Removes current route (can't go back to sign-up)

### `context.mounted` Check
**Purpose**: Ensures widget is still in the tree before navigating.  
**Why Needed**: `async` operations might complete after widget is disposed.

---

## Email Field

```dart
TextField(
  controller: _emailController,
  decoration: InputDecoration(
    hintText: 'student@alueducation.com',
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
)
```

**`controller`**: Binds `TextEditingController` to read value.  
**`hintText`**: Placeholder example.

---

## Loading Feedback

```dart
ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(content: Text('Creating your profile...')),
);
```

**User Experience**: Shows activity during `await appState.setUser()`.  
**Alternative**: `CircularProgressIndicator` overlay.

---

## Data Flow Diagram

```
SignUpScreen → setUser() → AppState
    ↓
Extract name from email
    ↓
Save to SharedPreferences
    ↓
Generate sample assignments/sessions
    ↓
Save data to disk
    ↓
notifyListeners()
    ↓
Navigate to HomeScreen
```

---

## Error Handling

### Invalid Email Format
**Current State**: No validation.  
**Improvement**:
```dart
bool isValidEmail(String email) {
  return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
}
```

### Network Dependency
**Current State**: Local-only (no backend).  
**Future**: Could call API to check if email exists.

---

## Lifecycle Management

```dart
@override
void dispose() {
  _emailController.dispose();
  _courseController.dispose();
  super.dispose();
}
```

**Why Dispose?**: Prevents memory leaks. Controllers hold listeners that must be cleaned up.

---

## Summary
- **Role**: User onboarding and profile creation
- **Critical Logic**: Email → Name extraction, Course selection → Data seeding
- **Pattern**: Local state for form, global state for profile
- **Navigation**: One-way trip (can't go back after sign-up)
