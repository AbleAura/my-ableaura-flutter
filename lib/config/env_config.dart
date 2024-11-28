import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  // Default values as fallback
  static const String DEFAULT_API_URL = 'https://dev.web.api.ableaura.com/academy/parent';
  static const String DEFAULT_APP_URL = 'https://dev.academy.ableaura.com';  // Added default app URL
  static const String DEFAULT_RAZORPAY_KEY = 'rzp_test_default_key';

  static String get fileName =>
      const String.fromEnvironment('ENVIRONMENT', defaultValue: 'dev') == 'prod'
          ? 'assets/.env.prod'
          : 'assets/.env.dev';

  static Future<void> init() async {
    try {
      print('Loading environment from: $fileName'); // Debug print
      
      // First try to load the file
      print('Environment file content loaded'); // Debug print
      
      // Load the environment variables
      await dotenv.load(fileName: fileName);
      
      // Verify loading
      print('Environment loaded successfully');
      print('API URL: ${dotenv.env['API_BASE_URL']}'); // Debug print
      print('App URL: ${dotenv.env['APP_URL']}');  // Added debug print
      
    } catch (e) {
      print('Error loading environment file: $e'); // Debug print
      print('Stack trace: ${StackTrace.current}'); // Debug print
      rethrow;
    }
  }

  static String get apiBaseUrl {
    final url = dotenv.env['API_BASE_URL'];
    print('Getting API URL: $url'); // Debug print
    return url ?? DEFAULT_API_URL;
  }
      
   static String get appUrl {  // Added app URL getter
    final url = dotenv.env['APP_URL'];
    print('Getting App URL: $url');
    return url ?? DEFAULT_APP_URL;
  }
  
  static String get razorpayKey {
    final key = dotenv.env['RAZORPAY_KEY'];
    print('Getting Razorpay key: $key'); // Debug print
    return key ?? DEFAULT_RAZORPAY_KEY;
  }

  static bool get isProd => 
      const String.fromEnvironment('ENVIRONMENT', defaultValue: 'dev') == 'prod';
      
  static bool get isDev => !isProd;
}