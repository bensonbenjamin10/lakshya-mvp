import 'package:lakshya_mvp/core/repositories/base_repository.dart';
import 'package:lakshya_mvp/models/course.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Course repository following Repository Pattern and SOLID principles
/// 
/// Handles all course data access operations via Supabase.
/// Extends BaseRepository for common CRUD, adds course-specific queries.
class CourseRepository implements BaseRepository<Course> {
  final SupabaseClient _client;

  CourseRepository(this._client);

  @override
  Future<List<Course>> getAll() async {
    try {
      final response = await _client
          .from('courses')
          .select()
          .eq('is_active', true)
          .order('created_at', ascending: false);

      return List<Course>.from(
        response.map((json) => Course.fromJson(json)),
      );
    } catch (e) {
      throw Exception('Failed to fetch courses: $e');
    }
  }

  @override
  Future<Course?> getById(String id) async {
    try {
      final response = await _client
          .from('courses')
          .select()
          .eq('id', id)
          .eq('is_active', true)
          .maybeSingle();

      if (response == null) return null;
      return Course.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch course: $e');
    }
  }

  @override
  Future<Course> create(Course entity) async {
    try {
      final response = await _client
          .from('courses')
          .insert(entity.toJson())
          .select()
          .single();

      return Course.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create course: $e');
    }
  }

  @override
  Future<Course> update(Course entity) async {
    try {
      final response = await _client
          .from('courses')
          .update(entity.toJson())
          .eq('id', entity.id)
          .select()
          .single();

      return Course.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update course: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      // Soft delete by setting is_active to false
      await _client.from('courses').update({'is_active': false}).eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete course: $e');
    }
  }

  /// Get courses by category - Course-specific query
  Future<List<Course>> getByCategory(CourseCategory category) async {
    try {
      // Convert enum to database string format
      String categoryString;
      switch (category) {
        case CourseCategory.acca:
          categoryString = 'acca';
          break;
        case CourseCategory.ca:
          categoryString = 'ca';
          break;
        case CourseCategory.cma:
          categoryString = 'cma';
          break;
        case CourseCategory.bcomMba:
          categoryString = 'bcom_mba';
          break;
      }

      final response = await _client
          .from('courses')
          .select()
          .eq('category', categoryString)
          .eq('is_active', true)
          .order('created_at', ascending: false);

      return List<Course>.from(
        response.map((json) => Course.fromJson(json)),
      );
    } catch (e) {
      throw Exception('Failed to fetch courses by category: $e');
    }
  }

  /// Get popular courses
  Future<List<Course>> getPopularCourses() async {
    try {
      final response = await _client
          .from('courses')
          .select()
          .eq('is_popular', true)
          .eq('is_active', true)
          .order('created_at', ascending: false);

      return List<Course>.from(
        response.map((json) => Course.fromJson(json)),
      );
    } catch (e) {
      throw Exception('Failed to fetch popular courses: $e');
    }
  }

  /// Get course by slug
  Future<Course?> getBySlug(String slug) async {
    try {
      final response = await _client
          .from('courses')
          .select()
          .eq('slug', slug)
          .eq('is_active', true)
          .maybeSingle();

      if (response == null) return null;
      return Course.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch course by slug: $e');
    }
  }
}
