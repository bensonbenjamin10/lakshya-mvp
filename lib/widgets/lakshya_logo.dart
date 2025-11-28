import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

/// Styled placeholder matching brand identity - shown when image is missing
class _LogoPlaceholder extends StatelessWidget {
  final double height;

  const _LogoPlaceholder({required this.height});

  @override
  Widget build(BuildContext context) {
    // Calculate width based on logo aspect ratio (4.5:1)
    final width = height * 4.5;
    
    return SizedBox(
      height: height,
      width: width,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Styled "L" icon
          _BrandedL(size: height * 0.9),
          SizedBox(width: height * 0.15),
          // "akshya" text
          Text(
            'akshya',
            style: GoogleFonts.nunito(
              color: AppColors.classicBlue,
              fontSize: height * 0.65,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          // Yellow accent
          Transform.translate(
            offset: Offset(-height * 0.05, -height * 0.25),
            child: _YellowAccent(size: height * 0.35),
          ),
        ],
      ),
    );
  }
}

/// Branded "L" letter matching the logo style
class _BrandedL extends StatelessWidget {
  final double size;
  
  const _BrandedL({required this.size});

  @override
  Widget build(BuildContext context) {
    return Text(
      'L',
      style: GoogleFonts.nunito(
        color: AppColors.classicBlue,
        fontSize: size,
        fontWeight: FontWeight.w800,
        height: 1.0,
      ),
    );
  }
}

/// Yellow accent triangle matching the logo
class _YellowAccent extends StatelessWidget {
  final double size;
  
  const _YellowAccent({required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _TrianglePainter(),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.mimosaGold
      ..style = PaintingStyle.fill;
    
    final path = Path()
      ..moveTo(size.width * 0.3, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height * 0.7)
      ..close();
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
