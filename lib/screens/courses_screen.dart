import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:lakshya_mvp/providers/course_provider.dart';
import 'package:lakshya_mvp/providers/favorites_provider.dart';
import 'package:lakshya_mvp/models/course.dart';
import 'package:lakshya_mvp/theme/theme.dart';
import 'package:lakshya_mvp/widgets/shared/skeleton_loader.dart';
import 'package:lakshya_mvp/widgets/shared/whatsapp_fab.dart';
import 'package:lakshya_mvp/config/app_config.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  CourseCategory? _selectedCategory;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchExpanded = false;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  List<Course> _filterCourses(List<Course> courses) {
    var filtered = courses;

    // Filter by category
    if (_selectedCategory != null) {
      filtered = filtered.where((c) => c.category == _selectedCategory).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((c) {
        return c.title.toLowerCase().contains(query) ||
            c.description.toLowerCase().contains(query) ||
            c.categoryName.toLowerCase().contains(query);
      }).toList();
    }

    return filtered;
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _isSearchExpanded = false;
    });
    _searchFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final courseProvider = Provider.of<CourseProvider>(context);
    final allCourses = courseProvider.courses;
    final filteredCourses = _filterCourses(allCourses);
    final isLoading = courseProvider.isLoading;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header Section
          SliverToBoxAdapter(
            child: _buildHeader(context),
          ),

          // Search Bar
          SliverToBoxAdapter(
            child: _buildSearchBar(context),
          ),

          // Category Filter
          SliverToBoxAdapter(
            child: _buildCategoryFilter(context, allCourses),
          ),

          // Results count
          SliverToBoxAdapter(
            child: _buildResultsCount(context, filteredCourses),
          ),

          // Courses List
          if (isLoading)
            _buildSkeletonList()
          else if (filteredCourses.isEmpty)
            _buildEmptyState(context)
          else
            _buildCoursesList(context, filteredCourses, courseProvider),
        ],
      ),
      floatingActionButton: const WhatsAppFab(
        phoneNumber: AppConfig.whatsAppNumber,
        prefilledMessage: AppConfig.whatsAppCourseInquiry,
        heroTag: 'whatsapp_fab_courses',
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPadding,
            AppSpacing.xxl,
            AppSpacing.screenPadding,
            AppSpacing.lg,
          ),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                AppColors.classicBlue10,
              ],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon badge
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.classicBlue.withValues(alpha: 0.1),
                    borderRadius: AppSpacing.borderRadiusMd,
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    color: AppColors.classicBlue,
                    size: AppSpacing.iconMd,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Our Programs',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.neutral900,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'CA, ACCA, CMA & more — globally recognized qualifications',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.neutral600,
                      ),
                ),
              ],
            ),
          ),
        ),
        // Golden accent (top-right)
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topRight,
                radius: 1.0,
                colors: [
                  AppColors.mimosaGold.withValues(alpha: 0.25),
                  AppColors.mimosaGold.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      color: AppColors.surfaceContainerLowestLight,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.sm,
        AppSpacing.screenPadding,
        AppSpacing.sm,
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: _isSearchExpanded
              ? AppColors.classicBlue.withValues(alpha: 0.05)
              : AppColors.surfaceContainerLight,
          borderRadius: AppSpacing.borderRadiusFull,
          border: Border.all(
            color: _isSearchExpanded ? AppColors.classicBlue : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          onChanged: (value) {
            setState(() => _searchQuery = value);
          },
          onTap: () {
            setState(() => _isSearchExpanded = true);
          },
          style: Theme.of(context).textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: 'Search courses...',
            hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.neutral400,
                ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: _isSearchExpanded ? AppColors.classicBlue : AppColors.neutral400,
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    onPressed: _clearSearch,
                    icon: const Icon(Icons.close_rounded, size: 20),
                    color: AppColors.neutral500,
                  )
                : null,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter(BuildContext context, List<Course> allCourses) {
    return Container(
      color: AppColors.surfaceContainerLowestLight,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
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
                HapticFeedback.selectionClick();
                setState(() => _selectedCategory = null);
              },
            ),
            const SizedBox(width: AppSpacing.sm),
            ...CourseCategory.values.map((category) {
              final count =
                  allCourses.where((c) => c.category == category).length;
              return Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: _CategoryChip(
                  label: _getCategoryLabel(category),
                  icon: _getCategoryIcon(category),
                  count: count,
                  isSelected: _selectedCategory == category,
                  color: _getCategoryColor(category),
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedCategory = category);
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsCount(BuildContext context, List<Course> filteredCourses) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.md,
        AppSpacing.screenPadding,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          Text(
            '${filteredCourses.length} ${filteredCourses.length == 1 ? 'Program' : 'Programs'} available',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.neutral600,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const Spacer(),
          // Filter indicator
          if (_selectedCategory != null || _searchQuery.isNotEmpty)
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() {
                  _selectedCategory = null;
                  _searchQuery = '';
                  _searchController.clear();
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.classicBlue.withValues(alpha: 0.1),
                  borderRadius: AppSpacing.borderRadiusFull,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.filter_list_off_rounded,
                      size: 14,
                      color: AppColors.classicBlue,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'Clear filters',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.classicBlue,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSkeletonList() {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.sm,
        AppSpacing.screenPadding,
        AppSpacing.xxl,
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => const CourseListItemSkeleton(),
          childCount: 4,
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              decoration: BoxDecoration(
                color: AppColors.classicBlue.withValues(alpha: 0.1),
                borderRadius: AppSpacing.borderRadiusFull,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: AppSpacing.iconXxl,
                color: AppColors.classicBlue,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No results for "$_searchQuery"'
                  : 'No programs in this category',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.neutral700,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Try adjusting your search or filters',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.neutral500,
                  ),
            ),
            const SizedBox(height: AppSpacing.lg),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _selectedCategory = null;
                  _searchQuery = '';
                  _searchController.clear();
                });
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Clear all filters'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoursesList(
    BuildContext context,
    List<Course> filteredCourses,
    CourseProvider courseProvider,
  ) {
    return SliverPadding(
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
            // Check enrollment status asynchronously - will be enhanced later
            return _CourseCard(
              course: course,
              onTap: () {
                HapticFeedback.lightImpact();
                courseProvider.selectCourse(course);
                context.push('/course/${course.id}');
              },
            );
          },
          childCount: filteredCourses.length,
        ),
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

// Course Card - Clean vertical layout
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
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppSpacing.borderRadiusLg,
        border: Border.all(color: AppColors.neutral200),
        boxShadow: [
          BoxShadow(
            color: AppColors.neutral900.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppSpacing.borderRadiusLg,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppSpacing.borderRadiusLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top section with icon, badges, and favorite
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: _courseColor.withValues(alpha: 0.03),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppSpacing.radiusLg),
                  ),
                ),
                child: Row(
                  children: [
                    // Course Icon
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            _courseColor,
                            _courseColor.withValues(alpha: 0.8),
                          ],
                        ),
                        borderRadius: AppSpacing.borderRadiusMd,
                        boxShadow: [
                          BoxShadow(
                            color: _courseColor.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        _courseIcon,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    // Badges
                    Expanded(
                      child: Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.xs,
                        children: [
                          _Badge(
                            label: course.categoryName,
                            color: _courseColor,
                            filled: false,
                          ),
                          if (course.isPopular)
                            const _Badge(
                              label: 'Top Pick',
                              color: AppColors.mimosaGold,
                              filled: true,
                              icon: Icons.bolt_rounded,
                            ),
                        ],
                      ),
                    ),
                    // Favorite button
                    Consumer<FavoritesProvider>(
                      builder: (context, favProvider, _) {
                        final isFavorite = favProvider.isFavorite(course.id);
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              favProvider.toggleFavorite(course.id);
                            },
                            borderRadius: AppSpacing.borderRadiusFull,
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.sm),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                transitionBuilder: (child, animation) {
                                  return ScaleTransition(
                                    scale: animation,
                                    child: child,
                                  );
                                },
                                child: Icon(
                                  isFavorite
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  key: ValueKey(isFavorite),
                                  size: 24,
                                  color: isFavorite
                                      ? AppColors.vivaMagenta
                                      : AppColors.neutral400,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              // Content section
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      course.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                            color: AppColors.neutral900,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    // Description
                    Text(
                      course.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.neutral600,
                            height: 1.5,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    // Footer with meta info and CTA
                    Row(
                      children: [
                        // Meta info - flexible to allow shrinking
                        Expanded(
                          child: Row(
                            children: [
                              // Duration
                              Flexible(
                                child: _MetaInfo(
                                  icon: Icons.schedule_rounded,
                                  label: course.duration,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              // Level
                              Flexible(
                                child: _MetaInfo(
                                  icon: Icons.signal_cellular_alt_rounded,
                                  label: course.level,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        // View button - fixed size
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: _courseColor,
                          size: 24,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Badge widget for category and popular tags
class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final bool filled;
  final IconData? icon;

  const _Badge({
    required this.label,
    required this.color,
    this.filled = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: filled ? color : color.withValues(alpha: 0.1),
        borderRadius: AppSpacing.borderRadiusSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 12,
              color: filled ? AppColors.neutral900 : color,
            ),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: filled ? AppColors.neutral900 : color,
            ),
          ),
        ],
      ),
    );
  }
}

// Meta info widget for duration and level
class _MetaInfo extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaInfo({
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
        Flexible(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.neutral600,
                  fontWeight: FontWeight.w500,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

