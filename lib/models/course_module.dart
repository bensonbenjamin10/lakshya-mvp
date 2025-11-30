import 'package:lakshya_mvp/core/models/base_model.dart';

/// Content type for module content
enum ContentType {
  url,
  markdown,
  html,
}

extension ContentTypeExtension on ContentType {
  String get name {
    switch (this) {
      case ContentType.url:
        return 'url';
      case ContentType.markdown:
        return 'markdown';
      case ContentType.html:
        return 'html';
    }
  }

  static ContentType fromString(String? value) {
    switch (value) {
      case 'markdown':
        return ContentType.markdown;
      case 'html':
        return ContentType.html;
      default:
        return ContentType.url;
    }
  }
}

/// Course module model representing a learning module within a course
class CourseModule extends BaseModel {
  final String id;
  final String courseId;
  final int moduleNumber;
  final String title;
  final String? description;
  final ModuleType type;
  final String? contentUrl;
  final String? contentBody;
  final ContentType contentType;
  final int? durationMinutes;
  final bool isRequired;
  final DateTime? unlockDate;
  final int displayOrder;
  final bool isFreePreview;
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
    this.contentBody,
    this.contentType = ContentType.url,
    this.durationMinutes,
    this.isRequired = true,
    this.unlockDate,
    this.displayOrder = 0,
    this.isFreePreview = false,
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
      if (contentBody != null) 'content_body': contentBody,
      'content_type': contentType.name,
      if (durationMinutes != null) 'duration_minutes': durationMinutes,
      'is_required': isRequired,
      if (unlockDate != null) 'unlock_date': unlockDate!.toIso8601String(),
      'display_order': displayOrder,
      'is_free_preview': isFreePreview,
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
      contentBody: json['content_body'] as String?,
      contentType: ContentTypeExtension.fromString(json['content_type'] as String?),
      durationMinutes: json['duration_minutes'] as int?,
      isRequired: json['is_required'] as bool? ?? true,
      unlockDate: json['unlock_date'] != null
          ? DateTime.parse(json['unlock_date'] as String)
          : null,
      displayOrder: json['display_order'] as int? ?? 0,
      isFreePreview: json['is_free_preview'] as bool? ?? false,
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
