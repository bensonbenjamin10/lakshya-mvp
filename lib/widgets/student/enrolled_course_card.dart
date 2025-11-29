import 'package:flutter/material.dart';
import 'package:lakshya_mvp/models/enrollment.dart';
import 'package:lakshya_mvp/widgets/student/progress_indicator.dart';
import 'package:lakshya_mvp/theme/theme.dart';

/// Course card widget for enrolled courses showing progress
class EnrolledCourseCard extends StatelessWidget {
  final Enrollment enrollment;
  final VoidCallback onTap;

  const EnrolledCourseCard({
    super.key,
    required this.enrollment,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final course = enrollment.course;
    if (course == null) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadiusMd,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppSpacing.borderRadiusMd,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Course title and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      course.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildStatusBadge(context),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Progress indicator
              ProgressIndicatorWidget(
                progress: enrollment.progressPercentage,
                showLabel: true,
              ),
              const SizedBox(height: AppSpacing.sm),

              // Footer
              Row(
                children: [
                  Text(
                    '${enrollment.progressPercentage.toStringAsFixed(0)}% Complete',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.neutral600,
                        ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: onTap,
                    child: const Text('Continue Learning'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    Color badgeColor;
    String label;

    switch (enrollment.status) {
      case EnrollmentStatus.active:
        badgeColor = AppColors.success;
        label = 'Active';
        break;
      case EnrollmentStatus.completed:
        badgeColor = AppColors.classicBlue;
        label = 'Completed';
        break;
      case EnrollmentStatus.pending:
        badgeColor = AppColors.mimosaGold;
        label = 'Pending';
        break;
      case EnrollmentStatus.dropped:
        badgeColor = AppColors.neutral400;
        label = 'Dropped';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        borderRadius: AppSpacing.borderRadiusSm,
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: badgeColor,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

