import 'package:flutter/material.dart';
import 'package:lakshya_mvp/models/course_module.dart';
import 'package:lakshya_mvp/models/student_progress.dart';
import 'package:lakshya_mvp/services/paywall_service.dart';
import 'package:lakshya_mvp/theme/theme.dart';

/// Module card widget showing course module information and progress
/// 
/// Optimized for better visual hierarchy and readability
class ModuleCard extends StatelessWidget {
  final CourseModule module;
  final StudentProgress? progress;
  final VoidCallback onTap;
  final bool isLocked;
  final AccessStatus? accessStatus;
  final int? moduleNumber;

  const ModuleCard({
    super.key,
    required this.module,
    this.progress,
    required this.onTap,
    this.isLocked = false,
    this.accessStatus,
    this.moduleNumber,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = progress?.status == ProgressStatus.completed;
    final isInProgress = progress?.status == ProgressStatus.inProgress;
    final showLock = isLocked && !module.isFreePreview;
    final isFreePreview = module.isFreePreview;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppSpacing.borderRadiusMd,
          child: Container(
            decoration: BoxDecoration(
              color: showLock 
                  ? AppColors.neutral50
                  : isCompleted
                      ? AppColors.success.withValues(alpha: 0.03)
                      : AppColors.surfaceContainerLowestLight,
              borderRadius: AppSpacing.borderRadiusMd,
              border: Border.all(
                color: isCompleted
                    ? AppColors.success.withValues(alpha: 0.3)
                    : isInProgress
                        ? AppColors.classicBlue.withValues(alpha: 0.3)
                        : AppColors.neutral200,
                width: isCompleted || isInProgress ? 1.5 : 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left: Module number + icon
                  _buildModuleIndicator(context, isCompleted, isInProgress, showLock),
                  const SizedBox(width: AppSpacing.md),

                  // Center: Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title row with badges
                        _buildTitleRow(context, isFreePreview, showLock),
                        
                        // Description
                        if (module.description != null) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            module.description!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: showLock ? AppColors.neutral400 : AppColors.neutral600,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        
                        // Meta row: Duration + Type
                        const SizedBox(height: AppSpacing.sm),
                        _buildMetaRow(context, showLock),
                      ],
                    ),
                  ),

                  // Right: Arrow or status
                  const SizedBox(width: AppSpacing.sm),
                  _buildTrailingIndicator(context, isCompleted, showLock),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModuleIndicator(
    BuildContext context,
    bool isCompleted,
    bool isInProgress,
    bool showLock,
  ) {
    final color = showLock
        ? AppColors.neutral400
        : isCompleted
            ? AppColors.success
            : isInProgress
                ? AppColors.classicBlue
                : _getModuleColor();

    return Column(
      children: [
        // Module number circle or icon
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: showLock
                ? AppColors.neutral100
                : color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: isInProgress
                ? Border.all(color: color.withValues(alpha: 0.5), width: 2)
                : null,
          ),
          child: Center(
            child: isCompleted
                ? Icon(
                    Icons.check_rounded,
                    color: color,
                    size: 24,
                  )
                : showLock
                    ? Icon(
                        Icons.lock_rounded,
                        color: AppColors.neutral400,
                        size: 20,
                      )
                    : moduleNumber != null
                        ? Text(
                            moduleNumber.toString(),
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          )
                        : Icon(
                            _getModuleIcon(),
                            color: color,
                            size: 22,
                          ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitleRow(BuildContext context, bool isFreePreview, bool showLock) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            module.title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: showLock ? AppColors.neutral500 : AppColors.neutral900,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (isFreePreview) ...[
          const SizedBox(width: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 3,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.success,
                  AppColors.success.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'FREE',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 10,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMetaRow(BuildContext context, bool showLock) {
    return Row(
      children: [
        // Duration
        Icon(
          Icons.schedule_rounded,
          size: 14,
          color: showLock ? AppColors.neutral300 : AppColors.neutral500,
        ),
        const SizedBox(width: 4),
        Text(
          module.durationMinutes != null
              ? '${module.durationMinutes} min'
              : '—',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: showLock ? AppColors.neutral400 : AppColors.neutral600,
            fontWeight: FontWeight.w500,
          ),
        ),
        
        // Divider
        Container(
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            color: showLock ? AppColors.neutral300 : AppColors.neutral400,
            shape: BoxShape.circle,
          ),
        ),
        
        // Type badge
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: 3,
          ),
          decoration: BoxDecoration(
            color: showLock
                ? AppColors.neutral100
                : _getModuleColor().withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getModuleIcon(),
                size: 12,
                color: showLock ? AppColors.neutral400 : _getModuleColor(),
              ),
              const SizedBox(width: 4),
              Text(
                module.type.displayName,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: showLock ? AppColors.neutral400 : _getModuleColor(),
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTrailingIndicator(BuildContext context, bool isCompleted, bool showLock) {
    if (showLock) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.lock_rounded,
          size: 18,
          color: AppColors.error,
        ),
      );
    }

    if (isCompleted) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.check_circle_rounded,
          size: 18,
          color: AppColors.success,
        ),
      );
    }

    return Icon(
      Icons.chevron_right_rounded,
      size: 24,
      color: AppColors.neutral400,
    );
  }

  Color _getModuleColor() {
    switch (module.type) {
      case ModuleType.video:
        return AppColors.classicBlue;
      case ModuleType.reading:
        return AppColors.success;
      case ModuleType.assignment:
        return AppColors.mimosaGold;
      case ModuleType.quiz:
        return AppColors.vivaMagenta;
      case ModuleType.liveSession:
        return AppColors.ultramarine;
    }
  }

  IconData _getModuleIcon() {
    switch (module.type) {
      case ModuleType.video:
        return Icons.play_circle_rounded;
      case ModuleType.reading:
        return Icons.auto_stories_rounded;
      case ModuleType.assignment:
        return Icons.assignment_rounded;
      case ModuleType.quiz:
        return Icons.quiz_rounded;
      case ModuleType.liveSession:
        return Icons.videocam_rounded;
    }
  }
}
