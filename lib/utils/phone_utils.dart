/// Phone number utility functions for formatting and validation

class PhoneUtils {
  PhoneUtils._();

  /// Default country code (India)
  static const String defaultCountryCode = '+91';

  /// Format phone number to E.164 international format
  /// 
  /// Examples:
  /// - "9876543210" → "+919876543210"
  /// - "09876543210" → "+919876543210"
  /// - "+919876543210" → "+919876543210"
  /// - "91 98765 43210" → "+919876543210"
  static String formatToE164(String phone, {String countryCode = defaultCountryCode}) {
    // Remove all non-digit characters except leading +
    String cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
    
    // If already has +, assume it's formatted
    if (cleaned.startsWith('+')) {
      return cleaned;
    }
    
    // Remove leading zeros
    cleaned = cleaned.replaceFirst(RegExp(r'^0+'), '');
    
    // If starts with country code without +, add +
    if (cleaned.startsWith('91') && cleaned.length > 10) {
      return '+$cleaned';
    }
    
    // Add country code
    return '$countryCode$cleaned';
  }

  /// Validate phone number (basic validation)
  /// 
  /// Checks:
  /// - Length is at least 10 digits
  /// - Contains only digits (after cleaning)
  static bool isValidPhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');
    return cleaned.length >= 10;
  }

  /// Validate Indian phone number specifically
  static bool isValidIndianPhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    // Remove country code if present
    String number = cleaned;
    if (number.startsWith('91') && number.length > 10) {
      number = number.substring(2);
    }
    
    // Indian mobile numbers are 10 digits starting with 6-9
    if (number.length != 10) return false;
    if (!RegExp(r'^[6-9]').hasMatch(number)) return false;
    
    return true;
  }

  /// Format phone for display (masked)
  /// 
  /// Example: "+919876543210" → "+91 98** *** **10"
  static String maskForDisplay(String phone) {
    final e164 = formatToE164(phone);
    if (e164.length < 10) return phone;
    
    final countryCode = e164.substring(0, 3); // +91
    final first2 = e164.substring(3, 5);
    final last2 = e164.substring(e164.length - 2);
    
    return '$countryCode $first2** *** **$last2';
  }

  /// Format phone for display (full, with spaces)
  /// 
  /// Example: "+919876543210" → "+91 98765 43210"
  static String formatForDisplay(String phone) {
    final e164 = formatToE164(phone);
    if (e164.length < 12) return phone;
    
    // Format as: +91 98765 43210
    return '${e164.substring(0, 3)} ${e164.substring(3, 8)} ${e164.substring(8)}';
  }

  /// Extract country code from phone number
  static String? extractCountryCode(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleaned.startsWith('+')) {
      // Common country codes
      if (cleaned.startsWith('+91')) return '+91'; // India
      if (cleaned.startsWith('+1')) return '+1';   // USA/Canada
      if (cleaned.startsWith('+44')) return '+44'; // UK
      if (cleaned.startsWith('+971')) return '+971'; // UAE
    }
    return null;
  }

  /// Get the national number (without country code)
  static String getNationalNumber(String phone) {
    final e164 = formatToE164(phone);
    
    // Remove country code
    if (e164.startsWith('+91')) {
      return e164.substring(3);
    }
    if (e164.startsWith('+1')) {
      return e164.substring(2);
    }
    if (e164.startsWith('+')) {
      // Generic: assume 2-3 digit country code
      return e164.substring(e164.length > 12 ? 4 : 3);
    }
    
    return e164;
  }
}

/// Country codes for phone number selection
class CountryCode {
  final String code;
  final String name;
  final String flag;

  const CountryCode({
    required this.code,
    required this.name,
    required this.flag,
  });

  /// Common country codes
  static const List<CountryCode> common = [
    CountryCode(code: '+91', name: 'India', flag: '🇮🇳'),
    CountryCode(code: '+1', name: 'USA', flag: '🇺🇸'),
    CountryCode(code: '+44', name: 'UK', flag: '🇬🇧'),
    CountryCode(code: '+971', name: 'UAE', flag: '🇦🇪'),
    CountryCode(code: '+65', name: 'Singapore', flag: '🇸🇬'),
    CountryCode(code: '+61', name: 'Australia', flag: '🇦🇺'),
    CountryCode(code: '+49', name: 'Germany', flag: '🇩🇪'),
    CountryCode(code: '+33', name: 'France', flag: '🇫🇷'),
  ];

  static CountryCode get india => common.first;
}

