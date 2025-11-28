import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < AppSpacing.breakpointMobile;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? AppSpacing.screenPadding : AppSpacing.huge,
        vertical: isMobile ? AppSpacing.huge : AppSpacing.giant,
      ),
      decoration: const BoxDecoration(
        gradient: AppColors.heroGradient,
      ),
      child: Stack(
        children: [
          // Decorative elements
          Positioned(
            top: -40,
            right: -40,
            child: _DecorativeCircle(
              size: 120,
              color: AppColors.neutral0.withValues(alpha: 0.05),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -30,
            child: _DecorativeCircle(
              size: 80,
              color: AppColors.mimosaGold.withValues(alpha: 0.1),
            ),
          ),
          // Main content
          Column(
            children: [
              // Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: AppColors.neutral0.withValues(alpha: 0.15),
                  borderRadius: AppSpacing.borderRadiusFull,
                  border: Border.all(
                    color: AppColors.neutral0.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.school_rounded,
                      size: AppSpacing.iconSm,
                      color: AppColors.mimosaGold,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Trusted by 10,000+ Students',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: AppColors.neutral0,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              // Main headline - More specific and compelling
              Text(
                isMobile
                    ? 'Master CA, ACCA\n& CMA'
                    : 'Master CA, ACCA & CMA with\nIndia\'s Top Commerce Faculty',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: AppColors.neutral0,
                      fontWeight: FontWeight.w800,
                      fontSize: isMobile ? 28 : 36,
                      height: 1.2,
                      letterSpacing: -0.5,
                    ),
              ),
              const SizedBox(height: AppSpacing.lg),
              // Course tags
              Wrap(
                alignment: WrapAlignment.center,
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  _CourseTag(label: 'ACCA', color: AppColors.accaColor),
                  _CourseTag(label: 'CA', color: AppColors.caColor),
                  _CourseTag(label: 'CMA (US)', color: AppColors.cmaColor),
                  _CourseTag(label: 'B.Com & MBA', color: AppColors.bcomMbaColor),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),
              // Description - Shorter, value-focused
              Container(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Text(
                  '95% pass rate • Expert faculty from Big 4 firms • Flexible online & offline batches',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.neutral0.withValues(alpha: 0.9),
                        height: 1.6,
                      ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              // CTA buttons
              if (isMobile)
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: AppSpacing.buttonHeightLg,
                      child: ElevatedButton.icon(
                        onPressed: () => context.go('/courses'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.neutral0,
                          foregroundColor: AppColors.classicBlue,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: AppSpacing.borderRadiusMd,
                          ),
                        ),
                        icon: const Icon(Icons.school_rounded, size: 20),
                        label: const Text(
                          'View Programs',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      width: double.infinity,
                      height: AppSpacing.buttonHeightLg,
                      child: OutlinedButton.icon(
                        onPressed: () => context.go('/contact'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.neutral0,
                          side: const BorderSide(
                            color: AppColors.neutral0,
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppSpacing.borderRadiusMd,
                          ),
                        ),
                        icon: const Icon(Icons.phone_in_talk_rounded, size: 20),
                        label: const Text(
                          'Talk to Advisor',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
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
                        onPressed: () => context.go('/courses'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.neutral0,
                          foregroundColor: AppColors.classicBlue,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xxxl,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppSpacing.borderRadiusMd,
                          ),
                        ),
                        icon: const Icon(Icons.school_rounded, size: 20),
                        label: const Text(
                          'View Programs',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    SizedBox(
                      height: AppSpacing.buttonHeightLg,
                      child: OutlinedButton.icon(
                        onPressed: () => context.go('/contact'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.neutral0,
                          side: const BorderSide(
                            color: AppColors.neutral0,
                            width: 2,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xxxl,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppSpacing.borderRadiusMd,
                          ),
                        ),
                        icon: const Icon(Icons.phone_in_talk_rounded, size: 20),
                        label: const Text(
                          'Talk to Advisor',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: AppSpacing.xxl),
              // Stats row
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: AppColors.neutral0.withValues(alpha: 0.1),
                  borderRadius: AppSpacing.borderRadiusLg,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const _StatItem(value: '10K+', label: 'Students'),
                    const _StatDivider(),
                    const _StatItem(value: '95%', label: 'Pass Rate'),
                    const _StatDivider(),
                    const _StatItem(value: '500+', label: 'Placements'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CourseTag extends StatelessWidget {
  final String label;
  final Color color;

  const _CourseTag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.3),
        borderRadius: AppSpacing.borderRadiusSm,
        border: Border.all(
          color: color.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.neutral0,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.mimosaGold,
                  fontWeight: FontWeight.w800,
                ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.neutral0.withValues(alpha: 0.8),
                ),
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      color: AppColors.neutral0.withValues(alpha: 0.2),
    );
  }
}

class _DecorativeCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _DecorativeCircle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
