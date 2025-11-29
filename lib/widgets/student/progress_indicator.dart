import 'package:flutter/material.dart';
import 'package:lakshya_mvp/theme/theme.dart';

/// Progress indicator widget showing course completion percentage
class ProgressIndicatorWidget extends StatelessWidget {
  final double progress;
  final bool showLabel;
  final double height;

  const ProgressIndicatorWidget({
    super.key,
    required this.progress,
    this.showLabel = false,
    this.height = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral600,
                    ),
              ),
              Text(
                '${progress.toStringAsFixed(0)}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral700,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 100.0) / 100.0,
            minHeight: height,
            backgroundColor: AppColors.neutral200,
            valueColor: AlwaysStoppedAnimation<Color>(
              _getProgressColor(progress),
            ),
          ),
        ),
      ],
    );
  }

  Color _getProgressColor(double progress) {
    if (progress >= 100) return AppColors.success;
    if (progress >= 50) return AppColors.classicBlue;
    if (progress >= 25) return AppColors.mimosaGold;
    return AppColors.neutral400;
  }
}

