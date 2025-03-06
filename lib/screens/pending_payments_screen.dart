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

  Widget _buildPaymentCard(Payment payment, bool isTablet) {
    return Card(
      margin: EdgeInsets.only(bottom: isTablet ? 20 : 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
      ),
      elevation: isTablet ? 2 : 1,
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
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
                        fontSize: isTablet ? 16 : 14,
                      ),
                    ),
                    Text(
                      '₹${payment.amount}',
                      style: TextStyle(
                        fontSize: isTablet ? 30 : 24,
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
                        fontSize: isTablet ? 16 : 14,
                      ),
                    ),
                    Text(
                      payment.monthName,
                      style: TextStyle(
                        fontSize: isTablet ? 20 : 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (payment.paymentStatus.toLowerCase() != 'paid') ...[
              SizedBox(height: isTablet ? 24 : 16),
              SizedBox(
                width: double.infinity,
                height: isTablet ? 56 : 48,
                child: ElevatedButton(
                  onPressed: _isProcessingPayment
                      ? null
                      : () => _processPayment(payment),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF303030),
                    padding: EdgeInsets.symmetric(vertical: isTablet ? 16 : 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
                    ),
                  ),
                  child: _isProcessingPayment
                      ? SizedBox(
                          height: isTablet ? 24 : 20,
                          width: isTablet ? 24 : 20,
                          child: const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Pay Now',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isTablet ? 18 : 14,
                            fontWeight: FontWeight.bold,
                          ),
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
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pending Payments',
          style: TextStyle(
            fontSize: isTablet ? 24 : 20,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        toolbarHeight: isTablet ? 70 : 56,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.studentName,
                  style: TextStyle(
                    fontSize: isTablet ? 26 : 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: isTablet ? 12 : 8),
                Text(
                  'Your pending payments',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: isTablet ? 18 : 14,
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
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 48 : 24,
                          ),
                          child: Text(
                            'Error: ${snapshot.error}',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: isTablet ? 18 : 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: isTablet ? 24 : 16),
                        SizedBox(
                          height: isTablet ? 56 : 48,
                          child: ElevatedButton(
                            onPressed: _refreshPayments,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF303030),
                              padding: EdgeInsets.symmetric(
                                horizontal: isTablet ? 32 : 24,
                                vertical: isTablet ? 12 : 8,
                              ),
                            ),
                            child: Text(
                              'Retry',
                              style: TextStyle(
                                fontSize: isTablet ? 18 : 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final payments = snapshot.data ?? [];
                if (payments.isEmpty) {
                  return Center(
                    child: Text(
                      'No pending payments',
                      style: TextStyle(
                        fontSize: isTablet ? 18 : 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  );
                }

                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isTablet ? 700 : screenWidth,
                    ),
                    child: ListView.builder(
                      padding: EdgeInsets.all(isTablet ? 24 : 16),
                      itemCount: payments.length,
                      itemBuilder: (context, index) => _buildPaymentCard(payments[index], isTablet),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}