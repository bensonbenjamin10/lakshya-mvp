import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';

/// Lakshya App Icon Widget
/// A branded "L" icon with the yellow accent - used as app icon fallback
/// and for in-app branding consistency
class LakshyaAppIcon extends StatelessWidget {
  final double size;
  final bool showBackground;
  final Color? backgroundColor;
  
  const LakshyaAppIcon({
    super.key,
    this.size = 48,
    this.showBackground = true,
    this.backgroundColor,
  });

  /// Small icon for lists, chips
  const LakshyaAppIcon.small({super.key})
      : size = 32,
        showBackground = true,
        backgroundColor = null;

  /// Medium icon for cards, buttons
  const LakshyaAppIcon.medium({super.key})
      : size = 48,
        showBackground = true,
        backgroundColor = null;

  /// Large icon for splash, about pages
  const LakshyaAppIcon.large({super.key})
      : size = 80,
        showBackground = true,
        backgroundColor = null;

  /// Extra large for splash screens
  const LakshyaAppIcon.xlarge({super.key})
      : size = 120,
        showBackground = true,
        backgroundColor = null;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: showBackground
          ? BoxDecoration(
              color: backgroundColor ?? Colors.white,
              borderRadius: BorderRadius.circular(size * 0.18),
              boxShadow: [
                BoxShadow(
                  color: AppColors.classicBlue.withValues(alpha: 0.15),
                  blurRadius: size * 0.2,
                  offset: Offset(0, size * 0.05),
                ),
              ],
            )
          : null,
      child: Stack(
        children: [
          // Blue rounded rectangle with "L"
          Center(
            child: Container(
              width: size * 0.72,
              height: size * 0.72,
              decoration: BoxDecoration(
                color: AppColors.classicBlue,
                borderRadius: BorderRadius.circular(size * 0.12),
              ),
              child: Center(
                child: Text(
                  'L',
                  style: GoogleFonts.nunito(
                    fontSize: size * 0.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.0,
                  ),
                ),
              ),
            ),
          ),
          // Yellow accent triangle (top right)
          Positioned(
            top: size * 0.02,
            right: size * 0.02,
            child: CustomPaint(
              size: Size(size * 0.22, size * 0.22),
              painter: _TrianglePainter(color: AppColors.mimosaGold),
            ),
          ),
          // Yellow accent dot (bottom right of L)
          Positioned(
            bottom: size * 0.18,
            right: size * 0.18,
            child: Container(
              width: size * 0.1,
              height: size * 0.1,
              decoration: const BoxDecoration(
                color: AppColors.mimosaGold,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Triangle painter for the yellow accent
class _TrianglePainter extends CustomPainter {
  final Color color;
  
  _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    final path = Path()
      ..moveTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, 0)
      ..close();
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Icon-only version without background (for adaptive icons)
class LakshyaAppIconForeground extends StatelessWidget {
  final double size;
  
  const LakshyaAppIconForeground({
    super.key,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Blue rounded rectangle with "L"
          Center(
            child: Container(
              width: size * 0.75,
              height: size * 0.75,
              decoration: BoxDecoration(
                color: AppColors.classicBlue,
                borderRadius: BorderRadius.circular(size * 0.12),
              ),
              child: Center(
                child: Text(
                  'L',
                  style: GoogleFonts.nunito(
                    fontSize: size * 0.52,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.0,
                  ),
                ),
              ),
            ),
          ),
          // Yellow accent triangle
          Positioned(
            top: 0,
            right: 0,
            child: CustomPaint(
              size: Size(size * 0.2, size * 0.2),
              painter: _TrianglePainter(color: AppColors.mimosaGold),
            ),
          ),
          // Yellow accent dot
          Positioned(
            bottom: size * 0.15,
            right: size * 0.15,
            child: Container(
              width: size * 0.1,
              height: size * 0.1,
              decoration: const BoxDecoration(
                color: AppColors.mimosaGold,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

