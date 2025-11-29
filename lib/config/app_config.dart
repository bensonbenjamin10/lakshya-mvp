/// Centralized app configuration
class AppConfig {
  AppConfig._();

  // ============================================
  // WHATSAPP CONFIGURATION
  // ============================================
  
  /// WhatsApp Business number (international format, no + or spaces)
  static const String whatsAppNumber = '919585361392';
  
  /// Default messages for different contexts
  static const String whatsAppDefaultMessage = 
      'Hi! I have a question about Lakshya Institute.';
  
  static const String whatsAppCourseInquiry = 
      'Hi! I\'m interested in your courses.';
  
  static const String whatsAppContactMessage = 
      'Hi! I need assistance with course information.';

  // ============================================
  // CONTACT INFORMATION
  // ============================================
  
  static const String contactEmail = 'info@lakshyainstitute.com';
  static const String contactPhone = '+91 95853 61392';
  
  // ============================================
  // SOCIAL LINKS
  // ============================================
  
  static const String websiteUrl = 'https://lakshyainstitute.com';
  
  // ============================================
  // AUTHENTICATION REDIRECT URLS
  // ============================================
  
  /// Production app URL for email confirmations and password resets
  static const String productionAppUrl = 'https://paperlms-001.web.app';
  
  /// Development/local URL (for local testing)
  static const String localAppUrl = 'http://localhost:3000';
  
  /// Get the appropriate redirect URL based on environment
  /// On web, uses production URL; can be overridden with environment variables
  static String get authRedirectUrl {
    // Check for environment variable override
    const envUrl = String.fromEnvironment('AUTH_REDIRECT_URL');
    if (envUrl.isNotEmpty) {
      return envUrl;
    }
    // Default to production URL
    return productionAppUrl;
  }
  
  // Add more social links as needed
  // static const String instagramUrl = '';
  // static const String linkedInUrl = '';
}

