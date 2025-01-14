class Payment {
  final int id;
  final String amount;
  final String paymentLink;
  final PaymentEnrollment enrollment;
  final String paymentStatus;
  final String paymentWeek;
  final String paymentMonth;
    final String paymentYear; // Add this line
  final String? invoicePath;

  Payment({
    required this.id,
    required this.amount,
    required this.paymentLink,
    required this.enrollment,
    required this.paymentStatus,
    required this.paymentWeek,
    required this.paymentMonth,
     required this.paymentYear,
    this.invoicePath,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    try {
      return Payment(
        id: json['id'] as int? ?? 0,
        amount: (json['amount'] ?? '0').toString(),
        paymentLink: json['payment_link'] as String? ?? '',
        enrollment: PaymentEnrollment.fromJson(
          (json['enrollment'] as Map<String, dynamic>?) ?? {},
        ),
        paymentStatus: json['payment_status'] as String? ?? 'pending',
        paymentWeek: (json['payment_week'] ?? '').toString(),
        paymentMonth: (json['payment_month'] ?? '').toString(),
        paymentYear: (json['payment_year'] ?? '').toString(),
        invoicePath: json['invoice_path'] as String?,
      );
    } catch (e) {
      print('Error parsing Payment: $json');
      print('Error details: $e');
      rethrow;
    }
  }

  String get monthName {
    try {
      if (paymentMonth.isEmpty) return '';
      final monthNumber = int.parse(paymentMonth);
      final months = [
        'January', 'February', 'March', 'April',
        'May', 'June', 'July', 'August',
        'September', 'October', 'November', 'December'
      ];
      if (monthNumber >= 1 && monthNumber <= 12) {
        return months[monthNumber - 1];
      }
      return paymentMonth;
    } catch (e) {
      return paymentMonth;
    }
  }
}

class PaymentEnrollment {
  final Course course;
  final String franchiseName;
  final String centerName;

  PaymentEnrollment({
    required this.course,
    required this.franchiseName,
    required this.centerName,
  });

  factory PaymentEnrollment.fromJson(Map<String, dynamic> json) {
    try {
      return PaymentEnrollment(
        course: Course.fromJson(
          (json['course'] as Map<String, dynamic>?) ?? {},
        ),
        franchiseName: json['franchise_name'] as String? ?? '',
        centerName: json['center_name'] as String? ?? '',
      );
    } catch (e) {
      print('Error parsing PaymentEnrollment: $json');
      print('Error details: $e');
      rethrow;
    }
  }
}

class Course {
  final String name;

  Course({
    required this.name,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    try {
      return Course(
        name: json['name'] as String? ?? '',
      );
    } catch (e) {
      print('Error parsing Course: $json');
      print('Error details: $e');
      rethrow;
    }
  }
}