import 'package:flutter/material.dart';

class ReferralDetail {
  final String name;
  final String phone;
  final String status;
  final DateTime createdAt;
  final DateTime? registrationDate;
  final DateTime? meetingScheduledAt;  // Added
  final DateTime? paymentCompletionDate;
  final String rewardStatus;

  ReferralDetail({
    required this.name,
    required this.phone,
    required this.status,
    required this.createdAt,
    this.registrationDate,
    this.meetingScheduledAt,  // Added
    this.paymentCompletionDate,
    required this.rewardStatus,
  });

  factory ReferralDetail.fromJson(Map<String, dynamic> json) {
    return ReferralDetail(
      name: json['name'],
      phone: json['phone'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      registrationDate: json['registration_date'] != null 
          ? DateTime.parse(json['registration_date']) 
          : null,
      meetingScheduledAt: json['meeting_scheduled_at'] != null  // Added
          ? DateTime.parse(json['meeting_scheduled_at']) 
          : null,
      paymentCompletionDate: json['payment_completion_date'] != null 
          ? DateTime.parse(json['payment_completion_date']) 
          : null,
      rewardStatus: json['reward_status'] ?? 'pending',
    );
  }

  String get displayStatus {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'meeting_scheduled':  // Added
        return 'Meeting Scheduled';
      case 'registered':
        return 'Registered';
      case 'payment_completed':
        return 'Completed';
      default:
        return 'Unknown';
    }
  }

  Color get statusColor {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'meeting_scheduled':  // Added
        return Colors.blue;
      case 'registered':
        return Colors.purple;
      case 'payment_completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}