import 'package:lakshya_mvp/core/models/base_model.dart';

/// Course module model representing a learning module within a course
class CourseModule extends BaseModel {
  final String id;
  final String courseId;
  final int moduleNumber;
  final String title;
  final String? description;
  final ModuleType type;
  final String? contentUrl;
  final int? durationMinutes;
  final bool isRequired;
  final DateTime? unlockDate;
  final int displayOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  CourseModule({
    required this.id,
    required this.courseId,
    required this.moduleNumber,
    required this.title,
    this.description,
    required this.type,
    this.contentUrl,
    this.durationMinutes,
    this.isRequired = true,
    this.unlockDate,
    this.displayOrder = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_id': courseId,
      'module_number': moduleNumber,
      'title': title,
      if (description != null) 'description': description,
      'type': type.name,
      if (contentUrl != null) 'content_url': contentUrl,
      if (durationMinutes != null) 'duration_minutes': durationMinutes,
      'is_required': isRequired,
      if (unlockDate != null) 'unlock_date': unlockDate!.toIso8601String(),
      'display_order': displayOrder,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory CourseModule.fromJson(Map<String, dynamic> json) {
    return CourseModule(
      id: json['id'] as String,
      courseId: json['course_id'] as String,
      moduleNumber: json['module_number'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      type: ModuleTypeExtension.fromString(json['type'] as String),
      contentUrl: json['content_url'] as String?,
      durationMinutes: json['duration_minutes'] as int?,
      isRequired: json['is_required'] as bool? ?? true,
      unlockDate: json['unlock_date'] != null
          ? DateTime.parse(json['unlock_date'] as String)
          : null,
      displayOrder: json['display_order'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}

/// Module type enum
enum ModuleType {
  video,
  reading,
  assignment,
  quiz,
  liveSession,
}

extension ModuleTypeExtension on ModuleType {
  String get displayName {
    switch (this) {
      case ModuleType.video:
        return 'Video';
      case ModuleType.reading:
        return 'Reading';
      case ModuleType.assignment:
        return 'Assignment';
      case ModuleType.quiz:
        return 'Quiz';
      case ModuleType.liveSession:
        return 'Live Session';
    }
  }

  String get icon {
    switch (this) {
      case ModuleType.video:
        return 'play_circle';
      case ModuleType.reading:
        return 'article';
      case ModuleType.assignment:
        return 'assignment';
      case ModuleType.quiz:
        return 'quiz';
      case ModuleType.liveSession:
        return 'videocam';
    }
  }

  static ModuleType fromString(String value) {
    switch (value) {
      case 'video':
        return ModuleType.video;
      case 'reading':
        return ModuleType.reading;
      case 'assignment':
        return ModuleType.assignment;
      case 'quiz':
        return ModuleType.quiz;
      case 'live_session':
        return ModuleType.liveSession;
      default:
        return ModuleType.video;
    }
  }
}

