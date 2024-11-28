class FeedbackAttachment {
  final int id;
  final String filePath;
  final String fileType;
  final int fileSize;

  FeedbackAttachment({
    required this.id,
    required this.filePath,
    required this.fileType,
    required this.fileSize,
  });

  factory FeedbackAttachment.fromJson(Map<String, dynamic> json) {
    return FeedbackAttachment(
      id: json['id'],
      filePath: json['file_path'],
      fileType: json['file_type'],
      fileSize: json['file_size'],
    );
  }
}