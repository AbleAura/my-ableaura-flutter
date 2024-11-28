import 'package:my_ableaura/config/env_config.dart';

enum BuildFlavor {
  development,
  production,
}

class BuildConfig {
  final BuildFlavor flavor;
  final String baseUrl;
    final String appUrl;  // Added appUrl
  final String razorpayKey;

  static late BuildConfig _instance;

  BuildConfig._internal({
    required this.flavor,
    required this.baseUrl,
       required this.appUrl,  // Added appUrl
    required this.razorpayKey,
  });

  static Future<void> init({required BuildFlavor flavor}) async {
    try {
      print('Initializing BuildConfig with flavor: $flavor'); // Debug print
      
      // Initialize environment
      await Environment.init();
      
      // Create instance with loaded values
      _instance = BuildConfig._internal(
        flavor: flavor,
        baseUrl: Environment.apiBaseUrl,
          appUrl: Environment.appUrl,  // Added appUrl
        razorpayKey: Environment.razorpayKey,
      );
      
      // Verify initialization
      print('BuildConfig initialized successfully');
      print('Base URL: ${_instance.baseUrl}');
       print('App URL: ${_instance.appUrl}');  // Added debug print
      print('Flavor: ${_instance.flavor}');
      
    } catch (e, stackTrace) {
      print('Error initializing BuildConfig: $e');
      print('Stack trace: $stackTrace');
      
      // Initialize with default values but still throw the error
      _instance = BuildConfig._internal(
        flavor: flavor,
        baseUrl: Environment.DEFAULT_API_URL,
          appUrl: Environment.DEFAULT_APP_URL,  // Added default app URL
        razorpayKey: Environment.DEFAULT_RAZORPAY_KEY,
      );
      
      rethrow;
    }
  }

  static BuildConfig get instance {
    return _instance;
  }

  static bool get isProduction => _instance.flavor == BuildFlavor.production;
  static bool get isDevelopment => _instance.flavor == BuildFlavor.development;
}