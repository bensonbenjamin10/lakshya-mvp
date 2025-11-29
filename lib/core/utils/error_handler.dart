import 'package:flutter/foundation.dart';

/// Centralized error handling utility
/// 
/// Provides consistent error handling patterns across the application.
class ErrorHandler {
  /// Handle and log errors consistently
  static void handleError(
    dynamic error, {
    String? context,
    void Function(String)? onError,
  }) {
    final errorMessage = _getErrorMessage(error);
    final logMessage = context != null ? '$context: $errorMessage' : errorMessage;
    
    debugPrint('ERROR: $logMessage');
    
    if (error is Exception) {
      debugPrint('Exception details: ${error.toString()}');
    }
    
    if (onError != null) {
      onError(errorMessage);
    }
  }

  /// Extract user-friendly error message from error
  /// Made public for use in repositories
  static String getErrorMessage(dynamic error) => _getErrorMessage(error);
  
  /// Extract user-friendly error message from error (private implementation)
  static String _getErrorMessage(dynamic error) {
    if (error is String) {
      return error;
    }
    
    if (error is Exception) {
      final errorString = error.toString();
      
      // Handle common Supabase errors
      if (errorString.contains('NetworkError') || errorString.contains('connection')) {
        return 'Network error. Please check your internet connection.';
      }
      
      if (errorString.contains('permission') || errorString.contains('RLS')) {
        return 'You do not have permission to perform this action.';
      }
      
      if (errorString.contains('duplicate') || errorString.contains('unique')) {
        return 'This record already exists.';
      }
      
      if (errorString.contains('not found')) {
        return 'The requested resource was not found.';
      }
      
      // Return the exception message if available
      return errorString;
    }
    
    return 'An unexpected error occurred. Please try again.';
  }

  /// Check if error is a network error
  static bool isNetworkError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('timeout');
  }

  /// Check if error is a permission error
  static bool isPermissionError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('permission') ||
        errorString.contains('rls') ||
        errorString.contains('unauthorized');
  }
}

