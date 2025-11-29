import 'package:flutter_test/flutter_test.dart';
import 'package:lakshya_mvp/models/lead.dart';

void main() {
  group('Lead Model', () {
    test('should create Lead from JSON', () {
      final json = {
        'id': 'test-id',
        'name': 'Test User',
        'email': 'test@example.com',
        'phone': '1234567890',
        'country': 'USA',
        'inquiry_type': 'enrollment',
        'course_id': 'course-id',
        'message': 'Test message',
        'source': 'website',
        'status': 'new',
        'created_at': '2024-01-01T00:00:00Z',
        'updated_at': null,
        'assigned_to': null,
        'notes': null,
      };

      final lead = Lead.fromJson(json);

      expect(lead.id, 'test-id');
      expect(lead.name, 'Test User');
      expect(lead.email, 'test@example.com');
      expect(lead.phone, '1234567890');
      expect(lead.inquiryType, InquiryType.enrollment);
      expect(lead.source, LeadSource.website);
      expect(lead.status, LeadStatus.newLead);
    });

    test('should convert Lead to JSON', () {
      final lead = Lead(
        id: 'test-id',
        name: 'Test User',
        email: 'test@example.com',
        phone: '1234567890',
        inquiryType: InquiryType.enrollment,
        source: LeadSource.website,
        createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
        status: LeadStatus.newLead,
      );

      final json = lead.toJson();

      expect(json['name'], 'Test User');
      expect(json['email'], 'test@example.com');
      expect(json['inquiry_type'], 'enrollment');
      expect(json['source'], 'website');
    });

    test('should convert status strings correctly', () {
      expect(Lead.statusFromString('new'), LeadStatus.newLead);
      expect(Lead.statusFromString('contacted'), LeadStatus.contacted);
      expect(Lead.statusFromString('qualified'), LeadStatus.qualified);
      expect(Lead.statusFromString('converted'), LeadStatus.converted);
      expect(Lead.statusFromString('lost'), LeadStatus.lost);
    });

    test('should convert source strings correctly', () {
      expect(Lead.sourceFromString('website'), LeadSource.website);
      expect(Lead.sourceFromString('social_media'), LeadSource.socialMedia);
      expect(Lead.sourceFromString('referral'), LeadSource.referral);
      expect(Lead.sourceFromString('advertisement'), LeadSource.advertisement);
      expect(Lead.sourceFromString('other'), LeadSource.other);
    });
  });
}

