import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../models/payment.dart';
import '../services/student_service.dart';
import '../services/razorpay_service.dart';

class PendingPaymentsScreen extends StatefulWidget {
  final int enrollmentId;
  final String studentName;

  const PendingPaymentsScreen({
    Key? key,
    required this.enrollmentId,
    required this.studentName,
  }) : super(key: key);

  @override
  _PendingPaymentsScreenState createState() => _PendingPaymentsScreenState();
}

class _PendingPaymentsScreenState extends State<PendingPaymentsScreen> {
  late Future<List<Payment>> _payments;
  bool _isProcessingPayment = false;

  @override
  void initState() {
    super.initState();
    _loadPayments();
    _initializePayments();
  }

  void _loadPayments() {
    _payments = StudentService.getPendingPayments(widget.enrollmentId);
  }

  void _initializePayments() {
    RazorpayService.initRazorpay(
      onSuccess: _handlePaymentSuccess,
      onFailure: _handlePaymentError,
      onWallet: _handleExternalWallet,
    );
  }

  void _refreshPayments() {
    setState(() {
      _loadPayments();
    });
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    setState(() => _isProcessingPayment = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payment Successful!'),
        backgroundColor: Colors.green,
      ),
    );
    _refreshPayments();
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() => _isProcessingPayment = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment Failed: ${response.message ?? 'Error occurred'}'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    setState(() => _isProcessingPayment = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('External Wallet Selected: ${response.walletName}'),
      ),
    );
  }

  Future<void> _processPayment(Payment payment) async {
    setState(() => _isProcessingPayment = true);

    try {
      // Extract payment_link_id from the payment link URL
      final uri = Uri.parse(payment.paymentLink);
      final paymentLinkId = uri.pathSegments.last;
      
      await RazorpayService.processPayment(
          paymentId: payment.id, // Added paymentId
        amount: payment.amount,
        paymentLink: paymentLinkId,
      );
    } catch (e) {
      setState(() => _isProcessingPayment = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error initiating payment: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    RazorpayService.dispose();
    super.dispose();
  }

  Widget _buildPaymentCard(Payment payment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
                      'Amount',
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Due Month',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      payment.monthName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (payment.paymentStatus.toLowerCase() != 'paid') ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isProcessingPayment
                      ? null
                      : () => _processPayment(payment),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF303030),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
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
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
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
            padding: const EdgeInsets.all(16.0),
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
                Text(
                  'Your pending payments',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
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
                          onPressed: _refreshPayments,
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
                  itemBuilder: (context, index) => _buildPaymentCard(payments[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}