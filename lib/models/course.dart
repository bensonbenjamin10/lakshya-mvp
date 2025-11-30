import 'package:lakshya_mvp/core/models/base_model.dart';

enum CourseCategory {
  acca,
  ca,
  cma,
  bcomMba,
}

class Course extends BaseModel {
  final String id;
  final String slug;
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
  
  // Pricing fields
  final double price;
  final double? salePrice;
  final String currency;
  final int freeTrialDays;
  final bool isFree;

  Course({
    required this.id,
    required this.slug,
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
    this.price = 0.0,
    this.salePrice,
    this.currency = 'INR',
    this.freeTrialDays = 0,
    this.isFree = false,
  });
  
  /// Get the effective price (sale price if available, otherwise regular price)
  double get effectivePrice => salePrice ?? price;
  
  /// Check if course is on sale
  bool get isOnSale => salePrice != null && salePrice! < price;
  
  /// Get discount percentage
  int get discountPercentage {
    if (!isOnSale || price == 0) return 0;
    return ((price - salePrice!) / price * 100).round();
  }
  
  /// Check if course has free trial
  bool get hasFreeTrial => freeTrialDays > 0;
  
  /// Format price for display
  String get formattedPrice {
    if (isFree || price == 0) return 'Free';
    return '₹${price.toStringAsFixed(0)}';
  }
  
  /// Format effective price for display
  String get formattedEffectivePrice {
    if (isFree || effectivePrice == 0) return 'Free';
    return '₹${effectivePrice.toStringAsFixed(0)}';
  }

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
    final json = <String, dynamic>{
      'slug': slug,
      'title': title,
      'description': description,
      'category': categoryString,
      'duration': duration,
      'level': level,
      'highlights': highlights,
      'image_url': imageUrl,
      'is_popular': isPopular,
      'is_active': true,
      'price': price,
      'currency': currency,
      'free_trial_days': freeTrialDays,
      'is_free': isFree,
    };

    // Only include id if it's not empty (for updates)
    if (id.isNotEmpty) {
      json['id'] = id;
    }

    // Include optional fields
    if (brochureUrl != null) {
      json['brochure_url'] = brochureUrl;
    }
    if (salePrice != null) {
      json['sale_price'] = salePrice;
    }

    return json;
  }

  /// Create Course from JSON (Supabase format)
  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as String,
      slug: json['slug'] as String? ?? json['id'] as String,
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
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      salePrice: (json['sale_price'] as num?)?.toDouble(),
      currency: json['currency'] as String? ?? 'INR',
      freeTrialDays: json['free_trial_days'] as int? ?? 0,
      isFree: json['is_free'] as bool? ?? false,
    );
  }
}

