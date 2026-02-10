# Assignments Screen - Complete Technical Documentation
**File Location**: [`lib/screens/assignments_screen.dart`](../../../lib/screens/assignments_screen.dart)  
**Purpose**: Display, filter, and manage academic assignments  
**Type**: `StatelessWidget` (main), `StatefulWidget` (form)  
**Lines of Code**: ~429

---

## Architecture Overview
This screen uses a **TabController** to provide 4 filtered views:
1. All Assignments
2. Missed (Overdue & Incomplete)
3. Formative (Practice)
4. Summative (Graded)

---

## TabBar Configuration

```dart
DefaultTabController(
  length: 4,
  child: Scaffold(
    appBar: AppBar(
      bottom: const TabBar(
        tabs: [
          Tab(text: 'All'),
          Tab(text: 'Missed'),
          Tab(text: 'Formative'),
          Tab(text: 'Summative'),
        ],
      ),
    ),
    body: TabBarView(
      children: [
        _buildAssignmentList(context, filterType: AssignmentType.all),
        _buildAssignmentList(context, showMissed: true),
        _buildAssignmentList(context, filterType: AssignmentType.formative),
        _buildAssignmentList(context, filterType: AssignmentType.summative),
      ],
    ),
  ),
)
```

### `DefaultTabController`
**Purpose**: Manages tab state automatically.  
**Alternative**: Manual `TabController` (more control, more boilerplate).

### Tab Synchronization
`Tab Bar` (headers) and `TabBarView` (content pages) are automatically synced by index.

---

## Filtering Logic

### `_buildAssignmentList()` Method
```dart
Widget _buildAssignmentList(BuildContext context, {
  AssignmentType filterType = AssignmentType.all,
  bool showMissed = false
}) {
  return Consumer<AppState>(
    builder: (context, appState, child) {
      // Course Filter
      final filter = appState.filteredCourse;
      final isAll = filter == null || filter == 'All Selected Courses';

      final courseFiltered = isAll
          ? appState.assignments
          : appState.assignments.where((a) => a.courseName == filter).toList();

      // Type Filter
      List<Assignment> assignments;
      if (showMissed) {
        assignments = courseFiltered.where((a) => 
          a.dueDate.isBefore(DateTime.now()) && !a.isCompleted
        ).toList();
      } else {
        assignments = filterType == AssignmentType.all 
            ? courseFiltered 
            : courseFiltered.where((a) => a.type == filterType).toList();
      }

      assignments.sort((a, b) => a.dueDate.compareTo(b.dueDate));

      return ListView.builder(...);
    },
  );
}
```

### Two-Stage Filtering

#### Stage 1: Course Filter
```dart
final courseFiltered = isAll
    ? appState.assignments
    : appState.assignments.where((a) => a.courseName == filter).toList();
```

**Respects**: The dashboard dropdown selection.

#### Stage 2: Type/Status Filter
```dart
if (showMissed) {
  assignments = courseFiltered.where((a) => 
    a.dueDate.isBefore(DateTime.now()) && !a.isCompleted
  ).toList();
}
```

**Missed Logic**: Due date has passed AND task is not completed.

---

## List Item: `Dismissible` Widget

```dart
Dismissible(
  key: Key(assignment.id),
  background: Container(
    color: AppColors.danger,
    alignment: Alignment.centerRight,
    padding: const EdgeInsets.only(right: 20),
    child: const Icon(Icons.delete, color: Colors.white),
  ),
  direction: DismissDirection.endToStart,
  onDismissed: (direction) {
    appState.removeAssignment(assignment.id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Assignment removed')),
    );
  },
  child: ListTile(...)
)
```

### Key Properties

#### `key: Key(assignment.id)`
**Critical**: Unique key required for Flutter to track which item is being dismissed.  
**Without Key**: Flutter might dismiss the wrong item.

#### `background`
**Revealed**: When user swipes left.  
**Design**: Red background with delete icon.

#### `direction: DismissDirection.endToStart`
**Constraint**: Only allow swipe from right to left (not left to right).

#### `onDismissed`
**Called**: After swipe animation completes.  
**Action**: Remove from state + show confirmation.

---

## Checkbox Interaction

```dart
Checkbox(
  value: assignment.isCompleted,
  onChanged: (bool? value) {
    appState.toggleAssignmentCompletion(assignment.id);
  },
)
```

**Flow**:
1. User taps checkbox
2. Calls `toggleAssignmentCompletion()`
3. Provider flips boolean
4. Calls `notifyListeners()`
5. `Consumer` rebuilds
6. Checkbox shows new state

---

## Overdue Visual Feedback

```dart
final isOverdue = assignment.dueDate.isBefore(DateTime.now()) && !assignment.isCompleted;

return Container(
  decoration: BoxDecoration(
    border: isOverdue ? Border.all(color: AppColors.danger.withOpacity(0.3)) : null,
  ),
  child: ListTile(
    title: Text(
      assignment.title,
      style: TextStyle(
        color: isOverdue ? AppColors.danger : Colors.black87,
      ),
    ),
    trailing: isOverdue 
        ? Container(child: Text('MISSED', style: TextStyle(color: AppColors.danger)))
        : Icon(Icons.chevron_right),
  ),
)
```

**Indicators**:
- Red border
- Red text
- "MISSED" badge

---

## Create/Edit Form

### `AssignmentForm` Widget
```dart
class AssignmentForm extends StatefulWidget {
  final Assignment? assignment;
  const AssignmentForm({super.key, this.assignment});
}
```

**Nullable Assignment**: If `null`, creating new. If provided, editing existing.

### Form Controllers
```dart
late TextEditingController _titleController;
late TextEditingController _courseController;
late DateTime _dueDate;
late PriorityLevel _priority;
late AssignmentType _type;

@override
void initState() {
  super.initState();
  _titleController = TextEditingController(text: widget.assignment?.title ?? '');
  _courseController = TextEditingController(text: widget.assignment?.courseName ?? '');
  _dueDate = widget.assignment?.dueDate ?? DateTime.now().add(const Duration(days: 1));
  _priority = widget.assignment?.priority ?? PriorityLevel.medium;
  _type = widget.assignment?.type ?? AssignmentType.formative;
}
```

**Initialization Logic**:
- If editing: Pre-fill with existing values
- If creating: Use sensible defaults

### Date Picker
```dart
InkWell(
  onTap: () async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _dueDate = date);
    }
  },
  child: InputDecorator(
    decoration: const InputDecoration(labelText: 'Due Date'),
    child: Text(DateFormat('MMM d, yyyy').format(_dueDate)),
  ),
)
```

**`showDatePicker()`**: Built-in Flutter dialog.  
**Returns**: `Future<DateTime?>` (null if cancelled).

### Save Logic
```dart
onPressed: () {
  if (_formKey.currentState!.validate()) {
    final assignment = Assignment(
      id: widget.assignment?.id, // Preserve ID if editing
      title: _titleController.text,
      dueDate: _dueDate,
      courseName: _courseController.text,
      priority: _priority,
      type: _type,
    );

    if (widget.assignment == null) {
      appState.addAssignment(assignment);
    } else {
      appState.updateAssignment(assignment);
    }

    Navigator.pop(context);
  }
}
```

**Branch Logic**: `addAssignment()` vs `updateAssignment()`.

---

## Priority Dropdown
```dart
DropdownButtonFormField<PriorityLevel>(
  value: _priority,
  items: PriorityLevel.values.map((level) {
    return DropdownMenuItem(
      value: level,
      child: Text(level.name.capitalize()),
    );
  }).toList(),
  onChanged: (val) => setState(() => _priority = val!),
)
```

**`PriorityLevel.values`**: Returns `[low, medium, high]`.  
**`.name`**: Converts enum to string.  
**`.capitalize()`**: Custom extension method.

---

## Summary
- **Role**: CRUD interface for assignments
- **Pattern**: Tabs for filtering + Dismissible for deletion + Modal form for creation
- **State**: Uses `Consumer<AppState>` for reactive updates
- **UX**: Visual feedback for overdue items
