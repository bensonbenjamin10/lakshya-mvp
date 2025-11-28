import 'package:flutter/foundation.dart';
import 'package:lakshya_mvp/core/repositories/lead_repository.dart';
import 'package:lakshya_mvp/models/lead.dart';

/// Lead provider following Provider pattern and SOLID principles
/// 
/// Manages lead state and delegates data access to LeadRepository.
/// Dependency Inversion: depends on LeadRepository abstraction, not concrete implementation.
class LeadProvider with ChangeNotifier {
  final LeadRepository _repository;

  List<Lead> _leads = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _error;

  LeadProvider(this._repository) {
    _loadLeads();
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

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
