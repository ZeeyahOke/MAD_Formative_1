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

  List<Assignment> get assignments => List.unmodifiable(_assignments);
  List<AcademicSession> get sessions => List.unmodifiable(_sessions);
  String get username => _username;
  List<String> get selectedCourses => List.unmodifiable(_selectedCourses);
  String? get filteredCourse => _filteredCourse;

  void setCourseFilter(String? course) {
    _filteredCourse = course;
    notifyListeners();
  }

  AppState() {
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    _username = prefs.getString('username') ?? 'Student';
    _selectedCourses = prefs.getStringList('courses') ?? [];

    // Load Assignments
    final String? assignmentsString = prefs.getString('assignments');
    if (assignmentsString != null) {
      final List<dynamic> jsonList = json.decode(assignmentsString);
      _assignments = jsonList.map((json) => Assignment.fromJson(json)).toList();
    }

    // Load Sessions
    final String? sessionsString = prefs.getString('sessions');
    if (sessionsString != null) {
      final List<dynamic> jsonList = json.decode(sessionsString);
      _sessions = jsonList.map((json) => AcademicSession.fromJson(json)).toList();
    }
    
    notifyListeners();
  }

  Future<void> setUser(String email, List<String> courses) async {
    final prefs = await SharedPreferences.getInstance();
    // Extract name before @
    final namePart = email.split('@').first;
    // Capitalize
    _username = namePart.isEmpty ? 'Student' : "${namePart[0].toUpperCase()}${namePart.substring(1)}";
    _selectedCourses = courses;

    await prefs.setString('username', _username);
    await prefs.setStringList('courses', _selectedCourses);
    
    notifyListeners();
  }

  void seedSampleData() {
    if (_assignments.isNotEmpty || _sessions.isNotEmpty) return; // Don't overwrite if data exists

    final now = DateTime.now();
    
    // Sample Assignments based on courses - Extensive List for Realism
    // Linux
    if (_selectedCourses.contains('Introduction to Linux')) {
        _assignments.add(Assignment(title: 'Linux File Permissions', courseName: 'Introduction to Linux', dueDate: now.add(const Duration(days: 2)), priority: PriorityLevel.high));
        _assignments.add(Assignment(title: 'Shell Scripting Basics', courseName: 'Introduction to Linux', dueDate: now.add(const Duration(days: 5)), priority: PriorityLevel.medium, type: AssignmentType.summative));
        _assignments.add(Assignment(title: 'Vim Mastery', courseName: 'Introduction to Linux', dueDate: now.add(const Duration(days: 12)), priority: PriorityLevel.low));
        _assignments.add(Assignment(title: 'Process Management', courseName: 'Introduction to Linux', dueDate: now.add(const Duration(days: 1)), priority: PriorityLevel.high, type: AssignmentType.summative));
    }
    // Python
    if (_selectedCourses.contains('Introduction to Python Programming')) {
        _assignments.add(Assignment(title: 'Python Functions Quiz', courseName: 'Introduction to Python Programming', dueDate: now.add(const Duration(days: 1)), priority: PriorityLevel.high, type: AssignmentType.formative));
        _assignments.add(Assignment(title: 'Data Analysis Project', courseName: 'Introduction to Python Programming', dueDate: now.add(const Duration(days: 10)), priority: PriorityLevel.high, type: AssignmentType.summative));
        _assignments.add(Assignment(title: 'Pandas Library Intro', courseName: 'Introduction to Python Programming', dueDate: now.add(const Duration(days: 6)), priority: PriorityLevel.medium));
        _assignments.add(Assignment(title: 'NumPy Arrays Practice', courseName: 'Introduction to Python Programming', dueDate: now.add(const Duration(days: 3)), priority: PriorityLevel.low));
    }
    // Web Dev
     if (_selectedCourses.contains('Front End Web Development')) {
        _assignments.add(Assignment(title: 'HTML/CSS Portfolio', courseName: 'Front End Web Development', dueDate: now.add(const Duration(days: 3)), priority: PriorityLevel.medium));
        _assignments.add(Assignment(title: 'JavaScript Basics', courseName: 'Front End Web Development', dueDate: now.add(const Duration(days: 8)), priority: PriorityLevel.low, type: AssignmentType.formative));
        _assignments.add(Assignment(title: 'Responsive Design Lab', courseName: 'Front End Web Development', dueDate: now.add(const Duration(days: 2)), priority: PriorityLevel.high));
    }
    // Generic / Other
    _assignments.add(Assignment(title: 'Leadership Reflection', courseName: 'Leadership', dueDate: now.add(const Duration(days: 4))));
    _assignments.add(Assignment(title: 'Peer Review', courseName: 'Communication', dueDate: now.add(const Duration(days: 1))));
    _assignments.add(Assignment(title: 'Career Plan Draft', courseName: 'Career Development', dueDate: now.add(const Duration(days: 14)), priority: PriorityLevel.low));

    // Sample Sessions - Populating "Today" heavily
    // 09:00 - 10:30
    _sessions.add(AcademicSession(title: 'Morning Standup & Goal Setting', startTime: DateTime(now.year, now.month, now.day, 9, 0), endTime: DateTime(now.year, now.month, now.day, 10, 30), type: SessionType.pslMeeting, location: 'Room 101 - Main Hub', courseName: 'Leadership'));
    
    // 11:00 - 12:30 (Course based or generic)
    if (_selectedCourses.contains('Front End Web Development')) {
       _sessions.add(AcademicSession(title: 'Web Dev Lecture: CSS Grid', startTime: DateTime(now.year, now.month, now.day, 11, 0), endTime: DateTime(now.year, now.month, now.day, 12, 30), type: SessionType.classSession, location: 'Hall A', courseName: 'Front End Web Development'));
    } else {
       _sessions.add(AcademicSession(title: 'Guest Lecture: Tech Ethics', startTime: DateTime(now.year, now.month, now.day, 11, 0), endTime: DateTime(now.year, now.month, now.day, 12, 30), type: SessionType.classSession, location: 'Auditorium'));
    }

    // 14:00 - 16:00 (Lab)
    if (_selectedCourses.contains('Introduction to Python Programming')) {
      _sessions.add(AcademicSession(title: 'Python Lab: Pandas', startTime: DateTime(now.year, now.month, now.day, 14, 0), endTime: DateTime(now.year, now.month, now.day, 16, 0), type: SessionType.classSession, location: 'Computer Lab 3', courseName: 'Introduction to Python Programming'));
    } else if (_selectedCourses.contains('Introduction to Linux')) {
      _sessions.add(AcademicSession(title: 'Linux Lab: Scripting', startTime: DateTime(now.year, now.month, now.day, 14, 0), endTime: DateTime(now.year, now.month, now.day, 16, 0), type: SessionType.classSession, location: 'Computer Lab 1', courseName: 'Introduction to Linux'));
    } else {
       _sessions.add(AcademicSession(title: 'Independent Study', startTime: DateTime(now.year, now.month, now.day, 14, 0), endTime: DateTime(now.year, now.month, now.day, 16, 0), type: SessionType.masterySession, location: 'Library'));
    }
    
    // 16:30 - 17:30
    _sessions.add(AcademicSession(title: 'Peer Learning Circle', startTime: DateTime(now.year, now.month, now.day, 16, 30), endTime: DateTime(now.year, now.month, now.day, 17, 30), type: SessionType.masterySession, location: 'Breakout Room 4'));

    
    // Add some for future
    _sessions.add(AcademicSession(title: 'Project Review', startTime: now.add(const Duration(days: 1)), endTime: now.add(const Duration(days: 1)).add(const Duration(hours: 1)), type: SessionType.masterySession, location: 'Zoom'));
    _sessions.add(AcademicSession(title: 'Community Gathering', startTime: now.add(const Duration(days: 2)), endTime: now.add(const Duration(days: 2)).add(const Duration(hours: 1)), type: SessionType.classSession, location: 'Main Hall'));

    _saveData();
    notifyListeners();
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
    // Determine which sessions to count
    // If filtering by course, we ideally need to know which session belongs to which course.
    // Since Session model doesn't have courseName, simplistic approach:
    // We can't easily filter attendance by course without schema change.
    // For now, return global attendance or random variation if filter is on.
    
    if (_sessions.isEmpty) return 100.0;
    final pastSessions = _sessions.where((s) => s.endTime.isBefore(DateTime.now())).toList();
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
