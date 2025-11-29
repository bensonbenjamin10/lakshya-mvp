import 'package:lakshya_mvp/services/payment/interfaces/payment_request.dart';
import 'package:lakshya_mvp/services/payment/interfaces/payment_result.dart';

/// Abstract payment provider interface following SOLID principles
/// 
/// Single Responsibility: Handles payment operations for a specific provider
/// Open/Closed: Extensible via implementation, closed for modification
/// Liskov Substitution: All providers are interchangeable
/// Interface Segregation: Focused on payment operations only
/// Dependency Inversion: Depend on this abstraction, not concrete implementations
abstract class PaymentProvider {
  /// Initialize the payment provider
  /// Returns true if initialization was successful
  Future<bool> initialize();

  /// Check if this provider is available on the current platform
  bool get isAvailable;

  /// Get the provider name (e.g., 'razorpay', 'revenuecat')
  String get providerName;

  /// Initiate a payment transaction
  /// 
  /// [request] - Payment request containing amount, course, student info, etc.
  /// Returns PaymentResult with transaction details
  Future<PaymentResult> initiatePayment(PaymentRequest request);

  /// Verify a payment transaction
  /// 
  /// [transactionId] - Transaction ID from the payment provider
  /// [orderId] - Order ID associated with the transaction
  /// Returns PaymentVerificationResult with verification status
  Future<PaymentVerificationResult> verifyPayment({
    required String transactionId,
    required String orderId,
  });

  /// Process a refund
  /// 
  /// [transactionId] - Original transaction ID
  /// [amount] - Amount to refund (null for full refund)
  /// [reason] - Reason for refund
  /// Returns PaymentResult with refund details
  Future<PaymentResult> refundPayment({
    required String transactionId,
    double? amount,
    String? reason,
  });

  /// Get payment status
  /// 
  /// [transactionId] - Transaction ID to check
  /// Returns PaymentResult with current status
  Future<PaymentResult> getPaymentStatus(String transactionId);
}

