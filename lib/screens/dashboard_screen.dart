import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const int attendance = 80;
    final bool atRisk = attendance < 75;

    // Sample data
    final List<Map<String, String>> todaysClasses = [
      {'title': 'Programming in C#', 'time': '9:30 AM - 11:00 AM'},
      {
        'title': 'Mobile Application Development',
        'time': '11:00 AM - 12:30 PM'
      },
      {'title': 'VIS Immersion Skills', 'time': '2:00 PM - 4:00 PM'},
    ];

    final List<Map<String, String>> assignmentsDue = [
      {'title': 'W1_Pre Reading', 'due': 'Wed 3rd'},
      {'title': 'Formative_Assignment_1', 'due': 'Fri 5th'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF071A3D), // dark navy
      appBar: AppBar(
        backgroundColor: const Color(0xFF071A3D),
        elevation: 0,
        title: const Text(
          'Dashboard',
          style: TextStyle(color: Colors.white),
        ),
        leading: const Icon(Icons.arrow_back, color: Colors.white),
        actions: const [Icon(Icons.person_outline, color: Colors.white)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date & Week
            const Text(
              'January 1, 2026 • Week 1',
              style: TextStyle(color: Color(0xFFB0C4DE), fontSize: 14),
            ),
            const SizedBox(height: 20),

            // Risk Warning
            if (atRisk)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE53935),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.warning_amber, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'AT RISK WARNING',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // Stats Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _statCard('Attendance', '$attendance%'),
                _statCard('Pending', '${assignmentsDue.length}'),
                _statCard('Sessions', '${todaysClasses.length}'),
              ],
            ),

            const SizedBox(height: 24),

            // Today's Classes
            const Text(
              'Today\'s Classes',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...todaysClasses
                .map((cls) => _classCard(cls['title']!, cls['time']!)),

            const SizedBox(height: 24),

            // Assignments Due
            const Text(
              'Assignments Due (Next 7 Days)',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...assignmentsDue
                .map((a) => _assignmentCard(a['title']!, a['due']!)),
          ],
        ),
      ),
    );
  }

  // Reusable widgets
  static Widget _statCard(String label, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0E2A5A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: Color(0xFFB0C4DE), fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _classCard(String title, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0E2A5A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(time, style: const TextStyle(color: Color(0xFFB0C4DE))),
        ],
      ),
    );
  }

  static Widget _assignmentCard(String title, String due) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0E2A5A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          Text(due, style: const TextStyle(color: Color(0xFFB0C4DE))),
        ],
      ),
    );
  }
}
