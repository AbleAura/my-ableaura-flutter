import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'referral_service.dart';

class ReferralHandler {
  static const String _referralProcessedKey = 'referral_processed';

  static Future<void> handleReferral(String code) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final alreadyProcessed = prefs.getBool(_referralProcessedKey) ?? false;

      if (alreadyProcessed) {
        debugPrint('Referral already processed');
        return;
      }

      // Process referral
      await ReferralService.processReferral(
        code,
        deviceInfo: {
          'platform': 'android',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      // Mark as processed
      await prefs.setBool(_referralProcessedKey, true);
      debugPrint('Referral processed successfully');

    } catch (e) {
      debugPrint('Error processing referral: $e');
      rethrow;
    }
  }

  static Future<void> clearReferralProcessed() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_referralProcessedKey);
    debugPrint('Cleared referral processed state');
  }
}