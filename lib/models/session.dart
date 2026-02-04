import 'package:uuid/uuid.dart';

enum SessionType { classSession, masterySession, studyGroup, pslMeeting }

class AcademicSession {
  final String id;
  String title;
  DateTime startTime;
  DateTime endTime;
  String location;
  SessionType type;
  bool isPresent;
  String? courseName;

  AcademicSession({
    String? id,
    required this.title,
    required this.startTime,
    required this.endTime,
    this.location = '',
    required this.type,
    this.isPresent = true,
    this.courseName,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'location': location,
      'type': type.index,
      'isPresent': isPresent,
      'courseName': courseName,
    };
  }

  factory AcademicSession.fromJson(Map<String, dynamic> json) {
    return AcademicSession(
      id: json['id'],
      title: json['title'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      location: json['location'] ?? '',
      type: SessionType.values[json['type'] ?? 0],
      isPresent: json['isPresent'] ?? true,
      courseName: json['courseName'],
    );
  }
}
