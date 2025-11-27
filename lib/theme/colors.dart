import 'package:flutter/material.dart';

/// Lakshya Institute Color Palette
/// Inspired by Pantone colors for a professional educational brand
///
/// Primary: Pantone 19-4052 Classic Blue - Trust, stability, confidence
/// Secondary: Pantone 16-1546 Living Coral meets Pantone 18-4250 Ultramarine
/// Tertiary: Pantone 14-0848 Mimosa (Golden) - Excellence, achievement
/// Accent: Pantone 18-1750 Viva Magenta - Bold, innovative
class AppColors {
  AppColors._();

  // ============================================
  // PANTONE-INSPIRED BRAND COLORS
  // ============================================

  /// Primary: Classic Blue (Pantone 19-4052)
  /// Represents trust, confidence, and stability - perfect for education
  static const Color classicBlue = Color(0xFF0F4C81);
  static const Color classicBlue90 = Color(0xFF1A5A94);
  static const Color classicBlue80 = Color(0xFF2668A7);
  static const Color classicBlue70 = Color(0xFF3B7DBC);
  static const Color classicBlue60 = Color(0xFF5A96CC);
  static const Color classicBlue40 = Color(0xFF8FB8DD);
  static const Color classicBlue20 = Color(0xFFC7DBEE);
  static const Color classicBlue10 = Color(0xFFE8F1F8);

  /// Secondary: Ultramarine Blue (Pantone 18-4250)
  /// Modern, tech-forward, innovative
  static const Color ultramarine = Color(0xFF3F51B5);
  static const Color ultramarine90 = Color(0xFF5262BC);
  static const Color ultramarine80 = Color(0xFF6573C3);
  static const Color ultramarine60 = Color(0xFF8B97D5);
  static const Color ultramarine40 = Color(0xFFB1BAE7);
  static const Color ultramarine20 = Color(0xFFD8DCF3);
  static const Color ultramarine10 = Color(0xFFF0F1FA);

  /// Tertiary: Mimosa Gold (Pantone 14-0848)
  /// Excellence, achievement, prestige
  static const Color mimosaGold = Color(0xFFE8A838);
  static const Color mimosaGold90 = Color(0xFFEAB14D);
  static const Color mimosaGold80 = Color(0xFFEDBA62);
  static const Color mimosaGold60 = Color(0xFFF2CC8C);
  static const Color mimosaGold40 = Color(0xFFF7DEB5);
  static const Color mimosaGold20 = Color(0xFFFBEFDA);
  static const Color mimosaGold10 = Color(0xFFFDF8EF);

  /// Accent: Viva Magenta (Pantone 18-1750)
  /// Bold, innovative, energetic
  static const Color vivaMagenta = Color(0xFFBB2649);
  static const Color vivaMagenta90 = Color(0xFFC23B5B);
  static const Color vivaMagenta80 = Color(0xFFC9516D);
  static const Color vivaMagenta60 = Color(0xFFD77B92);
  static const Color vivaMagenta40 = Color(0xFFE5A5B6);
  static const Color vivaMagenta20 = Color(0xFFF2D2DB);
  static const Color vivaMagenta10 = Color(0xFFFAEDF0);

  // ============================================
  // SEMANTIC COLORS
  // ============================================

  /// Success: Emerald (Pantone 17-5641)
  static const Color success = Color(0xFF009B77);
  static const Color successLight = Color(0xFFE6F5F1);
  static const Color successDark = Color(0xFF007A5E);

  /// Warning: Marigold (Pantone 14-1050)
  static const Color warning = Color(0xFFF5A623);
  static const Color warningLight = Color(0xFFFEF6E6);
  static const Color warningDark = Color(0xFFD4910F);

  /// Error: Fiery Red (Pantone 18-1664)
  static const Color error = Color(0xFFD32F2F);
  static const Color errorLight = Color(0xFFFDE8E8);
  static const Color errorDark = Color(0xFFB71C1C);

  /// Info: Serenity Blue (Pantone 15-3919)
  static const Color info = Color(0xFF91A8D0);
  static const Color infoLight = Color(0xFFF0F4FA);
  static const Color infoDark = Color(0xFF6B87B8);

  // ============================================
  // NEUTRAL COLORS (Based on Pantone Ultimate Gray 17-5104)
  // ============================================

  static const Color neutral900 = Color(0xFF1A1A2E);
  static const Color neutral800 = Color(0xFF2D2D44);
  static const Color neutral700 = Color(0xFF404059);
  static const Color neutral600 = Color(0xFF5C5C73);
  static const Color neutral500 = Color(0xFF78788C);
  static const Color neutral400 = Color(0xFF9494A6);
  static const Color neutral300 = Color(0xFFB0B0BF);
  static const Color neutral200 = Color(0xFFD0D0DA);
  static const Color neutral100 = Color(0xFFE8E8EE);
  static const Color neutral50 = Color(0xFFF5F5F8);
  static const Color neutral0 = Color(0xFFFFFFFF);

  // ============================================
  // SURFACE COLORS (Material 3)
  // ============================================

  /// Light Theme Surfaces
  static const Color surfaceLight = Color(0xFFFCFCFF);
  static const Color surfaceContainerLowestLight = Color(0xFFFFFFFF);
  static const Color surfaceContainerLowLight = Color(0xFFF8F8FB);
  static const Color surfaceContainerLight = Color(0xFFF2F2F6);
  static const Color surfaceContainerHighLight = Color(0xFFECECF1);
  static const Color surfaceContainerHighestLight = Color(0xFFE6E6EB);

  /// Dark Theme Surfaces
  static const Color surfaceDark = Color(0xFF121218);
  static const Color surfaceContainerLowestDark = Color(0xFF0D0D12);
  static const Color surfaceContainerLowDark = Color(0xFF1A1A22);
  static const Color surfaceContainerDark = Color(0xFF1E1E27);
  static const Color surfaceContainerHighDark = Color(0xFF282832);
  static const Color surfaceContainerHighestDark = Color(0xFF33333D);

  // ============================================
  // GRADIENTS
  // ============================================

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [classicBlue, ultramarine],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [classicBlue, Color(0xFF1A237E)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [mimosaGold, Color(0xFFF4B942)],
  );

  static const LinearGradient ctaGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [classicBlue90, ultramarine],
  );

  // ============================================
  // COURSE CATEGORY COLORS
  // ============================================

  static const Color accaColor = Color(0xFF0F4C81); // Classic Blue
  static const Color caColor = Color(0xFF3F51B5); // Ultramarine
  static const Color cmaColor = Color(0xFF009B77); // Emerald
  static const Color bcomMbaColor = Color(0xFFE8A838); // Mimosa Gold
}

