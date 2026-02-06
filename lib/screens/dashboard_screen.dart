import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';
import '../theme/colors.dart';
import 'schedule_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final todaySessions = appState.getTodaysSessions();
    final attendancePercent = appState.getAttendancePercentage();
    final pendingToDos = appState.getPendingAssignmentsCount();
    final upcomingAssignments = appState.getAssignmentsDueNext7Days();

    // Map metrics to real data or sensible dummies
    // Box 1: Active Projects -> Total pending assignments
    final activeProjects = pendingToDos.toString();
    // Box 2: Code Fastocirs -> Maybe completed assignments this week? Or just a static/random number since it's unclear
    const codeFastocirs = "7"; 
    // Box 3: Upcoming Aganos -> Assignments due today/tomorrow?
    final upcomingAganos = upcomingAssignments.length.toString();

    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        centerTitle: true,
        leading: const Icon(Icons.arrow_back), // Dummy back arrow as in screenshot
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                   // Dropdown for Course Filtering
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
                        isExpanded: true,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                        items: ['All Selected Courses', ...appState.selectedCourses]
                            .map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white),
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
                  const SizedBox(height: 16),

                  // Risk Warning
                  if (attendancePercent < 75)
                    Container(
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
                          Text(
                            'AT RISK WARNING',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),

                  // 3 Stats Boxes
                  Row(
                    children: [
                      _buildMetricBox(activeProjects, 'Active\nProjects'),
                      const SizedBox(width: 8),
                      _buildMetricBox(codeFastocirs, 'Code\nfastocirs'), 
                      const SizedBox(width: 8),
                      _buildMetricBox(upcomingAganos, 'Upcoming\nAganos'), 
                    ],
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
                    
                    // Show 1st urgent assignment in the "ASSIGNMENT" card slot if any
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
                          title: Text(upcomingAssignments.first.title, style: const TextStyle(fontWeight: FontWeight.bold)), // Dynamic Title
                          subtitle: Text("Due ${DateFormat('MMM d').format(upcomingAssignments.first.dueDate)}"),
                          leading: const Icon(Icons.assignment, color: AppColors.primaryBlue),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          tileColor: AppColors.backgroundLight,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          onTap: () {
                             // Just for navigation, could go to Details
                          },
                        ),
                      )
                    else 
                       // Fallback static card if no assignments
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
                          title: const Text('No Pending Assignments', style: TextStyle(fontWeight: FontWeight.bold)),
                          tileColor: AppColors.backgroundLight,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      

                    // Functional list merged with design
                    if (todaySessions.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text("No classes scheduled today", style: TextStyle(color: Colors.grey)),
                      ),
                    
                    // Display actual scheduled sessions
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

  Widget _buildSimpleListTile(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildMetricBox(String number, String label) {
    return Expanded(
      child: Container(
        height: 100,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2A47), // Slightly lighter blue/navy
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
    );
  }
}
