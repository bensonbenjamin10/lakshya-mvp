import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:lakshya_mvp/providers/lead_provider.dart';
import 'package:lakshya_mvp/providers/auth_provider.dart';
import 'package:lakshya_mvp/models/lead.dart';
import 'package:lakshya_mvp/theme/theme.dart';
import 'package:lakshya_mvp/core/utils/formatters.dart';

/// Lead Detail Screen
/// 
/// View and manage individual lead details.
/// Requires authentication.
class LeadDetail extends StatefulWidget {
  final String leadId;

  const LeadDetail({
    super.key,
    required this.leadId,
  });

  @override
  State<LeadDetail> createState() => _LeadDetailState();
}

class _LeadDetailState extends State<LeadDetail> {
  LeadStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    // Redirect mobile users to home (admin is web-only)
    if (!kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.go('/');
        }
      });
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final leadProvider = Provider.of<LeadProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    // Check auth
    if (!authProvider.isAuthenticated) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock_outline_rounded,
                size: 64,
                color: AppColors.neutral400,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Authentication Required',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              ElevatedButton(
                onPressed: () => context.go('/login'),
                child: const Text('Sign In'),
              ),
            ],
          ),
        ),
      );
    }

    final lead = leadProvider.leads.firstWhere(
      (l) => l.id == widget.leadId,
      orElse: () => Lead(
        id: '',
        name: 'Not Found',
        email: '',
        phone: '',
        source: LeadSource.website,
        inquiryType: InquiryType.generalContact,
        createdAt: DateTime.now(),
      ),
    );

    if (lead.id.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Lead Not Found')),
        body: const Center(child: Text('Lead not found')),
      );
    }

    _selectedStatus ??= lead.status;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lead Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            onPressed: () {
              // TODO: Implement edit functionality
              HapticFeedback.lightImpact();
            },
            tooltip: 'Edit',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Card(
              color: _getStatusColor(lead.status).withValues(alpha: 0.1),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Icon(
                      _getStatusIcon(lead.status),
                      color: _getStatusColor(lead.status),
                      size: 32,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Status',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          DropdownButton<LeadStatus>(
                            value: _selectedStatus,
                            isExpanded: true,
                            items: LeadStatus.values.map((status) {
                              return DropdownMenuItem(
                                value: status,
                                child: Text(_getStatusLabel(status)),
                              );
                            }).toList(),
                            onChanged: (newStatus) async {
                              if (newStatus != null && newStatus != _selectedStatus) {
                                HapticFeedback.lightImpact();
                                final messenger = ScaffoldMessenger.of(context);
                                final success = await leadProvider.updateLeadStatus(
                                  widget.leadId,
                                  newStatus,
                                );
                                if (!mounted) return;
                                if (success) {
                                  setState(() => _selectedStatus = newStatus);
                                  messenger.showSnackBar(
                                    const SnackBar(
                                      content: Text('Lead status updated'),
                                      backgroundColor: AppColors.success,
                                    ),
                                  );
                                } else {
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        leadProvider.error ?? 'Failed to update status',
                                      ),
                                      backgroundColor: AppColors.error,
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Contact Information
            Text(
              'Contact Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppSpacing.md),
            _InfoCard(
              icon: Icons.person_outline_rounded,
              label: 'Name',
              value: lead.name,
            ),
            _InfoCard(
              icon: Icons.email_rounded,
              label: 'Email',
              value: lead.email,
            ),
            _InfoCard(
              icon: Icons.phone_rounded,
              label: 'Phone',
              value: lead.phone,
            ),
            if (lead.country != null)
              _InfoCard(
                icon: Icons.location_on_rounded,
                label: 'Country',
                value: lead.country!,
              ),

            const SizedBox(height: AppSpacing.lg),

            // Inquiry Details
            Text(
              'Inquiry Details',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppSpacing.md),
            _InfoCard(
              icon: Icons.help_outline_rounded,
              label: 'Inquiry Type',
              value: _getInquiryTypeLabel(lead.inquiryType),
            ),
            _InfoCard(
              icon: Icons.source_rounded,
              label: 'Source',
              value: _getSourceLabel(lead.source),
            ),
            _InfoCard(
              icon: Icons.access_time_rounded,
              label: 'Submitted',
              value: formatDateTime(lead.createdAt),
            ),

            if (lead.message != null) ...[
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Message',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: AppSpacing.md),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Text(
                    lead.message!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
            ],

            if (lead.notes != null) ...[
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Notes',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: AppSpacing.md),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Text(
                    lead.notes!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(LeadStatus status) {
    switch (status) {
      case LeadStatus.newLead:
        return AppColors.classicBlue;
      case LeadStatus.contacted:
        return AppColors.ultramarine;
      case LeadStatus.qualified:
        return AppColors.success;
      case LeadStatus.converted:
        return AppColors.success;
      case LeadStatus.lost:
        return AppColors.error;
    }
  }

  IconData _getStatusIcon(LeadStatus status) {
    switch (status) {
      case LeadStatus.newLead:
        return Icons.new_releases_rounded;
      case LeadStatus.contacted:
        return Icons.phone_rounded;
      case LeadStatus.qualified:
        return Icons.star_rounded;
      case LeadStatus.converted:
        return Icons.check_circle_rounded;
      case LeadStatus.lost:
        return Icons.cancel_rounded;
    }
  }

  String _getStatusLabel(LeadStatus status) {
    switch (status) {
      case LeadStatus.newLead:
        return 'New';
      case LeadStatus.contacted:
        return 'Contacted';
      case LeadStatus.qualified:
        return 'Qualified';
      case LeadStatus.converted:
        return 'Converted';
      case LeadStatus.lost:
        return 'Lost';
    }
  }

  String _getInquiryTypeLabel(InquiryType type) {
    switch (type) {
      case InquiryType.courseInquiry:
        return 'Course Inquiry';
      case InquiryType.enrollment:
        return 'Enrollment';
      case InquiryType.brochureRequest:
        return 'Brochure Request';
      case InquiryType.generalContact:
        return 'General Contact';
    }
  }

  String _getSourceLabel(LeadSource source) {
    switch (source) {
      case LeadSource.website:
        return 'Website';
      case LeadSource.socialMedia:
        return 'Social Media';
      case LeadSource.referral:
        return 'Referral';
      case LeadSource.advertisement:
        return 'Advertisement';
      case LeadSource.other:
        return 'Other';
    }
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: Icon(icon, color: AppColors.classicBlue),
        title: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.neutral600,
              ),
        ),
        subtitle: Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
      ),
    );
  }
}

