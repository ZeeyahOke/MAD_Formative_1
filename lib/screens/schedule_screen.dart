import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';
import '../models/session.dart';
import '../theme/colors.dart';
import '../utils/string_extensions.dart';

/// Displays the list of scheduled academic sessions with weekly view
/// 
/// Features:
/// - Weekly filtering of sessions (current week by default)
/// - Swipe-to-delete functionality with confirmation
/// - Attendance tracking with toggle buttons
/// - Session editing capability
/// - Grouped display by date for better organization
class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  // Track the current week offset (0 = this week, -1 = last week, +1 = next week)
  int _weekOffset = 0;

  /// Calculates the start date of the week based on offset
  /// Week starts on Monday
  DateTime get _weekStart {
    final now = DateTime.now();
    final currentWeekStart = now.subtract(Duration(days: now.weekday - 1));
    return currentWeekStart.add(Duration(days: 7 * _weekOffset));
  }

  /// Calculates the end date of the week (Sunday)
  DateTime get _weekEnd {
    return _weekStart.add(const Duration(days: 7));
  }

  /// Filters sessions to only show those within the current week view
  List<AcademicSession> _filterSessionsByWeek(List<AcademicSession> allSessions) {
    return allSessions.where((session) {
      return session.startTime.isAfter(_weekStart.subtract(const Duration(seconds: 1))) &&
          session.startTime.isBefore(_weekEnd);
    }).toList();
  }

  /// Groups sessions by date for organized display
  /// Returns a Map where keys are date strings and values are lists of sessions
  Map<String, List<AcademicSession>> _groupSessionsByDate(
      List<AcademicSession> sessions) {
    final grouped = <String, List<AcademicSession>>{};
    
    for (var session in sessions) {
      final dateKey = DateFormat('yyyy-MM-dd').format(session.startTime);
      grouped.putIfAbsent(dateKey, () => []).add(session);
    }
    
    // Sort sessions within each day by start time
    grouped.forEach((key, sessions) {
      sessions.sort((a, b) => a.startTime.compareTo(b.startTime));
    });
    
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule'),
        actions: [
          // Week navigation controls
          IconButton(
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Previous week',
            onPressed: () {
              setState(() => _weekOffset--);
            },
          ),
          IconButton(
            icon: const Icon(Icons.today),
            tooltip: 'Current week',
            onPressed: () {
              setState(() => _weekOffset = 0);
            },
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Next week',
            onPressed: () {
              setState(() => _weekOffset++);
            },
          ),
        ],
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          // Get all sessions and filter by current week
          final allSessions = appState.sessions;
          final weeklySessions = _filterSessionsByWeek(allSessions);

          return Column(
            children: [
              // Week indicator banner
              _buildWeekIndicator(),
              
              // Sessions list
              Expanded(
                child: weeklySessions.isEmpty
                    ? _buildEmptyState()
                    : _buildSessionsList(weeklySessions, appState),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accentYellow,
        tooltip: 'Add new session',
        child: const Icon(Icons.add, color: AppColors.primaryBlue),
        onPressed: () => _showAddEditSession(context),
      ),
    );
  }

  /// Builds a banner showing the current week range
  Widget _buildWeekIndicator() {
    final weekEndDisplay = _weekEnd.subtract(const Duration(days: 1));
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(color: AppColors.primaryBlue.withOpacity(0.2)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${DateFormat('MMM d').format(_weekStart)} - ${DateFormat('MMM d, yyyy').format(weekEndDisplay)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryBlue,
            ),
          ),
          if (_weekOffset != 0)
            Text(
              _weekOffset > 0 ? 'Future Week' : 'Past Week',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  /// Builds an informative empty state when no sessions are scheduled
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 24),
            const Text(
              "No sessions this week",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _weekOffset == 0
                  ? "Tap the + button to schedule your first session"
                  : "Navigate to another week or add new sessions",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the list of sessions grouped by date
  Widget _buildSessionsList(
      List<AcademicSession> sessions, AppState appState) {
    final groupedSessions = _groupSessionsByDate(sessions);
    final sortedDates = groupedSessions.keys.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final dateKey = sortedDates[index];
        final dateSessions = groupedSessions[dateKey]!;
        final date = DateTime.parse(dateKey);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header
            _buildDateHeader(date),
            const SizedBox(height: 8),
            
            // Sessions for this date
            ...dateSessions.map((session) => _buildSessionCard(
                  session,
                  appState,
                  context,
                )),
            
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  /// Builds a date header showing the day of the week and date
  Widget _buildDateHeader(DateTime date) {
    final isToday = DateFormat('yyyy-MM-dd').format(date) ==
        DateFormat('yyyy-MM-dd').format(DateTime.now());

    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 8, bottom: 4),
      child: Row(
        children: [
          Text(
            DateFormat('EEEE, MMMM d').format(date),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlue,
            ),
          ),
          if (isToday) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.accentYellow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'TODAY',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Builds a dismissible card for a single session
  Widget _buildSessionCard(
    AcademicSession session,
    AppState appState,
    BuildContext context,
  ) {
    // Check if session is in the past
    final isPast = session.endTime.isBefore(DateTime.now());

    return Dismissible(
      key: Key(session.id),
      background: Container(
        color: AppColors.danger,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white, size: 32),
      ),
      direction: DismissDirection.endToStart,
      // Add confirmation before deletion
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Session'),
            content: Text('Are you sure you want to remove "${session.title}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.danger,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        appState.removeSession(session.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${session.title} removed'),
            action: SnackBarAction(
              label: 'UNDO',
              onPressed: () {
                // Re-add the session (requires implementing undo in AppState)
                // appState.addSession(session);
              },
            ),
          ),
        );
      },
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 12),
        // Visual indicator for past sessions
        color: isPast ? Colors.grey[50] : null,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              _buildSessionHeader(session, context, isPast),
              const Divider(height: 24),
              _buildAttendanceToggle(session, appState),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the header section of a session card
  Widget _buildSessionHeader(
    AcademicSession session,
    BuildContext context,
    bool isPast,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date badge
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: isPast
                ? Colors.grey.withOpacity(0.2)
                : AppColors.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                DateFormat('MMM').format(session.startTime).toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: isPast ? Colors.grey : AppColors.primaryBlue,
                ),
              ),
              Text(
                DateFormat('d').format(session.startTime),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: isPast ? Colors.grey : AppColors.primaryBlue,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        
        // Session details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      session.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isPast ? Colors.grey[600] : Colors.black87,
                      ),
                    ),
                  ),
                  if (isPast)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'PAST',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${DateFormat('HH:mm').format(session.startTime)} - ${DateFormat('HH:mm').format(session.endTime)}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.category, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    session.type.name.camelCaseToTitle(),
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  if (session.location.isNotEmpty) ...[
                    Text(' • ', style: TextStyle(color: Colors.grey[600])),
                    Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        session.location,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        
        // Edit button
        IconButton(
          icon: const Icon(Icons.edit, size: 20),
          tooltip: 'Edit session',
          color: AppColors.primaryBlue,
          onPressed: () => _showAddEditSession(context, session: session),
        ),
      ],
    );
  }

  /// Builds the attendance tracking toggle buttons
  Widget _buildAttendanceToggle(AcademicSession session, AppState appState) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Row(
          children: [
            Icon(Icons.check_circle_outline, size: 18, color: Colors.grey),
            SizedBox(width: 6),
            Text(
              'Attendance:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        ToggleButtons(
          isSelected: [session.isPresent, !session.isPresent],
          onPressed: (index) {
            // index 0 = Present, index 1 = Absent
            final newStatus = index == 0;
            if (session.isPresent != newStatus) {
              appState.toggleAttendance(session.id);
            }
          },
          borderRadius: BorderRadius.circular(8),
          constraints: const BoxConstraints(minHeight: 32, minWidth: 75),
          selectedColor: Colors.white,
          fillColor: AppColors.primaryBlue,
          color: AppColors.primaryBlue,
          children: const [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text('Present'),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text('Absent'),
            ),
          ],
        ),
      ],
    );
  }

  /// Shows a modal bottom sheet for adding or editing a session
  void _showAddEditSession(BuildContext context, {AcademicSession? session}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SessionForm(session: session),
    );
  }
}

// ============================================================================
// SESSION FORM WIDGET
// ============================================================================

/// Form widget for creating or editing academic sessions
/// 
/// Handles all input fields with proper validation:
/// - Title (required, 3-100 characters)
/// - Date picker
/// - Start and end time pickers with validation
/// - Optional location field
/// - Session type dropdown
class SessionForm extends StatefulWidget {
  /// The session to edit, or null to create a new session
  final AcademicSession? session;

  const SessionForm({super.key, this.session});

  @override
  State<SessionForm> createState() => _SessionFormState();
}

class _SessionFormState extends State<SessionForm> {
  final _formKey = GlobalKey<FormState>();
  
  // Text editing controllers for input fields
  late TextEditingController _titleController;
  late TextEditingController _locationController;
  
  // Date and time state variables
  late DateTime _date;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late SessionType _type;
  
  // Track if times have been manually set to avoid auto-updating end time
  bool _endTimeManuallySet = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize controllers with existing data or empty strings
    _titleController = TextEditingController(text: widget.session?.title ?? '');
    _locationController = TextEditingController(text: widget.session?.location ?? '');

    // Initialize date/time values
    if (widget.session != null) {
      // Editing existing session
      _date = widget.session!.startTime;
      _startTime = TimeOfDay.fromDateTime(widget.session!.startTime);
      _endTime = TimeOfDay.fromDateTime(widget.session!.endTime);
      _type = widget.session!.type;
      _endTimeManuallySet = true;
    } else {
      // Creating new session - set smart defaults
      final now = DateTime.now();
      _date = now;
      
      // Round to next hour
      final nextHour = now.hour + 1;
      _startTime = TimeOfDay(hour: nextHour > 23 ? 23 : nextHour, minute: 0);
      
      // Default end time is 1 hour after start
      final endHour = nextHour + 1;
      _endTime = TimeOfDay(hour: endHour > 23 ? 23 : endHour, minute: 0);
      
      _type = SessionType.classSession;
    }
  }

  @override
  void dispose() {
    // Clean up controllers to prevent memory leaks
    _titleController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  /// Automatically updates end time to be 1 hour after start time
  /// Only if end time hasn't been manually set by the user
  void _updateEndTimeBasedOnStart() {
    if (_endTimeManuallySet) return;

    setState(() {
      final newEndHour = (_startTime.hour + 1) % 24;
      _endTime = TimeOfDay(hour: newEndHour, minute: _startTime.minute);
    });
  }

  /// Validates that end time is after start time
  /// Returns error message if invalid, null if valid
  String? _validateTimeOrder() {
    final startMinutes = _startTime.hour * 60 + _startTime.minute;
    final endMinutes = _endTime.hour * 60 + _endTime.minute;

    if (endMinutes <= startMinutes) {
      return 'End time must be after start time';
    }
    return null;
  }

  /// Combines a date and time into a single DateTime object
  DateTime _combineDateTime(DateTime date, TimeOfDay time) {
    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Form header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.session == null ? 'New Session' : 'Edit Session',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Title field (required)
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Session Title *',
                  hintText: 'e.g., Mobile Development Class',
                  prefixIcon: Icon(Icons.title),
                  border: OutlineInputBorder(),
                ),
                maxLength: 100,
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Title is required';
                  }
                  if (value.trim().length < 3) {
                    return 'Title must be at least 3 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Date picker
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime.now().subtract(const Duration(days: 30)),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    helpText: 'Select session date',
                  );
                  if (date != null) {
                    setState(() => _date = date);
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date *',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    DateFormat('EEEE, MMMM d, yyyy').format(_date),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Time pickers (start and end)
              Row(
                children: [
                  // Start time
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: _startTime,
                          helpText: 'Select start time',
                        );
                        if (time != null) {
                          setState(() {
                            _startTime = time;
                            _updateEndTimeBasedOnStart();
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Start Time *',
                          prefixIcon: Icon(Icons.access_time),
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          _startTime.format(context),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // End time
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: _endTime,
                          helpText: 'Select end time',
                        );
                        if (time != null) {
                          setState(() {
                            _endTime = time;
                            _endTimeManuallySet = true;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'End Time *',
                          prefixIcon: Icon(Icons.access_time_filled),
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          _endTime.format(context),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Session type dropdown
              DropdownButtonFormField<SessionType>(
                value: _type,
                decoration: const InputDecoration(
                  labelText: 'Session Type *',
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(),
                ),
                items: SessionType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.name.camelCaseToTitle()),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _type = value);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Location field (optional)
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location (Optional)',
                  hintText: 'e.g., Room 301, Online',
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(),
                ),
                maxLength: 100,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 24),

              // Save button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.save),
                label: Text(
                  widget.session == null ? 'Create Session' : 'Update Session',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: _saveSession,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  /// Validates and saves the session
  void _saveSession() {
    // Validate form fields
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate time order
    final timeError = _validateTimeOrder();
    if (timeError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(timeError),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    // Get AppState provider
    final appState = Provider.of<AppState>(context, listen: false);

    // Combine date and time into DateTime objects
    final startDateTime = _combineDateTime(_date, _startTime);
    final endDateTime = _combineDateTime(_date, _endTime);

    // Create or update session
    if (widget.session == null) {
      // Creating new session
      appState.addSession(AcademicSession(
        title: _titleController.text.trim(),
        location: _locationController.text.trim(),
        startTime: startDateTime,
        endTime: endDateTime,
        type: _type,
      ));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Session created successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      // Updating existing session
      appState.updateSession(AcademicSession(
        id: widget.session!.id,
        title: _titleController.text.trim(),
        location: _locationController.text.trim(),
        startTime: startDateTime,
        endTime: endDateTime,
        type: _type,
        isPresent: widget.session!.isPresent, // Preserve attendance status
      ));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Session updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }

    // Close the form
    Navigator.pop(context);
  }
}