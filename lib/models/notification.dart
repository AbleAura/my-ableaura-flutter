// lib/models/notification.dart

enum NotificationType {
  offer,
  referral,
  gallery,
  progress,
  general
}

enum NotificationScreen {
  attendance,
  payments,
  channels,
  referral,
  gallery,
  progress,
  home
}

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final NotificationScreen screen;
  final DateTime createdAt;
  final String? offerCode;
  bool isRead;
  final Map<String, dynamic>? data;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    this.type = NotificationType.general,
    this.screen = NotificationScreen.home,
    required this.createdAt,
    this.offerCode,
    this.isRead = false,
    this.data,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      type: _parseNotificationType(json['type']),
      screen: _parseNotificationScreen(json['screen']),
      createdAt: DateTime.parse(json['createdAt']),
      offerCode: json['offerCode'],
      isRead: json['isRead'] ?? false,
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'type': type.toString(),
    'screen': screen.toString(),
    'createdAt': createdAt.toIso8601String(),
    'offerCode': offerCode,
    'isRead': isRead,
    'data': data,
  };

  static NotificationType _parseNotificationType(String? type) {
    if (type == null) return NotificationType.general;
    try {
      return NotificationType.values.firstWhere(
        (e) => e.toString() == 'NotificationType.$type',
        orElse: () => NotificationType.general,
      );
    } catch (_) {
      return NotificationType.general;
    }
  }

  static NotificationScreen _parseNotificationScreen(String? screen) {
    if (screen == null) return NotificationScreen.home;
    try {
      return NotificationScreen.values.firstWhere(
        (e) => e.toString() == 'NotificationScreen.$screen',
        orElse: () => NotificationScreen.home,
      );
    } catch (_) {
      return NotificationScreen.home;
    }
  }

  static NotificationType getTypeFromString(String? type) {
    switch (type?.toLowerCase()) {
      case 'offer':
        return NotificationType.offer;
      case 'referral':
        return NotificationType.referral;
      case 'gallery':
        return NotificationType.gallery;
      case 'progress':
        return NotificationType.progress;
      default:
        return NotificationType.general;
    }
  }

  static NotificationScreen getScreenFromString(String? screen) {
    switch (screen?.toLowerCase()) {
      case 'attendance':
        return NotificationScreen.attendance;
      case 'payments':
        return NotificationScreen.payments;
      case 'whatsapp':
        return NotificationScreen.channels;
      case 'referral':
        return NotificationScreen.referral;
      case 'gallery':
        return NotificationScreen.gallery;
      case 'progress':
        return NotificationScreen.progress;
      default:
        return NotificationScreen.home;
    }
  }
}