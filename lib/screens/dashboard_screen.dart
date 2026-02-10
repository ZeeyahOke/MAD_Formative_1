import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';
import '../theme/colors.dart';
import 'schedule_screen.dart';
import 'assignments_screen.dart';
import 'risk_status_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final todaySessions = appState.getTodaysSessions();
    final attendancePercent = appState.getAttendancePercentage();
    final pendingToDos = appState.getPendingAssignmentsCount();
    final upcomingAssignments = appState.getAssignmentsDueNext7Days(); 

    // Map metrics to real data
    final activeProjects = pendingToDos.toString();
    final attendanceString = "${attendancePercent.toStringAsFixed(0)}%"; 
    
    // Upcoming Classes Logic
    final upcomingClasses = appState.filteredSessions.where((s) => s.startTime.isAfter(DateTime.now())).toList();
    final upcomingClassesCount = upcomingClasses.length.toString();

    // Date formatting
    final now = DateTime.now();
    final currentDate = DateFormat('MMM d, yyyy').format(now);
    final academicWeek = "Week ${((now.day / 7).ceil())}"; 

    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with date and academic week
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentDate,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Academic Week $academicWeek",
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    // Course filter dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white30),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          dropdownColor: AppColors.primaryBlue,
                          value: appState.filteredCourse,
                          hint: const Text("All Selected Courses", style: TextStyle(color: Colors.white)),
                          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                          isExpanded: false,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          items: [
                            const DropdownMenuItem<String>(
                              value: null, 
                              child: Text('All Selected Courses', style: TextStyle(color: Colors.white))
                            ),
                            ...appState.selectedCourses.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 150),
                                child: Text(
                                  value,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            );
                          })], 
                          onChanged: (newValue) {
                             appState.setCourseFilter(newValue);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Risk Warning (only shows if attendance < 75%)
            if (attendancePercent < 75)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.danger,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.white),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'AT RISK WARNING: Attendance below 75%',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            
            const SizedBox(height: 16),

            // 3 Stats Boxes 
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  _buildMetricBox(
                    activeProjects, 
                    'Pending\nTasks',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AssignmentsScreen()),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildMetricBox(
                    attendanceString, 
                    'Overall\nAttendance', 
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RiskStatusScreen()),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildMetricBox(
                    upcomingClassesCount, 
                    'Upcoming\nClasses',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ScheduleScreen(scrollToUpcoming: true)),
                      );
                    },
                  ), 
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // White Section
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Today's Classes",
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                             Navigator.push(
                               context,
                               MaterialPageRoute(builder: (context) => const ScheduleScreen()),
                             );
                          },
                          child: const Text('See All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Show UP TO 3 upcoming assignments
                    if (upcomingAssignments.isNotEmpty)
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                               Text("Upcoming Deadlines", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700])),
                               GestureDetector(
                                 onTap: () {
                                   Navigator.push(
                                     context,
                                     MaterialPageRoute(builder: (context) => const AssignmentsScreen()),
                                   );
                                 },
                                 child: Text("(${upcomingAssignments.length}) See All", style: const TextStyle(color: AppColors.primaryBlue, fontSize: 12)),
                               )
                            ],
                          ),
                          const SizedBox(height: 8),

                          ...upcomingAssignments.take(3).map((assignment) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.withOpacity(0.1)),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0,2))
                                ],
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                title: Text(assignment.title, style: const TextStyle(fontWeight: FontWeight.bold)), 
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(assignment.courseName, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                    const SizedBox(height: 2),
                                    Text(
                                      "Due ${DateFormat('MMM d').format(assignment.dueDate)}",
                                      style: TextStyle(
                                        color: assignment.dueDate.difference(DateTime.now()).inDays < 2 
                                            ? AppColors.danger 
                                            : Colors.grey[600],
                                        fontWeight: FontWeight.w500
                                      )
                                    ),
                                  ],
                                ),
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: AppColors.backgroundLight,
                                    shape: BoxShape.circle
                                  ),
                                  child: const Icon(Icons.assignment, color: AppColors.primaryBlue, size: 20),
                                ),
                                trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                                onTap: () {
                                  Navigator.push(
                                     context,
                                     MaterialPageRoute(builder: (context) => const AssignmentsScreen()),
                                   );
                                },
                              ),
                            );
                          }),
                        ],
                      ),
                      
                    // Display actual scheduled sessions
                    if (todaySessions.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text("No classes scheduled today", style: TextStyle(color: Colors.grey)),
                      ),
                    
                    ...todaySessions.map((s) {
                      final isPast = s.endTime.isBefore(DateTime.now());
                      final isActive = !isPast && s.startTime.isBefore(DateTime.now());
                      
                      return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        tileColor: AppColors.backgroundLight,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        leading: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              DateFormat('HH:mm').format(s.startTime),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            Text(
                              DateFormat('HH:mm').format(s.endTime),
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ),
                        title: Text(s.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (s.courseName != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 2.0),
                                child: Text(
                                  s.courseName!, 
                                  style: TextStyle(color: AppColors.primaryBlue.withValues(alpha: 0.8), fontSize: 12, fontWeight: FontWeight.w500)
                                ),
                              ),
                             const SizedBox(height: 2),
                             Row(
                               children: [
                                 const Icon(Icons.location_on, size: 12, color: Colors.grey),
                                 const SizedBox(width: 4),
                                 Expanded(child: Text(s.location, style: const TextStyle(fontSize: 12, color: Colors.grey))),
                                 if (isActive)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.success,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text('NOW', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                                    )
                                 else if (!isPast)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.accentYellow,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text('UPCOMING', style: TextStyle(color: AppColors.primaryBlue, fontSize: 9, fontWeight: FontWeight.bold)),
                                    ),
                               ],
                             ),
                          ],
                        ),
                        trailing: Icon(s.isPresent ? Icons.check_circle : Icons.circle_outlined, 
                          color: s.isPresent ? AppColors.success : Colors.grey),
                      ),
                    );
                    }),
                    
                    const SizedBox(height: 24),

                    // Assignments Due Next 7 Days Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                         Text(
                          "Due Within 7 Days",
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                               context,
                               MaterialPageRoute(builder: (context) => const AssignmentsScreen()),
                             );
                          },
                          child: const Text('See All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    if (upcomingAssignments.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.0),
                        child: Center(
                          child: Text(
                            "No immediate deadlines.\nGood job staying on top!",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),

                    ...upcomingAssignments.map((a) {
                      final daysLeft = a.dueDate.difference(DateTime.now()).inDays;
                      String dueText = 'Due ${DateFormat('MMM d').format(a.dueDate)}';
                       if (daysLeft < 0) {
                         dueText = 'Overdue';
                       } else if (daysLeft == 0) {
                         dueText = 'Due Today';
                       } else if (daysLeft == 1) {
                         dueText = 'Due Tomorrow';
                       } else {
                         dueText = 'Due in $daysLeft days';
                       }

                      return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                         boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0,2))
                          ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
                          child: const Icon(Icons.assignment_outlined, color: AppColors.primaryBlue),
                        ),
                        title: Text(
                          a.title, 
                          style: TextStyle(
                            fontWeight: FontWeight.w600, 
                            decoration: a.isCompleted ? TextDecoration.lineThrough : null,
                            color: a.isCompleted ? Colors.grey : Colors.black87,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(a.courseName, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                            const SizedBox(height: 2),
                            Text(
                              dueText,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: daysLeft <= 1 ? AppColors.danger : AppColors.warning,
                              ),
                            ),
                          ],
                        ),
                        trailing: Checkbox(
                          value: a.isCompleted,
                          activeColor: AppColors.primaryBlue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          onChanged: (bool? value) {
                            appState.toggleAssignmentCompletion(a.id);
                          },
                        ),
                      ),
                    );
                    }),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricBox(String number, String label, {VoidCallback? onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 100,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2A47), 
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
