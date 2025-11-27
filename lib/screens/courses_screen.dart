import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:lakshya_mvp/providers/course_provider.dart';
import 'package:lakshya_mvp/models/course.dart';
import 'package:lakshya_mvp/theme/theme.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  CourseCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final courseProvider = Provider.of<CourseProvider>(context);
    final allCourses = courseProvider.courses;
    final filteredCourses = _selectedCategory == null
        ? allCourses
        : allCourses.where((c) => c.category == _selectedCategory).toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header Section
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                AppSpacing.xxl,
                AppSpacing.screenPadding,
                AppSpacing.xxl,
              ),
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Explore Courses',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Globally recognized professional programs',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Category Filter
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.surfaceContainerLowestLight,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
                child: Row(
                  children: [
                    _CategoryChip(
                      label: 'All',
                      icon: Icons.apps_rounded,
                      count: allCourses.length,
                      isSelected: _selectedCategory == null,
                      color: AppColors.classicBlue,
                      onTap: () {
                        setState(() {
                          _selectedCategory = null;
                        });
                      },
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    ...CourseCategory.values.map((category) {
                      final count = allCourses.where((c) => c.category == category).length;
                      return Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.sm),
                        child: _CategoryChip(
                          label: _getCategoryLabel(category),
                          icon: _getCategoryIcon(category),
                          count: count,
                          isSelected: _selectedCategory == category,
                          color: _getCategoryColor(category),
                          onTap: () {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),

          // Results count
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                AppSpacing.md,
                AppSpacing.screenPadding,
                AppSpacing.sm,
              ),
              child: Row(
                children: [
                  Text(
                    '${filteredCourses.length} ${filteredCourses.length == 1 ? 'Course' : 'Courses'}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.neutral600,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const Spacer(),
                  // Sort button (visual only for now)
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.sort_rounded, size: 18),
                    label: const Text('Sort'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.neutral600,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Courses List
          filteredCourses.isEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.xxl),
                          decoration: BoxDecoration(
                            color: AppColors.neutral100,
                            borderRadius: AppSpacing.borderRadiusFull,
                          ),
                          child: Icon(
                            Icons.school_outlined,
                            size: AppSpacing.iconXxl,
                            color: AppColors.neutral400,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          'No courses found',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppColors.neutral600,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Try selecting a different category',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.neutral500,
                              ),
                        ),
                      ],
                    ),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenPadding,
                    AppSpacing.sm,
                    AppSpacing.screenPadding,
                    AppSpacing.xxl,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final course = filteredCourses[index];
                        return _CourseCard(
                          course: course,
                          onTap: () {
                            courseProvider.selectCourse(course);
                            context.push('/course/${course.id}');
                          },
                        );
                      },
                      childCount: filteredCourses.length,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  String _getCategoryLabel(CourseCategory category) {
    switch (category) {
      case CourseCategory.acca:
        return 'ACCA';
      case CourseCategory.ca:
        return 'CA';
      case CourseCategory.cma:
        return 'CMA';
      case CourseCategory.bcomMba:
        return 'B.Com & MBA';
    }
  }

  IconData _getCategoryIcon(CourseCategory category) {
    switch (category) {
      case CourseCategory.acca:
        return Icons.account_balance_rounded;
      case CourseCategory.ca:
        return Icons.balance_rounded;
      case CourseCategory.cma:
        return Icons.analytics_rounded;
      case CourseCategory.bcomMba:
        return Icons.business_center_rounded;
    }
  }

  Color _getCategoryColor(CourseCategory category) {
    switch (category) {
      case CourseCategory.acca:
        return AppColors.classicBlue;
      case CourseCategory.ca:
        return AppColors.ultramarine;
      case CourseCategory.cma:
        return AppColors.success;
      case CourseCategory.bcomMba:
        return AppColors.mimosaGold;
    }
  }
}

// Category Filter Chip
class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final int count;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.count,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: AppSpacing.borderRadiusFull,
          border: Border.all(
            color: isSelected ? color : AppColors.neutral300,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : color,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: isSelected ? Colors.white : AppColors.neutral700,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.2)
                    : AppColors.neutral200,
                borderRadius: AppSpacing.borderRadiusFull,
              ),
              child: Text(
                '$count',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: isSelected ? Colors.white : AppColors.neutral600,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Course Card
class _CourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback onTap;

  const _CourseCard({
    required this.course,
    required this.onTap,
  });

  Color get _courseColor {
    switch (course.category) {
      case CourseCategory.acca:
        return AppColors.classicBlue;
      case CourseCategory.ca:
        return AppColors.ultramarine;
      case CourseCategory.cma:
        return AppColors.success;
      case CourseCategory.bcomMba:
        return AppColors.mimosaGold;
    }
  }

  IconData get _courseIcon {
    switch (course.category) {
      case CourseCategory.acca:
        return Icons.account_balance_rounded;
      case CourseCategory.ca:
        return Icons.balance_rounded;
      case CourseCategory.cma:
        return Icons.analytics_rounded;
      case CourseCategory.bcomMba:
        return Icons.business_center_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: AppColors.neutral200),
        boxShadow: [
          BoxShadow(
            color: AppColors.neutral900.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppSpacing.borderRadiusMd,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Course Icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _courseColor,
                        _courseColor.withValues(alpha: 0.7),
                      ],
                    ),
                    borderRadius: AppSpacing.borderRadiusMd,
                  ),
                  child: Icon(
                    _courseIcon,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),

                // Course Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category & Popular Badge Row
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _courseColor.withValues(alpha: 0.1),
                              borderRadius: AppSpacing.borderRadiusSm,
                            ),
                            child: Text(
                              course.categoryName,
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: _courseColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                          if (course.isPopular) ...[
                            const SizedBox(width: AppSpacing.sm),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.mimosaGold,
                                borderRadius: AppSpacing.borderRadiusSm,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    size: 12,
                                    color: AppColors.neutral900,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    'Popular',
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.neutral900,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      // Title
                      Text(
                        course.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              height: 1.3,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      // Description
                      Text(
                        course.description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.neutral500,
                              height: 1.4,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Meta info
                      Row(
                        children: [
                          _MetaChip(
                            icon: Icons.schedule_rounded,
                            label: course.duration,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          _MetaChip(
                            icon: Icons.signal_cellular_alt_rounded,
                            label: course.level,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Arrow
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.lg),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.neutral100,
                      borderRadius: AppSpacing.borderRadiusFull,
                    ),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: _courseColor,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Meta Info Chip
class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: AppColors.neutral500,
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.neutral600,
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}
