/// Payment result model containing transaction information
class PaymentResult {
  final bool success;
  final String? transactionId;
  final String? orderId;
  final PaymentStatus status;
  final String? errorMessage;
  final String? errorCode;
  final Map<String, dynamic>? providerData;

  const PaymentResult({
    required this.success,
    this.transactionId,
    this.orderId,
    required this.status,
    this.errorMessage,
    this.errorCode,
    this.providerData,
  });

  factory PaymentResult.success({
    required String transactionId,
    required String orderId,
    PaymentStatus status = PaymentStatus.completed,
    Map<String, dynamic>? providerData,
  }) {
    return PaymentResult(
      success: true,
      transactionId: transactionId,
      orderId: orderId,
      status: status,
      providerData: providerData,
    );
  }

  factory PaymentResult.failure({
    required String errorMessage,
    String? errorCode,
    PaymentStatus status = PaymentStatus.failed,
  }) {
    return PaymentResult(
      success: false,
      status: status,
      errorMessage: errorMessage,
      errorCode: errorCode,
    );
  }
}

/// Payment verification result
class PaymentVerificationResult {
  final bool verified;
  final PaymentStatus status;
  final String? transactionId;
  final String? orderId;
  final String? errorMessage;
  final Map<String, dynamic>? providerData;

  const PaymentVerificationResult({
    required this.verified,
    required this.status,
    this.transactionId,
    this.orderId,
    this.errorMessage,
    this.providerData,
  });

  factory PaymentVerificationResult.verified({
    required String transactionId,
    required String orderId,
    PaymentStatus status = PaymentStatus.completed,
    Map<String, dynamic>? providerData,
  }) {
    return PaymentVerificationResult(
      verified: true,
      status: status,
      transactionId: transactionId,
      orderId: orderId,
      providerData: providerData,
    );
  }

  factory PaymentVerificationResult.notVerified({
    required String errorMessage,
    PaymentStatus status = PaymentStatus.failed,
  }) {
    return PaymentVerificationResult(
      verified: false,
      status: status,
      errorMessage: errorMessage,
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
}

