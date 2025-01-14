class FreeSession {
  final int id;
  final int referralLeadId;
  final int referrerId;
  final int referredUserId;
  final String rewardType;
  final int rewardAmount;
  final String status;
  final DateTime validUntil;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  FreeSession({
    required this.id,
    required this.referralLeadId,
    required this.referrerId,
    required this.referredUserId,
    required this.rewardType,
    required this.rewardAmount,
    required this.status,
    required this.validUntil,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FreeSession.fromJson(Map<String, dynamic> json) {
    return FreeSession(
      id: json['id'],
      referralLeadId: json['referral_lead_id'],
      referrerId: json['referrer_id'],
      referredUserId: json['referred_user_id'],
      rewardType: json['reward_type'],
      rewardAmount: json['reward_amount'],
      status: json['status'],
      validUntil: DateTime.parse(json['valid_until']),
      completedAt: json['completed_at'] != null 
          ? DateTime.parse(json['completed_at']) 
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  /// Check if the session is available for use
  bool get isAvailable => 
      validUntil.isAfter(DateTime.now()) && // Not expired
      status == 'completed' && // Not yet used
      completedAt == null; // Additional check for completion

  /// Check if the session has been used
  bool get isRedeemed => status == 'redeemed';
}