import 'package:lakshya_mvp/models/payment.dart';

/// Payment transaction model for tracking individual transactions
/// 
/// Used for installment payments where one enrollment may have multiple transactions
class PaymentTransaction {
  final String id;
  final String paymentId;
  final double amount;
  final PaymentStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? transactionId;
  final String? failureReason;

  PaymentTransaction({
    required this.id,
    required this.paymentId,
    required this.amount,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.transactionId,
    this.failureReason,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'payment_id': paymentId,
      'amount': amount,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      if (completedAt != null) 'completed_at': completedAt!.toIso8601String(),
      if (transactionId != null) 'transaction_id': transactionId,
      if (failureReason != null) 'failure_reason': failureReason,
    };
  }

  factory PaymentTransaction.fromJson(Map<String, dynamic> json) {
    return PaymentTransaction(
      id: json['id'] as String,
      paymentId: json['payment_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      status: PaymentStatusExtension.fromString(json['status'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      transactionId: json['transaction_id'] as String?,
      failureReason: json['failure_reason'] as String?,
    );
  }
}

