class PaymentHistory {
  final int id;
  final String? invoiceNumber;
  final String amount;
  final String paymentLink;
  final String? orderId;
  final String? paymentId;
  final String paymentStatus;
  final String? paymentDate;
  final String? invoicePath;
  final int isInvoiceGenerated;
  final int invoiceType;
  final String courseName;
  final String level;
  final DateTime createdAt;
  final DateTime updatedAt;
    final String? paymentMonth;  // Changed to String to match API
  final int? paymentYear;

  PaymentHistory({
    required this.id,
    this.invoiceNumber,
    required this.amount,
    required this.paymentLink,
    this.orderId,
    this.paymentId,
    required this.paymentStatus,
    this.paymentDate,
    this.invoicePath,
    required this.isInvoiceGenerated,
    required this.invoiceType,
    required this.courseName,
    required this.level,
    required this.createdAt,
    required this.updatedAt,
      this.paymentMonth,
    this.paymentYear,
  });

  factory PaymentHistory.fromJson(Map<String, dynamic> json) {
    return PaymentHistory(
      id: json['id'] ?? 0,
      invoiceNumber: json['invoice_number'],
      amount: json['amount'] ?? '0',
      paymentLink: json['payment_link'] ?? '',
      orderId: json['order_id'],
      paymentId: json['payment_id'],
      paymentStatus: json['payment_status'] ?? '0',
      paymentDate: json['payment_date'],
      invoicePath: json['invoice_path'],
      isInvoiceGenerated: json['is_invoice_generated'] ?? 0,
      invoiceType: json['invoice_type'] ?? 1,
      courseName: json['name'] ?? '',
      level: json['level'] ?? '',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : DateTime.now(),
      paymentMonth: json['payment_month'],
      paymentYear: json['payment_year'],
    );
  }
}