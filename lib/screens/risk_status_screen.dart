import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';
import '../theme/colors.dart';
import '../models/session.dart';

class RiskStatusScreen extends StatelessWidget {
  const RiskStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final username = appState.username; 
    final attendance = appState.getAttendancePercentage();
    final isAtRisk = attendance < 75;

    // Get past sessions for history
    final pastSessions = appState.filteredSessions
        .where((s) => s.endTime.isBefore(DateTime.now()))
        .toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime)); // Newest first

    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      appBar: AppBar(
        title: const Text('Attendance History'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Text(
                  isAtRisk ? 'Warning: At Risk' : 'On Track', 
                  style: TextStyle(
                    color: isAtRisk ? AppColors.danger : AppColors.success,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Hello $username, your attendance is ${attendance.toStringAsFixed(1)}%',
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 24),

                // Stats Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildRiskBox('${attendance.toStringAsFixed(0)}%',
                        isAtRisk ? AppColors.danger : AppColors.success, 'Attendance'),
                    const SizedBox(width: 16),
                    _buildRiskBox('${pastSessions.where((s) => s.isPresent).length}', 
                        Colors.blueGrey, 'Sessions\nAttended'),
                    const SizedBox(width: 16),
                    _buildRiskBox('${pastSessions.length - pastSessions.where((s) => s.isPresent).length}', 
                        AppColors.warning, 'Sessions\nMissed'),
                  ],
                ),
              ],
            ),
          ),
          
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: pastSessions.isEmpty 
                  ? const Center(child: Text("No past sessions recorded."))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: pastSessions.length,
                      itemBuilder: (context, index) {
                        final session = pastSessions[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: session.isPresent 
                                    ? Colors.grey.withOpacity(0.2) 
                                    : AppColors.danger.withOpacity(0.5)
                            ),
                            boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0,2))
                          ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: session.isPresent ? AppColors.success.withOpacity(0.1) : AppColors.danger.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                session.isPresent ? Icons.check : Icons.close,
                                color: session.isPresent ? AppColors.success : AppColors.danger,
                              ),
                            ),
                            title: Text(
                              session.title,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today, size: 12, color: Colors.grey[600]),
                                    const SizedBox(width: 4),
                                    Text(
                                      DateFormat('MMM d, yyyy • HH:mm').format(session.startTime),
                                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                    ),
                                  ],
                                ),
                                if (session.courseName != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2.0),
                                    child: Text(
                                      session.courseName!,
                                      style: TextStyle(color: AppColors.primaryBlue.withOpacity(0.7), fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                              ],
                            ),
                            trailing: Switch(
                              value: session.isPresent,
                              activeThumbColor: AppColors.success,
                              onChanged: (val) {
                                // Allow correcting history
                                appState.toggleAttendance(session.id);
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskBox(String percentage, Color color, String label) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            percentage,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
