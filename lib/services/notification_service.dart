import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/notification.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static late final GlobalKey<NavigatorState> _navigatorKey;
  static bool _isInitialized = false;
  static const String _notificationsKey = 'stored_notifications';
  static const String _pendingRouteKey = 'pending_notification_route';  // Added this line

  static Future<void> initialize(GlobalKey<NavigatorState> navigatorKey) async {
    if (_isInitialized) return;
    
    _navigatorKey = navigatorKey;

    // Create high importance channel
    const androidChannel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    // Initialize local notifications with proper channel
    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettingsIOS = DarwinInitializationSettings();
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        print('Local notification clicked with payload: ${details.payload}');
        handleNotificationTap(details.payload);
      },
    );

    // Request permission for iOS devices
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');

    // Handle notification when app is in background
   FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notification opened from background state');
      print('Message data: ${message.data}');
      _storeNotification(message);
      handleNotificationTap(message.data['screen']);
    });
    // Handle notification when app is terminated
     final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      print('Handling initial message from terminated state');
      print('Initial message data: ${initialMessage.data}');
      _storeNotification(initialMessage);
      // Store the route for after initialization
      await _storePendingRoute(initialMessage.data['screen']);
    }

    // Check for pending routes after initialization
    await _checkPendingRoute();

    // Handle notification when app is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received foreground message');
      print('Title: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');
      print('Data: ${message.data}');
      
      _storeNotification(message);
      showLocalNotification(
        title: message.notification?.title ?? 'Notification',
        body: message.notification?.body ?? '',
        payload: message.data['screen'],
      );
    });

    _isInitialized = true;
  }

  static Future<void> _storeNotification(RemoteMessage message) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedNotifications = await getNotifications();
      
      final newNotification = NotificationModel(
        id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: message.notification?.title ?? 'Notification',
        body: message.notification?.body ?? '',
        type: NotificationModel.getTypeFromString(message.data['type']),
        screen: NotificationModel.getScreenFromString(message.data['screen']),
        createdAt: DateTime.now(),
        data: message.data,
      );
      
      storedNotifications.insert(0, newNotification);
      
      await prefs.setString(
        _notificationsKey,
        jsonEncode(storedNotifications.map((n) => n.toJson()).toList()),
      );
    } catch (e) {
      print('Error storing notification: $e');
    }
  }

 static Future<void> _storePendingRoute(String? route) async {
    if (route != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_pendingRouteKey, route);
      print('Stored pending route: $route');
    }
  }

  static Future<void> _checkPendingRoute() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pendingRoute = prefs.getString(_pendingRouteKey);
      if (pendingRoute != null) {
        print('Found pending route: $pendingRoute');
        await prefs.remove(_pendingRouteKey);
        // Add a small delay to ensure navigation is ready
        await Future.delayed(const Duration(milliseconds: 500));
        handleNotificationTap(pendingRoute);
      }
    } catch (e) {
      print('Error checking pending route: $e');
    }
  }
   static void handleNotificationTap(String? route) {
    print('Handling notification tap for route: $route');
    if (route == null) return;

    // If navigator is not ready, store the route for later
    if (_navigatorKey.currentState == null) {
      print('Navigator not ready, storing route for later');
      _storePendingRoute(route);
      return;
    }

    // Add a small delay to ensure navigation state is stable
    Future.delayed(const Duration(milliseconds: 100), () {
      switch (route.toLowerCase()) {
        case 'payments':
          _navigatorKey.currentState?.pushNamedAndRemoveUntil(
            '/payments',
            (route) => route.isFirst,
          );
          break;
        case 'attendance':
          _navigatorKey.currentState?.pushNamedAndRemoveUntil(
            '/attendance',
            (route) => route.isFirst,
          );
          break;
        case 'whatsapp':
          _navigatorKey.currentState?.pushNamedAndRemoveUntil(
            '/channels',
            (route) => route.isFirst,
          );
          break;
        case 'referral':
          _navigatorKey.currentState?.pushNamedAndRemoveUntil(
            '/referral',
            (route) => route.isFirst,
          );
          break;
        case 'gallery':
          _navigatorKey.currentState?.pushNamedAndRemoveUntil(
            '/gallery',
            (route) => route.isFirst,
          );
          break;
        case 'progress':
          _navigatorKey.currentState?.pushNamedAndRemoveUntil(
            '/progress',
            (route) => route.isFirst,
          );
          break;
        default:
          _navigatorKey.currentState?.pushNamedAndRemoveUntil(
            '/',
            (route) => false,
          );
      }
    });}

  static Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
      channelShowBadge: true,
    );

    const iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecond,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  static Future<List<NotificationModel>> getNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? storedData = prefs.getString(_notificationsKey);
      
      if (storedData == null) return [];
      
      final List<dynamic> decodedData = jsonDecode(storedData);
      return decodedData
          .map((item) => NotificationModel.fromJson(item))
          .toList();
    } catch (e) {
      print('Error getting notifications: $e');
      return [];
    }
  }

  static Future<void> markAsRead(String notificationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? storedData = prefs.getString(_notificationsKey);
      
      if (storedData != null) {
        final List<dynamic> notifications = jsonDecode(storedData);
        final int index = notifications.indexWhere(
          (item) => item['id'] == notificationId
        );
        
        if (index != -1) {
          notifications[index]['isRead'] = true;
          await prefs.setString(_notificationsKey, jsonEncode(notifications));
        }
      }
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  static Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_notificationsKey);
    } catch (e) {
      print('Error clearing notifications: $e');
    }
  }

  static Future<int> getUnreadCount() async {
    try {
      final notifications = await getNotifications();
      return notifications.where((n) => !n.isRead).length;
    } catch (e) {
      print('Error getting unread count: $e');
      return 0;
    }
  }
}