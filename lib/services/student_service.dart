// student_service.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:my_ableaura/config/build_config.dart';
import 'package:my_ableaura/models/payment.dart';
import 'package:my_ableaura/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/session.dart';
import '../models/child.dart';
import '../models/enrollment.dart';
import '../models/progress_models.dart';

class AttendanceResponse {
  final bool success;
  final String message;
  final String studentId;
  final String studentName;
  final String profilePicture;
  final bool? isCheckedIn;

  AttendanceResponse({
    required this.success,
    required this.message,
    required this.studentId,
    required this.studentName,
    required this.profilePicture,
    this.isCheckedIn,
  });

  factory AttendanceResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return AttendanceResponse(
      success: json['success'],
      message: json['message'],
      studentId: data['student_id'],
      studentName: data['student_name'],
      profilePicture: data['profile_picture'],
      isCheckedIn: data['is_checked_in'],
    );
  }
}

class ProgressSummary {
  final double overallProgress;
  final String aiAnalysis;
  final List<String> keyImprovements;
  final List<String> areasForFocus;
  final List<String> recommendations;

  ProgressSummary({
    required this.overallProgress,
    required this.aiAnalysis,
    required this.keyImprovements,
    required this.areasForFocus,
    required this.recommendations,
  });

  factory ProgressSummary.fromJson(Map<String, dynamic> json) {
    return ProgressSummary(
      overallProgress: json['overall_progress'].toDouble(),
      aiAnalysis: json['ai_analysis'],
      keyImprovements: List<String>.from(json['key_improvements']),
      areasForFocus: List<String>.from(json['areas_for_focus']),
      recommendations: List<String>.from(json['recommendations']),
    );
  }
}

class StudentService {
  static String get baseUrl => BuildConfig.instance.baseUrl;

  static Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  // Get list of children
  static Future<List<Child>> getChildrenList() async {
    try {
      final token = await _getAuthToken();
      if (token == null) throw Exception('Authentication token not found');

      final response = await http.get(
        Uri.parse('$baseUrl/children/get'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print('Children Response: ${response.body}');

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        final List<dynamic> childrenData = data['data'];
        return childrenData.map((child) => Child.fromJson(child)).toList();
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch children list');
      }
    } catch (e) {
      print('Error fetching children: $e');
      throw Exception('Failed to fetch children list: $e');
    }
  }

  // Get child enrollments
  static Future<List<Enrollment>> getChildEnrollments(int childId) async {
    try {
      final token = await _getAuthToken();
      if (token == null) throw Exception('Authentication token not found');

      final response = await http.post(
        Uri.parse('$baseUrl/children/enrollments/get'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'child_id': childId,
        }),
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        final List<dynamic> enrollmentsData = data['data'];
        return enrollmentsData.map((enrollment) => Enrollment.fromJson(enrollment)).toList();
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch enrollments');
      }
    } catch (e) {
      print('Error fetching enrollments: $e');
      throw Exception('Failed to fetch enrollments: $e');
    }
  }

  // Get enrolled sessions
  static Future<List<Session>> getEnrolledSessions({
    required int franchiseId,
    required int studentId,
  }) async {
    try {
      final token = await _getAuthToken();
      if (token == null) throw Exception('Authentication token not found');

      final response = await http.post(
        Uri.parse('$baseUrl/franchise/sessions/get'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'franchise_id': franchiseId,
          'student_id': studentId,
        }),
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        final List<dynamic> sessionsData = data['data'];
        return sessionsData.map((session) => Session.fromJson(session)).toList();
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch enrolled sessions');
      }
    } catch (e) {
      print('Error fetching sessions: $e');
      throw Exception('Failed to fetch enrolled sessions: $e');
    }
  }

  // Mark attendance
  static Future<AttendanceResponse> markAttendance({
    required int sessionId,
    required int enrollmentId,
    required int studentId,
  }) async {
    try {
      final Position position = await _getCurrentLocation();
      final token = await _getAuthToken();
      if (token == null) throw Exception('Authentication token not found');

      final response = await http.post(
        Uri.parse('$baseUrl/attendance/mark'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'session_id': sessionId,
          'enrollment_id': enrollmentId,
          'student_id': studentId,
          'latitude': position.latitude,
          'longitude': position.longitude,
        }),
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return AttendanceResponse.fromJson(data);
      } else {
        throw Exception(data['message'] ?? 'Failed to mark attendance');
      }
    } catch (e) {
      print('Error marking attendance: $e');
      throw Exception('Failed to mark attendance: $e');
    }
  }

  // Get current location
  static Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
    }

    return await Geolocator.getCurrentPosition();
  }

  // Get pending payments
  static Future<List<Payment>> getPendingPayments(int enrollmentId) async {
    try {
      final token = await _getAuthToken();
      if (token == null) throw Exception('Authentication token not found');

      final response = await http.post(
        Uri.parse('$baseUrl/payments/get'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'enrollment_id': enrollmentId,
        }),
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        final List<dynamic> paymentsData = data['data'];
        return paymentsData.map((payment) => Payment.fromJson(payment)).toList();
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch payments');
      }
    } catch (e) {
      print('Error fetching payments: $e');
      throw Exception('Failed to fetch payments: $e');
    }
  }

  // Get monthly progress
  static Future<List<DailyProgress>> getMonthlyProgress(
    int childId,
    DateTime month,
  ) async {
    try {
      final token = await _getAuthToken();
      if (token == null) throw Exception('Authentication token not found');

      final response = await http.get(
        Uri.parse(
          '$baseUrl/student/progress/$childId/monthly'
          '?year=${month.year}&month=${month.month}',
        ),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        final List<dynamic> progressData = data['data'];
        return progressData
            .map((progress) => DailyProgress.fromJson(progress))
            .toList();
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch monthly progress');
      }
    } catch (e) {
      print('Error fetching monthly progress: $e');
      throw Exception('Failed to fetch monthly progress: $e');
    }
  }

  // Get progress summary
  static Future<ProgressSummary> getProgressSummary(int childId) async {
    try {
      final token = await _getAuthToken();
      if (token == null) throw Exception('Authentication token not found');

      final response = await http.get(
        Uri.parse('$baseUrl/student/progress/$childId/summary'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return ProgressSummary.fromJson(data['data']);
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch progress summary');
      }
    } catch (e) {
      print('Error fetching progress summary: $e');
      throw Exception('Failed to fetch progress summary: $e');
    }
  }

  // Get skill progress
  static Future<List<DailyProgress>> getSkillProgress(
    int childId,
    String skillName, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final token = await _getAuthToken();
      if (token == null) throw Exception('Authentication token not found');

      final queryParameters = {
        'skill_name': skillName,
        if (startDate != null) 'start_date': startDate.toIso8601String(),
        if (endDate != null) 'end_date': endDate.toIso8601String(),
      };

      final uri = Uri.parse('$baseUrl/student/progress/$childId/skill')
          .replace(queryParameters: queryParameters);

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        final List<dynamic> progressData = data['data'];
        return progressData
            .map((progress) => DailyProgress.fromJson(progress))
            .toList();
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch skill progress');
      }
    } catch (e) {
      print('Error fetching skill progress: $e');
      throw Exception('Failed to fetch skill progress: $e');
    }
  }

  // Logout
  static Future<void> logout(BuildContext context, GlobalKey<NavigatorState> navigatorKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      if (context.mounted) {
        navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => LoginScreen(navigatorKey: navigatorKey)
          ),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      print('Logout error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error logging out. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}