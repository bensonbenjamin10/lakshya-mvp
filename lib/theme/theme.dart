/// Lakshya Institute Design System
/// 
/// A comprehensive Material 3 design system with Pantone-inspired colors
/// 
/// Usage:
/// ```dart
/// import 'package:lakshya_mvp/theme/theme.dart';
/// 
/// // In your MaterialApp:
/// MaterialApp(
///   theme: AppTheme.lightTheme,
///   darkTheme: AppTheme.darkTheme,
/// );
/// 
/// // Access colors:
/// AppColors.classicBlue
/// AppColors.primaryGradient
/// 
/// // Access spacing:
/// AppSpacing.lg // 16.0
/// AppSpacing.borderRadiusMd // BorderRadius.circular(12)
/// 
/// // Access theme extensions in widgets:
/// context.statusColors.success
/// context.brandAccents.gold
/// context.courseColors.acca
/// ```
library;

export 'app_theme.dart';
export 'colors.dart';
export 'typography.dart';
export 'spacing.dart';
export 'extensions.dart';

