// lib/services/gallery_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_ableaura/config/build_config.dart';
import 'package:my_ableaura/models/gallery_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class GalleryService {
  static String get baseUrl => BuildConfig.instance.baseUrl;

  static Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  static Future<List<FranchiseGallery>> getStudentGallery(int studentId) async {
    try {
      final token = await _getAuthToken();
      if (token == null) throw Exception('Authentication token not found');

      final response = await http.post(
        Uri.parse('$baseUrl/gallery/student'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'student_id': studentId,
        }),
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        final List<dynamic> galleryData = data['data'];
        return galleryData.map((gallery) => FranchiseGallery.fromJson(gallery)).toList();
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch gallery images');
      }
    } catch (e) {
      print('Error fetching gallery: $e');
      throw Exception('Failed to fetch gallery: $e');
    }
  }

  static Future<String> downloadGalleryPhoto(String imageUrl) async {
    try {
      final dio = Dio();
      final directory = await getApplicationDocumentsDirectory();
      
      // Generate a unique filename based on the URL
      final filename = 'gallery_${DateTime.now().millisecondsSinceEpoch}_${imageUrl.split('/').last}';
      final savePath = '${directory.path}/$filename';
      
      await dio.download(
        imageUrl,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            print('${(received / total * 100).toStringAsFixed(0)}%');
          }
        },
      );
      
      print('Image saved to: $savePath');
      return savePath;
    } catch (e) {
      print('Error downloading image: $e');
      throw Exception('Failed to download image: $e');
    }
  }
}