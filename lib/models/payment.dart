import 'package:lakshya_mvp/core/models/base_model.dart';

/// Payment model representing a payment transaction
class Payment extends BaseModel {
  final String id;
  final String? enrollmentId;
  final String studentId;
  final String courseId;
  final double amount;
  final String currency;
  final PaymentStatus status;
  final PaymentProviderType provider;
  final String? paymentMethod;
  final String? transactionId;
  final String? providerOrderId;
  final PaymentPlan? paymentPlan;
  final int? installmentNumber;
  final Map<String, dynamic>? metadata;
  final String? failureReason;
  final double? refundAmount;
  final String? refundReason;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;

  Payment({
    required this.id,
    this.enrollmentId,
    required this.studentId,
    required this.courseId,
    required this.amount,
    this.currency = 'INR',
    required this.status,
    required this.provider,
    this.paymentMethod,
    this.transactionId,
    this.providerOrderId,
    this.paymentPlan,
    this.installmentNumber,
    this.metadata,
    this.failureReason,
    this.refundAmount,
    this.refundReason,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (enrollmentId != null) 'enrollment_id': enrollmentId,
      'student_id': studentId,
      'course_id': courseId,
      'amount': amount,
      'currency': currency,
      'payment_status': status.name,
      'payment_provider': provider.name,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (transactionId != null) 'transaction_id': transactionId,
      if (providerOrderId != null) 'provider_order_id': providerOrderId,
      if (paymentPlan != null) 'payment_plan': paymentPlan!.name,
      if (installmentNumber != null) 'installment_number': installmentNumber,
      if (metadata != null) 'metadata': metadata,
      if (failureReason != null) 'failure_reason': failureReason,
      if (refundAmount != null) 'refund_amount': refundAmount,
      if (refundReason != null) 'refund_reason': refundReason,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (completedAt != null) 'completed_at': completedAt!.toIso8601String(),
    };
  }

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] as String,
      enrollmentId: json['enrollment_id'] as String?,
      studentId: json['student_id'] as String,
      courseId: json['course_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'INR',
      status: PaymentStatusExtension.fromString(json['payment_status'] as String),
      provider: PaymentProviderTypeExtension.fromString(json['payment_provider'] as String),
      paymentMethod: json['payment_method'] as String?,
      transactionId: json['transaction_id'] as String?,
      providerOrderId: json['provider_order_id'] as String?,
      paymentPlan: json['payment_plan'] != null
          ? PaymentPlanExtension.fromString(json['payment_plan'] as String)
          : null,
      installmentNumber: json['installment_number'] as int?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      failureReason: json['failure_reason'] as String?,
      refundAmount: json['refund_amount'] != null
          ? (json['refund_amount'] as num).toDouble()
          : null,
      refundReason: json['refund_reason'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
    );
  }
}

/// Payment status enum
enum PaymentStatus {
  pending,
  processing,
  completed,
  failed,
  refunded,
  cancelled,
}

extension PaymentStatusExtension on PaymentStatus {
  String get displayName {
    switch (this) {
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.processing:
        return 'Processing';
      case PaymentStatus.completed:
        return 'Completed';
      case PaymentStatus.failed:
        return 'Failed';
      case PaymentStatus.refunded:
        return 'Refunded';
      case PaymentStatus.cancelled:
        return 'Cancelled';
    }
  }

  static PaymentStatus fromString(String value) {
    switch (value) {
      case 'pending':
        return PaymentStatus.pending;
      case 'processing':
        return PaymentStatus.processing;
      case 'completed':
        return PaymentStatus.completed;
      case 'failed':
        return PaymentStatus.failed;
      case 'refunded':
        return PaymentStatus.refunded;
      case 'cancelled':
        return PaymentStatus.cancelled;
      default:
        return PaymentStatus.pending;
    }
  }
}

/// Payment provider type enum
enum PaymentProviderType {
  razorpay,
  revenuecat,
  manual,
}

extension PaymentProviderTypeExtension on PaymentProviderType {
  static PaymentProviderType fromString(String value) {
    switch (value) {
      case 'razorpay':
        return PaymentProviderType.razorpay;
      case 'revenuecat':
        return PaymentProviderType.revenuecat;
      case 'manual':
        return PaymentProviderType.manual;
      default:
        return PaymentProviderType.manual;
    }
  }
}

/// Payment plan enum
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

  static PaymentPlan? fromString(String? value) {
    if (value == null) return null;
    switch (value) {
      case 'full':
        return PaymentPlan.full;
      case 'installment_3':
        return PaymentPlan.installment3;
      case 'installment_6':
        return PaymentPlan.installment6;
      default:
        return null;
    }
  }
}

