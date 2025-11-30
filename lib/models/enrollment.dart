import 'package:lakshya_mvp/core/models/base_model.dart';
import 'package:lakshya_mvp/models/course.dart';

/// Enrollment model representing a student's enrollment in a course
class Enrollment extends BaseModel {
  final String id;
  final String studentId;
  final String courseId;
  final EnrollmentStatus status;
  final PaymentStatus? paymentStatus;
  final bool paymentRequired;
  final double progressPercentage;
  final DateTime enrolledAt;
  final DateTime? completedAt;
  final DateTime? lastAccessedAt;
  final DateTime? trialStartedAt;
  final DateTime? trialEndsAt;
  final Course? course; // Populated when fetched with join

  Enrollment({
    required this.id,
    required this.studentId,
    required this.courseId,
    this.status = EnrollmentStatus.pending,
    this.paymentStatus,
    this.paymentRequired = true,
    this.progressPercentage = 0.0,
    required this.enrolledAt,
    this.completedAt,
    this.lastAccessedAt,
    this.trialStartedAt,
    this.trialEndsAt,
    this.course,
  });
  
  /// Check if trial is currently active
  bool get isTrialActive {
    if (paymentStatus == PaymentStatus.paid || 
        paymentStatus == PaymentStatus.notRequired) {
      return false; // Not on trial - fully paid
    }
    if (trialEndsAt == null) return false;
    return DateTime.now().isBefore(trialEndsAt!);
  }
  
  /// Check if trial has expired
  bool get isTrialExpired {
    if (trialEndsAt == null) return false;
    return DateTime.now().isAfter(trialEndsAt!);
  }
  
  /// Get remaining trial days
  int get trialDaysRemaining {
    if (trialEndsAt == null) return 0;
    final remaining = trialEndsAt!.difference(DateTime.now()).inDays;
    return remaining > 0 ? remaining : 0;
  }
  
  /// Check if user has full access (paid or active trial)
  bool get hasFullAccess {
    if (paymentStatus == PaymentStatus.paid || 
        paymentStatus == PaymentStatus.notRequired) {
      return true;
    }
    return isTrialActive;
  }

  @override
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'student_id': studentId,
      'course_id': courseId,
      'status': status.name,
      'payment_required': paymentRequired,
      'progress_percentage': progressPercentage,
      'enrolled_at': enrolledAt.toIso8601String(),
    };
    
    // Only include id if it's not empty (for updates)
    if (id.isNotEmpty) {
      json['id'] = id;
    }
    
    // Include optional fields
    if (paymentStatus != null) {
      json['payment_status'] = paymentStatus!.dbValue;
    }
    if (completedAt != null) {
      json['completed_at'] = completedAt!.toIso8601String();
    }
    if (lastAccessedAt != null) {
      json['last_accessed_at'] = lastAccessedAt!.toIso8601String();
    }
    if (trialStartedAt != null) {
      json['trial_started_at'] = trialStartedAt!.toIso8601String();
    }
    if (trialEndsAt != null) {
      json['trial_ends_at'] = trialEndsAt!.toIso8601String();
    }
    
    return json;
  }

  factory Enrollment.fromJson(Map<String, dynamic> json) {
    // Handle nested course data
    Course? course;
    if (json['courses'] != null) {
      course = Course.fromJson(json['courses'] as Map<String, dynamic>);
    }

    return Enrollment(
      id: json['id'] as String,
      studentId: json['student_id'] as String,
      courseId: json['course_id'] as String,
      status: EnrollmentStatusExtension.fromString(
        json['status'] as String? ?? 'pending',
      ),
      paymentStatus: json['payment_status'] != null
          ? PaymentStatusExtension.fromString(json['payment_status'] as String)
          : null,
      paymentRequired: json['payment_required'] as bool? ?? true,
      progressPercentage: json['progress_percentage'] != null
          ? (json['progress_percentage'] as num).toDouble()
          : 0.0,
      enrolledAt: DateTime.parse(json['enrolled_at'] as String),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      lastAccessedAt: json['last_accessed_at'] != null
          ? DateTime.parse(json['last_accessed_at'] as String)
          : null,
      trialStartedAt: json['trial_started_at'] != null
          ? DateTime.parse(json['trial_started_at'] as String)
          : null,
      trialEndsAt: json['trial_ends_at'] != null
          ? DateTime.parse(json['trial_ends_at'] as String)
          : null,
      course: course,
    );
  }

  Enrollment copyWith({
    String? id,
    String? studentId,
    String? courseId,
    EnrollmentStatus? status,
    PaymentStatus? paymentStatus,
    bool? paymentRequired,
    double? progressPercentage,
    DateTime? enrolledAt,
    DateTime? completedAt,
    DateTime? lastAccessedAt,
    DateTime? trialStartedAt,
    DateTime? trialEndsAt,
    Course? course,
  }) {
    return Enrollment(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      courseId: courseId ?? this.courseId,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentRequired: paymentRequired ?? this.paymentRequired,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      enrolledAt: enrolledAt ?? this.enrolledAt,
      completedAt: completedAt ?? this.completedAt,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      trialStartedAt: trialStartedAt ?? this.trialStartedAt,
      trialEndsAt: trialEndsAt ?? this.trialEndsAt,
      course: course ?? this.course,
    );
  }
}

/// Enrollment status enum
enum EnrollmentStatus {
  pending,
  active,
  completed,
  dropped,
}

extension EnrollmentStatusExtension on EnrollmentStatus {
  String get displayName {
    switch (this) {
      case EnrollmentStatus.pending:
        return 'Pending';
      case EnrollmentStatus.active:
        return 'Active';
      case EnrollmentStatus.completed:
        return 'Completed';
      case EnrollmentStatus.dropped:
        return 'Dropped';
    }
  }

  static EnrollmentStatus fromString(String value) {
    switch (value) {
      case 'pending':
        return EnrollmentStatus.pending;
      case 'active':
        return EnrollmentStatus.active;
      case 'completed':
        return EnrollmentStatus.completed;
      case 'dropped':
        return EnrollmentStatus.dropped;
      default:
        return EnrollmentStatus.pending;
    }
  }
}

/// Payment status enum (for enrollments)
enum PaymentStatus {
  pending,
  partial,
  paid,
  notRequired,
}

extension PaymentStatusExtension on PaymentStatus {
  String get displayName {
    switch (this) {
      case PaymentStatus.pending:
        return 'Payment Pending';
      case PaymentStatus.partial:
        return 'Partially Paid';
      case PaymentStatus.paid:
        return 'Paid';
      case PaymentStatus.notRequired:
        return 'Not Required';
    }
  }
  
  /// Convert to database string value
  String get dbValue {
    switch (this) {
      case PaymentStatus.pending:
        return 'pending';
      case PaymentStatus.partial:
        return 'partial';
      case PaymentStatus.paid:
        return 'paid';
      case PaymentStatus.notRequired:
        return 'not_required';
    }
  }

  static PaymentStatus fromString(String value) {
    switch (value) {
      case 'pending':
        return PaymentStatus.pending;
      case 'partial':
        return PaymentStatus.partial;
      case 'paid':
        return PaymentStatus.paid;
      case 'not_required':
        return PaymentStatus.notRequired;
      default:
        return PaymentStatus.pending;
    }
  }
}

