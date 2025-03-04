// lib/models/gallery_image.dart
class FranchiseGallery {
  final String title;
  final String description;
  final int franchiseId;
  final String franchiseName;
  final String createdAt;
  final List<GalleryImage> images;
  final int imageCount;

  FranchiseGallery({
    required this.title,
    required this.description,
    required this.franchiseId,
    required this.franchiseName,
    required this.createdAt,
    required this.images,
    required this.imageCount,
  });

  factory FranchiseGallery.fromJson(Map<String, dynamic> json) {
    return FranchiseGallery(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      franchiseId: json['franchise_id'] ?? 0,
      franchiseName: json['franchise_name'] ?? 'Unknown',
      createdAt: json['created_at'] ?? '',
      images: (json['images'] as List<dynamic>?)
          ?.map((image) => GalleryImage.fromJson(image))
          .toList() ?? [],
      imageCount: json['image_count'] ?? 0,
    );
  }
}

class GalleryImage {
  final int id;
  final String imageUrl;
  final List<String> categories;

  GalleryImage({
    required this.id,
    required this.imageUrl,
    required this.categories,
  });

  factory GalleryImage.fromJson(Map<String, dynamic> json) {
    return GalleryImage(
      id: json['id'] ?? 0,
      imageUrl: json['image_url'] ?? '',
      categories: (json['categories'] as List<dynamic>?)
          ?.map((category) => category.toString())
          .toList() ?? [],
    );
  }
}