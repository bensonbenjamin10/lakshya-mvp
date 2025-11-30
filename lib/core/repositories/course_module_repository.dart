import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lakshya_mvp/models/course_module.dart';

/// Repository for course module data access
class CourseModuleRepository {
  final SupabaseClient _client;

  CourseModuleRepository(this._client);

  /// Get all modules for a course
  Future<List<CourseModule>> getByCourseId(String courseId) async {
    try {
      final response = await _client
          .from('course_modules')
          .select()
          .eq('course_id', courseId)
          .order('display_order', ascending: true)
          .order('module_number', ascending: true);

      return (response as List)
          .map((json) => CourseModule.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch course modules: $e');
    }
  }

  /// Get module by ID
  Future<CourseModule?> getById(String id) async {
    try {
      final response = await _client
          .from('course_modules')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return CourseModule.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch course module: $e');
    }
  }

  /// Create a new module
  Future<CourseModule> create(CourseModule module) async {
    try {
      final response = await _client
          .from('course_modules')
          .insert(module.toJson())
          .select()
          .single();

      return CourseModule.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create course module: $e');
    }
  }

  /// Update a module
  Future<CourseModule> update(CourseModule module) async {
    try {
      final response = await _client
          .from('course_modules')
          .update(module.toJson())
          .eq('id', module.id)
          .select()
          .single();

      return CourseModule.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update course module: $e');
    }
  }

  /// Delete a module
  Future<void> delete(String id) async {
    try {
      await _client.from('course_modules').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete course module: $e');
    }
  }
}

