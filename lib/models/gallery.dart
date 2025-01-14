// lib/models/gallery.dart

class GalleryPhoto {
  final int id;
  final DateTime date;
  final String url;
  final int confidenceScore;
  final String uploadBatch;

  GalleryPhoto({
    required this.id,
    required this.date,
    required this.url,
    required this.confidenceScore,
    required this.uploadBatch,
  });

  // Get the complete URL for the photo
  String get fullUrl => url.startsWith('http') ? url : '/storage$url';

  factory GalleryPhoto.fromJson(Map<String, dynamic> json) {
    return GalleryPhoto(
      id: json['id'],
      date: DateTime.parse(json['date']),
      url: json['url'],
      confidenceScore: json['confidence_score'],
      uploadBatch: json['upload_batch'],
    );
  }
}

class GalleryResponse {
  final int currentPage;
  final List<GalleryPhoto> photos;
  final int total;
  final int perPage;
  final int lastPage;

  GalleryResponse({
    required this.currentPage,
    required this.photos,
    required this.total,
    required this.perPage,
    required this.lastPage,
  });

  factory GalleryResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return GalleryResponse(
      currentPage: data['current_page'],
      photos: (data['data'] as List)
          .map((photo) => GalleryPhoto.fromJson(photo))
          .toList(),
      total: data['total'],
      perPage: data['per_page'],
      lastPage: data['last_page'],
    );
  }
}