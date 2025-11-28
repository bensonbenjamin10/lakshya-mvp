import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:lakshya_mvp/providers/course_provider.dart';
import 'package:lakshya_mvp/providers/theme_provider.dart';
import 'package:lakshya_mvp/widgets/course_card.dart';
import 'package:lakshya_mvp/widgets/hero_section.dart';
import 'package:lakshya_mvp/widgets/features_section.dart';
import 'package:lakshya_mvp/widgets/testimonials_section.dart';
import 'package:lakshya_mvp/widgets/cta_section.dart';
import 'package:lakshya_mvp/widgets/video_promo_section.dart';
import 'package:lakshya_mvp/widgets/lakshya_logo.dart';
import 'package:lakshya_mvp/widgets/shared/app_footer.dart';
import 'package:lakshya_mvp/widgets/shared/whatsapp_fab.dart';
import 'package:lakshya_mvp/widgets/shared/skeleton_loader.dart';
import 'package:lakshya_mvp/theme/theme.dart';
import 'package:lakshya_mvp/config/app_config.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final courseProvider = Provider.of<CourseProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final popularCourses = courseProvider.getPopularCourses();
    final isLoading = courseProvider.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const LakshyaLogo.appBar(),
        actions: [
          // Theme toggle button
          IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) {
                return RotationTransition(
                  turns: animation,
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child: Icon(
                themeProvider.themeIcon,
                key: ValueKey(themeProvider.themeMode),
              ),
            ),
            tooltip: 'Theme: ${themeProvider.themeLabel}',
            onPressed: () {
              HapticFeedback.lightImpact();
              themeProvider.toggleTheme();
            },
          ),
          // Notifications button
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No new notifications'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          HapticFeedback.mediumImpact();
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Section
              const HeroSection(),

              // Programs Section
              Padding(
                padding: const EdgeInsets.all(AppSpacing.screenPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon badge
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: AppColors.classicBlue.withValues(alpha: 0.1),
                            borderRadius: AppSpacing.borderRadiusSm,
                          ),
                          child: const Icon(
                            Icons.school_rounded,
                            color: AppColors.classicBlue,
                            size: AppSpacing.iconSm,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Our Programs',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                'Globally recognized qualifications',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: AppColors.neutral500,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            context.go('/courses');
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('See All'),
                              SizedBox(width: AppSpacing.xs),
                              Icon(Icons.arrow_forward_rounded, size: 16),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    // Course carousel with loading state
                    SizedBox(
                      height: 340,
                      child: isLoading
                          ? _buildCourseSkeletons()
                          : ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: popularCourses.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: EdgeInsets.only(
                                    right: index < popularCourses.length - 1
                                        ? AppSpacing.lg
                                        : 0,
                                  ),
                                  child: CourseCard(
                                    course: popularCourses[index],
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                      courseProvider
                                          .selectCourse(popularCourses[index]);
                                      context.push(
                                          '/course/${popularCourses[index].id}');
                                    },
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),

              // Video Promo Section
              const SizedBox(height: AppSpacing.xxl),
              const VideoPromoSection(),

              // Features Section
              const SizedBox(height: AppSpacing.xxl),
              const FeaturesSection(),

              // Testimonials Section
              const TestimonialsSection(),

              // CTA Section
              const CtaSection(),

              // Footer - Using shared widget
              const AppFooter(showSocialIcons: true),
            ],
          ),
        ),
      ),
      floatingActionButton: const WhatsAppFab(
        phoneNumber: AppConfig.whatsAppNumber,
        prefilledMessage: AppConfig.whatsAppDefaultMessage,
      ),
    );
  }

  Widget _buildCourseSkeletons() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: 3,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(right: index < 2 ? AppSpacing.lg : 0),
          child: const CourseCardSkeleton(),
        );
      },
    );
  }
}
