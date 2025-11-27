enum CourseCategory {
  acca,
  ca,
  cma,
  bcomMba,
}

class Course {
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
}

