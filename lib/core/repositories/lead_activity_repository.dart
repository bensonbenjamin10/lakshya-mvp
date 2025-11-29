import 'package:lakshya_mvp/core/repositories/base_repository.dart';
import 'package:lakshya_mvp/models/lead_activity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Lead Activity repository following Repository Pattern
/// 
/// Handles all lead activity data access operations via Supabase.
class LeadActivityRepository implements BaseRepository<LeadActivity> {
  final SupabaseClient _client;

  LeadActivityRepository(this._client);

  @override
  Future<List<LeadActivity>> getAll() async {
    try {
      final response = await _client
          .from('lead_activities')
          .select()
          .order('created_at', ascending: false);

      return List<LeadActivity>.from(
        response.map((json) => LeadActivity.fromJson(json)),
      );
    } catch (e) {
      throw Exception('Failed to fetch lead activities: $e');
    }
  }

  @override
  Future<LeadActivity?> getById(String id) async {
    try {
      final response = await _client
          .from('lead_activities')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return LeadActivity.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch lead activity: $e');
    }
  }

  @override
  Future<LeadActivity> create(LeadActivity entity) async {
    try {
      final response = await _client
          .from('lead_activities')
          .insert(entity.toJson(includeId: false))
          .select()
          .single();

      return LeadActivity.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create lead activity: $e');
    }
  }

  @override
  Future<LeadActivity> update(LeadActivity entity) async {
    try {
      final response = await _client
          .from('lead_activities')
          .update(entity.toJson())
          .eq('id', entity.id)
          .select()
          .single();

      return LeadActivity.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update lead activity: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _client.from('lead_activities').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete lead activity: $e');
    }
  }

  /// Get activities for a specific lead
  Future<List<LeadActivity>> getByLeadId(String leadId) async {
    try {
      final response = await _client
          .from('lead_activities')
          .select()
          .eq('lead_id', leadId)
          .order('created_at', ascending: false);

      return List<LeadActivity>.from(
        response.map((json) => LeadActivity.fromJson(json)),
      );
    } catch (e) {
      throw Exception('Failed to fetch lead activities: $e');
    }
  }

  /// Get activities by type
  Future<List<LeadActivity>> getByActivityType(ActivityType type) async {
    try {
      final tempActivity = LeadActivity(
        id: '',
        leadId: '',
        activityType: type,
        createdAt: DateTime.now(),
      );

      final response = await _client
          .from('lead_activities')
          .select()
          .eq('activity_type', tempActivity.activityTypeString)
          .order('created_at', ascending: false);

      return List<LeadActivity>.from(
        response.map((json) => LeadActivity.fromJson(json)),
      );
    } catch (e) {
      throw Exception('Failed to fetch activities by type: $e');
    }
  }
}

