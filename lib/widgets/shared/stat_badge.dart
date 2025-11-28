import 'package:flutter/material.dart';
import 'package:lakshya_mvp/theme/theme.dart';

/// Reusable stat badge widget for displaying metrics
class StatBadge extends StatelessWidget {
  final String value;
  final String label;
  final Color? valueColor;
  final Color? labelColor;
  final double? valueFontSize;
  final double? labelFontSize;
  final MainAxisAlignment alignment;

  const StatBadge({
    super.key,
    required this.value,
    required this.label,
    this.valueColor,
    this.labelColor,
    this.valueFontSize,
    this.labelFontSize,
    this.alignment = MainAxisAlignment.center,
  });

  /// Light theme stat badge (for light backgrounds)
  const StatBadge.light({
    super.key,
    required this.value,
    required this.label,
    this.valueFontSize = 20,
    this.labelFontSize = 11,
    this.alignment = MainAxisAlignment.center,
  })  : valueColor = AppColors.classicBlue,
        labelColor = null;

  /// Dark theme stat badge (for dark/gradient backgrounds)
  const StatBadge.dark({
    super.key,
    required this.value,
    required this.label,
    this.valueFontSize,
    this.labelFontSize,
    this.alignment = MainAxisAlignment.center,
  })  : valueColor = AppColors.mimosaGold,
        labelColor = AppColors.neutral0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: alignment,
      children: [
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? AppColors.classicBlue,
            fontSize: valueFontSize ?? 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: labelColor ??
                (valueColor ?? AppColors.classicBlue).withValues(alpha: 0.6),
            fontSize: labelFontSize ?? 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// Row of stat badges with dividers
class StatBadgeRow extends StatelessWidget {
  final List<StatBadge> stats;
  final Color? dividerColor;
  final double dividerHeight;
  final bool isDark;

  const StatBadgeRow({
    super.key,
    required this.stats,
    this.dividerColor,
    this.dividerHeight = 30,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < stats.length; i++) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: stats[i],
          ),
          if (i < stats.length - 1)
            Container(
              width: 1,
              height: dividerHeight,
              color: dividerColor ??
                  (isDark
                      ? AppColors.neutral0.withValues(alpha: 0.2)
                      : AppColors.classicBlue20),
            ),
        ],
      ],
    );
  }
}

