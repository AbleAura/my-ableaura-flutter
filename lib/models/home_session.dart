class HomeSession {
  final int id;
  final String? coach;  // Make coach nullable
  final String listing;
  final DateTime date;
  final String fromTime;
  final String toTime;
  final String status;
  final bool hasFeedback; // A

  HomeSession({
    required this.id,
    this.coach,
    required this.listing,
    required this.date,
    required this.fromTime,
    required this.toTime,
    required this.status,
    this.hasFeedback = false,
  });

  factory HomeSession.fromJson(Map<String, dynamic> json) {
    return HomeSession(
      id: json['id'],
      coach: json['coach'],
      listing: json['listing'],
      date: DateTime.parse(json['date']),
      fromTime: json['from_time'],
      toTime: json['to_time'],
      status: json['status'],
      hasFeedback: json['has_feedback'] ?? false,
    );
  }
}