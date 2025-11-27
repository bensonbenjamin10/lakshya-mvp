import 'package:flutter/foundation.dart';
import 'package:lakshya_mvp/models/lead.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LeadProvider with ChangeNotifier {
  List<Lead> _leads = [];
  bool _isSubmitting = false;

  List<Lead> get leads => _leads;
  bool get isSubmitting => _isSubmitting;

  LeadProvider() {
    _loadLeads();
  }

  Future<void> _loadLeads() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final leadsJson = prefs.getString('leads');
      if (leadsJson != null) {
        final List<dynamic> decoded = json.decode(leadsJson);
        _leads = decoded.map((json) => _leadFromJson(json)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading leads: $e');
    }
  }

  Future<bool> submitLead(Lead lead) async {
    _isSubmitting = true;
    notifyListeners();

    try {
      // In production, this would send to your backend API
      // For MVP, we'll store locally
      _leads.add(lead);
      
      // Save to local storage
      final prefs = await SharedPreferences.getInstance();
      final leadsJson = json.encode(_leads.map((l) => l.toJson()).toList());
      await prefs.setString('leads', leadsJson);

      _isSubmitting = false;
      notifyListeners();
      
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));
      
      return true;
    } catch (e) {
      _isSubmitting = false;
      notifyListeners();
      debugPrint('Error submitting lead: $e');
      return false;
    }
  }

  Lead _leadFromJson(Map<String, dynamic> json) {
    return Lead(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      country: json['country'],
      inquiryType: _parseInquiryType(json['inquiryType']),
      courseId: json['courseId'],
      message: json['message'],
      source: _parseLeadSource(json['source']),
      createdAt: DateTime.parse(json['createdAt']),
      isContacted: json['isContacted'] ?? false,
      notes: json['notes'],
    );
  }

  InquiryType _parseInquiryType(String? type) {
    switch (type) {
      case 'InquiryType.courseInquiry':
        return InquiryType.courseInquiry;
      case 'InquiryType.enrollment':
        return InquiryType.enrollment;
      case 'InquiryType.brochureRequest':
        return InquiryType.brochureRequest;
      default:
        return InquiryType.generalContact;
    }
  }

  LeadSource _parseLeadSource(String? source) {
    switch (source) {
      case 'LeadSource.socialMedia':
        return LeadSource.socialMedia;
      case 'LeadSource.referral':
        return LeadSource.referral;
      case 'LeadSource.advertisement':
        return LeadSource.advertisement;
      case 'LeadSource.other':
        return LeadSource.other;
      default:
        return LeadSource.website;
    }
  }
}

