import 'package:flutter/material.dart';
import 'package:lakshya_mvp/models/enrollment.dart';
import 'package:lakshya_mvp/theme/theme.dart';

/// Badge widget showing enrollment status
class EnrollmentBadge extends StatelessWidget {
  final Enrollment enrollment;

  const EnrollmentBadge({
    super.key,
    required this.enrollment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: AppSpacing.borderRadiusFull,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            'Enrolled',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}

