class AttendanceCourse {
  final int id;
  final String name;
  final String? level;

  AttendanceCourse({
    required this.id,
    required this.name,
    this.level,
  });

  factory AttendanceCourse.fromJson(Map<String, dynamic> json) {
    return AttendanceCourse(
      id: json['id'],
      name: json['name'],
      level: json['level']?.toString(),
    );
  }
}

class AttendanceEnrollment {
  final int id;
  final int studentId;
  final AttendanceCourse course;

  AttendanceEnrollment({
    required this.id,
    required this.studentId,
    required this.course,
  });

  factory AttendanceEnrollment.fromJson(Map<String, dynamic> json) {
    return AttendanceEnrollment(
      id: json['id'],
      studentId: json['student_id'],
      course: AttendanceCourse.fromJson(json['course']),
    );
  }
}

class AttendanceRecord {
  final int id;
  final DateTime date;
  final bool present;
  final AttendanceEnrollment enrollment;

  AttendanceRecord({
    required this.id,
    required this.date,
    required this.present,
    required this.enrollment,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'],
      date: DateTime.parse(json['date']),
      present: json['present'] == 1,
      enrollment: AttendanceEnrollment.fromJson(json['enrollment']),
    );
  }
}