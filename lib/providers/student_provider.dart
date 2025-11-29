import 'package:flutter/foundation.dart';
import 'package:lakshya_mvp/core/repositories/enrollment_repository.dart';
import 'package:lakshya_mvp/core/repositories/student_progress_repository.dart';
import 'package:lakshya_mvp/core/repositories/course_module_repository.dart';
import 'package:lakshya_mvp/models/enrollment.dart';
import 'package:lakshya_mvp/models/student_progress.dart';
import 'package:lakshya_mvp/models/course_module.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Student provider for managing student-specific data and statistics
class StudentProvider with ChangeNotifier {
  final EnrollmentRepository _enrollmentRepository;
  final StudentProgressRepository _progressRepository;
  final CourseModuleRepository _moduleRepository;
  final SupabaseClient _client;

  List<Enrollment> _enrollments = [];
  Map<String, List<StudentProgress>> _progressMap = {};
  Map<String, List<CourseModule>> _modulesMap = {}; // courseId -> modules
  bool _isLoading = false;
  String? _error;

  // Statistics
  int _totalCourses = 0;
  int _completedCourses = 0;
  double _averageProgress = 0.0;
  int _totalModulesCompleted = 0;

  StudentProvider(
    this._enrollmentRepository,
    this._progressRepository,
    this._moduleRepository,
    this._client,
  ) {
    _loadStudentData();
  }

  List<Enrollment> get enrollments => _enrollments;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Statistics getters
  int get totalCourses => _totalCourses;
  int get completedCourses => _completedCourses;
  double get averageProgress => _averageProgress;
  int get totalModulesCompleted => _totalModulesCompleted;

  /// Get progress for a specific enrollment
  List<StudentProgress> getProgressForEnrollment(String enrollmentId) {
    return _progressMap[enrollmentId] ?? [];
  }

  /// Load all student data
  Future<void> _loadStudentData() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      _enrollments = [];
      _updateStatistics();
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Load enrollments
      _enrollments = await _enrollmentRepository.getByStudentId(userId);

      // Load progress and modules for each enrollment
      for (final enrollment in _enrollments) {
        final progress = await _progressRepository.getByEnrollmentId(enrollment.id);
        _progressMap[enrollment.id] = progress;
        
        // Load modules for the course
        if (!_modulesMap.containsKey(enrollment.courseId)) {
          final modules = await _moduleRepository.getByCourseId(enrollment.courseId);
          _modulesMap[enrollment.courseId] = modules;
        }
      }

      _updateStatistics();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      debugPrint('Error loading student data: $e');
      notifyListeners();
    }
  }

  /// Update statistics based on current data
  void _updateStatistics() {
    _totalCourses = _enrollments.length;
    _completedCourses = _enrollments
        .where((e) => e.status == EnrollmentStatus.completed)
        .length;

    if (_enrollments.isNotEmpty) {
      _averageProgress = _enrollments
          .map((e) => e.progressPercentage)
          .reduce((a, b) => a + b) /
          _enrollments.length;
    } else {
      _averageProgress = 0.0;
    }

    _totalModulesCompleted = _progressMap.values
        .expand((list) => list)
        .where((p) => p.status == ProgressStatus.completed)
        .length;
  }

  /// Refresh student data
  Future<void> refresh() async {
    await _loadStudentData();
  }

  /// Get enrollment by course ID
  Enrollment? getEnrollmentByCourseId(String courseId) {
    try {
      return _enrollments.firstWhere(
        (e) => e.courseId == courseId,
      );
    } catch (e) {
      return null;
    }
  }

  /// Get modules for a specific course
  List<CourseModule> getModulesForCourse(String courseId) {
    return _modulesMap[courseId] ?? [];
  }

  /// Get progress for a specific module within an enrollment
  StudentProgress? getModuleProgress(String enrollmentId, String moduleId) {
    final progressList = _progressMap[enrollmentId] ?? [];
    try {
      return progressList.firstWhere(
        (p) => p.moduleId == moduleId,
      );
    } catch (e) {
      return null;
    }
  }

  /// Refresh modules for a course (useful when modules are added)
  Future<void> refreshModulesForCourse(String courseId) async {
    try {
      final modules = await _moduleRepository.getByCourseId(courseId);
      _modulesMap[courseId] = modules;
      notifyListeners();
    } catch (e) {
      debugPrint('Error refreshing modules: $e');
    }
  }
}

