import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../services/analytics_service.dart';

class CtaSection extends StatelessWidget {
  const CtaSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < AppSpacing.breakpointMobile;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: AppSpacing.lg,
      ),
      padding: EdgeInsets.all(isMobile ? AppSpacing.xxl : AppSpacing.xxxl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.classicBlue,
            AppColors.ultramarine,
          ],
        ),
        borderRadius: AppSpacing.borderRadiusXl,
        boxShadow: [
          BoxShadow(
            color: AppColors.classicBlue.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative gold accent
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    AppColors.mimosaGold.withValues(alpha: 0.3),
                    AppColors.mimosaGold.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          // Content
          Column(
            children: [
              // Icon with gold accent
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.mimosaGold.withValues(alpha: 0.2),
                  borderRadius: AppSpacing.borderRadiusMd,
                ),
                child: const Icon(
                  Icons.school_rounded,
                  size: AppSpacing.iconXl,
                  color: AppColors.mimosaGold,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              // Headline - more specific and compelling
              Text(
                'Begin Your CA/ACCA Journey',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              // Subtext - with value proposition
              Text(
                'Join 10,000+ students who transformed their careers.\nFree counseling session for new aspirants.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                      height: 1.5,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxl),
              // CTA Buttons
              if (isMobile)
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: AppSpacing.buttonHeightLg,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          AnalyticsService.logCtaClick(ctaLocation: 'cta_section_book_counseling');
                          context.go('/contact');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.mimosaGold,
                          foregroundColor: AppColors.neutral900,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: AppSpacing.borderRadiusMd,
                          ),
                        ),
                        icon: const Icon(Icons.calendar_today_rounded, size: 18),
                        label: const Text(
                          'Book Free Counseling',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      width: double.infinity,
                      height: AppSpacing.buttonHeightLg,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          AnalyticsService.logCtaClick(ctaLocation: 'cta_section_view_programs');
                          context.go('/courses');
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppSpacing.borderRadiusMd,
                          ),
                        ),
                        icon: const Icon(Icons.explore_rounded, size: 18),
                        label: const Text(
                          'View Programs',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: AppSpacing.buttonHeightLg,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          AnalyticsService.logCtaClick(ctaLocation: 'cta_section_book_counseling');
                          context.go('/contact');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.mimosaGold,
                          foregroundColor: AppColors.neutral900,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xxl,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppSpacing.borderRadiusMd,
                          ),
                        ),
                        icon: const Icon(Icons.calendar_today_rounded, size: 18),
                        label: const Text(
                          'Book Free Counseling',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    SizedBox(
                      height: AppSpacing.buttonHeightLg,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          AnalyticsService.logCtaClick(ctaLocation: 'cta_section_view_programs');
                          context.go('/courses');
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white, width: 2),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xxl,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppSpacing.borderRadiusMd,
                          ),
                        ),
                        icon: const Icon(Icons.explore_rounded, size: 18),
                        label: const Text(
                          'View Programs',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
