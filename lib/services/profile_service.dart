import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/build_config.dart';
import '../models/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {
  static String get baseUrl => BuildConfig.instance.baseUrl;

  static Future<Profile> getProfile() async {
    try {
      print('Fetching profile from: $baseUrl/profile/get'); // Debug log

      final response = await http.get(
        Uri.parse('$baseUrl/profile/get'),
        headers: await _getHeaders(),
      );

      print('Response status code: ${response.statusCode}'); // Debug log
      print('Response body: ${response.body}'); // Debug log

      if (response.statusCode != 200) {
        throw Exception('Server returned status code: ${response.statusCode}');
      }

      final data = jsonDecode(response.body);
      if (data['success']) {
        return Profile.fromJson(data['data']);
      } else {
        throw Exception(data['message'] ?? 'Failed to load profile');
      }
    } on FormatException catch (e) {
      throw Exception('Failed to parse response: $e');
    } catch (e) {
      throw Exception('Failed to load profile: $e');
    }
  }

  static Future<Map<String, String>> _getHeaders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token == null) throw Exception('No access token found');
      
      print('Token being sent: ${token.substring(0, 10)}...'); // Only show first 10 chars for security
      
      return {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
    } catch (e) {
      throw Exception('Error getting headers: $e');
    }
  }
}