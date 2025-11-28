import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';

class FeaturesSection extends StatelessWidget {
  const FeaturesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < AppSpacing.breakpointMobile;

    final features = [
      _FeatureData(
        icon: Icons.public_rounded,
        title: 'Global Recognition',
        description: 'ACCA, CA & CMA accepted worldwide',
        color: AppColors.classicBlue,
      ),
      _FeatureData(
        icon: Icons.school_rounded,
        title: 'Expert Faculty',
        description: 'Chartered Accountants from Big 4',
        color: AppColors.ultramarine,
      ),
      _FeatureData(
        icon: Icons.trending_up_rounded,
        title: '95% Pass Rate',
        description: 'Consistently above national average',
        color: AppColors.success,
      ),
      _FeatureData(
        icon: Icons.schedule_rounded,
        title: 'Flexible Batches',
        description: 'Weekday, weekend & online options',
        color: AppColors.vivaMagenta,
      ),
      _FeatureData(
        icon: Icons.work_rounded,
        title: '500+ Placements',
        description: 'Top firms recruit from campus',
        color: AppColors.mimosaGold,
      ),
      _FeatureData(
        icon: Icons.support_agent_rounded,
        title: 'Lifetime Support',
        description: 'Career guidance even after course',
        color: AppColors.info,
      ),
    ];

    return Container(
      padding: EdgeInsets.all(isMobile ? AppSpacing.screenPadding : AppSpacing.screenPaddingLarge),
      color: AppColors.surfaceContainerLowLight,
      child: Column(
        children: [
          // Section header
          const _SectionHeader(
            title: 'The Lakshya Advantage',
            subtitle: 'What sets our programs apart',
            icon: Icons.verified_rounded,
          ),
          const SizedBox(height: AppSpacing.xxxl),
          // Features grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile ? 2 : 3,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              childAspectRatio: isMobile ? 0.95 : 1.1,
            ),
            itemCount: features.length,
            itemBuilder: (context, index) {
              return _FeatureCard(feature: features[index]);
            },
          ),
        ],
      ),
    );
  }
}

class _FeatureData {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _FeatureData({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
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
                AppColors.classicBlue.withValues(alpha: 0.1),
                AppColors.ultramarine.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: AppSpacing.borderRadiusMd,
          ),
          child: Icon(
            icon,
            size: AppSpacing.iconLg,
            color: AppColors.classicBlue,
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

class _FeatureCard extends StatelessWidget {
  final _FeatureData feature;

  const _FeatureCard({required this.feature});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.neutral0,
        borderRadius: AppSpacing.borderRadiusLg,
        border: Border.all(
          color: AppColors.neutral100,
          width: 1,
        ),
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
        borderRadius: AppSpacing.borderRadiusLg,
        child: InkWell(
          onTap: () {}, // Could navigate to feature details
          borderRadius: AppSpacing.borderRadiusLg,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon container
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: feature.color.withValues(alpha: 0.1),
                    borderRadius: AppSpacing.borderRadiusMd,
                  ),
                  child: Icon(
                    feature.icon,
                    size: AppSpacing.iconLg,
                    color: feature.color,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                // Title
                Text(
                  feature.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.neutral900,
                      ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                // Description
                Text(
                  feature.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.neutral500,
                        height: 1.4,
                      ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
