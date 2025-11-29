import 'package:lakshya_mvp/core/models/base_model.dart';

enum ActivityType {
  statusChange,
  assignment,
  notesUpdate,
  created,
  other,
}

class LeadActivity extends BaseModel {
  final String id;
  final String leadId;
  final ActivityType activityType;
  final String? oldValue;
  final String? newValue;
  final String? description;
  final String? createdBy;
  final DateTime createdAt;

  LeadActivity({
    required this.id,
    required this.leadId,
    required this.activityType,
    this.oldValue,
    this.newValue,
    this.description,
    this.createdBy,
    required this.createdAt,
  });

  String get activityTypeString {
    switch (activityType) {
      case ActivityType.statusChange:
        return 'status_change';
      case ActivityType.assignment:
        return 'assignment';
      case ActivityType.notesUpdate:
        return 'notes_update';
      case ActivityType.created:
        return 'created';
      case ActivityType.other:
        return 'other';
    }
  }

  static ActivityType activityTypeFromString(String value) {
    switch (value) {
      case 'status_change':
        return ActivityType.statusChange;
      case 'assignment':
        return ActivityType.assignment;
      case 'notes_update':
        return ActivityType.notesUpdate;
      case 'created':
        return ActivityType.created;
      case 'other':
        return ActivityType.other;
      default:
        return ActivityType.other;
    }
  }

  @override
  Map<String, dynamic> toJson({bool includeId = true}) {
    final json = <String, dynamic>{
      'lead_id': leadId,
      'activity_type': activityTypeString,
      'old_value': oldValue,
      'new_value': newValue,
      'description': description,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
    };

    if (includeId) {
      json['id'] = id;
    }

    return json;
  }

  factory LeadActivity.fromJson(Map<String, dynamic> json) {
    return LeadActivity(
      id: json['id'] as String,
      leadId: json['lead_id'] as String,
      activityType: activityTypeFromString(json['activity_type'] as String),
      oldValue: json['old_value'] as String?,
      newValue: json['new_value'] as String?,
      description: json['description'] as String?,
      createdBy: json['created_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

