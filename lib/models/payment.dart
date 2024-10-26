
class Payment {
  final int id;
  final int enrollmentId;
  final String amount;
  final String paymentLink;
  final String paymentStatus;
  final String paymentWeek;
  final String paymentMonth;
  final String? invoicePath;

  Payment({
    required this.id,
    required this.enrollmentId,
    required this.amount,
    required this.paymentLink,
    required this.paymentStatus,
    required this.paymentWeek,
    required this.paymentMonth,
    this.invoicePath,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      enrollmentId: json['enrollment_id'],
      amount: json['amount'],
      paymentLink: json['payment_link'],
      paymentStatus: json['payment_status'],
      paymentWeek: json['payment_week'],
      paymentMonth: json['payment_month'],
      invoicePath: json['invoice_path'],
    );
  }

  String get monthName {
    final months = [
      'January', 'February', 'March', 'April',
      'May', 'June', 'July', 'August',
      'September', 'October', 'November', 'December'
    ];
    return months[int.parse(paymentMonth) - 1];
  }
}