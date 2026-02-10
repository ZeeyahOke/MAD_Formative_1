# Home Screen - Complete Technical Documentation
**File Location**: [`lib/screens/home_screen.dart`](../../../lib/screens/home_screen.dart)  
**Purpose**: Bottom navigation container  
**Type**: `StatefulWidget`  
**Lines of Code**: ~67

---

## Overview
The `HomeScreen` is a **container widget** that manages tab-based navigation between three main screens:
1. Dashboard
2. Assignments
3. Schedule

### Why StatefulWidget?
- Needs to track `_selectedIndex` (which tab is active)
- Index changes trigger rebuilds

---

## State Variables

```dart
class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const AssignmentsScreen(),
    const ScheduleScreen(),
  ];
}
```

### `_selectedIndex`
**Type**: `int`  
**Values**: 0 (Dashboard), 1 (Assignments), 2 (Schedule)  
**Purpose**: Tracks active tab

### `_screens`
**Type**: `List<Widget>`  
**Purpose**: Holds instances of each screen. We display `_screens[_selectedIndex]`.

**Why Create Instances Upfront?**  
Preserves scroll position and form state when switching tabs.

---

## Navigation Logic

### `_onItemTapped()`
```dart
void _onItemTapped(int index) {
  setState(() {
    _selectedIndex = index;
  });
}
```

**Called By**: `BottomNavigationBar.onTap`  
**Effect**: Updates `_selectedIndex` and triggers rebuild.

**`setState(() {})`**: Tells Flutter "I changed state, redraw this widget".

---

## build() Method

### The Scaffold Body
```dart
body: _screens[_selectedIndex]
```

**Dynamic Display**: Shows different screen based on index.  
**No Transition Animation**: Instant switch (not a Navigator push).

### BottomNavigationBar Configuration
```dart
BottomNavigationBar(
  items: const <BottomNavigationBarItem>[
    BottomNavigationBarItem(
      icon: Icon(Icons.grid_view),
      label: 'Dashboard',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.assignment),
      label: 'Assignments',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.calendar_today),
      label: 'Schedule',
    ),
  ],
  currentIndex: _selectedIndex,
  selectedItemColor: AppColors.accentYellow,
  unselectedItemColor: Colors.grey,
  onTap: _onItemTapped,
  showUnselectedLabels: true,
  type: BottomNavigationBarType.fixed,
  backgroundColor: AppColors.primaryBlue,
  elevation: 0,
)
```

### Property Breakdown

#### `items`
List of navigation items. Each has an `icon` and `label`.

#### `currentIndex`
**Bound to State**: `_selectedIndex`  
**Effect**: Highlights the active tab.

#### `selectedItemColor` / `unselectedItemColor`
**Visual Feedback**: Active tab is yellow, others are grey.

#### `onTap`
**Callback**: Receives the tapped index. We pass `_onItemTapped`.

#### `type: BottomNavigationBarType.fixed`
**Behavior**: Items don't animate/shift when selected (vs. `shifting` type).

#### `elevation: 0`
**Design Choice**: Flat appearance (no shadow).

---

## Theme Wrapper
```dart
Theme(
  data: Theme.of(context).copyWith(
    canvasColor: AppColors.primaryBlue,
  ),
  child: BottomNavigationBar(...),
)
```

**Purpose**: Override the default white background.  
**`canvasColor`**: Background color of the navigation bar.

---

## State Preservation

### How It Works
```dart
final List<Widget> _screens = [
  const DashboardScreen(),
  const AssignmentsScreen(),
  const ScheduleScreen(),
];
```

**Key Point**: These instances are **final**. They don't get recreated when switching tabs.

**Benefit**: If you scroll down in Assignments, switch to Dashboard, then switch back, your scroll position is preserved.

---

## Alternative Approaches

### IndexedStack (Better Preservation)
```dart
body: IndexedStack(
  index: _selectedIndex,
  children: _screens,
)
```

**Difference**: Keeps all screens in memory and just toggles visibility.  
**Trade-off**: Uses more memory but better for forms with user input.

### PageView (Swipeable)
```dart
body: PageView(
  controller: _pageController,
  onPageChanged: (index) => setState(() => _selectedIndex = index),
  children: _screens,
)
```

**Adds**: Swipe gesture between tabs.

---

## Summary
- **Role**: Navigation controller
- **Pattern**: Tab-based navigation with bottom bar
- **State**: Local state (`_selectedIndex`) doesn't need global AppState
- **Integration**: Acts as parent to Dashboard, Assignments, Schedule
