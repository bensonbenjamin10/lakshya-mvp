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

class Lead {
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
  final bool isContacted;
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
    this.isContacted = false,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'country': country,
      'inquiryType': inquiryType.toString(),
      'courseId': courseId,
      'message': message,
      'source': source.toString(),
      'createdAt': createdAt.toIso8601String(),
      'isContacted': isContacted,
      'notes': notes,
    };
  }
}

