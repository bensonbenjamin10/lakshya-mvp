import 'package:lakshya_mvp/core/models/base_model.dart';

enum CourseCategory {
  acca,
  ca,
  cma,
  bcomMba,
}

class Course extends BaseModel {
  final String id;
  final String title;
  final String description;
  final CourseCategory category;
  final String duration;
  final String level;
  final List<String> highlights;
  final String imageUrl;
  final String? brochureUrl;
  final bool isPopular;
  final String? enrollmentUrl;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.duration,
    required this.level,
    required this.highlights,
    required this.imageUrl,
    this.brochureUrl,
    this.isPopular = false,
    this.enrollmentUrl,
  });

  String get categoryName {
    switch (category) {
      case CourseCategory.acca:
        return 'ACCA';
      case CourseCategory.ca:
        return 'CA';
      case CourseCategory.cma:
        return 'CMA (US)';
      case CourseCategory.bcomMba:
        return 'B.Com & MBA';
    }
  }

  /// Convert category enum to database string
  String get categoryString {
    switch (category) {
      case CourseCategory.acca:
        return 'acca';
      case CourseCategory.ca:
        return 'ca';
      case CourseCategory.cma:
        return 'cma';
      case CourseCategory.bcomMba:
        return 'bcom_mba';
    }
  }

  /// Create Course from database string
  static CourseCategory categoryFromString(String value) {
    switch (value) {
      case 'acca':
        return CourseCategory.acca;
      case 'ca':
        return CourseCategory.ca;
      case 'cma':
        return CourseCategory.cma;
      case 'bcom_mba':
        return CourseCategory.bcomMba;
      default:
        return CourseCategory.acca;
    }
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'slug': id, // Using id as slug for now
      'title': title,
      'description': description,
      'category': categoryString,
      'duration': duration,
      'level': level,
      'highlights': highlights,
      'image_url': imageUrl,
      'brochure_url': brochureUrl,
      'is_popular': isPopular,
      'is_active': true,
    };
  }

  /// Create Course from JSON (Supabase format)
  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      category: categoryFromString(json['category'] as String),
      duration: json['duration'] as String? ?? '',
      level: json['level'] as String? ?? '',
      highlights: (json['highlights'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      imageUrl: json['image_url'] as String? ?? '',
      brochureUrl: json['brochure_url'] as String?,
      isPopular: json['is_popular'] as bool? ?? false,
      enrollmentUrl: json['enrollment_url'] as String?,
    );
  }
}

