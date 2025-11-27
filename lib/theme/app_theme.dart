import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'colors.dart';
import 'typography.dart';
import 'spacing.dart';

/// Lakshya Institute Theme Configuration
/// Material 3 Design System with Pantone-inspired colors
class AppTheme {
  AppTheme._();

  // ============================================
  // LIGHT THEME
  // ============================================

  static ThemeData get lightTheme {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      // Primary colors
      primary: AppColors.classicBlue,
      onPrimary: AppColors.neutral0,
      primaryContainer: AppColors.classicBlue20,
      onPrimaryContainer: AppColors.classicBlue,
      // Secondary colors
      secondary: AppColors.ultramarine,
      onSecondary: AppColors.neutral0,
      secondaryContainer: AppColors.ultramarine20,
      onSecondaryContainer: AppColors.ultramarine,
      // Tertiary colors
      tertiary: AppColors.mimosaGold,
      onTertiary: AppColors.neutral900,
      tertiaryContainer: AppColors.mimosaGold20,
      onTertiaryContainer: AppColors.mimosaGold,
      // Error colors
      error: AppColors.error,
      onError: AppColors.neutral0,
      errorContainer: AppColors.errorLight,
      onErrorContainer: AppColors.errorDark,
      // Surface colors
      surface: AppColors.surfaceLight,
      onSurface: AppColors.neutral900,
      surfaceContainerLowest: AppColors.surfaceContainerLowestLight,
      surfaceContainerLow: AppColors.surfaceContainerLowLight,
      surfaceContainer: AppColors.surfaceContainerLight,
      surfaceContainerHigh: AppColors.surfaceContainerHighLight,
      surfaceContainerHighest: AppColors.surfaceContainerHighestLight,
      onSurfaceVariant: AppColors.neutral600,
      // Outline colors
      outline: AppColors.neutral300,
      outlineVariant: AppColors.neutral200,
      // Other
      shadow: AppColors.neutral900,
      scrim: AppColors.neutral900,
      inverseSurface: AppColors.neutral800,
      onInverseSurface: AppColors.neutral50,
      inversePrimary: AppColors.classicBlue40,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: AppTypography.lightTextTheme,
      scaffoldBackgroundColor: AppColors.surfaceContainerLowestLight,

      // AppBar Theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        backgroundColor: AppColors.surfaceLight,
        foregroundColor: AppColors.neutral900,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: AppTypography.lightTextTheme.titleLarge?.copyWith(
          color: AppColors.neutral900,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.neutral700,
          size: AppSpacing.iconMd,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: AppSpacing.elevationLow,
        shadowColor: AppColors.neutral900.withValues(alpha: 0.08),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusMd,
        ),
        color: AppColors.surfaceContainerLowestLight,
        margin: EdgeInsets.zero,
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: AppSpacing.elevationLow,
          shadowColor: AppColors.classicBlue.withValues(alpha: 0.3),
          backgroundColor: AppColors.classicBlue,
          foregroundColor: AppColors.neutral0,
          disabledBackgroundColor: AppColors.neutral200,
          disabledForegroundColor: AppColors.neutral500,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.buttonPaddingHorizontal,
            vertical: AppSpacing.buttonPaddingVertical,
          ),
          minimumSize: const Size(88, AppSpacing.buttonHeightMd),
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusSm,
          ),
          textStyle: AppTypography.lightTextTheme.labelLarge,
        ),
      ),

      // Filled Button Theme (Material 3)
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.classicBlue,
          foregroundColor: AppColors.neutral0,
          disabledBackgroundColor: AppColors.neutral200,
          disabledForegroundColor: AppColors.neutral500,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.buttonPaddingHorizontal,
            vertical: AppSpacing.buttonPaddingVertical,
          ),
          minimumSize: const Size(88, AppSpacing.buttonHeightMd),
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusSm,
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.classicBlue,
          disabledForegroundColor: AppColors.neutral400,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.buttonPaddingHorizontal,
            vertical: AppSpacing.buttonPaddingVertical,
          ),
          minimumSize: const Size(88, AppSpacing.buttonHeightMd),
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusSm,
          ),
          side: const BorderSide(color: AppColors.classicBlue, width: 1.5),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.classicBlue,
          disabledForegroundColor: AppColors.neutral400,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusSm,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainerLowestLight,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        border: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusSm,
          borderSide: const BorderSide(color: AppColors.neutral300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusSm,
          borderSide: const BorderSide(color: AppColors.neutral300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusSm,
          borderSide: const BorderSide(color: AppColors.classicBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusSm,
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusSm,
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        labelStyle: AppTypography.lightTextTheme.bodyMedium,
        hintStyle: AppTypography.lightTextTheme.bodyMedium?.copyWith(
          color: AppColors.neutral400,
        ),
        errorStyle: AppTypography.lightTextTheme.bodySmall?.copyWith(
          color: AppColors.error,
        ),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.classicBlue,
        foregroundColor: AppColors.neutral0,
        elevation: AppSpacing.elevationMedium,
        focusElevation: AppSpacing.elevationHigh,
        hoverElevation: AppSpacing.elevationHigh,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusLg,
        ),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceContainerLight,
        selectedColor: AppColors.classicBlue20,
        disabledColor: AppColors.neutral100,
        labelStyle: AppTypography.lightTextTheme.labelMedium,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusSm,
        ),
        side: BorderSide.none,
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceContainerLowestLight,
        elevation: AppSpacing.elevationHighest,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusXl,
        ),
        titleTextStyle: AppTypography.lightTextTheme.headlineSmall,
        contentTextStyle: AppTypography.lightTextTheme.bodyMedium,
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceContainerLowestLight,
        elevation: AppSpacing.elevationHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusXl),
          ),
        ),
        showDragHandle: true,
        dragHandleColor: AppColors.neutral300,
        dragHandleSize: Size(32, 4),
      ),

      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.neutral800,
        contentTextStyle: AppTypography.lightTextTheme.bodyMedium?.copyWith(
          color: AppColors.neutral50,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusSm,
        ),
        behavior: SnackBarBehavior.floating,
        elevation: AppSpacing.elevationMedium,
      ),

      // Tab Bar Theme
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.classicBlue,
        unselectedLabelColor: AppColors.neutral500,
        indicatorColor: AppColors.classicBlue,
        labelStyle: AppTypography.lightTextTheme.labelLarge,
        unselectedLabelStyle: AppTypography.lightTextTheme.labelLarge,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: AppColors.neutral200,
      ),

      // Navigation Bar Theme (Bottom Navigation)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surfaceContainerLowestLight,
        elevation: AppSpacing.elevationMedium,
        indicatorColor: AppColors.classicBlue20,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.classicBlue);
          }
          return const IconThemeData(color: AppColors.neutral500);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTypography.lightTextTheme.labelMedium?.copyWith(
              color: AppColors.classicBlue,
            );
          }
          return AppTypography.lightTextTheme.labelMedium?.copyWith(
            color: AppColors.neutral500,
          );
        }),
        height: AppSpacing.bottomNavHeight,
      ),

      // Navigation Rail Theme
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: AppColors.surfaceContainerLowestLight,
        selectedIconTheme: const IconThemeData(color: AppColors.classicBlue),
        unselectedIconTheme: const IconThemeData(color: AppColors.neutral500),
        selectedLabelTextStyle: AppTypography.lightTextTheme.labelMedium?.copyWith(
          color: AppColors.classicBlue,
        ),
        unselectedLabelTextStyle: AppTypography.lightTextTheme.labelMedium?.copyWith(
          color: AppColors.neutral500,
        ),
        indicatorColor: AppColors.classicBlue20,
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.neutral200,
        thickness: 1,
        space: 1,
      ),

      // List Tile Theme
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusSm,
        ),
        titleTextStyle: AppTypography.lightTextTheme.titleMedium,
        subtitleTextStyle: AppTypography.lightTextTheme.bodyMedium,
        leadingAndTrailingTextStyle: AppTypography.lightTextTheme.labelMedium,
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: AppColors.neutral700,
        size: AppSpacing.iconMd,
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.classicBlue,
        linearTrackColor: AppColors.classicBlue20,
        circularTrackColor: AppColors.classicBlue20,
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.classicBlue;
          }
          return AppColors.neutral400;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.classicBlue40;
          }
          return AppColors.neutral200;
        }),
      ),

      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.classicBlue;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(AppColors.neutral0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
        ),
      ),

      // Radio Theme
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.classicBlue;
          }
          return AppColors.neutral400;
        }),
      ),

      // Tooltip Theme
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.neutral800,
          borderRadius: AppSpacing.borderRadiusSm,
        ),
        textStyle: AppTypography.lightTextTheme.bodySmall?.copyWith(
          color: AppColors.neutral50,
        ),
      ),

      // Badge Theme
      badgeTheme: BadgeThemeData(
        backgroundColor: AppColors.vivaMagenta,
        textColor: AppColors.neutral0,
        textStyle: AppTypography.lightTextTheme.labelSmall?.copyWith(
          color: AppColors.neutral0,
        ),
      ),

      // Search Bar Theme
      searchBarTheme: SearchBarThemeData(
        backgroundColor: WidgetStateProperty.all(AppColors.surfaceContainerLight),
        elevation: WidgetStateProperty.all(0),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusFull,
          ),
        ),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        ),
        textStyle: WidgetStateProperty.all(AppTypography.lightTextTheme.bodyLarge),
        hintStyle: WidgetStateProperty.all(
          AppTypography.lightTextTheme.bodyLarge?.copyWith(
            color: AppColors.neutral400,
          ),
        ),
      ),

      // Segmented Button Theme
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.classicBlue;
            }
            return Colors.transparent;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.neutral0;
            }
            return AppColors.classicBlue;
          }),
        ),
      ),
    );
  }

  // ============================================
  // DARK THEME
  // ============================================

  static ThemeData get darkTheme {
    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      // Primary colors
      primary: AppColors.classicBlue60,
      onPrimary: AppColors.neutral900,
      primaryContainer: AppColors.classicBlue90,
      onPrimaryContainer: AppColors.classicBlue10,
      // Secondary colors
      secondary: AppColors.ultramarine60,
      onSecondary: AppColors.neutral900,
      secondaryContainer: AppColors.ultramarine90,
      onSecondaryContainer: AppColors.ultramarine10,
      // Tertiary colors
      tertiary: AppColors.mimosaGold60,
      onTertiary: AppColors.neutral900,
      tertiaryContainer: AppColors.mimosaGold90,
      onTertiaryContainer: AppColors.mimosaGold10,
      // Error colors
      error: AppColors.errorLight,
      onError: AppColors.neutral900,
      errorContainer: AppColors.errorDark,
      onErrorContainer: AppColors.errorLight,
      // Surface colors
      surface: AppColors.surfaceDark,
      onSurface: AppColors.neutral50,
      surfaceContainerLowest: AppColors.surfaceContainerLowestDark,
      surfaceContainerLow: AppColors.surfaceContainerLowDark,
      surfaceContainer: AppColors.surfaceContainerDark,
      surfaceContainerHigh: AppColors.surfaceContainerHighDark,
      surfaceContainerHighest: AppColors.surfaceContainerHighestDark,
      onSurfaceVariant: AppColors.neutral300,
      // Outline colors
      outline: AppColors.neutral600,
      outlineVariant: AppColors.neutral700,
      // Other
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: AppColors.neutral100,
      onInverseSurface: AppColors.neutral800,
      inversePrimary: AppColors.classicBlue,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: AppTypography.darkTextTheme,
      scaffoldBackgroundColor: AppColors.surfaceContainerLowestDark,

      // AppBar Theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: AppColors.neutral50,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: AppTypography.darkTextTheme.titleLarge,
        iconTheme: const IconThemeData(
          color: AppColors.neutral200,
          size: AppSpacing.iconMd,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: AppSpacing.elevationLow,
        shadowColor: Colors.black26,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusMd,
        ),
        color: AppColors.surfaceContainerDark,
        margin: EdgeInsets.zero,
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: AppSpacing.elevationLow,
          shadowColor: Colors.black38,
          backgroundColor: AppColors.classicBlue60,
          foregroundColor: AppColors.neutral900,
          disabledBackgroundColor: AppColors.neutral700,
          disabledForegroundColor: AppColors.neutral500,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.buttonPaddingHorizontal,
            vertical: AppSpacing.buttonPaddingVertical,
          ),
          minimumSize: const Size(88, AppSpacing.buttonHeightMd),
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusSm,
          ),
          textStyle: AppTypography.darkTextTheme.labelLarge,
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.classicBlue60,
          disabledForegroundColor: AppColors.neutral600,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.buttonPaddingHorizontal,
            vertical: AppSpacing.buttonPaddingVertical,
          ),
          minimumSize: const Size(88, AppSpacing.buttonHeightMd),
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusSm,
          ),
          side: const BorderSide(color: AppColors.classicBlue60, width: 1.5),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainerDark,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        border: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusSm,
          borderSide: const BorderSide(color: AppColors.neutral600),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusSm,
          borderSide: const BorderSide(color: AppColors.neutral600),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusSm,
          borderSide: const BorderSide(color: AppColors.classicBlue60, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusSm,
          borderSide: const BorderSide(color: AppColors.errorLight),
        ),
        labelStyle: AppTypography.darkTextTheme.bodyMedium,
        hintStyle: AppTypography.darkTextTheme.bodyMedium?.copyWith(
          color: AppColors.neutral500,
        ),
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceContainerHighDark,
        elevation: AppSpacing.elevationHighest,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusXl,
        ),
        titleTextStyle: AppTypography.darkTextTheme.headlineSmall,
        contentTextStyle: AppTypography.darkTextTheme.bodyMedium,
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceContainerHighDark,
        elevation: AppSpacing.elevationHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusXl),
          ),
        ),
        showDragHandle: true,
        dragHandleColor: AppColors.neutral600,
        dragHandleSize: Size(32, 4),
      ),

      // Navigation Bar Theme
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surfaceContainerDark,
        elevation: AppSpacing.elevationMedium,
        indicatorColor: AppColors.classicBlue90,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.classicBlue40);
          }
          return const IconThemeData(color: AppColors.neutral400);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTypography.darkTextTheme.labelMedium?.copyWith(
              color: AppColors.classicBlue40,
            );
          }
          return AppTypography.darkTextTheme.labelMedium?.copyWith(
            color: AppColors.neutral400,
          );
        }),
        height: AppSpacing.bottomNavHeight,
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.neutral700,
        thickness: 1,
        space: 1,
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: AppColors.neutral200,
        size: AppSpacing.iconMd,
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.classicBlue60,
        linearTrackColor: AppColors.classicBlue90,
        circularTrackColor: AppColors.classicBlue90,
      ),

      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.neutral100,
        contentTextStyle: AppTypography.darkTextTheme.bodyMedium?.copyWith(
          color: AppColors.neutral800,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusSm,
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
