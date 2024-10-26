import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_service.dart';
import '../config/build_config.dart';

// Custom Exception class for API errors
class ApiException implements Exception {
  final String message;
  final bool needsSupport;

  ApiException(this.message, {this.needsSupport = false});

  @override
  String toString() => message;
}

class AuthService {
  static String get baseUrl => BuildConfig.instance.baseUrl;

  // Send OTP
  static Future<void> sendOTP(String mobileNumber) async {
    try {
      print('Using base URL: $baseUrl'); // Debug print

      final response = await http.post(
        Uri.parse('$baseUrl/sendotp'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'country_code': 91,
          'mobile_no': int.parse(mobileNumber),
        }),
      );

      print('SendOTP Response: ${response.body}'); // For debugging

      final data = jsonDecode(response.body);
      
      if (data['success'] == true) {
        return;
      } else {
        final message = data['message'] ?? 'Failed to send OTP';
        final needsSupport = message.contains('9159911116') || 
                           message.contains('do not have an active enrollment');
        throw ApiException(message, needsSupport: needsSupport);
      }
    } on FormatException catch (_) {
      throw ApiException('Invalid phone number format');
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to connect to the server. Please check your internet connection.');
    }
  }

// In auth_service.dart, update the verifyOTP method:

  static Future<void> verifyOTP(String mobileNumber, String otp) async {
    try {
      print('Starting OTP verification process'); // Debug log
      
      // Initialize Firebase if not already initialized
      await FirebaseService.initialize();
      
      // Get Firebase token with proper error handling
      final firebaseToken = await FirebaseService.getToken();
      print('Retrieved Firebase token: ${firebaseToken?.substring(0, 10) ?? 'null'}...'); // Debug log - only show first 10 chars

      final response = await http.post(
        Uri.parse('$baseUrl/verifyotp'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'otp': int.parse(otp),
          'mobile_no': int.parse(mobileNumber),
          'device_token': firebaseToken ?? '', // Send empty string if token is null
        }),
      );

      print('VerifyOTP Response: ${response.body}'); // Debug log

      final data = jsonDecode(response.body);

      if (data['success'] == true && data['data'] != null) {
        final userData = data['data']['user'];
        final accessToken = data['data']['access_token'];

        // Store the Firebase token along with other user data
        await storeUserData(
          accessToken: accessToken,
          firstName: userData['first_name'] ?? '',
          lastName: userData['last_name'] ?? '',
          email: userData['email'] ?? '',
          phone: userData['phone'] ?? '',
          firebaseToken: firebaseToken ?? '', // Store the token even if null
        );
      } else {
        throw ApiException(data['message'] ?? 'Verification failed');
      }
    } catch (e) {
      print('Error in verifyOTP: $e'); // Debug log
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to verify OTP: $e');
    }
  }

  // Store user data in SharedPreferences
  static Future<void> storeUserData({
    required String accessToken,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String firebaseToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setString('access_token', accessToken),
      prefs.setString('first_name', firstName),
      prefs.setString('last_name', lastName),
      prefs.setString('email', email),
      prefs.setString('phone', phone),
      prefs.setString('firebase_token', firebaseToken),
      // Also store the current environment
      prefs.setString('environment', BuildConfig.isDevelopment ? 'dev' : 'prod'),
    ]);
  }

  // Get stored user data
  static Future<Map<String, String?>> getStoredUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'access_token': prefs.getString('access_token'),
      'first_name': prefs.getString('first_name'),
      'last_name': prefs.getString('last_name'),
      'email': prefs.getString('email'),
      'phone': prefs.getString('phone'),
      'firebase_token': prefs.getString('firebase_token'),
      'environment': prefs.getString('environment'),
    };
  }

  // Clear stored user data (for logout)
  static Future<void> clearUserData() async {
    try {
      print('Clearing user data'); // Debug print
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      print('User data cleared successfully'); // Debug print
    } catch (e) {
      print('Error clearing user data: $e'); // Debug print
      rethrow;
    }
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final hasToken = prefs.containsKey('access_token');
    print('User logged in status: $hasToken'); // Debug print
    return hasToken;
  }

  // Get auth token
  static Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    print('Retrieved auth token: ${token?.substring(0, 10)}...'); // Debug print - only show first 10 chars
    return token;
  }

  // Validate current environment
  static Future<bool> validateEnvironment() async {
    final prefs = await SharedPreferences.getInstance();
    final storedEnv = prefs.getString('environment');
    final currentEnv = BuildConfig.isDevelopment ? 'dev' : 'prod';
    
    // If environment has changed, logout user
    if (storedEnv != null && storedEnv != currentEnv) {
      print('Environment changed from $storedEnv to $currentEnv. Logging out.'); // Debug print
      await clearUserData();
      return false;
    }
    return true;
  }
}