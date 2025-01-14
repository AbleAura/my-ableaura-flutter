import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/build_config.dart';
import '../models/referral_detail.dart';

class ReferralService {
  static String get baseUrl => BuildConfig.instance.baseUrl;
  // Add app URL for shareable links
  static String get appUrl => BuildConfig.instance.appUrl;

   // Generate referral URL for sharing
static String getReferralUrl(String referralCode) {
  // Create the metadata JSON
  final metadata = {
    'referral_code': referralCode,
  };
  
  // Convert metadata to JSON string and URL encode it
  final encodedMetadata = Uri.encodeComponent(jsonEncode(metadata));
  
  // Use existing BuildConfig.isDevelopment getter
  return BuildConfig.isDevelopment 
      ? 'https://bookings.academy.ableaura.com/team/chennai/15-mins-meeting-with-ableaura-team-dev?metadata=$encodedMetadata'
      : 'https://bookings.academy.ableaura.com/team/chennai/15-mins-referral-meeting?metadata=$encodedMetadata';
}
  
  static Future<Map<String, dynamic>> generateCode() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/referral/generate'),
        headers: await _getHeaders(),
      );

      final data = jsonDecode(response.body);
      if (data['success']) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to generate code');
      }
    } catch (e) {
      throw Exception('Failed to generate code: $e');
    }
  }

  static Future<Map<String, dynamic>> getReferralStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/referral/stats'),
        headers: await _getHeaders(),
      );

      final data = jsonDecode(response.body);
      if (data['success']) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to get stats');
      }
    } catch (e) {
      throw Exception('Failed to get stats: $e');
    }
  }

  static Future<Map<String, dynamic>> getReferralHistory() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/referral/history'),
        headers: await _getHeaders(),
      );

      final data = jsonDecode(response.body);
      if (data['success']) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to get history');
      }
    } catch (e) {
      throw Exception('Failed to get history: $e');
    }
  }
   static Future<List<ReferralDetail>> getReferrals() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/referral/my-referrals'),
        headers: await _getHeaders(),
      );

      final data = jsonDecode(response.body);
      if (data['success']) {
        return (data['data'] as List)
            .map((item) => ReferralDetail.fromJson(item))
            .toList();
      } else {
        throw Exception(data['message']);
      }
    } catch (e) {
      throw Exception('Failed to load referrals: $e');
    }
  }

   static Future<Map<String, String>> _getHeaders() async {
    final token = await _getAuthToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<String> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null) throw Exception('No auth token found');
    return token;
  }

  static Future<void> processReferral(
    String code, {
    Map<String, dynamic>? deviceInfo,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/referral/complete'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'referral_code': code,
          'device_info': deviceInfo,
        }),
      );

      final data = jsonDecode(response.body);
      if (!data['success']) {
        throw Exception(data['message'] ?? 'Failed to process referral');
      }
    } catch (e) {
      debugPrint('Error processing referral: $e');
      rethrow;
    }
  }

  // Method to handle deep link referrals
  static Future<void> handleDeepLinkReferral(Uri uri) async {
    try {
      final code = uri.queryParameters['code'];
      if (code != null) {
        await processReferral(code);
      }
    } catch (e) {
      print('Error handling deep link referral: $e');
      rethrow;
    }
  }
}