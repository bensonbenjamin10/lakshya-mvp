import 'package:flutter/foundation.dart';
import 'package:lakshya_mvp/models/course.dart';

class CourseProvider with ChangeNotifier {
  List<Course> _courses = [];
  Course? _selectedCourse;
  bool _isLoading = false;

  List<Course> get courses => _courses;
  Course? get selectedCourse => _selectedCourse;
  bool get isLoading => _isLoading;

  CourseProvider() {
    _loadCourses();
  }

  void _loadCourses() {
    _isLoading = true;
    notifyListeners();

    // Mock data - In production, this would fetch from an API
    _courses = [
      Course(
        id: 'acca-001',
        title: 'ACCA (Association of Chartered Certified Accountants)',
        description:
            'Globally recognized professional accounting qualification that opens doors to a successful career in finance and accounting worldwide.',
        category: CourseCategory.acca,
        duration: '24-36 months',
        level: 'Professional',
        highlights: [
          '13 papers covering accounting, finance, and business',
          'Globally recognized qualification',
          'Flexible study options',
          'Career support and guidance',
          'Access to global job opportunities',
        ],
        imageUrl: 'assets/images/acca.jpg',
        isPopular: true,
      ),
      Course(
        id: 'ca-001',
        title: 'CA (Chartered Accountancy)',
        description:
            'The premier accounting qualification in India, recognized for excellence in accounting, auditing, taxation, and financial management.',
        category: CourseCategory.ca,
        duration: '3-5 years',
        level: 'Professional',
        highlights: [
          'Three levels: Foundation, Intermediate, Final',
          'Articleship training program',
          'Highly respected in India and abroad',
          'Strong career prospects',
          'Comprehensive curriculum',
        ],
        imageUrl: 'assets/images/ca.jpg',
        isPopular: true,
      ),
      Course(
        id: 'cma-001',
        title: 'CMA (US) - Certified Management Accountant',
        description:
            'The leading management accounting certification in the United States, focusing on financial planning, analysis, control, and decision support.',
        category: CourseCategory.cma,
        duration: '12-18 months',
        level: 'Professional',
        highlights: [
          'Two-part examination',
          'Focus on management accounting',
          'US-based certification',
          'High earning potential',
          'Global recognition',
        ],
        imageUrl: 'assets/images/cma.jpg',
      ),
      Course(
        id: 'bcom-mba-001',
        title: 'Integrated B.Com & MBA',
        description:
            'A comprehensive dual-degree program combining undergraduate commerce education with advanced business management skills.',
        category: CourseCategory.bcomMba,
        duration: '5 years',
        level: 'Graduate',
        highlights: [
          'Dual degree program',
          'Industry-integrated curriculum',
          'Internship opportunities',
          'Placement assistance',
          'Holistic business education',
        ],
        imageUrl: 'assets/images/bcom-mba.jpg',
      ),
    ];

    _isLoading = false;
    notifyListeners();
  }

  void selectCourse(Course course) {
    _selectedCourse = course;
    notifyListeners();
  }

  void clearSelection() {
    _selectedCourse = null;
    notifyListeners();
  }

  List<Course> getCoursesByCategory(CourseCategory category) {
    return _courses.where((course) => course.category == category).toList();
  }

  List<Course> getPopularCourses() {
    return _courses.where((course) => course.isPopular).toList();
  }
}

