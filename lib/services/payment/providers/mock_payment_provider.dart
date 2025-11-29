import 'package:flutter/foundation.dart';
import 'package:lakshya_mvp/services/payment/interfaces/payment_provider.dart';
import 'package:lakshya_mvp/services/payment/interfaces/payment_request.dart';
import 'package:lakshya_mvp/services/payment/interfaces/payment_result.dart';

/// Mock payment provider for testing and development
/// 
/// Simulates payment flow without actual payment processing
class MockPaymentProvider implements PaymentProvider {
  bool _initialized = false;
  final Map<String, PaymentResult> _mockTransactions = {};

  @override
  String get providerName => 'mock';

  @override
  bool get isAvailable => true; // Always available for testing

  @override
  Future<bool> initialize() async {
    _initialized = true;
    debugPrint('MockPaymentProvider initialized (for testing/development)');
    return true;
  }

  @override
  Future<PaymentResult> initiatePayment(PaymentRequest request) async {
    if (!_initialized) {
      await initialize();
    }

    // Simulate payment processing delay
    await Future.delayed(const Duration(seconds: 1));

    // Generate mock transaction ID
    final transactionId = 'mock_${DateTime.now().millisecondsSinceEpoch}';
    final orderId = 'order_${DateTime.now().millisecondsSinceEpoch}';

    // Store mock transaction
    final result = PaymentResult.success(
      transactionId: transactionId,
      orderId: orderId,
      status: PaymentStatus.completed,
      providerData: {
        'mock': true,
        'course_id': request.courseId,
        'amount': request.amount,
      },
    );

    _mockTransactions[transactionId] = result;

    debugPrint('Mock payment initiated: $transactionId for ${request.courseName}');
    return result;
  }

  @override
  Future<PaymentVerificationResult> verifyPayment({
    required String transactionId,
    required String orderId,
  }) async {
    // Simulate verification delay
    await Future.delayed(const Duration(milliseconds: 500));

    final transaction = _mockTransactions[transactionId];
    if (transaction != null && transaction.success) {
      return PaymentVerificationResult.verified(
        transactionId: transactionId,
        orderId: orderId,
        status: PaymentStatus.completed,
      );
    }

    return PaymentVerificationResult.notVerified(
      errorMessage: 'Transaction not found',
    );
  }

  @override
  Future<PaymentResult> refundPayment({
    required String transactionId,
    double? amount,
    String? reason,
  }) async {
    // Simulate refund delay
    await Future.delayed(const Duration(seconds: 1));

    final transaction = _mockTransactions[transactionId];
    if (transaction == null) {
      return PaymentResult.failure(
        errorMessage: 'Transaction not found',
        errorCode: 'NOT_FOUND',
      );
    }

    debugPrint('Mock refund processed: $transactionId, reason: $reason');
    return PaymentResult.success(
      transactionId: 'refund_${DateTime.now().millisecondsSinceEpoch}',
      orderId: transaction.orderId ?? '',
      status: PaymentStatus.refunded,
      providerData: {
        'original_transaction_id': transactionId,
        'refund_amount': amount,
        'reason': reason,
      },
    );
  }

  @override
  Future<PaymentResult> getPaymentStatus(String transactionId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final transaction = _mockTransactions[transactionId];
    if (transaction != null) {
      return transaction;
    }

    return PaymentResult.failure(
      errorMessage: 'Transaction not found',
      errorCode: 'NOT_FOUND',
      status: PaymentStatus.failed,
    );
  }

  /// Clear mock transactions (for testing)
  void clearTransactions() {
    _mockTransactions.clear();
  }
}

