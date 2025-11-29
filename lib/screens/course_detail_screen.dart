import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:lakshya_mvp/providers/course_provider.dart';
import 'package:lakshya_mvp/models/lead.dart';
import 'package:lakshya_mvp/models/course.dart';
import 'package:lakshya_mvp/widgets/lead_form_dialog.dart';
import 'package:lakshya_mvp/widgets/vimeo_player.dart';
import 'package:lakshya_mvp/theme/theme.dart';
import 'package:lakshya_mvp/services/analytics_service.dart';
import 'package:lakshya_mvp/providers/video_promo_provider.dart';
import 'package:lakshya_mvp/models/video_promo.dart';

class CourseDetailScreen extends StatefulWidget {
  final String courseId;

  const CourseDetailScreen({
    super.key,
    required this.courseId,
  });

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  bool _hasTrackedView = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Track course view once when screen is displayed
    if (!_hasTrackedView) {
      final courseProvider = Provider.of<CourseProvider>(context);
      final course = courseProvider.courses.firstWhere(
        (c) => c.id == widget.courseId,
        orElse: () => courseProvider.courses.first,
      );
      AnalyticsService.logCourseView(
        courseId: course.id,
        courseName: course.title,
      );
      _hasTrackedView = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final courseProvider = Provider.of<CourseProvider>(context);
    final course = courseProvider.courses.firstWhere(
      (c) => c.id == widget.courseId,
      orElse: () => courseProvider.courses.first,
    );
    final courseColor = _CourseDetailScreenState._getCourseColor(course.category);

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        // Reset status bar when leaving
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
        backgroundColor: AppColors.surfaceContainerLowestLight,
        body: CustomScrollView(
          slivers: [
            // Hero Header
            SliverAppBar(
              expandedHeight: 280,
              pinned: true,
              stretch: true,
              backgroundColor: courseColor,
              leading: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: CircleAvatar(
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/');
                      }
                    },
                  ),
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: CircleAvatar(
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    child: IconButton(
                      icon: const Icon(Icons.share_rounded, color: Colors.white),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Share feature coming soon!'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        courseColor,
                        courseColor.withValues(alpha: 0.8),
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: AppSpacing.massive),
                        // Course Icon
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: AppSpacing.borderRadiusLg,
                          ),
                          child: Icon(
                            _CourseDetailScreenState._getCourseIcon(course.category),
                            size: AppSpacing.iconHuge,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        // Category Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: AppSpacing.borderRadiusFull,
                          ),
                          child: Text(
                            course.categoryName,
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        if (course.isPopular) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.mimosaGold,
                              borderRadius: AppSpacing.borderRadiusFull,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  size: 14,
                                  color: AppColors.neutral900,
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                Text(
                                  'Popular Course',
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                        color: AppColors.neutral900,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Content
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Course Title Card
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(AppSpacing.screenPadding),
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: AppSpacing.borderRadiusMd,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.neutral900.withValues(alpha: 0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.title,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        // Info Chips
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          children: [
                            _InfoChip(
                              icon: Icons.schedule_rounded,
                              label: course.duration,
                              color: courseColor,
                            ),
                            _InfoChip(
                              icon: Icons.signal_cellular_alt_rounded,
                              label: course.level,
                              color: courseColor,
                            ),
                            _InfoChip(
                              icon: Icons.language_rounded,
                              label: 'English',
                              color: courseColor,
                            ),
                            const _InfoChip(
                              icon: Icons.verified_rounded,
                              label: 'Certified',
                              color: AppColors.success,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Course Preview Video Section
                  _CourseVideoPreview(
                    courseColor: courseColor,
                    courseCategory: course.category,
                    courseId: course.id,
                  ),

                  // About Section
                  _SectionContainer(
                    title: 'About This Course',
                    icon: Icons.info_outline_rounded,
                    iconColor: courseColor,
                    child: Text(
                      course.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.neutral600,
                            height: 1.7,
                          ),
                    ),
                  ),

                  // Highlights Section
                  _SectionContainer(
                    title: 'What You\'ll Learn',
                    icon: Icons.lightbulb_outline_rounded,
                    iconColor: AppColors.mimosaGold,
                    child: Column(
                      children: course.highlights.map((highlight) {
                        return _HighlightItem(
                          text: highlight,
                          color: courseColor,
                        );
                      }).toList(),
                    ),
                  ),

                  // Key Features Section
                  const _SectionContainer(
                    title: 'Key Features',
                    icon: Icons.star_outline_rounded,
                    iconColor: AppColors.vivaMagenta,
                    child: Column(
                      children: [
                        _FeatureRow(
                          icon: Icons.people_outline_rounded,
                          title: 'Expert Faculty',
                          description: 'Learn from industry professionals',
                        ),
                        _FeatureRow(
                          icon: Icons.play_circle_outline_rounded,
                          title: 'Flexible Learning',
                          description: 'Online & offline classes available',
                        ),
                        _FeatureRow(
                          icon: Icons.workspace_premium_outlined,
                          title: 'Global Recognition',
                          description: 'Internationally recognized certification',
                        ),
                        _FeatureRow(
                          icon: Icons.support_agent_rounded,
                          title: 'Dedicated Support',
                          description: '24/7 doubt clearing sessions',
                        ),
                      ],
                    ),
                  ),

                  // CTA Card
                  Container(
                    margin: const EdgeInsets.all(AppSpacing.screenPadding),
                    padding: const EdgeInsets.all(AppSpacing.xxl),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [courseColor, courseColor.withValues(alpha: 0.8)],
                      ),
                      borderRadius: AppSpacing.borderRadiusLg,
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.school_rounded,
                          size: AppSpacing.iconXl,
                          color: Colors.white,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Ready to Start?',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Join thousands of successful students',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        SizedBox(
                          width: double.infinity,
                          height: AppSpacing.buttonHeightLg,
                          child: ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => LeadFormDialog(
                                  courseId: course.id,
                                  inquiryType: InquiryType.enrollment,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: courseColor,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: AppSpacing.borderRadiusSm,
                              ),
                            ),
                            child: const Text(
                              'Enroll Now',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bottom spacing for action bar
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),

        // Bottom Action Bar
          bottomNavigationBar: _BottomActionBar(
            course: course,
            courseColor: courseColor,
          ),
        ),
      ),
    );
  }

  static Color _getCourseColor(CourseCategory category) {
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

  static IconData _getCourseIcon(CourseCategory category) {
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
}

// Info Chip Widget
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppSpacing.borderRadiusFull,
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

// Section Container Widget
class _SectionContainer extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Widget child;

  const _SectionContainer({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: AppSpacing.borderRadiusSm,
                ),
                child: Icon(
                  icon,
                  size: AppSpacing.iconSm,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          child,
        ],
      ),
    );
  }
}

// Highlight Item Widget
class _HighlightItem extends StatelessWidget {
  final String text;
  final Color color;

  const _HighlightItem({
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.all(AppSpacing.xs),
            decoration: BoxDecoration(
              color: AppColors.successLight,
              borderRadius: AppSpacing.borderRadiusFull,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: AppColors.success,
              size: 14,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.neutral700,
                    height: 1.5,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

// Feature Row Widget
class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.classicBlue10,
              borderRadius: AppSpacing.borderRadiusMd,
            ),
            child: Icon(
              icon,
              size: AppSpacing.iconMd,
              color: AppColors.classicBlue,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.neutral500,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Bottom Action Bar Widget
class _BottomActionBar extends StatelessWidget {
  final Course course;
  final Color courseColor;

  const _BottomActionBar({
    required this.course,
    required this.courseColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.neutral900.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Request Info Button (Icon only)
            SizedBox(
              width: 52,
              height: 52,
              child: OutlinedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => LeadFormDialog(
                      courseId: course.id,
                      inquiryType: InquiryType.courseInquiry,
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  foregroundColor: courseColor,
                  side: BorderSide(color: courseColor.withValues(alpha: 0.5), width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppSpacing.borderRadiusSm,
                  ),
                ),
                child: const Icon(Icons.chat_bubble_outline_rounded, size: 22),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            // Enroll Now Button (Full width)
            Expanded(
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => LeadFormDialog(
                        courseId: course.id,
                        inquiryType: InquiryType.enrollment,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: courseColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppSpacing.borderRadiusSm,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.school_rounded, size: 20),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Enroll Now',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Course Video Preview Widget
class _CourseVideoPreview extends StatelessWidget {
  final Color courseColor;
  final CourseCategory courseCategory;
  final String? courseId;

  const _CourseVideoPreview({
    required this.courseColor,
    required this.courseCategory,
    this.courseId,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<VideoPromoProvider>(
      builder: (context, videoProvider, child) {
        // Find course preview video for this course
        if (videoProvider.videos.isEmpty) {
          return const SizedBox.shrink();
        }

        VideoPromo video;
        try {
          if (courseId != null) {
            video = videoProvider.videos.firstWhere(
              (v) => v.courseId == courseId && v.type == VideoPromoType.coursePreview,
            );
          } else {
            throw Exception('No course ID');
          }
        } catch (_) {
          // No course-specific video found, try course preview type
          try {
            video = videoProvider.videos.firstWhere(
              (v) => v.type == VideoPromoType.coursePreview,
            );
          } catch (_) {
            // No course preview videos, use first video
            video = videoProvider.videos.first;
          }
        }

        return Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: courseColor.withValues(alpha: 0.1),
                      borderRadius: AppSpacing.borderRadiusSm,
                    ),
                    child: Icon(
                      Icons.play_circle_outline_rounded,
                      size: AppSpacing.iconSm,
                      color: courseColor,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    'Course Preview',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Video Thumbnail
              GestureDetector(
                onTap: () {
                  // Log analytics event
                  AnalyticsService.logVideoPlay(
                    videoId: video.vimeoId,
                    videoTitle: video.title,
                  );
                  _openVideoPlayer(context, video);
                },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: AppSpacing.borderRadiusLg,
                boxShadow: [
                  BoxShadow(
                    color: courseColor.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: AppSpacing.borderRadiusLg,
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Background Gradient
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              courseColor,
                              courseColor.withValues(alpha: 0.7),
                            ],
                          ),
                        ),
                      ),

                      // Pattern
                      Opacity(
                        opacity: 0.1,
                        child: CustomPaint(
                          painter: _DotPatternPainter(),
                          size: Size.infinite,
                        ),
                      ),

                      // Content
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Duration Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.xs,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.3),
                                borderRadius: AppSpacing.borderRadiusFull,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.videocam_rounded,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                  const SizedBox(width: AppSpacing.xs),
                                  Text(
                                    'Course Preview',
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ],
                              ),
                            ),

                            const Spacer(),

                            // Play Button
                            Center(
                              child: Container(
                                padding: const EdgeInsets.all(AppSpacing.lg),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.2),
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.play_arrow_rounded,
                                  color: courseColor,
                                  size: 36,
                                ),
                              ),
                            ),

                            const Spacer(),

                            // Title
                            Text(
                              video.title,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              'Watch our introduction video',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                            ),
                          ],
                        ),
                      ),

                      // Duration chip
                      Positioned(
                        right: AppSpacing.md,
                        bottom: AppSpacing.md,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.7),
                            borderRadius: AppSpacing.borderRadiusSm,
                          ),
                          child: Text(
                            video.duration ?? '--:--',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Watch button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
                onPressed: () {
                // Log analytics event
                AnalyticsService.logVideoPlay(
                  videoId: video.vimeoId,
                  videoTitle: video.title,
                );
                _openVideoPlayer(context, video);
              },
              icon: const Icon(Icons.play_circle_outline_rounded, size: 20),
              label: const Text('Watch Course Introduction'),
              style: OutlinedButton.styleFrom(
                foregroundColor: courseColor,
                side: BorderSide(color: courseColor.withValues(alpha: 0.5)),
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: AppSpacing.borderRadiusSm,
                ),
              ),
            ),
          ),
        ],
      ),
    );
      },
    );
  }

  void _openVideoPlayer(BuildContext context, VideoPromo video) {
    // Log analytics event
    AnalyticsService.logVideoPlay(
      videoId: video.vimeoId,
      videoTitle: video.title,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => VideoPlayerModal(
        videoId: video.vimeoId,
        title: video.title,
      ),
    );
  }
}

// Dot Pattern Painter
class _DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    const spacing = 20.0;
    for (double x = 0; x < size.width + spacing; x += spacing) {
      for (double y = 0; y < size.height + spacing; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
