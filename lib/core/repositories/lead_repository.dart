import 'package:lakshya_mvp/core/repositories/base_repository.dart';
import 'package:lakshya_mvp/models/lead.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Lead repository following Repository Pattern and SOLID principles
/// 
/// Handles all lead data access operations via Supabase.
/// Extends BaseRepository for common CRUD, adds lead-specific queries.
class LeadRepository implements BaseRepository<Lead> {
  final SupabaseClient _client;

  LeadRepository(this._client);

  @override
  Future<List<Lead>> getAll() async {
    try {
      final response = await _client
          .from('leads')
          .select()
          .order('created_at', ascending: false);

      return List<Lead>.from(
        response.map((json) => Lead.fromJson(json)),
      );
    } catch (e) {
      throw Exception('Failed to fetch leads: $e');
    }
  }

  @override
  Future<Lead?> getById(String id) async {
    try {
      final response =
          await _client.from('leads').select().eq('id', id).maybeSingle();

      if (response == null) return null;
      return Lead.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch lead: $e');
    }
  }

  @override
  Future<Lead> create(Lead entity) async {
    try {
      // Use the create_lead function which bypasses RLS with security definer
      // This ensures anonymous users can create leads
      final jsonData = entity.toJson(includeId: false, forInsert: true);
      
      final response = await _client.rpc('create_lead', params: {
        'p_name': jsonData['name'] as String,
        'p_email': jsonData['email'] as String,
        'p_phone': jsonData['phone'] as String,
        'p_country': jsonData['country'] as String?,
        'p_inquiry_type': jsonData['inquiry_type'] as String,
        'p_course_id': jsonData['course_id'] as String?,
        'p_message': jsonData['message'] as String?,
      });
      
      // The function returns the full lead as JSONB
      // Supabase RPC wraps the result, so we need to extract it
      final responseMap = response as Map<String, dynamic>;
      final leadJson = responseMap['create_lead'] as Map<String, dynamic>? ?? responseMap;
      return Lead.fromJson(leadJson);
    } catch (e) {
      throw Exception('Failed to create lead: $e');
    }
  }

  @override
  Future<Lead> update(Lead entity) async {
    try {
      final response = await _client
          .from('leads')
          .update(entity.toJson())
          .eq('id', entity.id)
          .select()
          .single();

      return Lead.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update lead: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _client.from('leads').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete lead: $e');
    }
  }

  /// Get leads by status - Lead-specific query
  Future<List<Lead>> getByStatus(LeadStatus status) async {
    try {
      // Convert enum to database string format
      String statusString;
      switch (status) {
        case LeadStatus.newLead:
          statusString = 'new';
          break;
        case LeadStatus.contacted:
          statusString = 'contacted';
          break;
        case LeadStatus.qualified:
          statusString = 'qualified';
          break;
        case LeadStatus.converted:
          statusString = 'converted';
          break;
        case LeadStatus.lost:
          statusString = 'lost';
          break;
      }

      final response = await _client
          .from('leads')
          .select()
          .eq('status', statusString)
          .order('created_at', ascending: false);

      return List<Lead>.from(
        response.map((json) => Lead.fromJson(json)),
      );
    } catch (e) {
      throw Exception('Failed to fetch leads by status: $e');
    }
  }

  /// Get leads assigned to a faculty member
  Future<List<Lead>> getAssignedTo(String facultyId) async {
    try {
      final response = await _client
          .from('leads')
          .select()
          .eq('assigned_to', facultyId);

      return List<Lead>.from(
        response.map((json) => Lead.fromJson(json)),
      );
    } catch (e) {
      throw Exception('Failed to fetch assigned leads: $e');
    }
  }

  /// Get leads by source
  Future<List<Lead>> getBySource(LeadSource source) async {
    try {
      // Create a temporary Lead instance to use the sourceString getter
      final tempLead = Lead(
        id: '',
        name: '',
        email: '',
        phone: '',
        source: source,
        inquiryType: InquiryType.generalContact,
        createdAt: DateTime.now(),
      );

      final response = await _client
          .from('leads')
          .select()
          .eq('source', tempLead.sourceString)
          .order('created_at', ascending: false);

      return List<Lead>.from(
        response.map((json) => Lead.fromJson(json)),
      );
    } catch (e) {
      throw Exception('Failed to fetch leads by source: $e');
    }
  }

  /// Get leads by course
  Future<List<Lead>> getByCourse(String courseId) async {
    try {
      final response = await _client
          .from('leads')
          .select()
          .eq('course_id', courseId);

      return List<Lead>.from(
        response.map((json) => Lead.fromJson(json)),
      );
    } catch (e) {
      throw Exception('Failed to fetch leads by course: $e');
    }
  }
}
