/// Payment request model containing all information needed to initiate a payment
class PaymentRequest {
  final String courseId;
  final String courseName;
  final String studentId;
  final String studentEmail;
  final String studentName;
  final double amount;
  final String currency;
  final PaymentPlan paymentPlan;
  final Map<String, dynamic>? metadata;

  const PaymentRequest({
    required this.courseId,
    required this.courseName,
    required this.studentId,
    required this.studentEmail,
    required this.studentName,
    required this.amount,
    this.currency = 'INR',
    this.paymentPlan = PaymentPlan.full,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'course_id': courseId,
      'course_name': courseName,
      'student_id': studentId,
      'student_email': studentEmail,
      'student_name': studentName,
      'amount': amount,
      'currency': currency,
      'payment_plan': paymentPlan.name,
      if (metadata != null) 'metadata': metadata,
    };
  }
}

/// Payment plan options
enum PaymentPlan {
  full,
  installment3,
  installment6,
}

extension PaymentPlanExtension on PaymentPlan {
  String get displayName {
    switch (this) {
      case PaymentPlan.full:
        return 'Full Payment';
      case PaymentPlan.installment3:
        return '3 Installments';
      case PaymentPlan.installment6:
        return '6 Installments';
    }
  }

  int get installmentCount {
    switch (this) {
      case PaymentPlan.full:
        return 1;
      case PaymentPlan.installment3:
        return 3;
      case PaymentPlan.installment6:
        return 6;
    }
  }
}

