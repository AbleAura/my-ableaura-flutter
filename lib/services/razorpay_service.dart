import 'package:my_ableaura/config/build_config.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorpayService {
  static late Razorpay _razorpay;
  
  static void initRazorpay({
    required Function(PaymentSuccessResponse) onSuccess,
    required Function(PaymentFailureResponse) onFailure,
    required Function(ExternalWalletResponse) onWallet,
  }) {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, onSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, onFailure);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, onWallet);
  }

  static void dispose() {
    _razorpay.clear();
  }

  static Future<void> processPayment({
    required String orderId,
    required String amount,
    required String paymentLinkId,
  }) async {
    var options = {
      'key': BuildConfig.instance.razorpayKey,
      'payment_link_id': paymentLinkId,
      'amount': int.parse(amount) * 100, // amount in paise
      'name': 'Sports Academy',
      'prefill': {
        'contact': '',
        'email': ''
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      throw Exception('Error processing payment: $e');
    }
  }
}