import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:lakshya_mvp/services/payment/interfaces/payment_provider.dart';
import 'package:lakshya_mvp/services/payment/providers/razorpay_provider.dart';
import 'package:lakshya_mvp/services/payment/providers/revenuecat_provider.dart';
import 'package:lakshya_mvp/services/payment/providers/mock_payment_provider.dart';

/// Factory for creating platform-specific payment providers
/// 
/// Follows Factory Pattern and Dependency Inversion Principle
/// Detects platform and returns appropriate provider
class PaymentProviderFactory {
  /// Get the appropriate payment provider for the current platform
  /// 
  /// Returns:
  /// - RazorpayPaymentProvider for Android and Web
  /// - RevenueCatPaymentProvider for iOS
  /// - MockPaymentProvider for testing/development
  static PaymentProvider createProvider({bool useMock = false}) {
    if (useMock) {
      return MockPaymentProvider();
    }

    // Detect platform
    if (kIsWeb) {
      // Web platform - use Razorpay
      return RazorpayPaymentProvider();
    } else if (Platform.isAndroid) {
      // Android platform - use Razorpay
      return RazorpayPaymentProvider();
    } else if (Platform.isIOS) {
      // iOS platform - use RevenueCat
      return RevenueCatPaymentProvider();
    } else {
      // Fallback to mock for unsupported platforms
      return MockPaymentProvider();
    }
  }

  /// Get all available providers for the current platform
  static List<PaymentProvider> getAvailableProviders() {
    final providers = <PaymentProvider>[];

    if (kIsWeb || Platform.isAndroid) {
      providers.add(RazorpayPaymentProvider());
    }

    if (Platform.isIOS) {
      providers.add(RevenueCatPaymentProvider());
    }

    // Always include mock for testing
    providers.add(MockPaymentProvider());

    return providers;
  }
}

