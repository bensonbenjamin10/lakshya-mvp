import 'package:lakshya_mvp/core/models/base_model.dart';
import 'package:lakshya_mvp/models/course_module.dart';

/// Student progress model tracking learning progress through course modules
class StudentProgress extends BaseModel {
  final String id;
  final String studentId;
  final String enrollmentId;
  final String moduleId;
  final ProgressStatus status;
  final DateTime? completionDate;
  final int timeSpentMinutes;
  final DateTime? lastAccessedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final CourseModule? module; // Populated when fetched with join

  StudentProgress({
    required this.id,
    required this.studentId,
    required this.enrollmentId,
    required this.moduleId,
    this.status = ProgressStatus.notStarted,
    this.completionDate,
    this.timeSpentMinutes = 0,
    this.lastAccessedAt,
    required this.createdAt,
    required this.updatedAt,
    this.module,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'enrollment_id': enrollmentId,
      'module_id': moduleId,
      'status': status.name,
      if (completionDate != null)
        'completion_date': completionDate!.toIso8601String(),
      'time_spent_minutes': timeSpentMinutes,
      if (lastAccessedAt != null)
        'last_accessed_at': lastAccessedAt!.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory StudentProgress.fromJson(Map<String, dynamic> json) {
    CourseModule? module;
    if (json['course_modules'] != null) {
      module = CourseModule.fromJson(
        json['course_modules'] as Map<String, dynamic>,
      );
    }

    return StudentProgress(
      id: json['id'] as String,
      studentId: json['student_id'] as String,
      enrollmentId: json['enrollment_id'] as String,
      moduleId: json['module_id'] as String,
      status: ProgressStatusExtension.fromString(
        json['status'] as String? ?? 'not_started',
      ),
      completionDate: json['completion_date'] != null
          ? DateTime.parse(json['completion_date'] as String)
          : null,
      timeSpentMinutes: json['time_spent_minutes'] as int? ?? 0,
      lastAccessedAt: json['last_accessed_at'] != null
          ? DateTime.parse(json['last_accessed_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      module: module,
    );
  }

  StudentProgress copyWith({
    String? id,
    String? studentId,
    String? enrollmentId,
    String? moduleId,
    ProgressStatus? status,
    DateTime? completionDate,
    int? timeSpentMinutes,
    DateTime? lastAccessedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    CourseModule? module,
  }) {
    return StudentProgress(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      enrollmentId: enrollmentId ?? this.enrollmentId,
      moduleId: moduleId ?? this.moduleId,
      status: status ?? this.status,
      completionDate: completionDate ?? this.completionDate,
      timeSpentMinutes: timeSpentMinutes ?? this.timeSpentMinutes,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      module: module ?? this.module,
    );
  }
}

/// Progress status enum
enum ProgressStatus {
  notStarted,
  inProgress,
  completed,
}

extension ProgressStatusExtension on ProgressStatus {
  String get displayName {
    switch (this) {
      case ProgressStatus.notStarted:
        return 'Not Started';
      case ProgressStatus.inProgress:
        return 'In Progress';
      case ProgressStatus.completed:
        return 'Completed';
    }
  }

  static ProgressStatus fromString(String value) {
    switch (value) {
      case 'not_started':
        return ProgressStatus.notStarted;
      case 'in_progress':
        return ProgressStatus.inProgress;
      case 'completed':
        return ProgressStatus.completed;
      default:
        return ProgressStatus.notStarted;
    }
  }
}

