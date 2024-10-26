import 'package:flutter/material.dart';
import 'package:my_ableaura/screens/children_list_screen.dart';
import 'package:my_ableaura/screens/notifications_screen.dart';
import 'package:my_ableaura/screens/payment_selection_screen.dart';
import 'package:my_ableaura/screens/progress_report_screen.dart';
import 'package:my_ableaura/screens/referral_screen.dart';
import 'package:my_ableaura/screens/whatsapp_channels_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'config/build_config.dart';
import 'services/notification_service.dart';

// Global navigator key to be used across the app
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    print('Flutter initialized');

    await Firebase.initializeApp();
    await NotificationService.initialize(navigatorKey);

    final flavor = const String.fromEnvironment('ENVIRONMENT', defaultValue: 'dev') == 'prod'
        ? BuildFlavor.production
        : BuildFlavor.development;
    
    await BuildConfig.init(flavor: flavor);
    
    runApp(const MyApp());
  } catch (e) {
    print('Initialization error: $e');
    runApp(ErrorApp(error: e.toString(), navigatorKey: navigatorKey));
  }
}

class ErrorApp extends StatelessWidget {
  final String error;
  final GlobalKey<NavigatorState> navigatorKey;

  const ErrorApp({
    Key? key, 
    required this.error,
    required this.navigatorKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      home: Scaffold(
        body: Center(
          child: Text('Failed to initialize app: $error'),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: BuildConfig.isDevelopment ? 'Sports Academy Dev' : 'Sports Academy',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(
              builder: (_) => SplashScreen(navigatorKey: navigatorKey)
            );
          case '/home':
            return MaterialPageRoute(
              builder: (_) => HomeScreen(navigatorKey: navigatorKey)
            );
          case '/attendance':
            return MaterialPageRoute(
              builder: (_) => ChildrenListScreen(navigatorKey: navigatorKey)
            );
          case '/notifications':
            return MaterialPageRoute(
              builder: (_) => NotificationsScreen(navigatorKey: navigatorKey)
            );
          case '/channels':
            return MaterialPageRoute(
              builder: (_) => WhatsAppChannelsScreen(navigatorKey: navigatorKey)
            );
          case '/payments':
            return MaterialPageRoute(
              builder: (_) => PaymentSelectionScreen(navigatorKey: navigatorKey)
            );
          case '/referral':
            return MaterialPageRoute(
              builder: (_) => ReferralScreen(navigatorKey: navigatorKey)
            );
          case '/progress':
            return MaterialPageRoute(
              builder: (_) => ProgressReportScreen(navigatorKey: navigatorKey)
            );
          case '/addresses':
            return MaterialPageRoute(
              builder: (_) => const Scaffold(
                body: Center(
                  child: Text('Addresses Screen - Coming Soon'),
                ),
              ),
            );
          case '/gallery':
            return MaterialPageRoute(
              builder: (_) => const Scaffold(
                body: Center(
                  child: Text('Gallery Screen - Coming Soon'),
                ),
              ),
            );
          case '/login':
            return MaterialPageRoute(
              builder: (_) => LoginScreen(navigatorKey: navigatorKey)
            );
          default:
            return MaterialPageRoute(
              builder: (_) => SplashScreen(navigatorKey: navigatorKey)
            );
        }
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const SplashScreen({
    Key? key,
    required this.navigatorKey,
  }) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      
      if (!mounted) return;

      if (token != null) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      print('Auth check error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to initialize app: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              child: Text('SA', style: TextStyle(fontSize: 32)),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text(
              'Sports Academy',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}