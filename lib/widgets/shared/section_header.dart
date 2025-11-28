import 'package:flutter/material.dart';
import 'package:lakshya_mvp/theme/theme.dart';

/// Reusable section header widget used across the app
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;
  final Widget? trailing;
  final bool centered;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.trailing,
    this.centered = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment:
          centered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  (iconColor ?? AppColors.mimosaGold).withValues(alpha: 0.15),
                  (iconColor ?? AppColors.mimosaGold).withValues(alpha: 0.05),
                ],
              ),
              borderRadius: AppSpacing.borderRadiusMd,
            ),
            child: Icon(
              icon,
              size: AppSpacing.iconLg,
              color: iconColor ?? AppColors.mimosaGold,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.neutral900,
              ),
          textAlign: centered ? TextAlign.center : TextAlign.start,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            subtitle!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.neutral500,
                ),
            textAlign: centered ? TextAlign.center : TextAlign.start,
          ),
        ],
      ],
    );

    if (trailing != null && !centered) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: content),
          trailing!,
        ],
      );
    }

    return content;
  }
}

/// Compact section header with icon badge on the left
class CompactSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color iconColor;
  final Color? iconBackgroundColor;
  final Widget? trailing;

  const CompactSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.iconColor,
    this.iconBackgroundColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: iconBackgroundColor ?? iconColor.withValues(alpha: 0.1),
            borderRadius: AppSpacing.borderRadiusSm,
          ),
          child: Icon(
            icon,
            color: iconColor,
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
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.neutral500,
                      ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

