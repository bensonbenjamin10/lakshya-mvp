import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';

class TestimonialsSection extends StatelessWidget {
  const TestimonialsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final testimonials = [
      _TestimonialData(
        name: 'Priya Sharma',
        course: 'ACCA Graduate',
        text: 'Lakshya Institute helped me achieve my ACCA qualification. The faculty is excellent and the support throughout the journey was incredible.',
        rating: 5,
        avatarColor: AppColors.accaColor,
        courseColor: AppColors.accaColor,
      ),
      _TestimonialData(
        name: 'Rahul Kumar',
        course: 'CA Final',
        text: 'The comprehensive CA program at Lakshya prepared me well for my career. I\'m now working at a top accounting firm.',
        rating: 5,
        avatarColor: AppColors.caColor,
        courseColor: AppColors.caColor,
      ),
      _TestimonialData(
        name: 'Anjali Patel',
        course: 'CMA (US)',
        text: 'The CMA program opened doors to international opportunities. Outstanding course structure and guidance.',
        rating: 5,
        avatarColor: AppColors.cmaColor,
        courseColor: AppColors.cmaColor,
      ),
      _TestimonialData(
        name: 'Vikram Singh',
        course: 'MBA Graduate',
        text: 'The B.Com & MBA program gave me a strong foundation. The practical approach to learning is what sets Lakshya apart.',
        rating: 5,
        avatarColor: AppColors.bcomMbaColor,
        courseColor: AppColors.bcomMbaColor,
      ),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.sectionSpacing,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.surfaceLight,
            AppColors.classicBlue10,
          ],
        ),
      ),
      child: Column(
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
            child: const _SectionHeader(
              title: 'Student Success Stories',
              subtitle: 'Hear from our 10,000+ alumni',
              icon: Icons.format_quote_rounded,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          // Testimonials carousel
          SizedBox(
            height: 240,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
              itemCount: testimonials.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(
                    right: index < testimonials.length - 1 ? AppSpacing.lg : 0,
                  ),
                  child: _TestimonialCard(testimonial: testimonials[index]),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          // Trust indicators
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const _TrustBadge(
                  icon: Icons.verified_user_rounded,
                  label: 'Verified Reviews',
                ),
                const SizedBox(width: AppSpacing.xl),
                const _TrustBadge(
                  icon: Icons.stars_rounded,
                  label: '4.9 Rating',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TestimonialData {
  final String name;
  final String course;
  final String text;
  final int rating;
  final Color avatarColor;
  final Color courseColor;

  const _TestimonialData({
    required this.name,
    required this.course,
    required this.text,
    required this.rating,
    required this.avatarColor,
    required this.courseColor,
  });
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Icon badge
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.mimosaGold.withValues(alpha: 0.15),
                AppColors.mimosaGold.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: AppSpacing.borderRadiusMd,
          ),
          child: Icon(
            icon,
            size: AppSpacing.iconLg,
            color: AppColors.mimosaGold,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.neutral900,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.neutral500,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _TestimonialCard extends StatelessWidget {
  final _TestimonialData testimonial;

  const _TestimonialCard({required this.testimonial});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(AppSpacing.cardPaddingLarge),
      decoration: BoxDecoration(
        color: AppColors.neutral0,
        borderRadius: AppSpacing.borderRadiusXl,
        border: Border.all(
          color: AppColors.neutral100,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.neutral900.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with avatar and info
          Row(
            children: [
              // Avatar
              Container(
                width: AppSpacing.avatarLg,
                height: AppSpacing.avatarLg,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      testimonial.avatarColor,
                      testimonial.avatarColor.withValues(alpha: 0.7),
                    ],
                  ),
                  borderRadius: AppSpacing.borderRadiusMd,
                ),
                child: Center(
                  child: Text(
                    testimonial.name[0],
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.neutral0,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      testimonial.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.neutral900,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: testimonial.courseColor.withValues(alpha: 0.1),
                        borderRadius: AppSpacing.borderRadiusSm,
                      ),
                      child: Text(
                        testimonial.course,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: testimonial.courseColor,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Rating stars
          Row(
            children: List.generate(
              testimonial.rating,
              (i) => Padding(
                padding: const EdgeInsets.only(right: 2),
                child: Icon(
                  Icons.star_rounded,
                  color: AppColors.mimosaGold,
                  size: AppSpacing.iconSm,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Testimonial text
          Expanded(
            child: Text(
              '"${testimonial.text}"',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.neutral600,
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                  ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrustBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _TrustBadge({
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
          size: AppSpacing.iconSm,
          color: AppColors.success,
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.neutral600,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
