# Risk Status Screen - Complete Technical Documentation
**File Location**: [`lib/screens/risk_status_screen.dart`](../../../lib/screens/risk_status_screen.dart)  
**Purpose**: Detailed attendance history and risk analysis  
**Type**: `StatelessWidget`  
**Lines of Code**: ~196

---

## Architecture Overview
This screen provides:
1. **Attendance Summary**: Overall percentage + stats
2. **Detailed History**: List of all past sessions with attendance status
3. **Toggle Capability**: Correct historical attendance mistakes

---

## Data Queries

```dart
final appState = Provider.of<AppState>(context);
final username = appState.username; 
final attendance = appState.getAttendancePercentage();
final isAtRisk = attendance < 75;

final pastSessions = appState.filteredSessions
    .where((s) => s.endTime.isBefore(DateTime.now()))
    .toList()
  ..sort((a, b) => b.startTime.compareTo(a.startTime)); // Newest first
```

### Reverse Chronological Sort
```dart
..sort((a, b) => b.startTime.compareTo(a.startTime));
```

**Logic**: `b` compared to `a` (reversed) puts newest first.

---

## Risk Status Header

```dart
Text(
  isAtRisk ? 'Warning: At Risk' : 'On Track',
  style: TextStyle(
    color: isAtRisk ? AppColors.danger : AppColors.success,
    fontSize: 24,
    fontWeight: FontWeight.bold,
  ),
)
```

###Conditional Styling
- **At Risk** (<75%): Red text, "Warning: At Risk"
- **On Track** (≥75%): Green text, "On Track"

---

## Statistics Cards

```dart
Row(
  children: [
    _buildRiskBox(
      '${attendance.toStringAsFixed(0)}%',
      isAtRisk ? AppColors.danger : AppColors.success,
      'Attendance'
    ),
    _buildRiskBox(
      '${pastSessions.where((s) => s.isPresent).length}', 
      Colors.blueGrey,
      'Sessions\nAttended'
    ),
    _buildRiskBox(
      '${pastSessions.length - pastSessions.where((s) => s.isPresent).length}', 
      AppColors.warning,
      'Sessions\nMissed'
    ),
  ],
)
```

### Metric Calculations

#### Attended Count
```dart
pastSessions.where((s) => s.isPresent).length
```

#### Missed Count
```dart
pastSessions.length - pastSessions.where((s) => s.isPresent).length
```

**Alternative**:
```dart
pastSessions.where((s) => !s.isPresent).length
```

---

## History List

```dart
ListView.builder(
  itemCount: pastSessions.length,
  itemBuilder: (context, index) {
    final session = pastSessions[index];
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: session.isPresent 
              ? Colors.grey.withOpacity(0.2) 
              : AppColors.danger.withOpacity(0.5)
        ),
      ),
      child: ListTile(
        leading: Container(
          decoration: BoxDecoration(
            color: session.isPresent 
                ? AppColors.success.withOpacity(0.1) 
                : AppColors.danger.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            session.isPresent ? Icons.check : Icons.close,
            color: session.isPresent ? AppColors.success : AppColors.danger,
          ),
        ),
        title: Text(session.title),
        subtitle: Column(
          children: [
            Text(DateFormat('MMM d, yyyy • HH:mm').format(session.startTime)),
            if (session.courseName != null)
              Text(session.courseName!, 
                style: TextStyle(color: AppColors.primaryBlue)),
          ],
        ),
        trailing: Switch(
          value: session.isPresent,
          onChanged: (val) {
            appState.toggleAttendance(session.id);
          },
        ),
      ),
    );
  },
)
```

### Visual Feedback for Attendance
- **Present**: Green icon, light border
- **Absent**: Red icon, red border

### The Switch Widget
```dart
Switch(
  value: session.isPresent,
  onChanged: (val) {
    appState.toggleAttendance(session.id);
  },
)
```

**Purpose**: Allows user to correct mistaken absences.

**Flow**:
1. User toggles switch
2. Calls `appState.toggleAttendance()`
3. Provider flips boolean
4. Saves to disk
5. Calls `notifyListeners()`
6. Screen rebuilds
7. Attendance % updates in header

---

## Date Formatting

```dart
DateFormat('MMM d, yyyy • HH:mm').format(session.startTime)
```

**Output**: "Feb 10, 2026 • 10:00"

**Bullet Separator**: `•` (U+2022)

---

## Empty State

```dart
pastSessions.isEmpty 
    ? const Center(child: Text("No past sessions recorded."))
    : ListView.builder(...)
```

**Condition**: Shows when no sessions have occurred yet (start of semester).

---

## Container Decoration Pattern

```dart
Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
      color: session.isPresent 
          ? Colors.grey.withOpacity(0.2) 
          : AppColors.danger.withOpacity(0.5)
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.05),
        blurRadius: 4,
        offset: const Offset(0,2)
      )
    ],
  ),
  child: ...,
)
```

### Shadow Properties
- **`blurRadius`**: Softness of shadow
- **`offset`**: Position (0,2) = 2px down
- **`alpha: 0.05`**: 5% opacity (subtle)

---

## _buildRiskBox() Helper

```dart
Widget _buildRiskBox(String value, Color color, String label) {
  return Expanded(
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecation(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          ),
        ],
      ),
    ),
  );
}
```

**Design Pattern**: Reusable component with data-driven styling.

---

## Navigation Flow

**Entry Points**:
1. Dashboard risk warning tap
2. "View Attendance" links

**Exit**: Back button in AppBar.

---

## Real-Time Updates

### Scenario
1. User toggles attendance
2. Provider updates data
3. `notifyListeners()` called
4. `Provider.of<AppState>(context)` rebuilds widget
5. New attendance % calculated
6. Header color changes if crossing 75% threshold

---

## Summary
- **Role**: Detailed view for attendance risk analysis
- **Key Feature**: Ability to toggle historical attendance
- **Pattern**: Read-only display + editable switches
- **Integration**: Responds immediately to Provider changes
