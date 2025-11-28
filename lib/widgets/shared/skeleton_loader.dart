import 'package:flutter/material.dart';
import 'package:lakshya_mvp/theme/theme.dart';

/// Skeleton loader for showing loading states
class SkeletonLoader extends StatefulWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final bool isCircle;

  const SkeletonLoader({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.isCircle = false,
  });

  /// Creates a text-like skeleton
  const SkeletonLoader.text({
    super.key,
    this.width = 100,
    this.height = 16,
  })  : borderRadius = null,
        isCircle = false;

  /// Creates a circular skeleton (for avatars)
  const SkeletonLoader.circle({
    super.key,
    double size = 48,
  })  : width = size,
        height = size,
        borderRadius = null,
        isCircle = true;

  /// Creates a card-like skeleton
  const SkeletonLoader.card({
    super.key,
    this.width = double.infinity,
    this.height = 120,
  })  : borderRadius = null,
        isCircle = false;

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.isCircle
                ? null
                : (widget.borderRadius ?? AppSpacing.borderRadiusSm),
            shape: widget.isCircle ? BoxShape.circle : BoxShape.rectangle,
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value + 1, 0),
              colors: const [
                AppColors.neutral100,
                AppColors.neutral50,
                AppColors.neutral100,
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Skeleton loader for a course card
class CourseCardSkeleton extends StatelessWidget {
  const CourseCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: AppColors.neutral200),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          SkeletonLoader(
            width: double.infinity,
            height: 140,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppSpacing.radiusMd),
              topRight: Radius.circular(AppSpacing.radiusMd),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category badge
                SkeletonLoader(width: 60, height: 20),
                SizedBox(height: AppSpacing.sm),
                // Title
                SkeletonLoader(width: double.infinity, height: 20),
                SizedBox(height: AppSpacing.xs),
                SkeletonLoader(width: 180, height: 20),
                SizedBox(height: AppSpacing.md),
                // Description
                SkeletonLoader(width: double.infinity, height: 14),
                SizedBox(height: AppSpacing.xs),
                SkeletonLoader(width: 200, height: 14),
                SizedBox(height: AppSpacing.lg),
                // Meta info
                Row(
                  children: [
                    SkeletonLoader(width: 80, height: 14),
                    Spacer(),
                    SkeletonLoader.circle(size: 24),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton loader for course list item (vertical card layout)
class CourseListItemSkeleton extends StatelessWidget {
  const CourseListItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppSpacing.borderRadiusLg,
        border: Border.all(color: AppColors.neutral200),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top section with icon and badges
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.neutral50,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppSpacing.radiusLg),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  // Icon placeholder
                  SkeletonLoader(width: 48, height: 48),
                  SizedBox(width: AppSpacing.md),
                  // Badges
                  Row(
                    children: [
                      SkeletonLoader(width: 60, height: 22),
                      SizedBox(width: AppSpacing.sm),
                      SkeletonLoader(width: 70, height: 22),
                    ],
                  ),
                  Spacer(),
                  // Favorite placeholder
                  SkeletonLoader.circle(size: 24),
                ],
              ),
            ),
          ),
          // Content section
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                SkeletonLoader(width: double.infinity, height: 20),
                SizedBox(height: AppSpacing.xs),
                SkeletonLoader(width: 200, height: 20),
                SizedBox(height: AppSpacing.md),
                // Description
                SkeletonLoader(width: double.infinity, height: 16),
                SizedBox(height: AppSpacing.xs),
                SkeletonLoader(width: 250, height: 16),
                SizedBox(height: AppSpacing.lg),
                // Footer
                Row(
                  children: [
                    SkeletonLoader(width: 90, height: 28),
                    SizedBox(width: AppSpacing.md),
                    SkeletonLoader(width: 80, height: 28),
                    Spacer(),
                    SkeletonLoader(width: 70, height: 32),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

