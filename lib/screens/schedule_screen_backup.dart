import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';
import '../models/session.dart';
import '../theme/colors.dart';
import '../utils/string_extensions.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule'),
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          final sessions = appState.filteredSessions;

          if (sessions.isEmpty) {
            return const Center(child: Text("No sessions scheduled."));
          }

          // Group by Date for better view
          // Simple list for now, sorted by time
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final session = sessions[index];
              return Dismissible(
                key: Key(session.id),
                background: Container(
                  color: AppColors.danger,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  appState.removeSession(session.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Session removed')),
                  );
                },
                child: Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    DateFormat('MMM').format(session.startTime).toUpperCase(),
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                  Text(
                                    DateFormat('d').format(session.startTime),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: AppColors.primaryBlue
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    session.title,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${DateFormat('HH:mm').format(session.startTime)} - ${DateFormat('HH:mm').format(session.endTime)}',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                  Text(
                                    '${session.type.name.camelCaseToTitle()} • ${session.location}', 
                                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20),
                              onPressed: () => _showAddEditSession(context, session: session),
                            ),
                          ],
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Attendance:'),
                            ToggleButtons(
                              isSelected: [session.isPresent, !session.isPresent],
                              onPressed: (index) {
                                // 0 is Present, 1 is Absent
                                final newStatus = index == 0;
                                if (session.isPresent != newStatus) {
                                   appState.toggleAttendance(session.id);
                                }
                              },
                              borderRadius: BorderRadius.circular(8),
                              constraints: const BoxConstraints(minHeight: 30, minWidth: 80),
                              children: const [
                                Text('Present'),
                                Text('Absent'),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accentYellow,
        child: const Icon(Icons.add, color: AppColors.primaryBlue),
        onPressed: () => _showAddEditSession(context),
      ),
    );
  }

  void _showAddEditSession(BuildContext context, {AcademicSession? session}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SessionForm(session: session),
    );
  }
}

class SessionForm extends StatefulWidget {
  final AcademicSession? session;
  const SessionForm({super.key, this.session});

  @override
  State<SessionForm> createState() => _SessionFormState();
}

class _SessionFormState extends State<SessionForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _locationController;
  late DateTime _date;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late SessionType _type;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.session?.title ?? '');
    _locationController = TextEditingController(text: widget.session?.location ?? '');
    
    // Default to nearest hour
    final now = DateTime.now();
    _date = widget.session?.startTime ?? now;
    _startTime = widget.session != null 
        ? TimeOfDay.fromDateTime(widget.session!.startTime)
        : TimeOfDay(hour: now.hour + 1, minute: 0);
    _endTime = widget.session != null 
        ? TimeOfDay.fromDateTime(widget.session!.endTime)
        : TimeOfDay(hour: now.hour + 2, minute: 0);
        
    _type = widget.session?.type ?? SessionType.classSession;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    super.dispose();
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
              Text(
                widget.session == null ? 'New Session' : 'Edit Session',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location (Optional)'),
              ),
              const SizedBox(height: 16),
              
              // Date Picker
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime.now().subtract(const Duration(days: 30)),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() => _date = date);
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Date'),
                  child: Text(DateFormat('MMM d, yyyy').format(_date)),
                ),
              ),
              const SizedBox(height: 16),
              
              // Time Pickers
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final time = await showTimePicker(context: context, initialTime: _startTime);
                        if (time != null) setState(() => _startTime = time);
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Start Time'),
                        child: Text(_startTime.format(context)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final time = await showTimePicker(context: context, initialTime: _endTime);
                        if (time != null) setState(() => _endTime = time);
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'End Time'),
                        child: Text(_endTime.format(context)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Type Dropdown
              DropdownButtonFormField<SessionType>(
                value: _type,
                decoration: const InputDecoration(labelText: 'Session Type'),
                items: SessionType.values.map((t) {
                  return DropdownMenuItem(
                    value: t,
                    child: Text(t.name.camelCaseToTitle()),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _type = value!);
                },
              ),
              
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final appState = Provider.of<AppState>(context, listen: false);
                    
                    // Construct DateTimes
                    final startDateTime = DateTime(
                      _date.year, _date.month, _date.day, _startTime.hour, _startTime.minute
                    );
                    final endDateTime = DateTime(
                      _date.year, _date.month, _date.day, _endTime.hour, _endTime.minute
                    );

                    if (widget.session == null) {
                      appState.addSession(AcademicSession(
                        title: _titleController.text,
                        location: _locationController.text,
                        startTime: startDateTime,
                        endTime: endDateTime,
                        type: _type,
                      ));
                    } else {
                      appState.updateSession(AcademicSession(
                        id: widget.session!.id,
                        title: _titleController.text,
                        location: _locationController.text,
                        startTime: startDateTime,
                        endTime: endDateTime,
                        type: _type,
                        isPresent: widget.session!.isPresent,
                      ));
                    }
                    Navigator.pop(context);
                  }
                },
                child: const Text('Save Session'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
