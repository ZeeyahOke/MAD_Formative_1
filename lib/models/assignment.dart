import 'package:uuid/uuid.dart';

enum PriorityLevel { low, medium, high }
enum AssignmentType { all, formative, summative }

class Assignment {
  final String id;
  String title;
  DateTime dueDate;
  String courseName;
  PriorityLevel priority;
  AssignmentType type;
  bool isCompleted;

  Assignment({
    String? id,
    required this.title,
    required this.dueDate,
    required this.courseName,
    this.priority = PriorityLevel.medium,
    this.type = AssignmentType.formative,
    this.isCompleted = false,
  }) : id = id ?? const Uuid().v4();

  // For JSON serialization (SharedPrefs)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'dueDate': dueDate.toIso8601String(),
      'courseName': courseName,
      'priority': priority.index,
      'type': type.index,
      'isCompleted': isCompleted,
    };
  }

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['id'],
      title: json['title'],
      dueDate: DateTime.parse(json['dueDate']),
      courseName: json['courseName'],
      priority: PriorityLevel.values[json['priority'] ?? 1],
      type: AssignmentType.values[json['type'] ?? 1],
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}
