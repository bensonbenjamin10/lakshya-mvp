import 'package:lakshya_mvp/core/models/base_model.dart';

enum LeadSource {
  website,
  socialMedia,
  referral,
  advertisement,
  other,
}

enum InquiryType {
  courseInquiry,
  enrollment,
  generalContact,
  brochureRequest,
}

enum LeadStatus {
  newLead,
  contacted,
  qualified,
  converted,
  lost,
}

class Lead extends BaseModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? country;
  final InquiryType inquiryType;
  final String? courseId;
  final String? message;
  final LeadSource source;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final LeadStatus status;
  final String? assignedTo;
  final String? notes;

  Lead({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.country,
    required this.inquiryType,
    this.courseId,
    this.message,
    required this.source,
    required this.createdAt,
    this.updatedAt,
    this.status = LeadStatus.newLead,
    this.assignedTo,
    this.notes,
  });

  bool get isContacted => status != LeadStatus.newLead;

  String get sourceString {
    switch (source) {
      case LeadSource.website:
        return 'website';
      case LeadSource.socialMedia:
        return 'social_media';
      case LeadSource.referral:
        return 'referral';
      case LeadSource.advertisement:
        return 'advertisement';
      case LeadSource.other:
        return 'other';
    }
  }

  String get inquiryTypeString {
    switch (inquiryType) {
      case InquiryType.courseInquiry:
        return 'course_inquiry';
      case InquiryType.enrollment:
        return 'enrollment';
      case InquiryType.generalContact:
        return 'general_contact';
      case InquiryType.brochureRequest:
        return 'brochure_request';
    }
  }

  String get statusString {
    switch (status) {
      case LeadStatus.newLead:
        return 'new';
      case LeadStatus.contacted:
        return 'contacted';
      case LeadStatus.qualified:
        return 'qualified';
      case LeadStatus.converted:
        return 'converted';
      case LeadStatus.lost:
        return 'lost';
    }
  }

  static LeadSource sourceFromString(String value) {
    switch (value) {
      case 'website':
        return LeadSource.website;
      case 'social_media':
        return LeadSource.socialMedia;
      case 'referral':
        return LeadSource.referral;
      case 'advertisement':
        return LeadSource.advertisement;
      case 'other':
        return LeadSource.other;
      default:
        return LeadSource.website;
    }
  }

  static InquiryType inquiryTypeFromString(String value) {
    switch (value) {
      case 'course_inquiry':
        return InquiryType.courseInquiry;
      case 'enrollment':
        return InquiryType.enrollment;
      case 'general_contact':
        return InquiryType.generalContact;
      case 'brochure_request':
        return InquiryType.brochureRequest;
      default:
        return InquiryType.generalContact;
    }
  }

  static LeadStatus statusFromString(String value) {
    switch (value) {
      case 'new':
        return LeadStatus.newLead;
      case 'contacted':
        return LeadStatus.contacted;
      case 'qualified':
        return LeadStatus.qualified;
      case 'converted':
        return LeadStatus.converted;
      case 'lost':
        return LeadStatus.lost;
      default:
        return LeadStatus.newLead;
    }
  }

  @override
  Map<String, dynamic> toJson({bool includeId = true, bool forInsert = false}) {
    final json = <String, dynamic>{
      'name': name,
      'email': email,
      'phone': phone,
      'country': country,
      'inquiry_type': inquiryTypeString,
      'course_id': courseId,
      'message': message,
    };
    
    // Only include id if it's a valid UUID format (contains dashes) or if explicitly requested
    if (includeId && _isValidUuid(id)) {
      json['id'] = id;
    }
    
    // For inserts, exclude timestamps and fields with defaults - let database handle them
    if (!forInsert) {
      json['source'] = sourceString;
      json['status'] = statusString;
      json['created_at'] = createdAt.toIso8601String();
      if (updatedAt != null) {
        json['updated_at'] = updatedAt!.toIso8601String();
      }
      json['assigned_to'] = assignedTo;
      json['notes'] = notes;
    }
    // For inserts, only include source/status if they're not the defaults
    else {
      // Only include source if it's not the default 'website'
      if (source != LeadSource.website) {
        json['source'] = sourceString;
      }
      // Only include status if it's not the default 'new'
      if (status != LeadStatus.newLead) {
        json['status'] = statusString;
      }
    }
    
    return json;
  }
  
  /// Check if a string is a valid UUID format
  bool _isValidUuid(String value) {
    // UUID format: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
    final uuidRegex = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      caseSensitive: false,
    );
    return uuidRegex.hasMatch(value);
  }

  factory Lead.fromJson(Map<String, dynamic> json) {
    return Lead(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      country: json['country'] as String?,
      inquiryType: inquiryTypeFromString(json['inquiry_type'] as String),
      courseId: json['course_id'] as String?,
      message: json['message'] as String?,
      source: sourceFromString(json['source'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      status: statusFromString(json['status'] as String? ?? 'new'),
      assignedTo: json['assigned_to'] as String?,
      notes: json['notes'] as String?,
    );
  }
}
