import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';

/// Lakshya Logo Widget
/// Displays the official Lakshya brand logo image
/// 
/// IMPORTANT: Uses the exact brand logo - do not modify the design!
/// Only size adjustments are allowed.
/// 
/// Logo aspect ratio: approximately 4.5:1 (width:height)
/// Logo colors: Classic Blue (#1B4F8A) + Mimosa Gold (#F4B942)
class LakshyaLogo extends StatelessWidget {
  /// The height of the logo in logical pixels
  final double height;

  const LakshyaLogo({
    super.key,
    this.height = 40,
  });

  /// For app bar - Material 3 compliant (36dp for comfortable touch)
  const LakshyaLogo.appBar({super.key}) : height = 36;

  /// For splash screen - responsive based on screen width
  /// Material 3 recommends max 200dp width for splash logos
  /// At 4.5:1 ratio, height should be ~44dp for 200dp width
  /// But we use larger for visual impact: 56dp (252dp width)
  const LakshyaLogo.splash({super.key}) : height = 56;

  /// Medium size for cards/headers (Material 3: 48dp)
  const LakshyaLogo.medium({super.key}) : height = 48;

  /// Large size for about page headers
  const LakshyaLogo.large({super.key}) : height = 64;

  /// Extra large for hero sections
  const LakshyaLogo.xlarge({super.key}) : height = 80;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/lakshya_logo.png',
      height: height,
      fit: BoxFit.contain,
      // Semantic label for accessibility
      semanticLabel: 'Lakshya Institute Logo',
      errorBuilder: (context, error, stackTrace) {
        // Temporary placeholder until image is added
        return _LogoPlaceholder(height: height);
      },
    );
  }
}

/// Responsive logo that adapts to screen size
class LakshyaLogoResponsive extends StatelessWidget {
  /// Percentage of screen width (0.0 - 1.0)
  final double widthFactor;
  
  /// Maximum width constraint
  final double maxWidth;
  
  /// Minimum width constraint  
  final double minWidth;

  const LakshyaLogoResponsive({
    super.key,
    this.widthFactor = 0.5,
    this.maxWidth = 280,
    this.minWidth = 120,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final logoWidth = (screenWidth * widthFactor).clamp(minWidth, maxWidth);
    
    return Image.asset(
      'assets/images/lakshya_logo.png',
      width: logoWidth,
      fit: BoxFit.contain,
      semanticLabel: 'Lakshya Institute Logo',
      errorBuilder: (context, error, stackTrace) {
        return _LogoPlaceholder(height: logoWidth / 4.5);
      },
    );
  }
}

/// Temporary placeholder shown only when image file is missing
class _LogoPlaceholder extends StatelessWidget {
  final double height;

  const _LogoPlaceholder({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: EdgeInsets.symmetric(horizontal: height * 0.2),
      decoration: BoxDecoration(
        color: AppColors.classicBlue10,
        borderRadius: BorderRadius.circular(height * 0.15),
        border: Border.all(
          color: AppColors.classicBlue20,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.image_outlined,
            size: height * 0.5,
            color: AppColors.classicBlue40,
          ),
          SizedBox(width: height * 0.1),
          Text(
            'Lakshya',
            style: TextStyle(
              color: AppColors.classicBlue,
              fontSize: height * 0.35,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Full logo with tagline (for about page, footer, etc.)
/// Material 3 compliant with proper spacing
class LakshyaLogoFull extends StatelessWidget {
  const LakshyaLogoFull({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const LakshyaLogo.large(),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: AppColors.classicBlue10,
            borderRadius: AppSpacing.borderRadiusFull,
          ),
          child: const Text(
            'Excellence in Commerce Education',
            style: TextStyle(
              color: AppColors.neutral600,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }
}
