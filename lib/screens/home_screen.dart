import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:lakshya_mvp/providers/course_provider.dart';
import 'package:lakshya_mvp/widgets/course_card.dart';
import 'package:lakshya_mvp/widgets/hero_section.dart';
import 'package:lakshya_mvp/widgets/features_section.dart';
import 'package:lakshya_mvp/widgets/testimonials_section.dart';
import 'package:lakshya_mvp/widgets/cta_section.dart';
import 'package:lakshya_mvp/widgets/video_promo_section.dart';
import 'package:lakshya_mvp/theme/theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final courseProvider = Provider.of<CourseProvider>(context);
    final popularCourses = courseProvider.getPopularCourses();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: AppSpacing.borderRadiusSm,
              ),
              child: const Text(
                'L',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              'Lakshya',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.classicBlue,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Show notifications
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
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Section
              const HeroSection(),

              // Popular Courses Section
              Padding(
                padding: const EdgeInsets.all(AppSpacing.screenPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Popular Courses',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                'Start your journey with our top programs',
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
                        const SizedBox(width: AppSpacing.sm),
                        TextButton(
                          onPressed: () => context.go('/courses'),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('View All'),
                              SizedBox(width: AppSpacing.xs),
                              Icon(Icons.arrow_forward, size: 16),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    SizedBox(
                      height: 340,
                      child: ListView.builder(
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
                                courseProvider
                                    .selectCourse(popularCourses[index]);
                                context
                                    .push('/course/${popularCourses[index].id}');
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

              // Footer
              _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: const BoxDecoration(
        gradient: AppColors.heroGradient,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppSpacing.borderRadiusSm,
                ),
                child: const Text(
                  'L',
                  style: TextStyle(
                    color: AppColors.classicBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                'Lakshya Institute',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Leading Institute for Commerce Professional Courses',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xxl),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SocialIcon(
                icon: Icons.language,
                onTap: () {},
              ),
              _SocialIcon(
                icon: Icons.email_outlined,
                onTap: () => context.go('/contact'),
              ),
              _SocialIcon(
                icon: Icons.phone_outlined,
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: AppSpacing.lg),
          Text(
            '© 2024 Lakshya Institute. All rights reserved.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white54,
                ),
          ),
          // Add padding for bottom nav
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _SocialIcon({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white),
        style: IconButton.styleFrom(
          backgroundColor: Colors.white.withValues(alpha: 0.1),
          padding: const EdgeInsets.all(AppSpacing.md),
        ),
      ),
    );
  }
}
