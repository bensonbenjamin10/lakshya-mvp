import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:lakshya_mvp/providers/student_provider.dart';
import 'package:lakshya_mvp/providers/course_provider.dart';
import 'package:lakshya_mvp/models/enrollment.dart';
import 'package:lakshya_mvp/models/student_progress.dart';
import 'package:lakshya_mvp/models/course.dart';
import 'package:lakshya_mvp/widgets/shared/loading_state.dart';
import 'package:lakshya_mvp/widgets/shared/error_state.dart';
import 'package:lakshya_mvp/widgets/student/module_card.dart';
import 'package:lakshya_mvp/widgets/payment/payment_sheet.dart';
import 'package:lakshya_mvp/services/paywall_service.dart';
import 'package:lakshya_mvp/theme/theme.dart';

/// Course content screen showing modules for an enrolled course
/// 
/// Optimized layout with:
/// - Compact progress header
/// - Numbered module list
/// - Better visual hierarchy
class CourseContentScreen extends StatefulWidget {
  final String courseId;

  const CourseContentScreen({
    super.key,
    required this.courseId,
  });

  @override
  State<CourseContentScreen> createState() => _CourseContentScreenState();
}

class _CourseContentScreenState extends State<CourseContentScreen> {
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshEnrollmentData();
    });
  }

  Future<void> _refreshEnrollmentData() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    
    final studentProvider = Provider.of<StudentProvider>(context, listen: false);
    await studentProvider.refresh();
    
    if (mounted) {
      setState(() => _isRefreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final studentProvider = Provider.of<StudentProvider>(context);
    final courseProvider = Provider.of<CourseProvider>(context);
    final enrollment = studentProvider.getEnrollmentByCourseId(widget.courseId);
    final course = courseProvider.courses.firstWhere(
      (c) => c.id == widget.courseId,
      orElse: () => courseProvider.courses.first,
    );

    if (enrollment == null) {
      return _buildNotEnrolledState(context);
    }

    final progress = studentProvider.getProgressForEnrollment(enrollment.id);
    final accessStatus = PaywallService.checkCourseAccess(
      course: course,
      enrollment: enrollment,
    );

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      appBar: _buildAppBar(context, course, accessStatus),
      body: studentProvider.isLoading && !_isRefreshing
          ? const LoadingState(message: 'Loading course content...')
          : studentProvider.error != null
              ? ErrorState(
                  message: studentProvider.error!,
                  onRetry: _refreshEnrollmentData,
                )
              : RefreshIndicator(
                  onRefresh: _refreshEnrollmentData,
                  color: AppColors.classicBlue,
                  child: _buildContent(context, enrollment, progress, course, accessStatus),
                ),
      bottomNavigationBar: _shouldShowUpgradeBanner(accessStatus)
          ? _buildUpgradeBanner(context, course, enrollment, accessStatus)
          : null,
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, Course course, AccessStatus accessStatus) {
    return AppBar(
      backgroundColor: AppColors.surfaceLight,
      elevation: 0,
      title: Text(
        course.title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      actions: [
        // Access badge in app bar
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.md),
          child: Center(
            child: _buildCompactAccessBadge(context, accessStatus),
          ),
        ),
      ],
    );
  }

  Widget _buildCompactAccessBadge(BuildContext context, AccessStatus status) {
    Color bgColor;
    Color textColor;
    IconData icon;
    String label;

    switch (status.accessType) {
      case AccessType.paid:
        bgColor = AppColors.success.withValues(alpha: 0.1);
        textColor = AppColors.success;
        icon = Icons.verified_rounded;
        label = 'Full Access';
        break;
      case AccessType.trial:
        bgColor = AppColors.mimosaGold.withValues(alpha: 0.1);
        textColor = AppColors.mimosaGold;
        icon = Icons.schedule_rounded;
        label = '${status.trialDaysRemaining}d left';
        break;
      case AccessType.freeCourse:
        bgColor = AppColors.success.withValues(alpha: 0.1);
        textColor = AppColors.success;
        icon = Icons.card_giftcard_rounded;
        label = 'Free';
        break;
      default:
        bgColor = AppColors.error.withValues(alpha: 0.1);
        textColor = AppColors.error;
        icon = Icons.lock_rounded;
        label = 'Limited';
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppSpacing.borderRadiusSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotEnrolledState(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Course Content')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: AppColors.neutral100,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: const Icon(
                  Icons.lock_outline_rounded,
                  size: 48,
                  color: AppColors.neutral400,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Not Enrolled',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Enroll in this course to access the content',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.neutral600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              FilledButton.icon(
                onPressed: () => context.go('/course/${widget.courseId}'),
                icon: const Icon(Icons.arrow_forward_rounded),
                label: const Text('View Course'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.classicBlue,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xxl,
                    vertical: AppSpacing.md,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _shouldShowUpgradeBanner(AccessStatus status) {
    return status.accessType == AccessType.trial || !status.hasAccess;
  }

  Widget _buildContent(
    BuildContext context,
    Enrollment enrollment,
    List<StudentProgress> progress,
    Course course,
    AccessStatus accessStatus,
  ) {
    final studentProvider = Provider.of<StudentProvider>(context);
    final modules = studentProvider.getModulesForCourse(widget.courseId);
    final completedCount = progress.where((p) => p.status == ProgressStatus.completed).length;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress header
          _buildProgressHeader(context, enrollment, modules.length, completedCount),

          // Trial expired warning
          if (!accessStatus.hasAccess && accessStatus.reason?.contains('expired') == true)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                0,
                AppSpacing.screenPadding,
                AppSpacing.md,
              ),
              child: _buildTrialExpiredBanner(context, course, enrollment),
            ),

          // Modules section header
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              AppSpacing.sm,
              AppSpacing.screenPadding,
              AppSpacing.md,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Modules',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.neutral900,
                  ),
                ),
                Text(
                  '${modules.length} lessons',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.neutral500,
                  ),
                ),
              ],
            ),
          ),

          // Module list
          if (modules.isEmpty)
            _buildEmptyModules(context)
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
              child: Column(
                children: modules.asMap().entries.map((entry) {
                  final index = entry.key;
                  final module = entry.value;
                  final moduleProgress = studentProvider.getModuleProgress(
                    enrollment.id,
                    module.id,
                  );
                  final moduleAccess = PaywallService.checkModuleAccess(
                    course: course,
                    module: module,
                    enrollment: enrollment,
                  );
                  final isLocked = !moduleAccess.hasAccess;

                  return ModuleCard(
                    module: module,
                    progress: moduleProgress,
                    isLocked: isLocked,
                    accessStatus: moduleAccess,
                    moduleNumber: index + 1,
                    onTap: () {
                      if (isLocked) {
                        _showPaymentSheet(context, course, enrollment);
                      } else {
                        context.push(
                          '/student/courses/${widget.courseId}/modules/${module.id}?enrollmentId=${enrollment.id}',
                        );
                      }
                    },
                  );
                }).toList(),
              ),
            ),

          // Bottom spacing
          SizedBox(height: _shouldShowUpgradeBanner(accessStatus) ? 100 : AppSpacing.xxl),
        ],
      ),
    );
  }

  Widget _buildProgressHeader(
    BuildContext context,
    Enrollment enrollment,
    int totalModules,
    int completedModules,
  ) {
    final progressPercent = enrollment.progressPercentage / 100;
    
    return Container(
      margin: const EdgeInsets.all(AppSpacing.screenPadding),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.classicBlue,
            AppColors.ultramarine,
          ],
        ),
        borderRadius: AppSpacing.borderRadiusLg,
        boxShadow: [
          BoxShadow(
            color: AppColors.classicBlue.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Progress label + percentage
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your Progress',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: AppSpacing.borderRadiusSm,
                ),
                child: Text(
                  '${enrollment.progressPercentage.toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          
          // Progress bar
          ClipRRect(
            borderRadius: AppSpacing.borderRadiusXs,
            child: LinearProgressIndicator(
              value: progressPercent,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              color: AppColors.mimosaGold,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          
          // Bottom row: Completion stats
          Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                size: 16,
                color: AppColors.mimosaGold,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '$completedModules of $totalModules modules completed',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyModules(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          children: [
            Icon(
              Icons.folder_open_rounded,
              size: 48,
              color: AppColors.neutral300,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No modules yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.neutral500,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Course content will appear here',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.neutral400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrialExpiredBanner(
    BuildContext context,
    Course course,
    Enrollment enrollment,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.05),
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.timer_off_rounded,
            color: AppColors.error,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Trial expired • Upgrade to continue',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () => _showPaymentSheet(context, course, enrollment),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            ),
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradeBanner(
    BuildContext context,
    Course course,
    Enrollment enrollment,
    AccessStatus status,
  ) {
    final isExpired = !status.hasAccess;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: isExpired ? AppColors.error : AppColors.classicBlue,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isExpired ? Icons.timer_off_rounded : Icons.rocket_launch_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            
            // Text
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isExpired ? 'Trial Expired' : '${status.trialDaysRemaining} days left',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    isExpired
                        ? 'Unlock all content'
                        : 'Get unlimited access',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            
            // Button
            FilledButton(
              onPressed: () => _showPaymentSheet(context, course, enrollment),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: isExpired ? AppColors.error : AppColors.classicBlue,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
              ),
              child: const Text(
                'Upgrade',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentSheet(
    BuildContext context,
    Course course,
    Enrollment enrollment,
  ) {
    PaymentSheet.show(
      context,
      course: course,
      enrollment: enrollment,
      onPaymentSuccess: () {
        setState(() {});
      },
      onTrialStarted: () {
        setState(() {});
      },
    );
  }
}
