import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lakshya_mvp/theme/theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _loaderController;

  late Animation<double> _logoFadeAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _loaderFadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimationSequence();
  }

  void _setupAnimations() {
    // Logo animation controller (0-1.2 seconds)
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Text animation controller (0.6-1.8 seconds)
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Loader animation controller
    _loaderController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Logo animations
    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _logoScaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.8, curve: Curves.elasticOut),
      ),
    );

    // Text animations
    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeOut,
      ),
    );

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Loader fade animation
    _loaderFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _loaderController,
        curve: Curves.easeOut,
      ),
    );
  }

  void _startAnimationSequence() async {
    // Set status bar style
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    // Start logo animation
    _logoController.forward();

    // Start text animation after 400ms
    await Future.delayed(const Duration(milliseconds: 400));
    _textController.forward();

    // Start loader after 800ms
    await Future.delayed(const Duration(milliseconds: 600));
    _loaderController.forward();

    // Navigate after 3.5 seconds total
    await Future.delayed(const Duration(milliseconds: 2000));
    if (mounted) {
      context.go('/');
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _loaderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A1628), // Dark navy
              Color(0xFF1A365D), // Deep blue
              Color(0xFF0F4C81), // Classic blue
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Logo Section
              AnimatedBuilder(
                animation: _logoController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _logoFadeAnimation,
                    child: ScaleTransition(
                      scale: _logoScaleAnimation,
                      child: child,
                    ),
                  );
                },
                child: _buildLogo(),
              ),

              const SizedBox(height: AppSpacing.xxxl),

              // Text Section
              SlideTransition(
                position: _textSlideAnimation,
                child: FadeTransition(
                  opacity: _textFadeAnimation,
                  child: _buildBrandText(),
                ),
              ),

              const Spacer(flex: 2),

              // Loader Section
              FadeTransition(
                opacity: _loaderFadeAnimation,
                child: _buildLoader(),
              ),

              const SizedBox(height: AppSpacing.massive),

              // Tagline
              FadeTransition(
                opacity: _loaderFadeAnimation,
                child: Text(
                  'Excellence in Commerce Education',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.6),
                        letterSpacing: 1.5,
                      ),
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: AppSpacing.borderRadiusXl,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Starburst Icon
          _buildStarburstIcon(),
          const SizedBox(height: AppSpacing.lg),
          // IIC Text
          Text(
            'Indian Institute',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w400,
                  letterSpacing: 2,
                ),
          ),
          Text(
            'of Commerce',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w400,
                  letterSpacing: 2,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildStarburstIcon() {
    return SizedBox(
      width: 80,
      height: 80,
      child: CustomPaint(
        painter: _StarburstPainter(),
      ),
    );
  }

  Widget _buildBrandText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lakshya',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
        ),
        // Golden accent
        Container(
          margin: const EdgeInsets.only(left: 2, top: 4),
          child: Transform.rotate(
            angle: -0.3,
            child: Container(
              width: 12,
              height: 20,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.mimosaGold,
                    Color(0xFFD4920F),
                  ],
                ),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoader() {
    return Column(
      children: [
        // Custom loading indicator
        SizedBox(
          width: 200,
          child: _AnimatedProgressBar(),
        ),
      ],
    );
  }
}

// Starburst Icon Painter
class _StarburstPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    // Draw rays
    const rayCount = 16;
    const innerRadius = 8.0;
    const outerRadius = 35.0;

    for (int i = 0; i < rayCount; i++) {
      final angle = (i * 360 / rayCount) * (math.pi / 180);
      final isLongRay = i % 2 == 0;
      final rayLength = isLongRay ? outerRadius : outerRadius * 0.6;

      final startX = center.dx + innerRadius * math.cos(angle);
      final startY = center.dy + innerRadius * math.sin(angle);
      final endX = center.dx + rayLength * math.cos(angle);
      final endY = center.dy + rayLength * math.sin(angle);

      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        paint,
      );
    }

    // Draw center circle
    final centerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 6, centerPaint);

    // Draw center dot
    final dotPaint = Paint()
      ..color = const Color(0xFF0F4C81)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 3, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Animated Progress Bar
class _AnimatedProgressBar extends StatefulWidget {
  @override
  State<_AnimatedProgressBar> createState() => _AnimatedProgressBarState();
}

class _AnimatedProgressBarState extends State<_AnimatedProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutCubic,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Column(
          children: [
            // Progress bar container
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: AppSpacing.borderRadiusFull,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: _animation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.mimosaGold,
                          Colors.white,
                        ],
                      ),
                      borderRadius: AppSpacing.borderRadiusFull,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.mimosaGold.withValues(alpha: 0.5),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            // Percentage text
            Text(
              '${(_animation.value * 100).toInt()}%',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        );
      },
    );
  }
}

