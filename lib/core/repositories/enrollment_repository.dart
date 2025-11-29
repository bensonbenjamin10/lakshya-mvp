import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lakshya_mvp/core/repositories/base_repository.dart';
import 'package:lakshya_mvp/models/enrollment.dart';

/// Repository for enrollment data access
/// 
/// Follows Repository Pattern and Single Responsibility Principle
class EnrollmentRepository implements BaseRepository<Enrollment> {
  final SupabaseClient _client;

  EnrollmentRepository(this._client);

  @override
  Future<List<Enrollment>> getAll() async {
    try {
      final response = await _client
          .from('enrollments')
          .select('''
            *,
            courses (*),
            profiles!enrollments_student_id_fkey (*)
          ''')
          .order('enrolled_at', ascending: false);

      return (response as List)
          .map((json) => Enrollment.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch enrollments: $e');
    }
  }

  /// Get enrollments for a specific student
  Future<List<Enrollment>> getByStudentId(String studentId) async {
    try {
      final response = await _client
          .from('enrollments')
          .select('''
            *,
            courses (*)
          ''')
          .eq('student_id', studentId)
          .order('enrolled_at', ascending: false);

      return (response as List)
          .map((json) => Enrollment.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch student enrollments: $e');
    }
  }

  /// Get enrollment by ID
  @override
  Future<Enrollment?> getById(String id) async {
    try {
      final response = await _client
          .from('enrollments')
          .select('''
            *,
            courses (*),
            profiles!enrollments_student_id_fkey (*)
          ''')
          .eq('id', id)
          .single();

      return Enrollment.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      if (e.toString().contains('PGRST116')) {
        return null; // Not found
      }
      throw Exception('Failed to fetch enrollment: $e');
    }
  }

  /// Get enrollment by student and course
  Future<Enrollment?> getByStudentAndCourse({
    required String studentId,
    required String courseId,
  }) async {
    try {
      final response = await _client
          .from('enrollments')
          .select('''
            *,
            courses (*)
          ''')
          .eq('student_id', studentId)
          .eq('course_id', courseId)
          .maybeSingle();

      if (response == null) return null;
      return Enrollment.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to fetch enrollment: $e');
    }
  }

  /// Check if student is enrolled in a course
  Future<bool> isEnrolled({
    required String studentId,
    required String courseId,
  }) async {
    try {
      final enrollment = await getByStudentAndCourse(
        studentId: studentId,
        courseId: courseId,
      );
      return enrollment != null && enrollment.status == EnrollmentStatus.active;
    } catch (e) {
      return false;
    }
  }

  /// Create a new enrollment
  @override
  Future<Enrollment> create(Enrollment enrollment) async {
    try {
      final response = await _client
          .from('enrollments')
          .insert(enrollment.toJson())
          .select('''
            *,
            courses (*)
          ''')
          .single();

      return Enrollment.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to create enrollment: $e');
    }
  }

  /// Update an enrollment
  @override
  Future<Enrollment> update(Enrollment enrollment) async {
    try {
      final response = await _client
          .from('enrollments')
          .update(enrollment.toJson())
          .eq('id', enrollment.id)
          .select('''
            *,
            courses (*)
          ''')
          .single();

      return Enrollment.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to update enrollment: $e');
    }
  }

  /// Update enrollment progress
  Future<void> updateProgress({
    required String enrollmentId,
    required double progressPercentage,
  }) async {
    try {
      await _client
          .from('enrollments')
          .update({
            'progress_percentage': progressPercentage,
            'last_accessed_at': DateTime.now().toIso8601String(),
          })
          .eq('id', enrollmentId);
    } catch (e) {
      throw Exception('Failed to update enrollment progress: $e');
    }
  }

  /// Update enrollment status
  Future<void> updateStatus({
    required String enrollmentId,
    required EnrollmentStatus status,
  }) async {
    try {
      await _client
          .from('enrollments')
          .update({
            'status': status.name,
            if (status == EnrollmentStatus.completed)
              'completed_at': DateTime.now().toIso8601String(),
          })
          .eq('id', enrollmentId);
    } catch (e) {
      throw Exception('Failed to update enrollment status: $e');
    }
  }

  /// Delete an enrollment
  @override
  Future<void> delete(String id) async {
    try {
      await _client.from('enrollments').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete enrollment: $e');
    }
  }
}

