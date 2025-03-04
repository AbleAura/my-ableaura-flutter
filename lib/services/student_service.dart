// student_service.dart

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:my_ableaura/config/build_config.dart';
import 'package:my_ableaura/models/payment.dart';
import 'package:my_ableaura/screens/login_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/attendance.dart';
import '../models/free_session.dart';
import '../models/gallery.dart';
import '../models/home_session.dart';
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

    static String _fixS3Url(String url) {
    // Remove extra slashes but preserve http:// or https://
    final fixedUrl = url.replaceAll(RegExp(r'(?<!:)//'), '/');
    print('Original URL: $url');
    print('Fixed URL: $fixedUrl');
    return fixedUrl;
  }
static Future<List<AttendanceRecord>> getAttendanceRecords(
  int studentId,
  DateTime month,
) async {
  try {
    final token = await _getAuthToken();
    if (token == null) throw Exception('Authentication token not found');

    final response = await http.post(
      Uri.parse('$baseUrl/attendance/view'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'student_id': studentId,
        'month': month.month,
        'year': month.year,
      }),
    );

    final data = jsonDecode(response.body);
    if (data['success'] == true) {
      final List<dynamic> records = data['data'];
      return records.map((record) => AttendanceRecord.fromJson(record)).toList();
    } else {
      throw Exception(data['message'] ?? 'Failed to fetch attendance records');
    }
  } catch (e) {
    print('Error fetching attendance records: $e');
    throw Exception('Failed to fetch attendance records: $e');
  }
}
// Get months with available progress data
static Future<List<DateTime>> getAvailableProgressMonths(int studentId) async {
  try {
    final token = await _getAuthToken();
    if (token == null) throw Exception('Authentication token not found');

    final response = await http.get(
      Uri.parse('$baseUrl/student/progress/$studentId/available-months'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);
    if (data['success'] == true) {
      final List<dynamic> monthsData = data['data'];
      return monthsData
          .map((monthData) => DateTime.parse(monthData['month']))
          .toList();
    } else {
      throw Exception(data['message'] ?? 'Failed to fetch available months');
    }
  } catch (e) {
    print('Error fetching available months: $e');
    // Return only the current month if there's an error
    return [DateTime(DateTime.now().year, DateTime.now().month)];
  }
}

// If the API endpoint doesn't exist yet, you can use this mock implementation for testing
static Future<List<DateTime>> getAvailableProgressMonthsMock(int studentId) async {
  // Simulate network delay
  await Future.delayed(Duration(milliseconds: 800));
  
  // Return the last 6 months
  final now = DateTime.now();
  final months = <DateTime>[];
  
  for (int i = 0; i < 6; i++) {
    final month = DateTime(now.year, now.month - i);
    months.add(month);
  }
  
  // Add some months from previous year
  months.add(DateTime(now.year - 1, 12));
  months.add(DateTime(now.year - 1, 11));
  months.add(DateTime(now.year - 1, 8));
  
  return months;
}
// Update the method signature to include the return type
static Future<GalleryResponse> getGalleryPhotos(int studentId) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/gallery/photos/get'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'student_id': studentId,
      }),
    );

    final data = jsonDecode(response.body);
    if (data['success'] == true) {
      return GalleryResponse.fromJson(data);
    } else {
      throw Exception(data['message'] ?? 'Failed to fetch gallery photos');
    }
  } catch (e) {
    print('Error fetching gallery photos: $e');
    throw Exception('Failed to fetch gallery photos: $e');
  }
}
static Future<List<HomeSession>> getHomeSessions(int studentId) async {
  try {
    final token = await _getAuthToken();
    if (token == null) throw Exception('Authentication token not found');

    final response = await http.post(
      Uri.parse('$baseUrl/athome/sessions/view'),
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
      final List<dynamic> sessions = data['data'];
      return sessions.map((session) => HomeSession.fromJson(session)).toList();
    } else {
      throw Exception(data['message'] ?? 'Failed to fetch home sessions');
    }
  } catch (e) {
    print('Error fetching home sessions: $e');
    throw Exception('Failed to fetch home sessions: $e');
  }
}
static Future<void> submitSessionFeedback({
  required int sessionId,
  required int rating,
  required List<String> aspects,
  required bool isPositive,
  required String comments,
  File? attachment,
}) async {
  try {
    final token = await _getAuthToken();
    if (token == null) throw Exception('Authentication token not found');

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/academy/parent/session/feedback/submit'),
    );

    // Add headers
    request.headers.addAll({
      'Authorization': 'Bearer $token',
    });

    // Add fields
    request.fields.addAll({
      'session_id': sessionId.toString(),
      'rating': rating.toString(),
      'aspects': jsonEncode(aspects),
      'is_positive': isPositive.toString(),
      'comments': comments,
    });

    // Add file if exists
    if (attachment != null) {
      final file = await http.MultipartFile.fromPath(
        'attachment',
        attachment.path,
      );
      request.files.add(file);
    }

    final response = await request.send();
    final responseData = await response.stream.bytesToString();
    final data = jsonDecode(responseData);

    if (!data['success']) {
      throw Exception(data['message'] ?? 'Failed to submit feedback');
    }
  } catch (e) {
    print('Error submitting feedback: $e');
    throw Exception('Failed to submit feedback: $e');
  }
}
  // Get list of children
    static Future<String?> getQRCode(int studentId) async {
    try {
      final response = await http.get(
        Uri.parse('${BuildConfig.instance.baseUrl}/student/get/qrcode'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 500) {
        return null; // Indicates QR code doesn't exist
      }

      final data = jsonDecode(response.body);
      return data['data']['qr_code'];
    } catch (e) {
      throw Exception('Failed to get QR code: $e');
    }
  }

   static Future<void> generateQRCode(int studentId) async {
    try {
      await http.post(
        Uri.parse('${BuildConfig.instance.baseUrl}/student/generate/qrcode'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'student_id': studentId,
        }),
      );
    } catch (e) {
      throw Exception('Failed to generate QR code: $e');
    }
  }

 static Future<ChildResponse> getChildrenList() async {
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
        // Parse the response using the updated model
        return ChildResponse.fromJson(data);
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch children list');
      }
    } catch (e) {
      print('Error fetching children: $e');
      throw Exception('Failed to fetch children list: $e');
    }
  }
  
 static Future<String?> getStudentQRCode(int studentId) async {
    try {
      final token = await _getAuthToken();
      if (token == null) throw Exception('Authentication token not found');

      final response = await http.post(
        Uri.parse('$baseUrl/student/get/qrcode'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'student_id': studentId,
        }),
      );

      if (response.statusCode == 500) {
        return null; // Indicates QR code doesn't exist
      }

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        final qrUrl = data['qr_code_pic'] as String;
        return _fixS3Url(qrUrl);
      } else {
        throw Exception(data['message'] ?? 'Failed to get QR code');
      }
    } catch (e) {
      print('Error getting QR code: $e');
      throw Exception('Failed to get QR code: $e');
    }
  }

   static Future<String> waitForQRCode(int studentId, {int maxAttempts = 10}) async {
    for (int i = 0; i < maxAttempts; i++) {
      final qrCode = await getStudentQRCode(studentId);
      if (qrCode != null) {
        return qrCode;
      }
      if (i == 0) {
        // First attempt, generate QR code
        await generateQRCode(studentId);
      }
      // Wait before next attempt
      await Future.delayed(const Duration(seconds: 2));
    }
    throw Exception('QR code generation timed out');
  }
// Add this method to your StudentService class
static Future<String> downloadGalleryPhoto(String photoUrl) async {
  try {
    final dio = Dio();
    
    // Use the complete S3 URL directly without modifications
    final String fullUrl = photoUrl;
    
    print('Downloading from URL: $fullUrl'); // Debug log
    
    // Get path for downloads directory
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'SA_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final savePath = '${directory.path}/$fileName';

    // For S3 URLs, we don't need any special headers
    final response = await dio.get(
      fullUrl,
      options: Options(
        responseType: ResponseType.bytes,
        followRedirects: true,
        contentType: 'application/octet-stream',
        headers: {
          'Accept': '*/*',
        },
      ),
    );

    if (response.statusCode != 200) {
      print('Download failed with status: ${response.statusCode}'); // Debug log
      print('Response headers: ${response.headers}'); // Debug log
      throw Exception('Failed to download: Status ${response.statusCode}');
    }

    // Save bytes to file
    final file = File(savePath);
    await file.writeAsBytes(response.data);

    print('File saved successfully to: $savePath'); // Debug log
    return savePath;

  } catch (e) {
    print('Error downloading image: $e');
    if (e is DioException) {
      print('DioError type: ${e.type}');
      print('DioError message: ${e.message}');
      print('DioError response: ${e.response}');
    }
    rethrow;
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
static Future<List<FreeSession>> checkFreeSessionsAvailable() async {
  try {
    final response = await http.post(
      Uri.parse('${BuildConfig.instance.baseUrl}/free-sessions/check'),
      headers: await _getHeaders(),
    );

    final data = jsonDecode(response.body);
    if (data['success']) {
      return (data['data'] as List)
          .map((session) => FreeSession.fromJson(session))
          .where((session) => session.isAvailable)
          .toList();
    } else {
      throw Exception(data['message'] ?? 'Failed to check free sessions');
    }
  } catch (e) {
    throw Exception('Failed to check free sessions: $e');
  }
}

static Future<Map<String, String>> _getHeaders() async {
  final token = await _getAuthToken();
  return {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };
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
static Future<Map<String, dynamic>> getCombinedPaymentOrder(int studentId) async {
  try {
    final token = await _getAuthToken();
    if (token == null) throw Exception('Authentication token not found');

    final response = await http.post(
      Uri.parse('$baseUrl/student/get/pending/payments/combine/order'),
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
      return data;
    } else {
      throw Exception(data['message'] ?? 'Failed to create combined payment order');
    }
  } catch (e) {
    print('Error creating combined payment order: $e');
    throw Exception('Failed to create combined payment order: $e');
  }
}
  // Get pending payments
 static Future<List<Payment>> getPendingPayments(int studentId) async {
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
          'student_id': studentId,
        }),
      );

      print('Payments Response: ${response.body}'); // Debug print

      final data = jsonDecode(response.body);
      if (data == null) {
        throw Exception('Invalid response data');
      }

      if (data['success'] == true && data['data'] != null) {
        final List<dynamic> paymentsData = data['data'];
        return paymentsData.map((payment) {
          if (payment == null) {
            throw Exception('Invalid payment data');
          }
          try {
            return Payment.fromJson(payment as Map<String, dynamic>);
          } catch (e) {
            print('Error parsing payment: $e');
            throw Exception('Error parsing payment data: $e');
          }
        }).toList();
      } else {
        String errorMessage = data['message'] ?? 'Failed to fetch payments';
        print('API Error: $errorMessage');  // Debug print
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Error in getPendingPayments: $e'); // Debug print
      throw Exception('Failed to fetch payments: $e');
    }
  }


  // Get monthly progress
  static Future<List<DailyProgress>> getMonthlyProgress(
  int studentId,
  DateTime month,
) async {
  try {
    final token = await _getAuthToken();
    if (token == null) throw Exception('Authentication token not found');

    final response = await http.post(
      Uri.parse('$baseUrl/student/progress/monthly'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'student_id': studentId,
        'month': month.month,
        'year': month.year,
      }),
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

  static applyFreeSession(int id, id2) {}
}