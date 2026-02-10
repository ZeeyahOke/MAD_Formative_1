import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/colors.dart';
import '../utils/email_validator.dart';
import 'home_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final Set<String> _selectedCourses = {};
    String? _emailErrorMessage;

  final List<String> _courses = [
    'Introduction to Linux',
    'Introduction to Python Programming',
    'Front End Web Development',
  ];

  @override
  void initState() {
    super.initState();
    // Add listener to validate email in real-time
    _emailController.addListener(_validateEmail);
  }

  @override
  void dispose() {
    _emailController.removeListener(_validateEmail);
    _emailController.dispose();
    super.dispose();
  }

  /// Validates the email input in real-time and updates error message.
  void _validateEmail() {
    setState(() {
      final email = _emailController.text;
      if (email.isEmpty) {
        _emailErrorMessage = null; // No error shown while field is empty
      } else if (EmailValidator.isValidAluStudentEmail(email)) {
        _emailErrorMessage = null; // Valid email, no error
      } else {
        _emailErrorMessage = EmailValidator.getErrorMessage(email);
      }
    });
  }

  /// Validates all form inputs before signup.
  bool _validateForm() {
    final email = _emailController.text;

    if (email.isEmpty) {
      setState(() {
        _emailErrorMessage = 'Email address is required';
      });
      return false;
    }

    // Validate email format and domain (client-side validation)
    if (!EmailValidator.isValidAluStudentEmail(email)) {
      setState(() {
        _emailErrorMessage = EmailValidator.getErrorMessage(email);
      });
      return false;
    }

    // Validate that at least one course is selected
    if (_selectedCourses.isEmpty) {
      _showErrorDialog(
        'Course Selection Required',
        'Please select at least one course to continue.',
      );
      return false;
    }
    return true;
  }

  /// Shows an error dialog to the user.
  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                // Logo/Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.settings,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Student Sign-Up',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),
                
                // Form Container
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          'Student Sign-Up',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Email Field
                      const Text(
                        'University Email',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: 'student@alueducation.com',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Course Selection
                      const Text(
                        'Select Your Courses',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._courses.map((course) => _buildCourseOption(course)),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                // Sign Up Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_emailController.text.isNotEmpty) {
                        final appState = Provider.of<AppState>(context, listen: false);
                        await appState.setUser(_emailController.text, _selectedCourses.toList());
                        appState.seedSampleData(); // Populate sample data based on selection
                      
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => const HomeScreen()),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter your email')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentYellow,
                      foregroundColor: AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Sign Up',
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
        ),
      ),
    );
  }

  Widget _buildCourseOption(String course) {
    final isSelected = _selectedCourses.contains(course);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          setState(() {
            if (isSelected) {
              _selectedCourses.remove(course);
            } else {
              _selectedCourses.add(course);
            }
          });
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryBlue : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.primaryBlue : AppColors.primaryBlue,
              width: 1,
            ),
          ),
          child: Text(
            course,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.primaryBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
