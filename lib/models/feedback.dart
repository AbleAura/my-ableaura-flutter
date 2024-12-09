import 'feedback_attachment.dart';
import 'feedback_type.dart';

class FeedbackModel {
  final int id;
  final int feedbackTypeId;
  final String title;
  final String? description;
  final String? voiceNotePath;
  final String status;
  final List<FeedbackAttachment> attachments;
  final DateTime createdAt;
  final FeedbackType? feedbackType;  // Make this nullable

  FeedbackModel({
    required this.id,
    required this.feedbackTypeId,
    required this.title,
    this.description,
    this.voiceNotePath,
    required this.status,
    required this.attachments,
    required this.createdAt,
    this.feedbackType,  // Make this optional
  });

  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    return FeedbackModel(
      id: json['id'],
      feedbackTypeId: json['feedback_type_id'],
      title: json['title'],
      description: json['description'],
      voiceNotePath: json['voice_note_path'],
      status: json['status'],
      attachments: (json['attachments'] as List?)
          ?.map((x) => FeedbackAttachment.fromJson(x))
          .toList() ?? [],
      createdAt: DateTime.parse(json['created_at']),
      feedbackType: json['feedback_type'] != null 
          ? FeedbackType.fromJson(json['feedback_type'])
          : null,  // Handle null feedback_type
    );
  }
}