class Session {
  final int id;
  final int studentId;
  final int sessionId;
  final int enrollmentId;  // Added this
  final String sessionName;
  final String startTime;
  final String endTime;

  Session({
    required this.id,
    required this.studentId,
    required this.sessionId,
    required this.enrollmentId,  // Added this
    required this.sessionName,
    required this.startTime,
    required this.endTime,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    final franchiseSession = json['franchise_session'];
    return Session(
      id: json['id'],
      studentId: json['student_id'],
      sessionId: json['session_id'],
      enrollmentId: json['id'],  // This is the enrollment_id from the response
      sessionName: franchiseSession['name'],
      startTime: franchiseSession['start_time'],
      endTime: franchiseSession['end_time'],
    );
  }
}