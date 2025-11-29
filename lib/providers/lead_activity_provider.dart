import 'package:flutter/foundation.dart';
import 'package:lakshya_mvp/core/repositories/lead_activity_repository.dart';
import 'package:lakshya_mvp/models/lead_activity.dart';

/// Lead Activity provider following Provider pattern
/// 
/// Manages lead activity state and delegates data access to LeadActivityRepository.
class LeadActivityProvider with ChangeNotifier {
  final LeadActivityRepository _repository;

  List<LeadActivity> _activities = [];
  bool _isLoading = false;
  String? _error;

  LeadActivityProvider(this._repository);

  List<LeadActivity> get activities => _activities;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load activities for a specific lead
  Future<void> loadActivitiesForLead(String leadId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _activities = await _repository.getByLeadId(leadId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      debugPrint('Error loading lead activities: $e');
      notifyListeners();
    }
  }

  /// Refresh activities
  Future<void> refresh(String leadId) async {
    await loadActivitiesForLead(leadId);
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

