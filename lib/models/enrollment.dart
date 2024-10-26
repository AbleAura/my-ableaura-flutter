class Enrollment {
  final int id;
  final int studentId;
  final int courseId;
  final int franchiseId;
  final String courseName;
  final String franchiseName;
  final String centerName;

  Enrollment({
    required this.id,
    required this.studentId,
    required this.courseId,
    required this.franchiseId,
    required this.courseName,
    required this.franchiseName,
    required this.centerName,
  });

  factory Enrollment.fromJson(Map<String, dynamic> json) {
    return Enrollment(
      id: json['id'],
      studentId: json['student_id'],
      courseId: json['course_id'],
      franchiseId: json['franchise_id'],
      courseName: json['course']['name'],
      franchiseName: json['franchise']['franchise_name'],
      centerName: json['franchise']['center']['name'],
    );
  }

  // Add toString for debugging
  @override
  String toString() {
    return 'Enrollment(id: $id, franchiseId: $franchiseId, franchiseName: $franchiseName)';
  }
}