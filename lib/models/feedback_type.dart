// lib/models/feedback_type.dart
class FeedbackType {
  final int id;
  final String name;

  FeedbackType({
    required this.id,
    required this.name,
  });

  factory FeedbackType.fromJson(Map<String, dynamic> json) {
    return FeedbackType(
      id: json['id'],
      name: json['name'],
    );
  }
}

