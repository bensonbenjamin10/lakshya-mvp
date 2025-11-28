import 'package:flutter/material.dart';
import 'package:lakshya_mvp/theme/theme.dart';

/// Loading state widget following DRY principles
/// 
/// Reusable loading indicator used throughout the app.
/// Single source of truth for loading UI.
class LoadingState extends StatelessWidget {
  final String? message;

  const LoadingState({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(AppColors.classicBlue),
          ),
          if (message != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.neutral600,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

