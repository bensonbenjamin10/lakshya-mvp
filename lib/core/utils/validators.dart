// Validation utilities following DRY principles
// 
// Reusable validation logic used throughout the app.
// Single source of truth for validation rules.

/// Email validation regex pattern
final RegExp _emailRegex = RegExp(
  r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
);

/// Phone validation regex pattern (supports international formats)
final RegExp _phoneRegex = RegExp(
  r'^[\+]?[(]?[0-9]{1,4}[)]?[-\s\.]?[(]?[0-9]{1,4}[)]?[-\s\.]?[0-9]{1,9}$',
);

/// Validate email address
String? validateEmail(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Email is required';
  }
  if (!_emailRegex.hasMatch(value.trim())) {
    return 'Please enter a valid email address';
  }
  return null;
}

/// Validate phone number
String? validatePhone(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Phone number is required';
  }
  if (value.trim().length < 10) {
    return 'Please enter a valid phone number';
  }
  if (!_phoneRegex.hasMatch(value.trim())) {
    return 'Please enter a valid phone number';
  }
  return null;
}

/// Validate required field
String? validateRequired(String? value, {String fieldName = 'This field'}) {
  if (value == null || value.trim().isEmpty) {
    return '$fieldName is required';
  }
  return null;
}

/// Validate minimum length
String? validateMinLength(String? value, int minLength, {String fieldName = 'This field'}) {
  if (value == null || value.trim().isEmpty) {
    return '$fieldName is required';
  }
  if (value.trim().length < minLength) {
    return '$fieldName must be at least $minLength characters';
  }
  return null;
}

/// Validate password strength
String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Password is required';
  }
  if (value.length < 8) {
    return 'Password must be at least 8 characters';
  }
  if (!value.contains(RegExp(r'[A-Z]'))) {
    return 'Password must contain at least one uppercase letter';
  }
  if (!value.contains(RegExp(r'[a-z]'))) {
    return 'Password must contain at least one lowercase letter';
  }
  if (!value.contains(RegExp(r'[0-9]'))) {
    return 'Password must contain at least one number';
  }
  return null;
}
