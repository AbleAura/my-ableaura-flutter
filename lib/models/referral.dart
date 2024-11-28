// models/referral.dart
class ReferralContact {
  final String name;
  final String phone;
  final bool isInvited;
  final bool hasOnboarded;
  final bool hasCompletedPayment;
  final DateTime? invitedAt;
  final DateTime? onboardedAt;
  final DateTime? paymentCompletedAt;

  ReferralContact({
    required this.name,
    required this.phone,
    this.isInvited = false,
    this.hasOnboarded = false,
    this.hasCompletedPayment = false,
    this.invitedAt,
    this.onboardedAt,
    this.paymentCompletedAt,
  });

  factory ReferralContact.fromJson(Map<String, dynamic> json) {
    return ReferralContact(
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      isInvited: json['is_invited'] ?? false,
      hasOnboarded: json['has_onboarded'] ?? false,
      hasCompletedPayment: json['has_completed_payment'] ?? false,
      invitedAt: json['invited_at'] != null ? DateTime.parse(json['invited_at']) : null,
      onboardedAt: json['onboarded_at'] != null ? DateTime.parse(json['onboarded_at']) : null,
      paymentCompletedAt: json['payment_completed_at'] != null ? DateTime.parse(json['payment_completed_at']) : null,
    );
  }
}

class ReferralStats {
  final int totalReferrals;
  final int successfulReferrals;
  final int pendingReferrals;
  final int freeSessionsEarned;

  ReferralStats({
    required this.totalReferrals,
    required this.successfulReferrals,
    required this.pendingReferrals,
    required this.freeSessionsEarned,
  });

  factory ReferralStats.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return ReferralStats(
      totalReferrals: data['total_referrals'] ?? 0,
      successfulReferrals: data['successful_referrals'] ?? 0,
      pendingReferrals: data['pending_referrals'] ?? 0,
      freeSessionsEarned: data['free_sessions_earned'] ?? 0,
    );
  }
}