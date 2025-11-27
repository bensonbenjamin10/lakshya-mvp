import 'package:flutter/material.dart';
import 'colors.dart';

/// Custom Theme Extensions for Lakshya Institute
/// Provides additional semantic colors and brand-specific tokens

/// Extension for semantic status colors
@immutable
class StatusColors extends ThemeExtension<StatusColors> {
  const StatusColors({
    required this.success,
    required this.successContainer,
    required this.onSuccess,
    required this.warning,
    required this.warningContainer,
    required this.onWarning,
    required this.info,
    required this.infoContainer,
    required this.onInfo,
  });

  final Color success;
  final Color successContainer;
  final Color onSuccess;
  final Color warning;
  final Color warningContainer;
  final Color onWarning;
  final Color info;
  final Color infoContainer;
  final Color onInfo;

  static const light = StatusColors(
    success: AppColors.success,
    successContainer: AppColors.successLight,
    onSuccess: AppColors.neutral0,
    warning: AppColors.warning,
    warningContainer: AppColors.warningLight,
    onWarning: AppColors.neutral900,
    info: AppColors.info,
    infoContainer: AppColors.infoLight,
    onInfo: AppColors.neutral900,
  );

  static const dark = StatusColors(
    success: AppColors.successLight,
    successContainer: AppColors.successDark,
    onSuccess: AppColors.neutral900,
    warning: AppColors.warningLight,
    warningContainer: AppColors.warningDark,
    onWarning: AppColors.neutral900,
    info: AppColors.infoLight,
    infoContainer: AppColors.infoDark,
    onInfo: AppColors.neutral900,
  );

  @override
  StatusColors copyWith({
    Color? success,
    Color? successContainer,
    Color? onSuccess,
    Color? warning,
    Color? warningContainer,
    Color? onWarning,
    Color? info,
    Color? infoContainer,
    Color? onInfo,
  }) {
    return StatusColors(
      success: success ?? this.success,
      successContainer: successContainer ?? this.successContainer,
      onSuccess: onSuccess ?? this.onSuccess,
      warning: warning ?? this.warning,
      warningContainer: warningContainer ?? this.warningContainer,
      onWarning: onWarning ?? this.onWarning,
      info: info ?? this.info,
      infoContainer: infoContainer ?? this.infoContainer,
      onInfo: onInfo ?? this.onInfo,
    );
  }

  @override
  StatusColors lerp(ThemeExtension<StatusColors>? other, double t) {
    if (other is! StatusColors) return this;
    return StatusColors(
      success: Color.lerp(success, other.success, t)!,
      successContainer: Color.lerp(successContainer, other.successContainer, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningContainer: Color.lerp(warningContainer, other.warningContainer, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      info: Color.lerp(info, other.info, t)!,
      infoContainer: Color.lerp(infoContainer, other.infoContainer, t)!,
      onInfo: Color.lerp(onInfo, other.onInfo, t)!,
    );
  }
}

/// Extension for brand accent colors
@immutable
class BrandAccents extends ThemeExtension<BrandAccents> {
  const BrandAccents({
    required this.gold,
    required this.goldContainer,
    required this.onGold,
    required this.magenta,
    required this.magentaContainer,
    required this.onMagenta,
  });

  final Color gold;
  final Color goldContainer;
  final Color onGold;
  final Color magenta;
  final Color magentaContainer;
  final Color onMagenta;

  static const light = BrandAccents(
    gold: AppColors.mimosaGold,
    goldContainer: AppColors.mimosaGold20,
    onGold: AppColors.neutral900,
    magenta: AppColors.vivaMagenta,
    magentaContainer: AppColors.vivaMagenta20,
    onMagenta: AppColors.neutral0,
  );

  static const dark = BrandAccents(
    gold: AppColors.mimosaGold60,
    goldContainer: AppColors.mimosaGold90,
    onGold: AppColors.neutral900,
    magenta: AppColors.vivaMagenta60,
    magentaContainer: AppColors.vivaMagenta90,
    onMagenta: AppColors.neutral0,
  );

  @override
  BrandAccents copyWith({
    Color? gold,
    Color? goldContainer,
    Color? onGold,
    Color? magenta,
    Color? magentaContainer,
    Color? onMagenta,
  }) {
    return BrandAccents(
      gold: gold ?? this.gold,
      goldContainer: goldContainer ?? this.goldContainer,
      onGold: onGold ?? this.onGold,
      magenta: magenta ?? this.magenta,
      magentaContainer: magentaContainer ?? this.magentaContainer,
      onMagenta: onMagenta ?? this.onMagenta,
    );
  }

  @override
  BrandAccents lerp(ThemeExtension<BrandAccents>? other, double t) {
    if (other is! BrandAccents) return this;
    return BrandAccents(
      gold: Color.lerp(gold, other.gold, t)!,
      goldContainer: Color.lerp(goldContainer, other.goldContainer, t)!,
      onGold: Color.lerp(onGold, other.onGold, t)!,
      magenta: Color.lerp(magenta, other.magenta, t)!,
      magentaContainer: Color.lerp(magentaContainer, other.magentaContainer, t)!,
      onMagenta: Color.lerp(onMagenta, other.onMagenta, t)!,
    );
  }
}

/// Extension for course category colors
@immutable
class CourseColors extends ThemeExtension<CourseColors> {
  const CourseColors({
    required this.acca,
    required this.accaContainer,
    required this.ca,
    required this.caContainer,
    required this.cma,
    required this.cmaContainer,
    required this.bcomMba,
    required this.bcomMbaContainer,
  });

  final Color acca;
  final Color accaContainer;
  final Color ca;
  final Color caContainer;
  final Color cma;
  final Color cmaContainer;
  final Color bcomMba;
  final Color bcomMbaContainer;

  static const light = CourseColors(
    acca: AppColors.accaColor,
    accaContainer: AppColors.classicBlue20,
    ca: AppColors.caColor,
    caContainer: AppColors.ultramarine20,
    cma: AppColors.cmaColor,
    cmaContainer: AppColors.successLight,
    bcomMba: AppColors.bcomMbaColor,
    bcomMbaContainer: AppColors.mimosaGold20,
  );

  static const dark = CourseColors(
    acca: AppColors.classicBlue60,
    accaContainer: AppColors.classicBlue90,
    ca: AppColors.ultramarine60,
    caContainer: AppColors.ultramarine90,
    cma: AppColors.success,
    cmaContainer: AppColors.successDark,
    bcomMba: AppColors.mimosaGold60,
    bcomMbaContainer: AppColors.mimosaGold90,
  );

  @override
  CourseColors copyWith({
    Color? acca,
    Color? accaContainer,
    Color? ca,
    Color? caContainer,
    Color? cma,
    Color? cmaContainer,
    Color? bcomMba,
    Color? bcomMbaContainer,
  }) {
    return CourseColors(
      acca: acca ?? this.acca,
      accaContainer: accaContainer ?? this.accaContainer,
      ca: ca ?? this.ca,
      caContainer: caContainer ?? this.caContainer,
      cma: cma ?? this.cma,
      cmaContainer: cmaContainer ?? this.cmaContainer,
      bcomMba: bcomMba ?? this.bcomMba,
      bcomMbaContainer: bcomMbaContainer ?? this.bcomMbaContainer,
    );
  }

  @override
  CourseColors lerp(ThemeExtension<CourseColors>? other, double t) {
    if (other is! CourseColors) return this;
    return CourseColors(
      acca: Color.lerp(acca, other.acca, t)!,
      accaContainer: Color.lerp(accaContainer, other.accaContainer, t)!,
      ca: Color.lerp(ca, other.ca, t)!,
      caContainer: Color.lerp(caContainer, other.caContainer, t)!,
      cma: Color.lerp(cma, other.cma, t)!,
      cmaContainer: Color.lerp(cmaContainer, other.cmaContainer, t)!,
      bcomMba: Color.lerp(bcomMba, other.bcomMba, t)!,
      bcomMbaContainer: Color.lerp(bcomMbaContainer, other.bcomMbaContainer, t)!,
    );
  }
}

/// Helper extension on BuildContext to easily access theme extensions
extension ThemeExtensionsContext on BuildContext {
  /// Access StatusColors extension
  StatusColors get statusColors =>
      Theme.of(this).extension<StatusColors>() ?? StatusColors.light;

  /// Access BrandAccents extension
  BrandAccents get brandAccents =>
      Theme.of(this).extension<BrandAccents>() ?? BrandAccents.light;

  /// Access CourseColors extension
  CourseColors get courseColors =>
      Theme.of(this).extension<CourseColors>() ?? CourseColors.light;
}

