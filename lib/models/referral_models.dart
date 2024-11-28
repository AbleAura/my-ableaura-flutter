class ReferralStats {
  final int totalReferrals;
  final int pendingReferrals;
  final int completedReferrals;
  final int rewardsEarned;

  ReferralStats({
    required this.totalReferrals,
    required this.pendingReferrals,
    required this.completedReferrals,
    required this.rewardsEarned,
  });

  factory ReferralStats.fromJson(Map<String, dynamic> json) {
    return ReferralStats(
      totalReferrals: json['total_referrals'] ?? 0,
      pendingReferrals: json['pending_referrals'] ?? 0,
      completedReferrals: json['completed_referrals'] ?? 0,
      rewardsEarned: json['rewards_earned'] ?? 0,
    );
  }
}

class ReferralHistory {
  final String code;
  final String status;
  final String? referredUser;
  final DateTime createdAt;
  final DateTime? installedAt;
  final DateTime? completedAt;

  ReferralHistory({
    required this.code,
    required this.status,
    this.referredUser,
    required this.createdAt,
    this.installedAt,
    this.completedAt,
  });

  factory ReferralHistory.fromJson(Map<String, dynamic> json) {
    return ReferralHistory(
      code: json['code'],
      status: json['status'],
      referredUser: json['referred_user'],
      createdAt: DateTime.parse(json['created_at']),
      installedAt: json['installed_at'] != null 
          ? DateTime.parse(json['installed_at']) 
          : null,
      completedAt: json['completed_at'] != null 
          ? DateTime.parse(json['completed_at']) 
          : null,
    );
  }
}