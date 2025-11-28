import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Analytics service for tracking user behavior and events
/// 
/// Wraps Firebase Analytics with error handling and provides
/// a clean interface for tracking events throughout the app.
class AnalyticsService {
  static FirebaseAnalytics? _analytics;
  static FirebaseAnalyticsObserver? _observer;

  /// Initialize Firebase Analytics
  /// Returns true if initialization was successful
  static Future<bool> initialize() async {
    try {
      _analytics = FirebaseAnalytics.instance;
      _observer = FirebaseAnalyticsObserver(analytics: _analytics!);
      
      // Set analytics collection enabled (can be disabled for privacy)
      await _analytics!.setAnalyticsCollectionEnabled(true);
      
      debugPrint('Firebase Analytics initialized successfully');
      return true;
    } catch (e) {
      debugPrint('Error initializing Firebase Analytics: $e');
      return false;
    }
  }

  /// Get the analytics instance
  static FirebaseAnalytics? get analytics => _analytics;

  /// Get the analytics observer for GoRouter
  static FirebaseAnalyticsObserver? get observer => _observer;

  /// Log a screen view
  /// 
  /// [screenName] - Name of the screen being viewed
  /// [screenClass] - Optional screen class name
  static Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    try {
      await _analytics?.logScreenView(
        screenName: screenName,
        screenClass: screenClass,
      );
    } catch (e) {
      debugPrint('Error logging screen view: $e');
    }
  }

  /// Log a custom event
  /// 
  /// [eventName] - Name of the event
  /// [parameters] - Optional event parameters
  static Future<void> logEvent({
    required String eventName,
    Map<String, Object>? parameters,
  }) async {
    try {
      await _analytics?.logEvent(
        name: eventName,
        parameters: parameters,
      );
    } catch (e) {
      debugPrint('Error logging event $eventName: $e');
    }
  }

  /// Log lead submission event
  static Future<void> logLeadSubmission({
    String? courseId,
    required String source,
    required String inquiryType,
    String? country,
  }) async {
    await logEvent(
      eventName: 'lead_submission',
      parameters: {
        if (courseId != null) 'course_id': courseId,
        'source': source,
        'inquiry_type': inquiryType,
        if (country != null) 'country': country,
      },
    );
  }

  /// Log course view event
  static Future<void> logCourseView({
    required String courseId,
    required String courseName,
  }) async {
    await logEvent(
      eventName: 'course_view',
      parameters: {
        'course_id': courseId,
        'course_name': courseName,
      },
    );
  }

  /// Log CTA click event
  static Future<void> logCtaClick({
    required String ctaLocation,
    String? courseId,
  }) async {
    await logEvent(
      eventName: 'cta_click',
      parameters: {
        'cta_location': ctaLocation,
        if (courseId != null) 'course_id': courseId,
      },
    );
  }

  /// Log video play event
  static Future<void> logVideoPlay({
    required String videoId,
    String? videoTitle,
  }) async {
    await logEvent(
      eventName: 'video_play',
      parameters: {
        'video_id': videoId,
        if (videoTitle != null) 'video_title': videoTitle,
      },
    );
  }

  /// Log WhatsApp click event
  static Future<void> logWhatsAppClick({
    required String sourceLocation,
  }) async {
    await logEvent(
      eventName: 'whatsapp_click',
      parameters: {
        'source_location': sourceLocation,
      },
    );
  }

  /// Set user property (for authenticated users)
  static Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {
    try {
      await _analytics?.setUserProperty(name: name, value: value);
    } catch (e) {
      debugPrint('Error setting user property: $e');
    }
  }

  /// Set user ID (for authenticated users)
  static Future<void> setUserId(String? userId) async {
    try {
      await _analytics?.setUserId(id: userId);
    } catch (e) {
      debugPrint('Error setting user ID: $e');
    }
  }
}

