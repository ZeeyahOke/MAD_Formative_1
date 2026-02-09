import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';
import '../theme/colors.dart';
import 'schedule_screen.dart';
import 'assignments_screen.dart';

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
    final upcomingCount = upcomingAssignments.length.toString();

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
                  color: Colors.white.withOpacity(0.1),
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
                            color: Colors.white.withOpacity(0.8),
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
                          value: appState.filteredCourse ?? 'All Selected Courses',
                          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                          isExpanded: false,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          items: ['All Selected Courses', ...appState.selectedCourses]
                              .map((String value) {
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
                          }).toList(),
                          onChanged: (newValue) {
                            if (newValue != null) {
                              appState.setCourseFilter(newValue);
                            }
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
                  _buildMetricBox(activeProjects, 'Pending\nTasks'),
                  const SizedBox(width: 8),
                  _buildMetricBox(attendanceString, 'Overall\nAttendance'), 
                  const SizedBox(width: 8),
                  _buildMetricBox(upcomingCount, 'Due\nSoon'), 
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
                    
                    // Show 1st urgent assignment if any
                    if (upcomingAssignments.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0,2))
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          title: Text(upcomingAssignments.first.title, style: const TextStyle(fontWeight: FontWeight.bold)), 
                          subtitle: Text("Due ${DateFormat('MMM d').format(upcomingAssignments.first.dueDate)}"),
                          leading: const Icon(Icons.assignment, color: AppColors.primaryBlue),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          tileColor: AppColors.backgroundLight,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          onTap: () {
                            Navigator.push(
                               context,
                               MaterialPageRoute(builder: (context) => const AssignmentsScreen()),
                             );
                          },
                        ),
                      ),

                    // Display actual scheduled sessions
                    if (todaySessions.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text("No classes scheduled today", style: TextStyle(color: Colors.grey)),
                      ),
                    
                    ...todaySessions.map((s) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        tileColor: AppColors.backgroundLight,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        title: Text(s.title, style: const TextStyle(fontWeight: FontWeight.w500)),
                        subtitle: Text('${DateFormat('HH:mm').format(s.startTime)} - ${s.location}'),
                        trailing: Icon(s.isPresent ? Icons.check_circle : Icons.circle_outlined, 
                          color: s.isPresent ? AppColors.success : Colors.grey),
                      ),
                    )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricBox(String number, String label) {
    return Expanded(
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
