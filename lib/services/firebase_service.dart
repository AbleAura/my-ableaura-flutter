import 'dart:typed_data';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart' as path_provider;

class FirebaseService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    await Firebase.initializeApp();
    
    // Request permission for iOS devices
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');

    // Initialize local notifications
    const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettingsIOS = DarwinInitializationSettings();
    
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
        print('Notification clicked: ${response.payload}');
      },
    );

    // Create notification channel for Android
    await _createNotificationChannel();

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    _isInitialized = true;
  }

  static Future<void> _createNotificationChannel() async {
    const androidChannel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
      playSound: true,
      showBadge: true,
      enableVibration: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    print('Handling background message: ${message.messageId}');
    await _showNotification(message);
  }

  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('Handling foreground message: ${message.messageId}');
    await _showNotification(message);
  }

  static Future<String?> _downloadAndSaveImage(String imageUrl, String fileName) async {
    try {
      final directory = await path_provider.getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName';
      final response = await http.get(Uri.parse(imageUrl));
      
      if (response.statusCode == 200) {
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        return filePath;
      }
      return null;
    } catch (e) {
      print('Error downloading image: $e');
      return null;
    }
  }

  static Future<void> _showNotification(RemoteMessage message) async {
    final notification = message.notification;
    final data = message.data;

    if (notification == null) return;

    // Get image URL from data payload
    final imageUrl = data['image_url'];
    
    // Create big picture style if image URL is present
    AndroidNotificationDetails androidDetails;
    
    if (imageUrl != null && imageUrl.isNotEmpty) {
      try {
        final imagePath = await _downloadAndSaveImage(imageUrl, 'notification_${DateTime.now().millisecondsSinceEpoch}.jpg');
        
        if (imagePath != null) {
          // Create rich media style notification
          androidDetails = AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription: 'This channel is used for important notifications.',
            importance: Importance.high,
            priority: Priority.high,
            styleInformation: BigPictureStyleInformation(
              FilePathAndroidBitmap(imagePath),
              largeIcon: FilePathAndroidBitmap(imagePath),
              contentTitle: notification.title,
              summaryText: notification.body,
              hideExpandedLargeIcon: false,
              htmlFormatContent: true,
              htmlFormatContentTitle: true,
            ),
            // Additional styling
            enableLights: true,
            color: const Color.fromARGB(255, 255, 0, 0),
            ledColor: const Color.fromARGB(255, 255, 0, 0),
            ledOnMs: 1000,
            ledOffMs: 500,
            playSound: true,
            sound: const RawResourceAndroidNotificationSound('notification_sound'),
            enableVibration: true,
            vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
            ticker: 'New notification',
            fullScreenIntent: true,
          );
        } else {
          // Fallback to default style if image download fails
          androidDetails = _getDefaultAndroidDetails();
        }
      } catch (e) {
        print('Error processing notification image: $e');
        androidDetails = _getDefaultAndroidDetails();
      }
    } else {
      androidDetails = _getDefaultAndroidDetails();
    }

    final iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      attachments: imageUrl != null ? [DarwinNotificationAttachment(imageUrl)] : null,
      subtitle: notification.body,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      details,
      payload: message.data.toString(),
    );
  }

  static AndroidNotificationDetails _getDefaultAndroidDetails() {
    return const AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.high,
      priority: Priority.high,
      enableLights: true,
      playSound: true,
      enableVibration: true,
    );
  }

  static Future<String?> getToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      print('Firebase Token: $token');
      return token;
    } catch (e) {
      print('Error getting Firebase token: $e');
      return null;
    }
  }

  static void onTokenRefresh() {
    _firebaseMessaging.onTokenRefresh.listen((String token) {
      print('New token: $token');
      // Here you could add logic to update the token on your server
    });
  }
}