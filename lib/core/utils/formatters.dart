import 'package:intl/intl.dart';

/// Formatting utilities following DRY principles
/// 
/// Reusable formatting logic used throughout the app.
/// Single source of truth for formatting rules.

/// Format date to readable string
String formatDate(DateTime date, {String format = 'MMM dd, yyyy'}) {
  return DateFormat(format).format(date);
}

/// Format date and time
String formatDateTime(DateTime dateTime) {
  return DateFormat('MMM dd, yyyy • hh:mm a').format(dateTime);
}

/// Format phone number (basic formatting)
String formatPhone(String phone) {
  final cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
  if (cleaned.length >= 10) {
    return cleaned.replaceAllMapped(
      RegExp(r'(\d{3})(\d{3})(\d{4})'),
      (match) => '${match[1]}-${match[2]}-${match[3]}',
    );
  }
  return phone;
}

/// Format currency (for future use)
String formatCurrency(double amount, {String symbol = '₹'}) {
  return '$symbol${amount.toStringAsFixed(2)}';
}

/// Format relative time (e.g., "2 hours ago")
String formatRelativeTime(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inDays > 365) {
    return '${(difference.inDays / 365).floor()} year${(difference.inDays / 365).floor() > 1 ? 's' : ''} ago';
  } else if (difference.inDays > 30) {
    return '${(difference.inDays / 30).floor()} month${(difference.inDays / 30).floor() > 1 ? 's' : ''} ago';
  } else if (difference.inDays > 0) {
    return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
  } else if (difference.inHours > 0) {
    return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
  } else if (difference.inMinutes > 0) {
    return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
  } else {
    return 'Just now';
  }
}
