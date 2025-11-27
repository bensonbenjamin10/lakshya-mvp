import 'package:flutter/material.dart';

/// Lakshya Institute Spacing & Sizing System
/// Based on 4px base unit for consistent spacing
class AppSpacing {
  AppSpacing._();

  // ============================================
  // BASE SPACING (4px increments)
  // ============================================

  static const double xs = 4.0;   // Extra small
  static const double sm = 8.0;   // Small
  static const double md = 12.0;  // Medium
  static const double lg = 16.0;  // Large
  static const double xl = 20.0;  // Extra large
  static const double xxl = 24.0; // 2X large
  static const double xxxl = 32.0; // 3X large
  static const double huge = 40.0; // Huge
  static const double massive = 48.0; // Massive
  static const double giant = 64.0; // Giant

  // ============================================
  // SEMANTIC SPACING
  // ============================================

  /// Screen padding
  static const double screenPadding = 20.0;
  static const double screenPaddingLarge = 24.0;

  /// Section spacing
  static const double sectionSpacing = 32.0;
  static const double sectionSpacingLarge = 48.0;

  /// Card padding
  static const double cardPadding = 16.0;
  static const double cardPaddingLarge = 20.0;

  /// List item spacing
  static const double listItemSpacing = 12.0;

  /// Button padding
  static const double buttonPaddingHorizontal = 24.0;
  static const double buttonPaddingVertical = 14.0;

  /// Input field spacing
  static const double inputSpacing = 16.0;

  // ============================================
  // BORDER RADIUS
  // ============================================

  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radiusXxl = 24.0;
  static const double radiusFull = 999.0;

  /// Pre-built BorderRadius
  static BorderRadius get borderRadiusXs => BorderRadius.circular(radiusXs);
  static BorderRadius get borderRadiusSm => BorderRadius.circular(radiusSm);
  static BorderRadius get borderRadiusMd => BorderRadius.circular(radiusMd);
  static BorderRadius get borderRadiusLg => BorderRadius.circular(radiusLg);
  static BorderRadius get borderRadiusXl => BorderRadius.circular(radiusXl);
  static BorderRadius get borderRadiusXxl => BorderRadius.circular(radiusXxl);
  static BorderRadius get borderRadiusFull => BorderRadius.circular(radiusFull);

  // ============================================
  // ELEVATION / SHADOWS
  // ============================================

  static const double elevationNone = 0.0;
  static const double elevationLow = 1.0;
  static const double elevationMedium = 2.0;
  static const double elevationHigh = 4.0;
  static const double elevationHighest = 8.0;

  // ============================================
  // ICON SIZES
  // ============================================

  static const double iconXs = 16.0;
  static const double iconSm = 20.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 40.0;
  static const double iconXxl = 48.0;
  static const double iconHuge = 64.0;

  // ============================================
  // COMPONENT SIZES
  // ============================================

  /// Button heights
  static const double buttonHeightSm = 36.0;
  static const double buttonHeightMd = 44.0;
  static const double buttonHeightLg = 52.0;

  /// Input field height
  static const double inputHeight = 52.0;

  /// App bar height
  static const double appBarHeight = 64.0;

  /// Bottom nav height
  static const double bottomNavHeight = 80.0;

  /// Card minimum height
  static const double cardMinHeight = 120.0;

  /// Avatar sizes
  static const double avatarSm = 32.0;
  static const double avatarMd = 40.0;
  static const double avatarLg = 56.0;
  static const double avatarXl = 72.0;

  // ============================================
  // BREAKPOINTS (for responsive design)
  // ============================================

  static const double breakpointMobile = 600.0;
  static const double breakpointTablet = 900.0;
  static const double breakpointDesktop = 1200.0;
  static const double breakpointWide = 1536.0;

  /// Max content width
  static const double maxContentWidth = 1200.0;
  static const double maxReadingWidth = 720.0;
}

/// Extension for easy EdgeInsets creation
extension SpacingEdgeInsets on AppSpacing {
  static EdgeInsets all(double value) => EdgeInsets.all(value);
  
  static EdgeInsets horizontal(double value) => 
      EdgeInsets.symmetric(horizontal: value);
  
  static EdgeInsets vertical(double value) => 
      EdgeInsets.symmetric(vertical: value);
  
  static EdgeInsets symmetric({double h = 0, double v = 0}) => 
      EdgeInsets.symmetric(horizontal: h, vertical: v);
}

