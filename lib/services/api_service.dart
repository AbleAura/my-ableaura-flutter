import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'https://your-api-url.com';

  static Future<void> markAttendance(String childId, bool present) async {
    final response = await http.post(
      Uri.parse('$baseUrl/mark-attendance'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'childId': childId,
        'present': present,
        'date': DateTime.now().toIso8601String(),
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to mark attendance');
    }
  }

  static Future<void> submitReferral(String referralCode) async {
    final response = await http.post(
      Uri.parse('$baseUrl/submit-referral'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'referralCode': referralCode,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to submit referral');
    }
  }

  static Future<void> makePayment(double amount, String paymentMethod) async {
    final response = await http.post(
      Uri.parse('$baseUrl/make-payment'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'amount': amount,
        'paymentMethod': paymentMethod,
        'date': DateTime.now().toIso8601String(),
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to process payment');
    }
  }

  static Future<Map<String, dynamic>> getProgressReport(String childId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/progress-report/$childId'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load progress report');
    }
  }
}