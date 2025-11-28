import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lakshya_mvp/theme/theme.dart';
import 'package:lakshya_mvp/widgets/lakshya_logo.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Lakshya'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header - Clean but visually rich
            Stack(
              children: [
                // Background gradient
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPadding,
                    vertical: AppSpacing.xxxl,
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
                  child: Column(
                    children: [
                      // Brand logo - centered
                      const LakshyaLogo(height: 56),
                      const SizedBox(height: AppSpacing.md),
                      // Subtitle
                      Text(
                        'Indian Institute of Commerce',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.classicBlue60,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      // Stats row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const _StatBadge(value: '10K+', label: 'Students'),
                          const SizedBox(width: AppSpacing.md),
                          Container(
                            width: 1,
                            height: 30,
                            color: AppColors.classicBlue20,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          const _StatBadge(value: '95%', label: 'Pass Rate'),
                          const SizedBox(width: AppSpacing.md),
                          Container(
                            width: 1,
                            height: 30,
                            color: AppColors.classicBlue20,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          const _StatBadge(value: '15+', label: 'Years'),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      // Tagline badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.classicBlue.withValues(alpha: 0.08),
                          borderRadius: AppSpacing.borderRadiusFull,
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified_rounded,
                              size: 14,
                              color: AppColors.mimosaGold,
                            ),
                            SizedBox(width: AppSpacing.xs),
                            Text(
                              'Excellence in Commerce Education',
                              style: TextStyle(
                                color: AppColors.classicBlue,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Golden accent (top-right, like splash)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 100,
                    height: 100,
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
            ),

            Padding(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mission & Vision
                  const _SectionCard(
                    icon: Icons.flag_rounded,
                    iconColor: AppColors.classicBlue,
                    title: 'Our Mission',
                    content:
                        'Lakshya Institute is dedicated to delivering excellence in commerce professional courses globally. We empower students with world-class qualifications and skills that drive successful careers.',
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const _SectionCard(
                    icon: Icons.visibility_rounded,
                    iconColor: AppColors.ultramarine,
                    title: 'Our Vision',
                    content:
                        'To be the leading institute for commerce education, creating globally competent professionals who excel in their chosen fields and contribute to the growth of organizations worldwide.',
                  ),
                  const SizedBox(height: AppSpacing.xxxl),

                  // Programs
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.mimosaGold20,
                          borderRadius: AppSpacing.borderRadiusSm,
                        ),
                        child: const Icon(
                          Icons.school_rounded,
                          color: AppColors.mimosaGold,
                          size: AppSpacing.iconSm,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Text(
                        'Our Programs',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _ProgramItem(
                    icon: Icons.account_balance_rounded,
                    color: AppColors.classicBlue,
                    title: 'ACCA',
                    description: 'Association of Chartered Certified Accountants',
                    courseId: 'acca-001',
                  ),
                  _ProgramItem(
                    icon: Icons.balance_rounded,
                    color: AppColors.ultramarine,
                    title: 'CA',
                    description: 'Chartered Accountancy - Premier qualification',
                    courseId: 'ca-001',
                  ),
                  _ProgramItem(
                    icon: Icons.analytics_rounded,
                    color: AppColors.success,
                    title: 'CMA (US)',
                    description: 'Certified Management Accountant',
                    courseId: 'cma-001',
                  ),
                  _ProgramItem(
                    icon: Icons.business_center_rounded,
                    color: AppColors.mimosaGold,
                    title: 'B.Com & MBA',
                    description: 'Integrated dual degree program',
                    courseId: 'bcom-mba-001',
                  ),

                  const SizedBox(height: AppSpacing.xxxl),

                  // Why Choose Us
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.successLight,
                          borderRadius: AppSpacing.borderRadiusSm,
                        ),
                        child: const Icon(
                          Icons.verified_rounded,
                          color: AppColors.success,
                          size: AppSpacing.iconSm,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Text(
                        'Why Choose Us',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const _FeatureItem(
                    icon: Icons.star_rounded,
                    title: 'Excellence',
                    description: 'Proven track record of student success',
                  ),
                  const _FeatureItem(
                    icon: Icons.people_rounded,
                    title: 'Expert Faculty',
                    description: 'Learn from industry professionals',
                  ),
                  const _FeatureItem(
                    icon: Icons.public_rounded,
                    title: 'Global Reach',
                    description: 'Students from across the world',
                  ),
                  const _FeatureItem(
                    icon: Icons.work_rounded,
                    title: 'Career Support',
                    description: 'Placement assistance & guidance',
                  ),

                  const SizedBox(height: AppSpacing.xxxl),

                  // CTA
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.xxl),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: AppSpacing.borderRadiusLg,
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Ready to Start?',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Take the first step towards your career',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        SizedBox(
                          width: double.infinity,
                          height: AppSpacing.buttonHeightLg,
                          child: ElevatedButton(
                            onPressed: () => context.go('/contact'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.classicBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: AppSpacing.borderRadiusSm,
                              ),
                            ),
                            child: const Text(
                              'Get in Touch',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bottom padding
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String content;

  const _SectionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadiusMd,
        side: const BorderSide(color: AppColors.neutral200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
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
                    color: iconColor,
                    size: AppSpacing.iconMd,
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
            const SizedBox(height: AppSpacing.md),
            Text(
              content,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.neutral600,
                    height: 1.6,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgramItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String description;
  final String courseId;

  const _ProgramItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
    required this.courseId,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadiusMd,
        side: const BorderSide(color: AppColors.neutral200),
      ),
      child: InkWell(
        onTap: () => context.push('/course/$courseId'),
        borderRadius: AppSpacing.borderRadiusMd,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color, color.withValues(alpha: 0.7)],
                  ),
                  borderRadius: AppSpacing.borderRadiusSm,
                ),
                child: Icon(icon, color: Colors.white, size: AppSpacing.iconSm),
              ),
              const SizedBox(width: AppSpacing.md),
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
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.neutral500,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.successLight,
              borderRadius: AppSpacing.borderRadiusSm,
            ),
            child: Icon(
              icon,
              color: AppColors.success,
              size: AppSpacing.iconSm,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
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

class _StatBadge extends StatelessWidget {
  final String value;
  final String label;

  const _StatBadge({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.classicBlue,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: AppColors.classicBlue.withValues(alpha: 0.6),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
