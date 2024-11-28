import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:my_ableaura/config/build_config.dart';

import 'payment_service.dart';

class RazorpayService {
  static late Razorpay _razorpay;
  static bool _isInitialized = false;

  static Razorpay get razorpay {
    if (!_isInitialized) {
      _razorpay = Razorpay();
      _isInitialized = true;
    }
    return _razorpay;
  }

  static void initRazorpay({
    required Function(PaymentSuccessResponse) onSuccess,
    required Function(PaymentFailureResponse) onFailure,
    required Function(ExternalWalletResponse) onWallet,
  }) {
    if (!_isInitialized) {
      _razorpay = Razorpay();
      _isInitialized = true;
    }

    _razorpay.clear(); // Clear any existing handlers

    // Set up new handlers
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, onSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, onFailure);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, onWallet);
  }

  static void dispose() {
    if (_isInitialized) {
      _razorpay.clear();
      _isInitialized = false;
    }
  }

  static Future<void> processPaymentWithLink({
    required String paymentLink,
    required Function(PaymentSuccessResponse) onSuccess,
    required Function(PaymentFailureResponse) onError,
    required Function(ExternalWalletResponse) onWallet,
  }) async {
    try {
      if (!_isInitialized) {
        _razorpay = Razorpay();
        _isInitialized = true;
      }

      _razorpay.clear();
      _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, onSuccess);
      _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, onError);
      _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, onWallet);

      // Extract the payment ID from the link
      final uri = Uri.parse(paymentLink);
      final paymentId = uri.pathSegments.last;

      var options = {
        'key': BuildConfig.instance.razorpayKey,
        'payment_link_id': paymentId,
      };

      _razorpay.open(options);
    } catch (e) {
      print('Error processing payment with link: $e');
      throw Exception('Error processing payment: $e');
    }
  }

static Future<void> processPayment({
   required int paymentId,  // Add this
  required String amount,
  required String paymentLink,
}) async {
  try {
    print('Starting payment process for amount: $amount');
    
    // Create order with the short ID
    final orderData = await PaymentService.createOrder(paymentId,amount, paymentLink);
    print('Order created with data: $orderData'); // Debug log

    if (!_isInitialized) {
      _razorpay = Razorpay();
      _isInitialized = true;
    }

    // Extract only the plink_xxx part if a full URL is provided
    final paymentLinkId = paymentLink.contains('plink_') 
        ? RegExp(r'plink_[a-zA-Z0-9]+').firstMatch(paymentLink)?.group(0) 
        : paymentLink;

    var options = {
      'key': BuildConfig.instance.razorpayKey,
      'amount': int.parse(amount) * 100,
      'order_id': orderData['order_id'],
      'name': 'Sports Academy',
    };

    print('Opening Razorpay with final options: $options'); // Debug log
    _razorpay.open(options);
  } catch (e, stack) {
    print('Payment processing error: $e');
    print('Stack trace: $stack');  // Added stack trace for better debugging
    throw Exception('Error processing payment: $e');
  }
}
}