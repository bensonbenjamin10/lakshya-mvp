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

/// Admin Dashboard Screen
/// 
/// Main dashboard for admin users to manage leads and view analytics.
/// Requires authentication - follows zero-friction principle (auth only for dashboards).
class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
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
    // Check authentication
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (!authProvider.isAuthenticated) {
        // Redirect to login (will be created)
        context.go('/login?redirect=/admin');
      }
    });
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
              Text(
                'Please sign in to access the admin dashboard',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.neutral600,
                    ),
              ),
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton(
                onPressed: () => context.go('/login?redirect=/admin'),
                child: const Text('Sign In'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              HapticFeedback.mediumImpact();
              leadProvider.refresh();
            },
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              HapticFeedback.mediumImpact();
              final router = GoRouter.of(context);
              await authProvider.signOut();
              if (mounted) {
                router.go('/');
              }
            },
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => leadProvider.refresh(),
        child: CustomScrollView(
          slivers: [
            // Quick Access Section
            SliverToBoxAdapter(
              child: _buildQuickAccessSection(context),
            ),

            // Stats Section
            SliverToBoxAdapter(
              child: _buildStatsSection(context, leadProvider),
            ),

            // Leads Section Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding,
                  AppSpacing.lg,
                  AppSpacing.screenPadding,
                  AppSpacing.md,
                ),
                child: Row(
                  children: [
                    Text(
                      'Recent Leads',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        context.push('/admin/leads');
                      },
                      icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                      label: const Text('View All'),
                    ),
                  ],
                ),
              ),
            ),

            // Leads List
            if (leadProvider.isLoading)
              const SliverFillRemaining(
                child: LoadingState(message: 'Loading leads...'),
              )
            else if (leadProvider.error != null)
              SliverFillRemaining(
                child: ErrorState(
                  message: leadProvider.error!,
                  onRetry: () => leadProvider.refresh(),
                ),
              )
            else if (leadProvider.leads.isEmpty)
              SliverFillRemaining(
                child: const EmptyState(
                  title: 'No leads yet',
                  message: 'Leads will appear here once submitted through the app',
                  icon: Icons.inbox_outlined,
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final lead = leadProvider.leads[index];
                      return _LeadCard(
                        lead: lead,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          context.push('/admin/leads/${lead.id}');
                        },
                      );
                    },
                    childCount: leadProvider.leads.length > 5
                        ? 5
                        : leadProvider.leads.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.screenPadding),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: AppSpacing.borderRadiusLg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Access',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              Expanded(
                child: _QuickAccessCard(
                  icon: Icons.school_rounded,
                  label: 'Courses',
                  onTap: () => context.go('/admin/courses'),
                ),
              ),
              Expanded(
                child: _QuickAccessCard(
                  icon: Icons.people_rounded,
                  label: 'Leads',
                  onTap: () => context.go('/admin/leads'),
                ),
              ),
              Expanded(
                child: _QuickAccessCard(
                  icon: Icons.video_library_rounded,
                  label: 'Videos',
                  onTap: () => context.go('/admin/videos'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context, LeadProvider leadProvider) {
    final totalLeads = leadProvider.leads.length;
    final newLeads = leadProvider.leads
        .where((l) => l.status == LeadStatus.newLead)
        .length;
    final contactedLeads = leadProvider.leads
        .where((l) => l.status == LeadStatus.contacted)
        .length;
    final convertedLeads = leadProvider.leads
        .where((l) => l.status == LeadStatus.converted)
        .length;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.classicBlue,
            AppColors.classicBlue.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dashboard Overview',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Total Leads',
                  value: totalLeads.toString(),
                  icon: Icons.people_outline_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _StatCard(
                  label: 'New',
                  value: newLeads.toString(),
                  icon: Icons.new_releases_rounded,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Contacted',
                  value: contactedLeads.toString(),
                  icon: Icons.phone_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _StatCard(
                  label: 'Converted',
                  value: convertedLeads.toString(),
                  icon: Icons.check_circle_outline_rounded,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickAccessCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAccessCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppSpacing.borderRadiusMd,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: AppSpacing.borderRadiusMd,
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: AppSpacing.borderRadiusMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color.withValues(alpha: 0.9),
                ),
          ),
        ],
      ),
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
                height: 48,
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
                    Text(
                      lead.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
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

