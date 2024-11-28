// lib/services/feedback_service.dart

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/build_config.dart';
import '../models/feedback_type.dart';
import '../models/feedback.dart';

class FeedbackService {
  static final _dio = Dio();
  static String get _baseUrl => BuildConfig.instance.baseUrl;

  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

static Future<Map<String, String>> _getMultipartHeaders() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('access_token');
  
  if (token == null) throw Exception('Authentication token not found');

  return {
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };
}
  static Future<List<FeedbackType>> getFeedbackTypes() async {
    try {
      final response = await _dio.get(
        '$_baseUrl/feedback-types',
        options: Options(headers: await _getHeaders()),
      );

      print('Feedback types response: ${response.data}'); // Debug log

      if (response.data['success'] == true) {
        return (response.data['data'] as List)
            .map((json) => FeedbackType.fromJson(json))
            .toList();
      } else {
        throw response.data['message'] ?? 'Failed to load feedback types';
      }
    } catch (e) {
      print('Error fetching feedback types: $e'); // Debug log
      throw 'Failed to load feedback types';
    }
  }

  static Future<void> submitFeedback({
    required int feedbackTypeId,
    required String title,
    String? description,
    File? voiceNote,
    List<File>? attachments,
  }) async {
    try {
      var formData = FormData.fromMap({
        'feedback_type_id': feedbackTypeId,
        'title': title,
        'description': description,
        if (voiceNote != null)
          'voice_note': await MultipartFile.fromFile(
            voiceNote.path,
            filename: 'voice_note.m4a',
          ),
        if (attachments != null)
          'attachments[]': attachments.map(
            (file) => MultipartFile.fromFileSync(
              file.path,
              filename: file.path.split('/').last,
            ),
          ).toList(),
      });

      print('Submitting feedback with data: $formData'); // Debug log

      final response = await _dio.post(
        '$_baseUrl/feedback',
        data: formData,
        options: Options(
           headers: await _getMultipartHeaders(),
          contentType: 'multipart/form-data',
        ),
      );

      print('Submit feedback response: ${response.data}'); // Debug log

      if (response.data['success'] != true) {
        throw response.data['message'] ?? 'Failed to submit feedback';
      }
    } catch (e) {
      print('Error submitting feedback: $e'); // Debug log
      throw 'Failed to submit feedback';
    }
  }

  static Future<List<FeedbackModel>> getFeedbacks() async {
    try {
      final response = await _dio.get(
        '$_baseUrl/feedbacks',
        options: Options(headers: await _getHeaders()),
      );

      if (response.data['success'] == true) {
        return (response.data['data'] as List)
            .map((json) => FeedbackModel.fromJson(json))
            .toList();
      } else {
        throw response.data['message'] ?? 'Failed to load feedbacks';
      }
    } catch (e) {
      print('Error fetching feedbacks: $e'); // Debug log
      throw 'Failed to load feedbacks';
    }
  }
}