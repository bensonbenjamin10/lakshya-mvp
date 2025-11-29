import 'package:flutter/material.dart';
import 'package:lakshya_mvp/models/course_module.dart';
import 'package:lakshya_mvp/models/student_progress.dart';
import 'package:lakshya_mvp/theme/theme.dart';

/// Module card widget showing course module information and progress
class ModuleCard extends StatelessWidget {
  final CourseModule module;
  final StudentProgress? progress;
  final VoidCallback onTap;

  const ModuleCard({
    super.key,
    required this.module,
    this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = progress?.status == ProgressStatus.completed;

    return Card(
      elevation: isCompleted ? 0 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadiusMd,
        side: isCompleted
            ? BorderSide(color: AppColors.success.withValues(alpha: 0.3))
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppSpacing.borderRadiusMd,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              // Module icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getModuleColor().withValues(alpha: 0.1),
                  borderRadius: AppSpacing.borderRadiusSm,
                ),
                child: Icon(
                  _getModuleIcon(),
                  color: _getModuleColor(),
                ),
              ),
              const SizedBox(width: AppSpacing.md),

              // Module info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            module.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isCompleted)
                          Icon(
                            Icons.check_circle,
                            color: AppColors.success,
                            size: 20,
                          ),
                      ],
                    ),
                    if (module.description != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        module.description!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.neutral600,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: AppColors.neutral500,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          module.durationMinutes != null
                              ? '${module.durationMinutes} min'
                              : 'N/A',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.neutral500,
                              ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getModuleColor().withValues(alpha: 0.1),
                            borderRadius: AppSpacing.borderRadiusSm,
                          ),
                          child: Text(
                            module.type.displayName,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: _getModuleColor(),
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow icon
              Icon(
                Icons.chevron_right,
                color: AppColors.neutral400,
              ),
            ],
          ),
        ),
      ),
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
        return Icons.play_circle_outline;
      case ModuleType.reading:
        return Icons.article_outlined;
      case ModuleType.assignment:
        return Icons.assignment_outlined;
      case ModuleType.quiz:
        return Icons.quiz_outlined;
      case ModuleType.liveSession:
        return Icons.videocam_outlined;
    }
  }
}

