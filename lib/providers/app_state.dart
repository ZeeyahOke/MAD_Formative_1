import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/assignment.dart';
import '../models/session.dart';

class AppState with ChangeNotifier {
  List<Assignment> _assignments = [];
  List<AcademicSession> _sessions = [];
  String _username = 'Student';
  List<String> _selectedCourses = [];
  String? _filteredCourse; // Null means "All"
  bool _isLoaded = false; // Prevent race conditions

  List<Assignment> get assignments => List.unmodifiable(_assignments);
  List<AcademicSession> get sessions => List.unmodifiable(_sessions);
  String get username => _username;
  List<String> get selectedCourses => List.unmodifiable(_selectedCourses);
  String? get filteredCourse => _filteredCourse;
  bool get isLoaded => _isLoaded;

  void setCourseFilter(String? course) {
    _filteredCourse = course;
    notifyListeners();
  }

  AppState() {
    _initData();
  }

  Future<void> _initData() async {
    final prefs = await SharedPreferences.getInstance();
    
    _username = prefs.getString('username') ?? 'Student';
    _selectedCourses = prefs.getStringList('courses') ?? [];

    // Load Assignments
    final String? assignmentsString = prefs.getString('assignments');
    if (assignmentsString != null && assignmentsString.isNotEmpty) {
      try {
        final List<dynamic> jsonList = json.decode(assignmentsString);
        _assignments = jsonList.map((j) => Assignment.fromJson(j)).toList();
      } catch (_) {
        _assignments = [];
      }
    }

    // Load Sessions
    final String? sessionsString = prefs.getString('sessions');
    if (sessionsString != null && sessionsString.isNotEmpty) {
      try {
        final List<dynamic> jsonList = json.decode(sessionsString);
        _sessions = jsonList.map((j) => AcademicSession.fromJson(j)).toList();
      } catch (_) {
        _sessions = [];
      }
    }

    _isLoaded = true;
    notifyListeners();
  }

  Future<void> setUser(String email, List<String> courses) async {
    final prefs = await SharedPreferences.getInstance();
    // Extract name before @
    final namePart = email.split('@').first;
    // Capitalize
    _username = namePart.isEmpty ? 'Student' : "${namePart[0].toUpperCase()}${namePart.substring(1)}";
    _selectedCourses = List<String>.from(courses); // Defensive copy
    _filteredCourse = null; // Reset filter

    // Save profile to prefs FIRST
    await prefs.setString('username', _username);
    await prefs.setStringList('courses', _selectedCourses);
    
    // Clear ALL existing data
    _assignments = [];
    _sessions = [];
    await prefs.remove('assignments');
    await prefs.remove('sessions');
    
    // Generate all sample data for selected courses
    _generateAllSampleData();
    
    // Persist everything
    await _saveData();
    _isLoaded = true;
    notifyListeners();
  }

  /// Synchronous method — no async gaps, no race conditions
  void _generateAllSampleData() {
    final now = DateTime.now();
    final courses = _selectedCourses;

    debugPrint('=== SEEDING DATA for courses: $courses ===');

    // ===================== LINUX =====================
    if (courses.any((c) => c.toLowerCase().contains('linux'))) {
      const cn = 'Introduction to Linux';
      debugPrint('Seeding Linux data...');

      // 10 Assignments
      _assignments.addAll([
        Assignment(title: 'Linux File Permissions', courseName: cn, dueDate: now.add(const Duration(days: 2)), priority: PriorityLevel.high),
        Assignment(title: 'Shell Scripting Basics', courseName: cn, dueDate: now.add(const Duration(days: 5)), priority: PriorityLevel.medium, type: AssignmentType.summative),
        Assignment(title: 'Vim Mastery', courseName: cn, dueDate: now.add(const Duration(days: 12)), priority: PriorityLevel.low),
        Assignment(title: 'Process Management', courseName: cn, dueDate: now.add(const Duration(days: 1)), priority: PriorityLevel.high, type: AssignmentType.summative),
        Assignment(title: 'Kernel Modules', courseName: cn, dueDate: now.subtract(const Duration(days: 1)), priority: PriorityLevel.high),
        Assignment(title: 'User Groups Setup', courseName: cn, dueDate: now.add(const Duration(days: 8)), priority: PriorityLevel.medium),
        Assignment(title: 'SSH Configuration', courseName: cn, dueDate: now.add(const Duration(days: 15)), priority: PriorityLevel.high, type: AssignmentType.formative),
        Assignment(title: 'Cron Job Scheduling', courseName: cn, dueDate: now.add(const Duration(days: 9)), priority: PriorityLevel.low),
        Assignment(title: 'Disk Partitioning', courseName: cn, dueDate: now.add(const Duration(days: 18)), priority: PriorityLevel.medium, type: AssignmentType.summative),
        Assignment(title: 'System Logs Analysis', courseName: cn, dueDate: now.subtract(const Duration(days: 4)), priority: PriorityLevel.medium),
      ]);

      // Sessions: Mon/Wed/Fri at 10:00, past 4 weeks + next 4 weeks
      _addRecurringSessions(cn, 'Linux Lecture', 'Lab 1', [1, 3, 5], 10, 0, now);
    }

    // ===================== PYTHON =====================
    if (courses.any((c) => c.toLowerCase().contains('python'))) {
      const cn = 'Introduction to Python Programming';
      debugPrint('Seeding Python data...');

      _assignments.addAll([
        Assignment(title: 'Python Functions Quiz', courseName: cn, dueDate: now.add(const Duration(days: 1)), priority: PriorityLevel.high, type: AssignmentType.formative),
        Assignment(title: 'Data Analysis Project', courseName: cn, dueDate: now.add(const Duration(days: 10)), priority: PriorityLevel.high, type: AssignmentType.summative),
        Assignment(title: 'Pandas Library Intro', courseName: cn, dueDate: now.add(const Duration(days: 6)), priority: PriorityLevel.medium),
        Assignment(title: 'NumPy Arrays Practice', courseName: cn, dueDate: now.add(const Duration(days: 3)), priority: PriorityLevel.low),
        Assignment(title: 'Matplotlib Charts', courseName: cn, dueDate: now.add(const Duration(days: 14)), priority: PriorityLevel.medium, type: AssignmentType.formative),
        Assignment(title: 'Web Scraping with BS4', courseName: cn, dueDate: now.add(const Duration(days: 8)), priority: PriorityLevel.high),
        Assignment(title: 'Flask API Basics', courseName: cn, dueDate: now.add(const Duration(days: 16)), priority: PriorityLevel.medium, type: AssignmentType.summative),
        Assignment(title: 'Unit Testing in Python', courseName: cn, dueDate: now.subtract(const Duration(days: 2)), priority: PriorityLevel.low),
        Assignment(title: 'Asyncio Deep Dive', courseName: cn, dueDate: now.add(const Duration(days: 20)), priority: PriorityLevel.high),
        Assignment(title: 'Django Models', courseName: cn, dueDate: now.add(const Duration(days: 25)), priority: PriorityLevel.medium),
      ]);

      // Sessions: Tue/Thu at 12:00
      _addRecurringSessions(cn, 'Python Programming', 'Lab 3', [2, 4], 12, 0, now);
    }

    // ===================== WEB DEV =====================
    if (courses.any((c) => c.toLowerCase().contains('web'))) {
      const cn = 'Front End Web Development';
      debugPrint('Seeding Web Dev data...');

      _assignments.addAll([
        Assignment(title: 'HTML/CSS Portfolio', courseName: cn, dueDate: now.add(const Duration(days: 3)), priority: PriorityLevel.medium),
        Assignment(title: 'JavaScript Basics', courseName: cn, dueDate: now.add(const Duration(days: 8)), priority: PriorityLevel.low, type: AssignmentType.formative),
        Assignment(title: 'Responsive Design Lab', courseName: cn, dueDate: now.add(const Duration(days: 2)), priority: PriorityLevel.high),
        Assignment(title: 'CSS Grid vs Flexbox', courseName: cn, dueDate: now.subtract(const Duration(days: 2)), priority: PriorityLevel.high),
        Assignment(title: 'React Components', courseName: cn, dueDate: now.add(const Duration(days: 12)), priority: PriorityLevel.high, type: AssignmentType.summative),
        Assignment(title: 'Accessibility Audit', courseName: cn, dueDate: now.add(const Duration(days: 5)), priority: PriorityLevel.medium, type: AssignmentType.formative),
        Assignment(title: 'React State Management', courseName: cn, dueDate: now.add(const Duration(days: 15)), priority: PriorityLevel.high, type: AssignmentType.summative),
        Assignment(title: 'Fetch API & JSON', courseName: cn, dueDate: now.add(const Duration(days: 10)), priority: PriorityLevel.medium),
        Assignment(title: 'Tailwind CSS Project', courseName: cn, dueDate: now.add(const Duration(days: 18)), priority: PriorityLevel.low),
        Assignment(title: 'Browser DevTools Quiz', courseName: cn, dueDate: now.subtract(const Duration(days: 5)), priority: PriorityLevel.low),
      ]);

      // Sessions: Mon/Wed at 14:00
      _addRecurringSessions(cn, 'Front End Workshop', 'Room 204', [1, 3], 14, 0, now);
    }

    debugPrint('=== SEEDING COMPLETE: ${_assignments.length} assignments, ${_sessions.length} sessions ===');
  }

  /// Synchronous session generator — no async, no race conditions
  void _addRecurringSessions(String courseName, String baseTitle, String location, List<int> daysOfWeek, int hour, int minute, DateTime now) {
    // Past 4 weeks — with mixed attendance
    for (int i = 1; i <= 28; i++) {
       final date = now.subtract(Duration(days: i));
       if (daysOfWeek.contains(date.weekday)) {
           final isPresent = (date.day % 4 != 0); // ~75% attendance
           _sessions.add(AcademicSession(
             title: '$baseTitle (${date.day}/${date.month})',
             startTime: DateTime(date.year, date.month, date.day, hour, minute),
             endTime: DateTime(date.year, date.month, date.day, hour + 1, minute + 30),
             type: SessionType.classSession,
             location: location,
             courseName: courseName,
             isPresent: isPresent,
           ));
       }
    }
    // Today + next 4 weeks
    for (int i = 0; i <= 28; i++) {
       final date = now.add(Duration(days: i));
       if (daysOfWeek.contains(date.weekday)) {
           _sessions.add(AcademicSession(
             title: '$baseTitle (${date.day}/${date.month})',
             startTime: DateTime(date.year, date.month, date.day, hour, minute),
             endTime: DateTime(date.year, date.month, date.day, hour + 1, minute + 30),
             type: SessionType.classSession,
             location: location,
             courseName: courseName,
           ));
       }
    }
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Save Assignments
    final String assignmentsString = json.encode(_assignments.map((a) => a.toJson()).toList());
    await prefs.setString('assignments', assignmentsString);

    // Save Sessions
    final String sessionsString = json.encode(_sessions.map((s) => s.toJson()).toList());
    await prefs.setString('sessions', sessionsString);
  }

  // --- Assignments ---

  void addAssignment(Assignment assignment) {
    _assignments.add(assignment);
    _sortAssignments();
    _saveData();
    notifyListeners();
  }

  void removeAssignment(String id) {
    _assignments.removeWhere((a) => a.id == id);
    _saveData();
    notifyListeners();
  }

  void toggleAssignmentCompletion(String id) {
    final index = _assignments.indexWhere((a) => a.id == id);
    if (index != -1) {
      _assignments[index].isCompleted = !_assignments[index].isCompleted;
      _saveData();
      notifyListeners();
    }
  }

  void updateAssignment(Assignment assignment) {
    final index = _assignments.indexWhere((a) => a.id == assignment.id);
    if (index != -1) {
      _assignments[index] = assignment;
      _sortAssignments();
      _saveData();
      notifyListeners();
    }
  }

  void _sortAssignments() {
    _assignments.sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  // --- Sessions ---

  void addSession(AcademicSession session) {
    _sessions.add(session);
    _sortSessions();
    _saveData();
    notifyListeners();
  }

  void removeSession(String id) {
    _sessions.removeWhere((s) => s.id == id);
    _saveData();
    notifyListeners();
  }

  void toggleAttendance(String id) {
    final index = _sessions.indexWhere((s) => s.id == id);
    if (index != -1) {
      _sessions[index].isPresent = !_sessions[index].isPresent;
      _saveData();
      notifyListeners();
    }
  }

   void updateSession(AcademicSession session) {
    final index = _sessions.indexWhere((s) => s.id == session.id);
    if (index != -1) {
      _sessions[index] = session;
      _sortSessions();
      _saveData();
      notifyListeners();
    }
  }


  void _sortSessions() {
    _sessions.sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  // --- Getters for Dashboard ---

  List<AcademicSession> getTodaysSessions() {
    final now = DateTime.now();
    return _sessions.where((s) {
      if (_filteredCourse != null && _filteredCourse != 'All Selected Courses') {
         if (s.courseName != null) {
             if (s.courseName != _filteredCourse) return false;
         } else {
             // Strict filtering: if it doesn't mention the course, hide it
             if (!s.title.contains(_filteredCourse!) && !s.location.contains(_filteredCourse!)) return false;
         }
      }
      return s.startTime.year == now.year &&
             s.startTime.month == now.month &&
             s.startTime.day == now.day;
    }).toList();
  }

  List<AcademicSession> get filteredSessions {
    return _sessions.where((s) {
      if (_filteredCourse != null && _filteredCourse != 'All Selected Courses') {
         if (s.courseName != null) {
             if (s.courseName != _filteredCourse) return false;
         } else {
             if (!s.title.contains(_filteredCourse!) && !s.location.contains(_filteredCourse!)) return false;
         }
      }
      return true;
    }).toList();
  }

  List<Assignment> getAssignmentsDueNext7Days() {
    final now = DateTime.now();
    final nextWeek = now.add(const Duration(days: 7));
    return _assignments.where((a) {
      if (_filteredCourse != null && _filteredCourse != 'All Selected Courses' && a.courseName != _filteredCourse) return false;
      return a.dueDate.isAfter(now.subtract(const Duration(days: 1))) && 
             a.dueDate.isBefore(nextWeek) && 
             !a.isCompleted;
    }).toList();
  }

  double getAttendancePercentage() {
    // Filter sessions first based on the active course filter
    final filteredSessions = _sessions.where((s) {
      if (_filteredCourse != null && _filteredCourse != 'All Selected Courses') {
         if (s.courseName != null) {
             if (s.courseName != _filteredCourse) return false;
         } else {
             // Fallback: strict text match if courseName is missing
             if (!s.title.contains(_filteredCourse!) && !s.location.contains(_filteredCourse!)) return false;
         }
      }
      return true;
    }).toList();

    if (filteredSessions.isEmpty) return 100.0; // Default to 100% if no sessions found (e.g., start of term)
    
    // Only count sessions that have already occurred (in the past)
    final pastSessions = filteredSessions.where((s) => s.endTime.isBefore(DateTime.now())).toList();
    
    if (pastSessions.isEmpty) return 100.0;
    
    final presentCount = pastSessions.where((s) => s.isPresent).length;
    return (presentCount / pastSessions.length) * 100;
  }
  
  int getPendingAssignmentsCount() {
    return _assignments.where((a) {
       if (_filteredCourse != null && _filteredCourse != 'All Selected Courses' && a.courseName != _filteredCourse) return false;
       return !a.isCompleted; 
    }).length;
  }
}
