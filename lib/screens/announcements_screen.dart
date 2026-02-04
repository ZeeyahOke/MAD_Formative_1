import 'package:flutter/material.dart';
import '../theme/colors.dart';

class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      appBar: AppBar(
        title: const Text('Announcements'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAnnouncementCard(
            'Announcements',
            'Reminder: Project Deadlines',
            'Department of Software Engineering\nComming at deliverable beyond\nwill issue in', 
            // The text in the screenshot is a bit truncated/gibberish "lorem ipsum" style, 
            // but I'm copying what I see approximately.
          ),
          const SizedBox(height: 16),
          _buildAnnouncementCard(
            'Upcoming Industry Talk',
            'Farming arrow iny of 1/4 state',
            'your coursework',
          ),
          const SizedBox(height: 16),
           _buildAnnouncementCard(
            'Update for All Students',
            'See additional online cequrees',
            'for asstel in your coursework',
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementCard(String title, String subtitle, String body) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(
              color: Colors.grey,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
