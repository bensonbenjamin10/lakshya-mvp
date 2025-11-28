import 'package:lakshya_mvp/core/models/base_model.dart';

enum VideoPromoType {
  welcome,
  promo,
  coursePreview,
  testimonial,
  faculty,
}

class VideoPromo extends BaseModel {
  final String id;
  final String vimeoId;
  final String title;
  final String? subtitle;
  final String? thumbnailUrl;
  final String? duration;
  final VideoPromoType type;
  final String? courseId;
  final bool isFeatured;
  final int displayOrder;
  final bool isActive;

  VideoPromo({
    required this.id,
    required this.vimeoId,
    required this.title,
    this.subtitle,
    this.thumbnailUrl,
    this.duration,
    required this.type,
    this.courseId,
    this.isFeatured = false,
    this.displayOrder = 0,
    this.isActive = true,
  });

  /// Convert type enum to database string
  String get typeString {
    switch (type) {
      case VideoPromoType.welcome:
        return 'welcome';
      case VideoPromoType.promo:
        return 'promo';
      case VideoPromoType.coursePreview:
        return 'course_preview';
      case VideoPromoType.testimonial:
        return 'testimonial';
      case VideoPromoType.faculty:
        return 'faculty';
    }
  }

  /// Create VideoPromoType from database string
  static VideoPromoType typeFromString(String value) {
    switch (value) {
      case 'welcome':
        return VideoPromoType.welcome;
      case 'promo':
        return VideoPromoType.promo;
      case 'course_preview':
        return VideoPromoType.coursePreview;
      case 'testimonial':
        return VideoPromoType.testimonial;
      case 'faculty':
        return VideoPromoType.faculty;
      default:
        return VideoPromoType.promo;
    }
  }

  @override
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'vimeo_id': vimeoId,
      'title': title,
      'type': typeString,
      'is_featured': isFeatured,
      'display_order': displayOrder,
      'is_active': isActive,
    };

    // Only include id if it's not empty (for updates)
    if (id.isNotEmpty) {
      json['id'] = id;
    }

    // Include optional fields
    if (subtitle != null) {
      json['subtitle'] = subtitle;
    }
    if (thumbnailUrl != null) {
      json['thumbnail_url'] = thumbnailUrl;
    }
    if (duration != null) {
      json['duration'] = duration;
    }
    if (courseId != null) {
      json['course_id'] = courseId;
    }

    return json;
  }

  /// Create VideoPromo from JSON (Supabase format)
  factory VideoPromo.fromJson(Map<String, dynamic> json) {
    return VideoPromo(
      id: json['id'] as String,
      vimeoId: json['vimeo_id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      duration: json['duration'] as String?,
      type: typeFromString(json['type'] as String),
      courseId: json['course_id'] as String?,
      isFeatured: json['is_featured'] as bool? ?? false,
      displayOrder: json['display_order'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}

