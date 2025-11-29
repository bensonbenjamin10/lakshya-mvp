import 'package:flutter/foundation.dart';
import 'package:lakshya_mvp/services/payment/interfaces/payment_provider.dart';
import 'package:lakshya_mvp/services/payment/interfaces/payment_request.dart';
import 'package:lakshya_mvp/services/payment/interfaces/payment_result.dart';
import 'package:lakshya_mvp/services/payment/payment_provider_factory.dart';

/// Payment service that manages payment operations
/// 
/// Uses Dependency Inversion Principle - depends on PaymentProvider abstraction
/// Follows Single Responsibility - handles payment orchestration only
class PaymentService {
  final PaymentProvider _provider;
  bool _initialized = false;

  PaymentService({PaymentProvider? provider})
      : _provider = provider ?? PaymentProviderFactory.createProvider();

  /// Initialize the payment service
  Future<bool> initialize() async {
    if (_initialized) return true;

    try {
      final success = await _provider.initialize();
      if (success) {
        _initialized = true;
        debugPrint('PaymentService initialized with provider: ${_provider.providerName}');
      }
      return success;
    } catch (e) {
      debugPrint('Error initializing PaymentService: $e');
      return false;
    }
  }

  /// Get the current payment provider
  PaymentProvider get provider => _provider;

  /// Get the provider name
  String get providerName => _provider.providerName;

  /// Check if payment is available
  bool get isAvailable => _provider.isAvailable && _initialized;

  /// Initiate a payment
  /// 
  /// [request] - Payment request with course and student information
  /// Returns PaymentResult with transaction details
  Future<PaymentResult> initiatePayment(PaymentRequest request) async {
    if (!_initialized) {
      final initialized = await initialize();
      if (!initialized) {
        return PaymentResult.failure(
          errorMessage: 'Payment service not initialized',
          errorCode: 'NOT_INITIALIZED',
        );
      }
    }

    if (!_provider.isAvailable) {
      return PaymentResult.failure(
        errorMessage: 'Payment provider not available on this platform',
        errorCode: 'PROVIDER_UNAVAILABLE',
      );
    }

    try {
      return await _provider.initiatePayment(request);
    } catch (e) {
      debugPrint('Error initiating payment: $e');
      return PaymentResult.failure(
        errorMessage: e.toString(),
        errorCode: 'INITIATION_ERROR',
      );
    }
  }

  /// Verify a payment transaction
  /// 
  /// [transactionId] - Transaction ID from payment provider
  /// [orderId] - Order ID associated with the transaction
  /// Returns PaymentVerificationResult
  Future<PaymentVerificationResult> verifyPayment({
    required String transactionId,
    required String orderId,
  }) async {
    if (!_initialized) {
      return PaymentVerificationResult.notVerified(
        errorMessage: 'Payment service not initialized',
      );
    }

    try {
      return await _provider.verifyPayment(
        transactionId: transactionId,
        orderId: orderId,
      );
    } catch (e) {
      debugPrint('Error verifying payment: $e');
      return PaymentVerificationResult.notVerified(
        errorMessage: e.toString(),
      );
    }
  }

  /// Process a refund
  /// 
  /// [transactionId] - Original transaction ID
  /// [amount] - Amount to refund (null for full refund)
  /// [reason] - Reason for refund
  /// Returns PaymentResult
  Future<PaymentResult> refundPayment({
    required String transactionId,
    double? amount,
    String? reason,
  }) async {
    if (!_initialized) {
      return PaymentResult.failure(
        errorMessage: 'Payment service not initialized',
        errorCode: 'NOT_INITIALIZED',
      );
    }

    try {
      return await _provider.refundPayment(
        transactionId: transactionId,
        amount: amount,
        reason: reason,
      );
    } catch (e) {
      debugPrint('Error processing refund: $e');
      return PaymentResult.failure(
        errorMessage: e.toString(),
        errorCode: 'REFUND_ERROR',
      );
    }
  }

  /// Get payment status
  /// 
  /// [transactionId] - Transaction ID to check
  /// Returns PaymentResult with current status
  Future<PaymentResult> getPaymentStatus(String transactionId) async {
    if (!_initialized) {
      return PaymentResult.failure(
        errorMessage: 'Payment service not initialized',
        errorCode: 'NOT_INITIALIZED',
      );
    }

    try {
      return await _provider.getPaymentStatus(transactionId);
    } catch (e) {
      debugPrint('Error getting payment status: $e');
      return PaymentResult.failure(
        errorMessage: e.toString(),
        errorCode: 'STATUS_ERROR',
      );
    }
  }
}

