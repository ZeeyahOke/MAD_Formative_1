# Dashboard Screen - Complete Technical Documentation
**File Location**: [`lib/screens/dashboard_screen.dart`](../../../lib/screens/dashboard_screen.dart)  
**Purpose**: Main information hub showing attendance, assignments, and today's schedule  
**Type**: `StatelessWidget`  
**Lines of Code**: ~551

---

## Architecture Overview
This is a complex **data aggregation screen**. It pulls from multiple sources:
- User profile (`username`)
- Attendance (`get AttendancePercentage()`)
- Assignments (`getAssignmentsDueNext7Days()`)
- Sessions (`getTodaysSessions()`)

---

## Provider Connection

```dart
final appState = Provider.of<AppState>(context);
```

**`Provider.of<AppState>(context)`**:
- **Searches** up the widget tree
- **Finds** the `ChangeNotifierProvider` created in `main.dart`
- **Returns** the `AppState` instance
- **Subscribes** to changes (rebuilds when `notifyListeners()` is called)

**Alternative**: `Consumer<AppState>` widget (more granular rebuilds).

---

## Data Queries

### Today's Sessions
```dart
final todaySessions = appState.getTodaysSessions();
```

**Returns**: List of sessions happening today.  
**Filtered By**: Active course filter from dropdown.

### Attendance Percentage
```dart
final attendancePercent = appState.getAttendancePercentage();
```

**Returns**: Double (0.0 - 100.0).  
**Logic**: (Present classes / Total past classes) × 100

### Upcoming Assignments
```dart
final upcomingAssignments = appState.getAssignmentsDueNext7Days();
```

**Returns**: Assignments due within next week.  
**Sorted**: By due date (earliest first).

---

## AppBar with Course Filter

### Sign Out Menu
```dart
actions: [
  PopupMenuButton<String>(
    icon: const Icon(Icons.person_outline),
    onSelected: (value) async {
      if (value == 'sign_out') {
        await appState.signOut();
        Navigator.pushAndRemoveUntil(...);
      }
    },
    itemBuilder: (context) => [
      PopupMenuItem(value: 'sign_out', child: Text('Sign out')),
    ],
  ),
]
```

**Flow**:
1. User taps person icon
2. Menu appears with "Sign out"
3. Calls `appState.signOut()`
4. Clears all data
5. Navigates to `SignUpScreen` (removing all previous routes)

### Course Filter Dropdown
```dart
DropdownButton<String>(
  value: appState.filteredCourse,
  items: [
    DropdownMenuItem(value: null, child: Text('All Selected Courses')),
    ...appState.selectedCourses.map((course) => 
      DropdownMenuItem(value: course, child: Text(course))
    ),
  ],
  onChanged: (newValue) {
    appState.setCourseFilter(newValue);
  },
)
```

**Controlled Input**: 
- **Read**: `appState.filteredCourse`
- **Write**: `appState.setCourseFilter()`

**Effect**: When changed, all data queries automatically respect the new filter.

---

## Conditional Risk Warning

```dart
if (attendancePercent < 75)
  Padding(
    padding: const EdgeInsets.all(16.0),
    child: GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => const RiskStatusScreen()
        ));
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.danger.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.danger, width: 2),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 32),
            SizedBox(width: 12),
            Expanded(
              child: Column(...),
            ),
            Icon(Icons.chevron_right, color: AppColors.danger),
          ],
        ),
      ),
    ),
  )
```

### Conditional Rendering
**Pattern**: `if (condition) Widget`  
**Effect**: Warning box only exists in widget tree when condition is true.

**Threshold**: 75% (standard academic attendance requirement).

**Navigation**: Tapping navigates to `RiskStatusScreen` for detailed history.

---

## Metric Cards

```dart
Row(
  children: [
    Expanded(child: _buildMetricCard(...)),
    SizedBox(width: 12),
    Expanded(child: _buildMetricCard(...)),
    SizedBox(width: 12),
    Expanded(child: _buildMetricCard(...)),
  ],
)
```

### `_buildMetricCard()` Helper
```dart
Widget _buildMetricCard(String value, String label, IconData icon, Color color) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [...],
    ),
    child: Column(
      children: [
        Icon(icon, size: 32, color: color),
        SizedBox(height: 8),
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    ),
  );
}
```

**Pattern**: Reusable component.  
**Parameters**: Data-driven design (pass different values for different cards).

---

## Upcoming Assignments List

```dart
...upcomingAssignments.take(3).map((assignment) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    child: ListTile(
      title: Text(assignment.title),
      subtitle: Text("Due ${DateFormat('MMM d').format(assignment.dueDate)}"),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.backgroundLight,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.assignment, color: AppColors.primaryBlue),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 14),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => const AssignmentsScreen()
        ));
      },
    ),
  );
})
```

### `.take(3)`
**Purpose**: Limit display to first 3 items.  
**Why**: Dashboard should be a summary, not a full list.

### Date Formatting
```dart
DateFormat('MMM d').format(assignment.dueDate)
```

**Output**: "Feb 14" (localized).  
**Package**: `intl`

---

## Today's Sessions Display

```dart
...todaySessions.map((s) {
  final isPast = s.endTime.isBefore(DateTime.now());
  final isActive = !isPast && s.startTime.isBefore(DateTime.now());
  
  return Container(
    child: ListTile(
      leading: Column(
        children: [
          Text(DateFormat('HH:mm').format(s.startTime)),
          Text(DateFormat('HH:mm').format(s.endTime)),
        ],
      ),
      title: Text(s.title),
      subtitle: Row(
        children: [
          Icon(Icons.location_on, size: 12),
          Text(s.location),
          if (isActive)
            Container(child: Text('NOW', style: TextStyle(color: Colors.white)))
          else if (!isPast)
            Container(child: Text('UPCOMING')),
        ],
      ),
      trailing: Icon(
        s.isPresent ? Icons.check_circle : Icons.circle_outlined
      ),
    ),
  );
})
```

### Time State Logic
```dart
final isPast = s.endTime.isBefore(DateTime.now());
final isActive = !isPast && s.startTime.isBefore(DateTime.now());
```

**States**:
- **Past**: Session ended
- **Active**: Currently happening
- **Upcoming**: Hasn't started yet

**Visual Feedback**: Different badges for each state.

---

## Scroll Behavior

```dart
body: SingleChildScrollView(
  child: Column(
    children: [...]
  ),
)
```

**`SingleChildScrollView`**: Allows content taller than screen to scroll vertically.  
**Alternative**: `ListView` (for dynamic lists).

---

## Performance Considerations

### Rebuilds on Data Change
Every time `notifyListeners()` is called in `AppState`, this entire screen rebuilds.

**Optimization**: Use `Consumer` wrapper around specific sections:
```dart
Consumer<AppState>(
  builder: (context, appState, child) {
    return Text(appState.getAttendancePercentage().toString());
  },
)
```

Only the `Consumer`'s subtree rebuilds, not the whole screen.

---

## Summary
- **Role**: Information aggregator and navigation hub
- **Data Sources**: Multiple getters from `AppState`
- **Key Features**: Conditional risk warning, course filtering, live session status
- **Navigation**: Gateway to detailed screens (Assignments, Schedule, Risk Status)
