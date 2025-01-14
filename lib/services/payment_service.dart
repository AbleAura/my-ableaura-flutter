// lib/services/payment_service.dart

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/build_config.dart';
import '../models/payment_history.dart';
import '../models/payment.dart';
import 'razorpay_service.dart';
import 'package:http/http.dart' as http;

class PaymentService {
  static final _dio = Dio();
  static String get _baseUrl => BuildConfig.instance.baseUrl;


  // Get Pending Payments
 static Future<List<Payment>> getPendingPayments(int studentId) async {
  try {
    final response = await _dio.post(
      '$_baseUrl/student/get/pending/payments',
      data: {
        'student_id': studentId,
      },
      options: Options(headers: await _getHeaders()),
    );

    if (response.data['success'] == true) {
      return (response.data['data'] as List)
          .map((json) => Payment.fromJson(json))
          .toList();
    } else {
      throw response.data['message'] ?? 'Failed to load payments';
    }
  } catch (e) {
    throw 'Failed to load pending payments';
  }
}

  // Get Completed Payments
  static Future<List<PaymentHistory>> getCompletedPayments(int studentId) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/student/get/completed/payments',
        data: {
          'student_id': studentId,
        },
        options: Options(headers: await _getHeaders()),
      );

      if (response.data['success'] == true) {
        return (response.data['data'] as List)
            .map((json) => PaymentHistory.fromJson(json))
            .toList();
      } else {
        throw response.data['message'] ?? 'Failed to load payments';
      }
    } catch (e) {
      throw 'Failed to load completed payments';
    }
  }

  // Get Headers with auth token
  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

static Future<String> getFullPaymentLinkId(String shortUrl) async {
  try {
    final dio = Dio();
    // First try the short URL
    final response = await dio.get('https://rzp.io/i/$shortUrl', 
      options: Options(
        followRedirects: true,
        maxRedirects: 5,
        validateStatus: (status) => true,
      )
    );

    print('Final URL: ${response.realUri.toString()}');
    
    // Extract plink_xxx from the final URL
    final match = RegExp(r'plink_[a-zA-Z0-9]+').firstMatch(response.realUri.toString());
    if (match != null) {
      print('Found payment link ID: ${match.group(0)}');
      return match.group(0) ?? '';
    }

    throw Exception('Payment link ID not found');
  } catch (e) {
    print('Error getting full payment link: $e');
    throw Exception('Failed to get payment link: $e');
  }
}
// In payment_service.dart
static Future<Map<String, dynamic>> createOrder(int paymentId,String amount, String paymentLink) async {
  try {
    // If it's already in plink_xxx format, use it directly
    String razorpayLinkId = paymentLink;
       final fullPaymentLinkId = await getFullPaymentLinkId(paymentLink);
         print('Got full payment link ID: $fullPaymentLinkId');
    // If it's a URL, try to extract plink_xxx
    if (paymentLink.contains('/')) {
      razorpayLinkId = paymentLink.split('/').firstWhere(
        (segment) => segment.startsWith('plink_'),
        orElse: () => paymentLink // fallback to original if not found
      );
    }

    print('Creating order with linkId: $razorpayLinkId'); // Debug log

    final response = await _dio.post(
      '$_baseUrl/create-order',
      data: {
        'amount': int.parse(amount),
         'razorpay_link_id': fullPaymentLinkId,
          'payment_id': paymentId  // Add this
      },
      options: Options(headers: await _getHeaders()),
    );
    
    print('Create order response: ${response.data}'); // Debug log

    if (response.data['success'] == true) {
      return {
        ...response.data['data'],
        'payment_link_id': fullPaymentLinkId  // Pass along the full ID
      };
    } else {
      throw response.data['message'] ?? 'Failed to create order';
    }
  } catch (e) {
    print('Create order error: $e'); // Debug log
    throw 'Failed to create order: $e';
  }
}
  // Download and Open Invoice
  static Future<void> downloadAndOpenInvoice(String invoicePath) async {
    try {
      debugPrint('Starting invoice download from path: $invoicePath');
      
      // 1. Validate URL
      final uri = Uri.parse(invoicePath);
      debugPrint('Parsed URI: $uri');

      // 2. Make HTTP request with error handling
      final response = await http.get(uri).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          debugPrint('Download timeout after 30 seconds');
          throw Exception('Download timeout - please try again');
        },
      );

      debugPrint('Download response status code: ${response.statusCode}');
      debugPrint('Response headers: ${response.headers}');
      
      if (response.statusCode != 200) {
        debugPrint('Error response body: ${response.body}');
        throw Exception('Failed to download invoice: HTTP ${response.statusCode}');
      }

      // 3. Get file info
      final contentType = response.headers['content-type'];
      final contentLength = response.headers['content-length'];
      debugPrint('Content-Type: $contentType');
      debugPrint('Content-Length: $contentLength');

      // 4. Create local file
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      String fileExtension = '.pdf'; // Default to PDF
      
      // Try to determine file extension from content-type
      if (contentType != null) {
        if (contentType.contains('pdf')) fileExtension = '.pdf';
        else if (contentType.contains('image/jpeg')) fileExtension = '.jpg';
        else if (contentType.contains('image/png')) fileExtension = '.png';
      }
      
      final filePath = '${directory.path}/invoice_$timestamp$fileExtension';
      debugPrint('Saving file to: $filePath');

      // 5. Save file
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      debugPrint('File saved successfully');

      // 6. Verify file exists and has content
      final savedFile = File(filePath);
      if (!await savedFile.exists()) {
        debugPrint('Error: Saved file does not exist');
        throw Exception('Failed to save invoice file');
      }
      
      final fileSize = await savedFile.length();
      debugPrint('Saved file size: $fileSize bytes');
      
      if (fileSize == 0) {
        debugPrint('Error: Saved file is empty');
        throw Exception('Downloaded file is empty');
      }

      // 7. Open file
      debugPrint('Attempting to open file');
      final result = await OpenFile.open(filePath);
      debugPrint('OpenFile result: ${result.type} - ${result.message}');

      if (result.type != ResultType.done) {
        throw Exception('Failed to open file: ${result.message}');
      }

    } catch (e, stackTrace) {
      debugPrint('Error in downloadAndOpenInvoice: $e');
      debugPrint('Stack trace: $stackTrace');
      throw Exception('Failed to download invoice: $e');
    }
  }

  // Process Payment
  static Future<void> processPayment(
    int paymentId,
    String orderId, 
    String amount, 
    String paymentLinkId
  ) async {
    try {
      // Extract payment_link_id from the payment link URL
      final uri = Uri.parse(paymentLinkId);
      final id = uri.pathSegments.last;
      
     await RazorpayService.processPayment(
       paymentId: paymentId,
  amount: amount,
  paymentLink: id,  // This should be the full payment link or plink_xxx ID
);
    } catch (e) {
      throw 'Failed to process payment';
    }
  }

  // Get Payment Status
  static Future<String> getPaymentStatus(int paymentId) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/payments/status/$paymentId',
        options: Options(headers: await _getHeaders()),
      );

      if (response.data['success'] == true) {
        return response.data['data']['status'];
      } else {
        throw response.data['message'] ?? 'Failed to get payment status';
      }
    } catch (e) {
      throw 'Failed to get payment status';
    }
  }

  // Get Payment Receipt
  static Future<String> getPaymentReceipt(String paymentId) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/payments/receipt/$paymentId',
        options: Options(headers: await _getHeaders()),
      );

      if (response.data['success'] == true) {
        return response.data['data']['receipt_url'];
      } else {
        throw response.data['message'] ?? 'Failed to get receipt';
      }
    } catch (e) {
      throw 'Failed to get payment receipt';
    }
  }

  // New method to get discounted amount
  static Future<Map<String, dynamic>> applyFreeSessionDiscount(int paymentId, int rewardId) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/free-sessions/amend',
        data: {
          'payment_id': paymentId,
          'reward_id': rewardId
        },
        options: Options(headers: await _getHeaders()),
      );

      if (response.data['success'] == true) {
        return {
          'discount_attempt_id': response.data['data']['discount_attempt_id'],
          'original_amount': response.data['data']['original_amount'],
          'discounted_amount': response.data['data']['discounted_amount'],
        };
      } else {
        throw response.data['message'] ?? 'Failed to apply discount';
      }
    } catch (e) {
      throw 'Failed to apply discount: $e';
    }
  }

  // New method to complete discount application
  static Future<void> completeFreeSessionDiscount(int discountAttemptId) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/free-sessions/amend/apply',
        data: {
          'discount_attempt_id': discountAttemptId
        },
        options: Options(headers: await _getHeaders()),
      );

      if (response.data['success'] != true) {
        throw response.data['message'] ?? 'Failed to complete discount application';
      }
    } catch (e) {
      throw 'Failed to complete discount application: $e';
    }
  }
}