// lib/screens/payments/completed_payments_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/payment_history.dart';
import '../../services/payment_service.dart';
import '../../models/payment_history.dart';
import '../../services/payment_service.dart';
import 'package:get/get.dart';

class CompletedPaymentsScreen extends StatefulWidget {
 final int studentId;
 final String studentName;

 const CompletedPaymentsScreen({
   Key? key,
   required this.studentId,
   required this.studentName,
 }) : super(key: key);

 @override
 State<CompletedPaymentsScreen> createState() => _CompletedPaymentsScreenState();
}

class _CompletedPaymentsScreenState extends State<CompletedPaymentsScreen> {
 bool _isLoading = true;
 List<PaymentHistory> _payments = [];

 @override
 void initState() {
   super.initState();
   _loadPayments();
 }

 Future<void> _loadPayments() async {
   setState(() => _isLoading = true);
   try {
     _payments = await PaymentService.getCompletedPayments(widget.studentId);
     setState(() => _isLoading = false);
   } catch (e) {
     setState(() => _isLoading = false);
     if (mounted) {
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text(e.toString())),
       );
     }
   }
 }

 @override
 Widget build(BuildContext context) {
   return Scaffold(
     appBar: AppBar(
       title: const Text('Payment History'),
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
                 'Your payment history',
                 style: TextStyle(
                   color: Colors.grey[600],
                   fontSize: 14,
                 ),
               ),
             ],
           ),
         ),
         Expanded(
           child: RefreshIndicator(
             onRefresh: _loadPayments,
             child: _isLoading
                 ? const Center(child: CircularProgressIndicator())
                 : _payments.isEmpty
                     ? Center(
                         child: Column(
                           mainAxisAlignment: MainAxisAlignment.center,
                           children: [
                             Icon(Icons.history, size: 64, color: Colors.grey),
                             SizedBox(height: 16),
                             Text(
                               'No payment history found',
                               style: TextStyle(color: Colors.grey),
                             ),
                           ],
                         ),
                       )
                     : ListView.builder(
                         padding: EdgeInsets.all(16),
                         itemCount: _payments.length,
                         itemBuilder: (context, index) {
                           final payment = _payments[index];
                           return Card(
                             margin: EdgeInsets.only(bottom: 12),
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
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
    if (payment.isInvoiceGenerated == 1)
      IconButton(
        icon: Icon(Icons.download),
        onPressed: () async {
          try {
            await PaymentService.downloadAndOpenInvoice(
              payment.invoicePath!,
            );
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(e.toString())),
              );
            }
          }
        },
      )
    else
      Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.orange[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Invoice Pending',
          style: TextStyle(
            color: Colors.orange[800],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
  ],
),
                                   SizedBox(height: 8),
                                   Text(
                                     payment.courseName,
                                     style: TextStyle(
                                       fontWeight: FontWeight.w500,
                                     ),
                                   ),
                                   Text(
                                     'Level ${payment.level}',
                                     style: TextStyle(
                                       color: Colors.grey[600],
                                       fontSize: 14,
                                     ),
                                   ),
                                   SizedBox(height: 8),
                                 Text(
  payment.paymentDate != null 
      ? 'Paid on ${DateFormat('MMM d, y').format(DateTime.parse(payment.paymentDate!))}' 
      : 'Paid on ${DateFormat('MMM d, y').format(payment.createdAt)}',  // Use createdAt as fallback
  style: TextStyle(
    color: Colors.grey[600],
    fontSize: 14,
  ),
),
                                   if (payment.invoiceNumber != null)
                                     Text(
                                       'Invoice: ${payment.invoiceNumber}',
                                       style: TextStyle(
                                         color: Colors.grey[600],
                                         fontSize: 14,
                                       ),
                                     ),
                                 ],
                               ),
                             ),
                           );
                         },
                       ),
           ),
         ),
       ],
     ),
   );
 }
}