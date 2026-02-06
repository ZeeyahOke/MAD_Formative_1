import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/colors.dart';

class RiskStatusScreen extends StatelessWidget {
  const RiskStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final username = appState.username; // Get dynamic username
    final attendance = appState.getAttendancePercentage();

    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      appBar: AppBar(
        title: const Text('Your Risk Status'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        leading: const Icon(Icons.arrow_back),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(
              'Hello $username At Risk', // Dynamic Name
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),

            // 3 Color Boxes
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildRiskBox('${attendance.toStringAsFixed(0)}%',
                    AppColors.danger, 'Attendance'),
                const SizedBox(width: 16),
                _buildRiskBox('60%', AppColors.accentYellow,
                    'Assignment to\nStlamment'), // Dummy static for now as no logic defined
                const SizedBox(width: 16),
                _buildRiskBox(
                    '63%', AppColors.danger, 'Average\nExsite'), // Dummy static
              ],
            ),

            const SizedBox(height: 60),

            // Get Help Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentYellow,
                  foregroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Get Help',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
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
