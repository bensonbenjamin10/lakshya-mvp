import 'package:flutter/foundation.dart';
import 'package:lakshya_mvp/core/repositories/lead_repository.dart';
import 'package:lakshya_mvp/models/lead.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Lead provider following Provider pattern and SOLID principles
/// 
/// Manages lead state and delegates data access to LeadRepository.
/// Dependency Inversion: depends on LeadRepository abstraction, not concrete implementation.
class LeadProvider with ChangeNotifier {
  final LeadRepository _repository;
  RealtimeChannel? _realtimeChannel;

  List<Lead> _leads = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _error;

  LeadProvider(this._repository) {
    _loadLeads();
    _setupRealtimeSubscription();
  }

  /// Setup real-time subscription for leads (admin only)
  void _setupRealtimeSubscription() {
    try {
      final client = Supabase.instance.client;
      _realtimeChannel = client
          .channel('leads_changes')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'leads',
            callback: (payload) {
              debugPrint('Realtime lead update: ${payload.eventType}');
              // Reload leads when changes occur
              _loadLeads();
            },
          )
          .subscribe();
    } catch (e) {
      debugPrint('Error setting up realtime subscription: $e');
    }
  }

  @override
  void dispose() {
    _realtimeChannel?.unsubscribe();
    super.dispose();
  }

  List<Lead> get leads => _leads;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get error => _error;

  Future<void> _loadLeads() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _leads = await _repository.getAll();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      debugPrint('Error loading leads: $e');
      notifyListeners();
    }
  }

  /// Submit a new lead (no auth required - zero friction lead magnet)
  Future<bool> submitLead(Lead lead) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      final createdLead = await _repository.create(lead);
      _leads.add(createdLead);
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isSubmitting = false;
      debugPrint('Error submitting lead: $e');
      notifyListeners();
      return false;
    }
  }

  /// Refresh leads list
  Future<void> refresh() async {
    await _loadLeads();
  }

  /// Get leads by status
  Future<List<Lead>> getLeadsByStatus(LeadStatus status) async {
    try {
      return await _repository.getByStatus(status);
    } catch (e) {
      debugPrint('Error fetching leads by status: $e');
      return [];
    }
  }

  /// Get leads by source
  Future<List<Lead>> getLeadsBySource(LeadSource source) async {
    try {
      return await _repository.getBySource(source);
    } catch (e) {
      debugPrint('Error fetching leads by source: $e');
      return [];
    }
  }

  /// Get leads assigned to a faculty member
  Future<List<Lead>> getAssignedLeads(String facultyId) async {
    try {
      return await _repository.getAssignedTo(facultyId);
    } catch (e) {
      debugPrint('Error fetching assigned leads: $e');
      return [];
    }
  }

  /// Update lead status
  Future<bool> updateLeadStatus(String leadId, LeadStatus newStatus) async {
    try {
      final lead = _leads.firstWhere((l) => l.id == leadId);
      final updatedLead = Lead(
        id: lead.id,
        name: lead.name,
        email: lead.email,
        phone: lead.phone,
        country: lead.country,
        inquiryType: lead.inquiryType,
        courseId: lead.courseId,
        message: lead.message,
        source: lead.source,
        createdAt: lead.createdAt,
        updatedAt: DateTime.now(),
        status: newStatus,
        assignedTo: lead.assignedTo,
        notes: lead.notes,
      );

      await _repository.update(updatedLead);
      final index = _leads.indexWhere((l) => l.id == leadId);
      if (index != -1) {
        _leads[index] = updatedLead;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error updating lead status: $e');
      notifyListeners();
      return false;
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
