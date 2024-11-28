import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../config/build_config.dart';
import '../../models/payment.dart';
import '../../services/student_service.dart';
import '../../services/razorpay_service.dart';

class PaymentListScreen extends StatefulWidget {
  final int studentId;
  final String studentName;

  const PaymentListScreen({
    Key? key,
    required this.studentId,
    required this.studentName,
  }) : super(key: key);

  @override
  _PaymentListScreenState createState() => _PaymentListScreenState();
}

class _PaymentListScreenState extends State<PaymentListScreen> {
  late Future<List<Payment>> _payments;
  bool _isProcessingPayment = false;

  @override
  void initState() {
    super.initState();
    _payments = _loadPayments();
    _initializeRazorpay();
  }

  void _initializeRazorpay() {
    RazorpayService.initRazorpay(
      onSuccess: _handlePaymentSuccess,
      onFailure: _handlePaymentError,
      onWallet: _handleExternalWallet,
    );
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    setState(() => _isProcessingPayment = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payment Successful!'),
        backgroundColor: Colors.green,
      ),
    );
    // Refresh payments list
    setState(() {
      _payments = _loadPayments();
    });
  }

 void _handlePaymentError(PaymentFailureResponse response) {
    setState(() => _isProcessingPayment = false);
    
    // Check if the error is due to user cancellation
    if (response.code == 2 || // Standard cancellation code
        response.message?.toLowerCase().contains('cancelled') == true ||
        response.message == 'undefined') { // Handle undefined error as cancellation
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange),
                SizedBox(width: 8),
                Text('Payment Cancelled'),
              ],
            ),
            content: const Text(
              'You have cancelled the payment process. Would you like to try again?',
              style: TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Close',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Refresh the payments list
                  setState(() {
                    _payments = _loadPayments();
                  });
                },
                child: const Text(
                  'Retry',
                  style: TextStyle(color: Color(0xFF303030)),
                ),
              ),
            ],
          );
        },
      );
    } else {
      // Handle other types of payment failures
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment Failed: ${response.message ?? 'Error occurred'}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: () {
              setState(() {
                _payments = _loadPayments();
              });
            },
          ),
        ),
      );
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    setState(() => _isProcessingPayment = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('External Wallet Selected: ${response.walletName}'),
      ),
    );
  }

  Future<List<Payment>> _loadPayments() async {
    try {
      final payments = await StudentService.getPendingPayments(widget.studentId);
      return payments;
    } catch (e) {
      throw Exception('Failed to load payments: $e');
    }
  }

 Future<void> _processPayment(Payment payment) async {
    setState(() => _isProcessingPayment = true);
    
    try {
      final uri = Uri.parse(payment.paymentLink);
      final paymentLinkId = uri.pathSegments.last;
      
      // Remove currency symbol and convert to proper number format
      final cleanAmount = payment.amount.replaceAll('₹', '').replaceAll(',', '').trim();
      print('Payment Link/ID being passed: $paymentLinkId');
      print('Amount being passed: $cleanAmount');
      
      await RazorpayService.processPayment(
        amount: cleanAmount,
        paymentLink: paymentLinkId,
          paymentId: payment.id  // Add this parameter
      );
    } catch (e) {
      setState(() => _isProcessingPayment = false);
      if (mounted) {
        if (e.toString().toLowerCase().contains('cancelled') ||
            e.toString() == 'undefined') {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                title: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Payment Cancelled'),
                  ],
                ),
                content: const Text(
                  'You have cancelled the payment process. Would you like to try again?',
                  style: TextStyle(fontSize: 16),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Close',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _processPayment(payment);
                    },
                    child: const Text(
                      'Retry',
                      style: TextStyle(color: Color(0xFF303030)),
                    ),
                  ),
                ],
              );
            },
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error initiating payment: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: () => _processPayment(payment),
              ),
            ),
          );
        }
      }
    }
  }

 Future<void> _processCombinedPayment() async {
    setState(() => _isProcessingPayment = true);
    
    try {
      final response = await StudentService.getCombinedPaymentOrder(widget.studentId);
      
      if (!mounted) return;
      
      if (response != null && response['success'] == true) {
        final paymentLinkId = response['data']['razorpay_order_id'];
        final amount = response['data']['amount'];
        
        final amountInPaisa = (double.parse(amount.toString()) * 100).round();
        
        var options = {
          'key': BuildConfig.instance.razorpayKey,
          'payment_link_id': paymentLinkId,
          'amount': amountInPaisa,
          'prefill': {
            'name': widget.studentName,
          },
          'theme': {
            'color': '#303030',
          }
        };

        RazorpayService.initRazorpay(
          onSuccess: _handlePaymentSuccess,
          onFailure: _handlePaymentError,
          onWallet: _handleExternalWallet,
        );

        RazorpayService.razorpay.open(options);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessingPayment = false);
      
      if (e.toString().toLowerCase().contains('cancelled') ||
          e.toString() == 'undefined') {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange),
                  SizedBox(width: 8),
                  Text('Payment Cancelled'),
                ],
              ),
              content: const Text(
                'You have cancelled the payment process. Would you like to try again?',
                style: TextStyle(fontSize: 16),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Close',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _processCombinedPayment();
                  },
                  child: const Text(
                    'Retry',
                    style: TextStyle(color: Color(0xFF303030)),
                  ),
                ),
              ],
            );
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error initiating payment: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Payments'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.studentName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your pending fee payments',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _payments = _loadPayments();
                });
              },
              child: FutureBuilder<List<Payment>>(
                future: _payments,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Error: ${snapshot.error}',
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _payments = _loadPayments();
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF303030),
                            ),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  final payments = snapshot.data ?? [];
                  if (payments.isEmpty) {
                    return const Center(
                      child: Text('No pending payments'),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: payments.length,
                    itemBuilder: (context, index) {
                      final payment = payments[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Amount Due',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        '₹${payment.amount}',
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red[50],
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      'Pending',
                                      style: TextStyle(
                                        color: Colors.red[700],
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                payment.enrollment.course.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _isProcessingPayment 
                                      ? null 
                                      : () => _processPayment(payment),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF303030),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    disabledBackgroundColor: Colors.grey,
                                  ),
                                  child: _isProcessingPayment
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        )
                                      : const Text(
                                          'Pay Now',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isProcessingPayment 
                      ? null 
                      : _processCombinedPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF303030),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    disabledBackgroundColor: Colors.grey,
                  ),
                  child: _isProcessingPayment
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Pay All Dues',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    RazorpayService.dispose();
    super.dispose();
  }
}