import 'package:flutter/material.dart';
import '../theme/colors.dart';
import 'dashboard_screen.dart';
import 'assignments_screen.dart';
import 'schedule_screen.dart'; // Keep schedule screen logic but might not be in nav bar based on screenshot 5 items?
// Screenshot 5 items are: Dashboard, Assignments, Announcements, Risk Status?
// Actually the screenshot shows 4 tabs in bottom nav:
// 1. Dashboard icon
// 2. Assignments icon (box with check)
// 3. Announcements/Message icon
// 4. Person/Risk icon?
// The 4th screenshot is "Announcements". 5th is "Risk Status".
// Waiting on closer inspection of bottom bar.
// Screenshot 2 (Dashboard) shows visible bottom nav with 4 items:
// 1. Grid/Window icon (Dashboard)
// 2. List/Doc icon (Assignments)
// 3. Chat/Message icon (Announcements?)
// 4. Warning/Bell icon? (Risk)
 
import 'announcements_screen.dart';
import 'risk_status_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const AssignmentsScreen(),
    const AnnouncementsScreen(),
    const RiskStatusScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
           canvasColor: AppColors.primaryBlue, // Dark background for nav bar
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment),
              label: 'Assignments',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              label: 'Announcements',
            ),
             BottomNavigationBarItem(
              icon: Icon(Icons.warning_amber),
              label: 'Risk Status',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: AppColors.accentYellow,
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.primaryBlue,
          elevation: 0,
        ),
      ),
    );
  }
}
