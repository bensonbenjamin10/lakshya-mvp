import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:lakshya_mvp/providers/lead_provider.dart';
import 'package:lakshya_mvp/providers/auth_provider.dart';
import 'package:lakshya_mvp/models/lead.dart';
import 'package:lakshya_mvp/theme/theme.dart';
import 'package:lakshya_mvp/widgets/shared/loading_state.dart';
import 'package:lakshya_mvp/widgets/shared/error_state.dart';
import 'package:lakshya_mvp/widgets/shared/empty_state.dart';
import 'package:lakshya_mvp/core/utils/formatters.dart';

/// Leads Management Screen
/// 
/// Full list of all leads with filtering and status management.
/// Requires authentication.
class LeadsManagement extends StatefulWidget {
  const LeadsManagement({super.key});

  @override
  State<LeadsManagement> createState() => _LeadsManagementState();
}

class _LeadsManagementState extends State<LeadsManagement> {
  LeadStatus? _selectedStatus;
  LeadSource? _selectedSource;

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
                onPressed: () => context.go('/login?redirect=/admin/leads'),
                child: const Text('Sign In'),
              ),
            ],
          ),
        ),
      );
    }

    final filteredLeads = _filterLeads(leadProvider.leads);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leads Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              HapticFeedback.mediumImpact();
              leadProvider.refresh();
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowestLight,
              border: Border(
                bottom: BorderSide(color: AppColors.neutral200),
              ),
            ),
            child: Column(
              children: [
                // Status filter
                Row(
                  children: [
                    Text(
                      'Status:',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Wrap(
                        spacing: AppSpacing.xs,
                        children: [
                          _FilterChip(
                            label: 'All',
                            selected: _selectedStatus == null,
                            onTap: () {
                              setState(() => _selectedStatus = null);
                            },
                          ),
                          ...LeadStatus.values.map((status) {
                            return _FilterChip(
                              label: _getStatusLabel(status),
                              selected: _selectedStatus == status,
                              onTap: () {
                                setState(() => _selectedStatus = status);
                              },
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Leads list
          Expanded(
            child: leadProvider.isLoading
                ? const LoadingState(message: 'Loading leads...')
                : leadProvider.error != null
                    ? ErrorState(
                        message: leadProvider.error!,
                        onRetry: () => leadProvider.refresh(),
                      )
                    : filteredLeads.isEmpty
                        ? const EmptyState(
                            title: 'No leads found',
                            message: 'Try adjusting your filters',
                            icon: Icons.filter_list_off_rounded,
                          )
                        : RefreshIndicator(
                            onRefresh: () => leadProvider.refresh(),
                            child: ListView.builder(
                              padding: const EdgeInsets.all(AppSpacing.screenPadding),
                              itemCount: filteredLeads.length,
                              itemBuilder: (context, index) {
                                final lead = filteredLeads[index];
                                return _LeadCard(
                                  lead: lead,
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    context.push('/admin/leads/${lead.id}');
                                  },
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  List<Lead> _filterLeads(List<Lead> leads) {
    var filtered = leads;
    if (_selectedStatus != null) {
      filtered = filtered
          .where((l) => l.status == _selectedStatus)
          .toList();
    }
    if (_selectedSource != null) {
      filtered = filtered
          .where((l) => l.source == _selectedSource)
          .toList();
    }
    return filtered;
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
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.classicBlue.withValues(alpha: 0.2),
      checkmarkColor: AppColors.classicBlue,
    );
  }
}

class _LeadCard extends StatelessWidget {
  final Lead lead;
  final VoidCallback onTap;

  const _LeadCard({
    required this.lead,
    required this.onTap,
  });

  Color get _statusColor {
    switch (lead.status) {
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

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppSpacing.borderRadiusMd,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              // Status indicator
              Container(
                width: 4,
                height: 60,
                decoration: BoxDecoration(
                  color: _statusColor,
                  borderRadius: AppSpacing.borderRadiusSm,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              // Lead info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            lead.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        Chip(
                          label: Text(
                            lead.statusString.toUpperCase(),
                            style: const TextStyle(fontSize: 10),
                          ),
                          backgroundColor: _statusColor.withValues(alpha: 0.1),
                          labelStyle: TextStyle(color: _statusColor),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      lead.email,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.neutral600,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Icon(
                          Icons.phone_rounded,
                          size: 14,
                          color: AppColors.neutral500,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          lead.phone,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.neutral600,
                              ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: AppColors.neutral500,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          formatRelativeTime(lead.createdAt),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.neutral500,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

