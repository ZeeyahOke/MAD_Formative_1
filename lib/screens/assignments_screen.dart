import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';
import '../models/assignment.dart';
import '../theme/colors.dart';

class AssignmentsScreen extends StatelessWidget {
  const AssignmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.primaryBlue, // Dark background
        appBar: AppBar(
          title: const Text('Assignments'),
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          leading: const Icon(Icons.arrow_back), // Match screenshot
          bottom: const TabBar(
            indicatorColor: AppColors.accentYellow,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'Formative'),
              Tab(text: 'Summative'),
            ],
          ),
        ),
        body: Column(
          children: [
             Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => _showAddEditAssignment(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentYellow,
                    foregroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Create Group Assignment', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ),
            Expanded(
              child: Container(
                 // Using white background for list container if preferred, 
                 // or just cards on blue. Screenshot 3 looks like cards on blue/dark.
                 // Actually looking closer at image 3, the list area seems to be on dark blue background too.
                 // The cards are white rounded rectangles.
                child: TabBarView(
                  children: [
                    _buildAssignmentList(context, AssignmentType.all),
                    _buildAssignmentList(context, AssignmentType.formative),
                    _buildAssignmentList(context, AssignmentType.summative),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignmentList(BuildContext context, AssignmentType filterType) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final allAssignments = appState.assignments;
        
        final assignments = filterType == AssignmentType.all 
            ? allAssignments 
            : allAssignments.where((a) => a.type == filterType).toList();
        
        // Dummy data if empty to match screenshot appearance
        if (assignments.isEmpty && allAssignments.isEmpty) {
           // We can render dummy cards to show the design if the list is empty
           // But logically we should show the "No assignments" text.
           // However user asked to "do the same design".
           // Let's stick to functional list.
        }

        if (assignments.isEmpty) {
          return Center(child: Text("No ${filterType == AssignmentType.all ? '' : filterType.name} assignments.", style: const TextStyle(color: Colors.white70)));
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: assignments.length,
          itemBuilder: (context, index) {
            final assignment = assignments[index];
            return Dismissible(
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
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ASSIGNMENT ${index + 1}', // Mimic "ASSIGNMENT 1" header
                        style: const TextStyle(
                          fontSize: 10, 
                          color: Colors.grey, 
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        assignment.title,
                        style: TextStyle(
                          decoration: assignment.isCompleted ? TextDecoration.lineThrough : null,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Due ${DateFormat('MMM d').format(assignment.dueDate)}',
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  trailing: (assignment.type == AssignmentType.formative) // Mimic the "Remmedial" label look if specific type
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFBE4A0), // Light yellow/beige
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('Remedial', style: TextStyle(color: Color(0xFF8D6E63), fontSize: 10, fontWeight: FontWeight.bold)),
                        )
                      : const Icon(Icons.chevron_right),
                  onTap: () => _showAddEditAssignment(context, assignment: assignment),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPriorityChip(PriorityLevel priority) {
    Color color;
    String label;
    switch (priority) {
      case PriorityLevel.high:
        color = AppColors.danger;
        label = 'High';
        break;
      case PriorityLevel.medium:
        color = AppColors.warning;
        label = 'Med';
        break;
      case PriorityLevel.low:
        color = AppColors.success;
        label = 'Low';
        break;
    }
    return Chip(
      label: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      backgroundColor: color,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }

  void _showAddEditAssignment(BuildContext context, {Assignment? assignment}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AssignmentForm(assignment: assignment),
    );
  }
}

class AssignmentForm extends StatefulWidget {
  final Assignment? assignment;
  const AssignmentForm({super.key, this.assignment});

  @override
  State<AssignmentForm> createState() => _AssignmentFormState();
}

class _AssignmentFormState extends State<AssignmentForm> {
  final _formKey = GlobalKey<FormState>();
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

  @override
  void dispose() {
    _titleController.dispose();
    _courseController.dispose();
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.assignment == null ? 'New Assignment' : 'Edit Assignment',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (value) => value!.isEmpty ? 'Required' : null,
            ),
            TextFormField(
              controller: _courseController,
              decoration: const InputDecoration(labelText: 'Course Name'),
              validator: (value) => value!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InkWell(
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
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<PriorityLevel>(
                    value: _priority,
                    decoration: const InputDecoration(labelText: 'Priority'),
                    items: PriorityLevel.values.map((p) {
                      return DropdownMenuItem(
                        value: p,
                        child: Text(p.name.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _priority = value!);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<AssignmentType>(
              value: _type,
              decoration: const InputDecoration(labelText: 'Assessment Type'),
              items: [AssignmentType.formative, AssignmentType.summative].map((t) {
                return DropdownMenuItem(
                  value: t,
                  child: Text(t.name.toUpperCase()),
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
                  if (widget.assignment == null) {
                    appState.addAssignment(Assignment(
                      title: _titleController.text,
                      courseName: _courseController.text,
                      dueDate: _dueDate,
                      priority: _priority,
                      type: _type,
                    ));
                  } else {
                    appState.updateAssignment(Assignment(
                      id: widget.assignment!.id,
                      title: _titleController.text,
                      courseName: _courseController.text,
                      dueDate: _dueDate,
                      priority: _priority,
                      type: _type,
                      isCompleted: widget.assignment!.isCompleted,
                    ));
                  }
                  Navigator.pop(context);
                }
              },
              child: const Text('Save Assignment'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
