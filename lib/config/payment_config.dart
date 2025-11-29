/// Payment configuration
/// 
/// Credentials will be added later when ready to integrate payment providers
class PaymentConfig {
  /// Razorpay Key ID
  /// Get this from: https://dashboard.razorpay.com/app/keys
  /// Add to environment variables or secure storage
  static String get razorpayKeyId {
    // TODO: Replace with actual key from environment/config
    // Example: return const String.fromEnvironment('RAZORPAY_KEY_ID');
    return '';
  }

  /// Razorpay Key Secret
  /// Get this from: https://dashboard.razorpay.com/app/keys
  /// Should be stored securely (not in client code)
  static String get razorpayKeySecret {
    // TODO: Replace with actual secret from secure storage
    // Note: Secret should be kept server-side, not in client
    return '';
  }

  /// RevenueCat API Key
  /// Get this from: https://app.revenuecat.com/projects
  /// Add to environment variables or secure storage
  static String get revenueCatApiKey {
    // TODO: Replace with actual API key from environment/config
    // Example: return const String.fromEnvironment('REVENUECAT_API_KEY');
    return '';
  }

  /// Default currency
  static const String defaultCurrency = 'INR';

  /// Enable mock payments for development
  static const bool enableMockPayments = true; // Set to false in production
}

