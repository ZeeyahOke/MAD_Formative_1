# Schedule Screen - Complete Technical Documentation
**File Location**: [`lib/screens/schedule_screen.dart`](../../../lib/screens/schedule_screen.dart)  
**Purpose**: Weekly calendar view of academic sessions  
**Type**: `StatefulWidget`  
**Lines of Code**: ~1031

---

## Architecture Overview
This is the most complex screen. Features:
- **Week Navigation**: Previous/next week functionality
- **Date Grouping**: Sessions grouped by day
- **Time-based Rendering**: Past/present/future visual states
- **Scroll-to-Upcoming**: Auto-scroll to next session

---

## State Variables

```dart
int _weekOffset = 0;
final GlobalKey _upcomingKey = GlobalKey();
```

### `_weekOffset`
**Type**: `int`  
**Values**:
- `0`: Current week
- `-1`: Last week
- `1`: Next week
- `-2`: Two weeks ago, etc.

**Used In**: `_weekStart` calculation.

### `_upcomingKey`
**Type**: `GlobalKey`  
**Purpose**: Marker for auto-scroll target.  
**Usage**: Passed to the first upcoming session widget.

---

## Week Calculation Logic

```dart
DateTime get _weekStart {
  final now = DateTime.now();
  final currentWeekStart = now.subtract(Duration(days: now.weekday - 1));
  return currentWeekStart.add(Duration(days: 7 * _weekOffset));
}

DateTime get _weekEnd {
  return _weekStart.add(const Duration(days: 7));
}
```

### `now.weekday`
**Returns**: 1-7 (Monday-Sunday).

### Week Start Calculation
**Example**:
- Today: Wednesday (weekday = 3)
- Subtract: 3 - 1 = 2 days
- Result: Monday of this week

### Week Range
- **Start**: Monday 00:00:00
- **End**: Monday 00:00:00 (next week)

---

## Session Filtering

### By Week
```dart
List<AcademicSession> _filterSessionsByWeek(List<AcademicSession> allSessions) {
  return allSessions.where((session) {
    return session.startTime.isAfter(_weekStart.subtract(const Duration(seconds: 1))) &&
        session.startTime.isBefore(_weekEnd);
  }).toList();
}
```

**Logic**: Session must start within `[_weekStart, _weekEnd)`.

**Edge Case**: `.subtract(const Duration(seconds: 1))` makes the start inclusive.

---

## Grouping Sessions by Date

```dart
Map<String, List<AcademicSession>> _groupSessionsByDate(
    List<AcademicSession> sessions) {
  final grouped = <String, List<AcademicSession>>{};
  
  for (var session in sessions) {
    final dateKey = DateFormat('yyyy-MM-dd').format(session.startTime);
    grouped.putIfAbsent(dateKey, () => []).add(session);
  }
  
  // Sort sessions within each day
  grouped.forEach((key, sessions) {
    sessions.sort((a, b) => a.startTime.compareTo(b.startTime));
  });
  
  return grouped;
}
```

### Map Structure
```dart
{
  "2026-02-10": [Session1, Session2],
  "2026-02-12": [Session3],
  "2026-02-14": [Session4, Session5, Session6],
}
```

### `.putIfAbsent()` Logic
**Behavior**:
- If key exists: Add to existing list
- If key doesn't exist: Create new list with item

---

## Week Navigation Controls

```dart
actions: [
  IconButton(
    icon: const Icon(Icons.chevron_left),
    onPressed: () {
      setState(() => _weekOffset--);
    },
  ),
  IconButton(
    icon: const Icon(Icons.today),
    onPressed: () {
      setState(() => _weekOffset = 0);
    },
  ),
  IconButton(
    icon: const Icon(Icons.chevron_right),
    onPressed: () {
      setState(() => _weekOffset++);
    },
  ),
]
```

**Flow**:
1. User taps arrow
2. `_weekOffset` changes
3. `setState()` triggers rebuild
4. `_weekStart`/`_weekEnd` getters recalculate
5. Sessions are re-filtered for new week

---

## Week Indicator Banner

```dart
Widget _buildWeekIndicator() {
  final weekEndDisplay = _weekEnd.subtract(const Duration(days: 1));
  
  return Container(
    child: Row(
      children: [
        Text(
          '${DateFormat('MMM d').format(_weekStart)} - ${DateFormat('MMM d, yyyy').format(weekEndDisplay)}',
        ),
        if (_weekOffset != 0)
          Text(_weekOffset > 0 ? 'Future Week' : 'Past Week'),
      ],
    ),
  );
}
```

**Display**: "Feb 10 - Feb 16, 2026"  
**Conditional Label**: Shows "Past Week" or "Future Week" if not current week.

---

## Finding the First Upcoming Session

```dart
String? firstUpcomingSessionId;
final now = DateTime.now();

final allSorted = sessions.toList()..sort((a,b) => a.startTime.compareTo(b.startTime));
for (var s in allSorted) {
  if (s.startTime.isAfter(now)) {
    firstUpcomingSessionId = s.id;
    break;
  }
}
```

**Purpose**: Identify where to place the "Upcoming Sessions" header.

**Cascade Operator `..`**:
```dart
sessions.toList()..sort(...)
```
Equivalent to:
```dart
final temp = sessions.toList();
temp.sort(...);
// Use temp
```

---

## Session Card Rendering

```dart
Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    border: session.startTime.isAfter(DateTime.now())
        ? Border.all(color: Colors.blue)
        : null,
  ),
  child: ListTile(
    leading: Column(
      children: [
        Text(DateFormat('HH:mm').format(session.startTime)),
        Text(DateFormat('HH:mm').format(session.endTime), 
          style: TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    ),
    title: Text(session.title),
    subtitle: Row(
      children: [
        Icon(Icons.location_on, size: 12),
        Text(session.location),
      ],
    ),
    trailing: Icon(
      session.isPresent ? Icons.check_circle : Icons.circle_outlined
    ),
    onTap: () => _showSessionDetails(context, session),
  ),
)
```

### Time State Visual Feedback
- **Future**: Blue border
- **Past**: No border
- **Active**: Special badge (handled elsewhere)

---

## FAB: Add Session

```dart
floatingActionButton: FloatingActionButton(
  onPressed: () => _showAddEditSession(context),
  child: const Icon(Icons.add),
)
```

**Opens**: Modal bottom sheet with form (similar to assignments).

---

## Auto-Scroll to Upcoming

```dart
@override
void initState() {
  super.initState();
  if (widget.scrollToUpcoming) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToUpcoming();
    });
  }
}

void _scrollToUpcoming() {
  if (_upcomingKey.currentContext != null) {
    Scrollable.ensureVisible(
      _upcomingKey.currentContext!,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      alignment: 0.1,
    );
  }
}
```

### `addPostFrameCallback`
**Purpose**: Wait for first frame to paint before scrolling.  
**Why?**: Widget positions aren't known until after first render.

### `Scrollable.ensureVisible`
**Parameters**:
- `duration`: Animation length
- `curve`: Easing function
- `alignment`: 0.0 = top, 1.0 = bottom, 0.1 = near top

---

## Empty State

```dart
Widget _buildEmptyState() {
  return Center(
    child: Column(
      children: [
        Icon(Icons.calendar_today_outlined, size: 80, color: Colors.grey[300]),
        Text(
          _weekOffset == 0
              ? "Tap the + button to schedule your first session"
              : "Navigate to another week or add new sessions",
        ),
      ],
    ),
  );
}
```

**Context-Aware Message**: Different text for current week vs other weeks.

---

## Performance Considerations

### Expensive Operations
```dart
final groupedSessions = _groupSessionsByDate(sessions);
```

**Cost**: O(n) grouping + O(n log n) sorting.  
**Optimization**: Could memoize if dataset is large (>1000 sessions).

### Rebuild Scope
Every week navigation triggers full rebuild.  
**Alternative**: Use `AnimatedSwitcher` for smoother transitions.

---

## Summary
- **Role**: Calendar view with time intelligence
- **Complexity**: Most complex screen (1000+ lines)
- **Key Features**: Week navigation, date grouping, auto-scroll
- **State**: Local state for week offset, global state for sessions
