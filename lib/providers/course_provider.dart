import 'package:flutter/foundation.dart';
import 'package:lakshya_mvp/core/repositories/course_repository.dart';
import 'package:lakshya_mvp/models/course.dart';

/// Course provider following Provider pattern and SOLID principles
/// 
/// Manages course state and delegates data access to CourseRepository.
/// Dependency Inversion: depends on CourseRepository abstraction, not concrete implementation.
class CourseProvider with ChangeNotifier {
  final CourseRepository _repository;

  List<Course> _courses = [];
  Course? _selectedCourse;
  bool _isLoading = false;
  String? _error;

  CourseProvider(this._repository) {
    _loadCourses();
  }

  List<Course> get courses => _courses;
  Course? get selectedCourse => _selectedCourse;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> _loadCourses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _courses = await _repository.getAll();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      debugPrint('Error loading courses: $e');
      notifyListeners();
    }
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

  /// Refresh courses list
  Future<void> refresh() async {
    await _loadCourses();
  }

  /// Get course by ID
  Future<Course?> getCourseById(String id) async {
    try {
      return await _repository.getById(id);
    } catch (e) {
      debugPrint('Error fetching course by ID: $e');
      return null;
    }
  }

  /// Get courses by category (async from repository)
  Future<List<Course>> fetchCoursesByCategory(CourseCategory category) async {
    try {
      return await _repository.getByCategory(category);
    } catch (e) {
      debugPrint('Error fetching courses by category: $e');
      return [];
    }
  }

  /// Get popular courses (async from repository)
  Future<List<Course>> fetchPopularCourses() async {
    try {
      return await _repository.getPopularCourses();
    } catch (e) {
      debugPrint('Error fetching popular courses: $e');
      return [];
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
