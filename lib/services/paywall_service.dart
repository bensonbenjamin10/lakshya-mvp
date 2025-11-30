import 'package:flutter/foundation.dart';
import 'package:lakshya_mvp/models/enrollment.dart';
import 'package:lakshya_mvp/models/course.dart';
import 'package:lakshya_mvp/models/course_module.dart';

/// Access status result for paywall checks
class AccessStatus {
  final bool hasAccess;
  final AccessType accessType;
  final String? reason;
  final int? trialDaysRemaining;
  final DateTime? trialEndsAt;
  final bool canStartTrial;
  final int trialDaysAvailable;

  const AccessStatus({
    required this.hasAccess,
    required this.accessType,
    this.reason,
    this.trialDaysRemaining,
    this.trialEndsAt,
    this.canStartTrial = false,
    this.trialDaysAvailable = 0,
  });

  factory AccessStatus.fullAccess() => const AccessStatus(
        hasAccess: true,
        accessType: AccessType.paid,
      );

  factory AccessStatus.freeCourse() => const AccessStatus(
        hasAccess: true,
        accessType: AccessType.freeCourse,
      );

  factory AccessStatus.trial({
    required int daysRemaining,
    required DateTime endsAt,
  }) =>
      AccessStatus(
        hasAccess: true,
        accessType: AccessType.trial,
        trialDaysRemaining: daysRemaining,
        trialEndsAt: endsAt,
      );

  factory AccessStatus.trialExpired() => const AccessStatus(
        hasAccess: false,
        accessType: AccessType.none,
        reason: 'Your free trial has expired. Please subscribe to continue.',
      );

  factory AccessStatus.paymentRequired({
    bool canStartTrial = false,
    int trialDays = 0,
  }) =>
      AccessStatus(
        hasAccess: false,
        accessType: AccessType.none,
        reason: canStartTrial
            ? 'Start your $trialDays-day free trial to access this content.'
            : 'Payment required to access this content.',
        canStartTrial: canStartTrial,
        trialDaysAvailable: trialDays,
      );

  factory AccessStatus.freePreview() => const AccessStatus(
        hasAccess: true,
        accessType: AccessType.freePreview,
      );

  factory AccessStatus.locked() => const AccessStatus(
        hasAccess: false,
        accessType: AccessType.none,
        reason: 'This content is locked. Please complete payment to access.',
      );

  factory AccessStatus.notEnrolled() => const AccessStatus(
        hasAccess: false,
        accessType: AccessType.none,
        reason: 'You are not enrolled in this course.',
      );
}

/// Types of access a user can have
enum AccessType {
  paid, // Full paid access
  trial, // Active trial
  freeCourse, // Course is free
  freePreview, // Module is free preview
  none, // No access
}

/// Service for managing paywall and access control logic
/// 
/// Centralizes all access checking to ensure consistent behavior
/// across the app.
class PaywallService {
  PaywallService._();

  /// Check if user has access to a course
  /// 
  /// Returns [AccessStatus] with details about access level
  static AccessStatus checkCourseAccess({
    required Course course,
    Enrollment? enrollment,
  }) {
    // Course is free - always accessible
    if (course.isFree || course.price == 0) {
      return AccessStatus.freeCourse();
    }

    // Not enrolled
    if (enrollment == null) {
      return AccessStatus.paymentRequired(
        canStartTrial: course.hasFreeTrial,
        trialDays: course.freeTrialDays,
      );
    }

    // Check payment status
    if (enrollment.paymentStatus == PaymentStatus.paid ||
        enrollment.paymentStatus == PaymentStatus.notRequired) {
      return AccessStatus.fullAccess();
    }

    // Check trial status
    if (enrollment.trialEndsAt != null) {
      if (enrollment.isTrialActive) {
        return AccessStatus.trial(
          daysRemaining: enrollment.trialDaysRemaining,
          endsAt: enrollment.trialEndsAt!,
        );
      } else if (enrollment.isTrialExpired) {
        return AccessStatus.trialExpired();
      }
    }

    // No payment, no trial - check if trial can be started
    return AccessStatus.paymentRequired(
      canStartTrial: course.hasFreeTrial && enrollment.trialStartedAt == null,
      trialDays: course.freeTrialDays,
    );
  }

  /// Check if user has access to a specific module
  /// 
  /// Free preview modules are accessible regardless of payment status
  static AccessStatus checkModuleAccess({
    required Course course,
    required CourseModule module,
    Enrollment? enrollment,
  }) {
    // Free preview module - always accessible
    if (module.isFreePreview) {
      return AccessStatus.freePreview();
    }

    // Check course-level access
    return checkCourseAccess(course: course, enrollment: enrollment);
  }

  /// Check if a module is locked for a user
  static bool isModuleLocked({
    required Course course,
    required CourseModule module,
    Enrollment? enrollment,
  }) {
    final access = checkModuleAccess(
      course: course,
      module: module,
      enrollment: enrollment,
    );
    return !access.hasAccess;
  }

  /// Get a user-friendly message for the current access status
  static String getAccessMessage(AccessStatus status) {
    switch (status.accessType) {
      case AccessType.paid:
        return 'Full access';
      case AccessType.trial:
        return '${status.trialDaysRemaining} days left in trial';
      case AccessType.freeCourse:
        return 'Free course';
      case AccessType.freePreview:
        return 'Free preview';
      case AccessType.none:
        return status.reason ?? 'Access restricted';
    }
  }

  /// Log access check for debugging
  static void logAccessCheck({
    required String courseId,
    String? moduleId,
    required AccessStatus status,
  }) {
    debugPrint(
      'PaywallService: Course $courseId${moduleId != null ? ', Module $moduleId' : ''} - '
      'Access: ${status.hasAccess}, Type: ${status.accessType.name}',
    );
  }
}

