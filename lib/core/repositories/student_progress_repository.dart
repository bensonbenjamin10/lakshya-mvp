import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lakshya_mvp/models/student_progress.dart';

/// Repository for student progress data access
class StudentProgressRepository {
  final SupabaseClient _client;

  StudentProgressRepository(this._client);

  /// Get all progress for a student
  Future<List<StudentProgress>> getByStudentId(String studentId) async {
    try {
      final response = await _client
          .from('student_progress')
          .select('''
            *,
            course_modules (*)
          ''')
          .eq('student_id', studentId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => StudentProgress.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch student progress: $e');
    }
  }

  /// Get progress for a specific enrollment
  Future<List<StudentProgress>> getByEnrollmentId(String enrollmentId) async {
    try {
      final response = await _client
          .from('student_progress')
          .select('''
            *,
            course_modules (*)
          ''')
          .eq('enrollment_id', enrollmentId)
          .order('created_at', ascending: true);

      return (response as List)
          .map((json) => StudentProgress.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch enrollment progress: $e');
    }
  }

  /// Get progress for a specific module
  Future<StudentProgress?> getByEnrollmentAndModule({
    required String enrollmentId,
    required String moduleId,
  }) async {
    try {
      final response = await _client
          .from('student_progress')
          .select('''
            *,
            course_modules (*)
          ''')
          .eq('enrollment_id', enrollmentId)
          .eq('module_id', moduleId)
          .maybeSingle();

      if (response == null) return null;
      return StudentProgress.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch module progress: $e');
    }
  }

  /// Create or update progress
  Future<StudentProgress> upsert(StudentProgress progress) async {
    try {
      final response = await _client
          .from('student_progress')
          .upsert(progress.toJson())
          .select('''
            *,
            course_modules (*)
          ''')
          .single();

      return StudentProgress.fromJson(response);
    } catch (e) {
      throw Exception('Failed to save progress: $e');
    }
  }

  /// Update progress status
  Future<void> updateStatus({
    required String enrollmentId,
    required String moduleId,
    required ProgressStatus status,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'status': status.name,
        'last_accessed_at': DateTime.now().toIso8601String(),
      };

      if (status == ProgressStatus.completed) {
        updateData['completion_date'] = DateTime.now().toIso8601String();
      }

      await _client
          .from('student_progress')
          .update(updateData)
          .eq('enrollment_id', enrollmentId)
          .eq('module_id', moduleId);
    } catch (e) {
      throw Exception('Failed to update progress status: $e');
    }
  }

  /// Update time spent on a module
  Future<void> updateTimeSpent({
    required String enrollmentId,
    required String moduleId,
    required int minutes,
  }) async {
    try {
      await _client
          .from('student_progress')
          .update({
            'time_spent_minutes': minutes,
            'last_accessed_at': DateTime.now().toIso8601String(),
          })
          .eq('enrollment_id', enrollmentId)
          .eq('module_id', moduleId);
    } catch (e) {
      throw Exception('Failed to update time spent: $e');
    }
  }

  /// Delete progress
  Future<void> delete(String id) async {
    try {
      await _client.from('student_progress').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete progress: $e');
    }
  }
}

