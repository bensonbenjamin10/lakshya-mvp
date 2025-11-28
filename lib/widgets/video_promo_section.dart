import 'package:flutter/material.dart';
import 'package:lakshya_mvp/theme/theme.dart';
import 'package:lakshya_mvp/widgets/vimeo_player.dart';

/// Video data model for promos
class VideoPromo {
  final String id;
  final String vimeoId;
  final String title;
  final String? subtitle;
  final String? thumbnailUrl;
  final String? duration;
  final VideoPromoType type;

  const VideoPromo({
    required this.id,
    required this.vimeoId,
    required this.title,
    this.subtitle,
    this.thumbnailUrl,
    this.duration,
    this.type = VideoPromoType.promo,
  });
}

enum VideoPromoType {
  welcome,
  promo,
  coursePreview,
  testimonial,
  faculty,
}

/// Video Promo Section for Home Screen
class VideoPromoSection extends StatelessWidget {
  const VideoPromoSection({super.key});

  // Sample video promos - replace with actual Vimeo IDs
  static const List<VideoPromo> _promos = [
    VideoPromo(
      id: '1',
      vimeoId: '824804225', // Replace with actual Vimeo ID
      title: 'Welcome to Lakshya',
      subtitle: 'Your journey to success starts here',
      duration: '2:30',
      type: VideoPromoType.welcome,
    ),
    VideoPromo(
      id: '2',
      vimeoId: '824804225', // Replace with actual Vimeo ID
      title: 'Why Choose Lakshya?',
      subtitle: 'Excellence in commerce education',
      duration: '1:45',
      type: VideoPromoType.promo,
    ),
    VideoPromo(
      id: '3',
      vimeoId: '824804225', // Replace with actual Vimeo ID
      title: 'Student Success Stories',
      subtitle: 'Hear from our alumni',
      duration: '3:15',
      type: VideoPromoType.testimonial,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.vivaMagenta.withValues(alpha: 0.1),
                          borderRadius: AppSpacing.borderRadiusSm,
                        ),
                        child: const Icon(
                          Icons.play_circle_filled_rounded,
                          color: AppColors.vivaMagenta,
                          size: AppSpacing.iconSm,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Text(
                        'See Inside Lakshya',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Padding(
                    padding: const EdgeInsets.only(left: 44),
                    child: Text(
                      'Campus tours, faculty intros & more',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.neutral500,
                          ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        // Featured Video (First one, larger)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
          child: _FeaturedVideoCard(video: _promos.first),
        ),

        const SizedBox(height: AppSpacing.lg),

        // Other Videos (Horizontal scroll)
        if (_promos.length > 1)
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
              itemCount: _promos.length - 1,
              itemBuilder: (context, index) {
                final video = _promos[index + 1];
                return Padding(
                  padding: EdgeInsets.only(
                    right: index < _promos.length - 2 ? AppSpacing.md : 0,
                  ),
                  child: _SmallVideoCard(video: video),
                );
              },
            ),
          ),
      ],
    );
  }
}

/// Featured Video Card (Large)
class _FeaturedVideoCard extends StatelessWidget {
  final VideoPromo video;

  const _FeaturedVideoCard({required this.video});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openVideo(context),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: AppSpacing.borderRadiusLg,
          boxShadow: [
            BoxShadow(
              color: AppColors.neutral900.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: AppSpacing.borderRadiusLg,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background Gradient
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.classicBlue,
                        AppColors.ultramarine,
                      ],
                    ),
                  ),
                ),

                // Pattern Overlay
                Opacity(
                  opacity: 0.1,
                  child: CustomPaint(
                    painter: _PatternPainter(),
                    size: Size.infinite,
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: AppSpacing.borderRadiusFull,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.play_circle_outline_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              'FEATURED VIDEO',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // Title
                      Text(
                        video.title,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      if (video.subtitle != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          video.subtitle!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                        ),
                      ],

                      const SizedBox(height: AppSpacing.md),

                      // Play Button & Duration
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                              vertical: AppSpacing.sm,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: AppSpacing.borderRadiusFull,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.play_arrow_rounded,
                                  color: AppColors.classicBlue,
                                  size: 20,
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                Text(
                                  'Watch Now',
                                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                        color: AppColors.classicBlue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          if (video.duration != null) ...[
                            const SizedBox(width: AppSpacing.md),
                            Text(
                              video.duration!,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.8),
                                  ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openVideo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => VideoPlayerModal(
        videoId: video.vimeoId,
        title: video.title,
      ),
    );
  }
}

/// Small Video Card (For horizontal list)
class _SmallVideoCard extends StatelessWidget {
  final VideoPromo video;

  const _SmallVideoCard({required this.video});

  IconData get _typeIcon {
    switch (video.type) {
      case VideoPromoType.welcome:
        return Icons.waving_hand_rounded;
      case VideoPromoType.promo:
        return Icons.campaign_rounded;
      case VideoPromoType.coursePreview:
        return Icons.school_rounded;
      case VideoPromoType.testimonial:
        return Icons.format_quote_rounded;
      case VideoPromoType.faculty:
        return Icons.person_rounded;
    }
  }

  Color get _typeColor {
    switch (video.type) {
      case VideoPromoType.welcome:
        return AppColors.classicBlue;
      case VideoPromoType.promo:
        return AppColors.vivaMagenta;
      case VideoPromoType.coursePreview:
        return AppColors.ultramarine;
      case VideoPromoType.testimonial:
        return AppColors.success;
      case VideoPromoType.faculty:
        return AppColors.mimosaGold;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openVideo(context),
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppSpacing.borderRadiusMd,
          border: Border.all(color: AppColors.neutral200),
          boxShadow: [
            BoxShadow(
              color: AppColors.neutral900.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail area
            Container(
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _typeColor,
                    _typeColor.withValues(alpha: 0.7),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppSpacing.radiusMd),
                ),
              ),
              child: Stack(
                children: [
                  // Icon
                  Center(
                    child: Icon(
                      _typeIcon,
                      color: Colors.white.withValues(alpha: 0.3),
                      size: 40,
                    ),
                  ),
                  // Play button
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.play_arrow_rounded,
                        color: _typeColor,
                        size: 20,
                      ),
                    ),
                  ),
                  // Duration
                  if (video.duration != null)
                    Positioned(
                      right: AppSpacing.sm,
                      bottom: AppSpacing.sm,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: AppSpacing.borderRadiusSm,
                        ),
                        child: Text(
                          video.duration!,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text(
                video.title,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openVideo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => VideoPlayerModal(
        videoId: video.vimeoId,
        title: video.title,
      ),
    );
  }
}

/// Pattern Painter for background
class _PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const spacing = 30.0;
    for (double x = 0; x < size.width + spacing; x += spacing) {
      for (double y = 0; y < size.height + spacing; y += spacing) {
        canvas.drawCircle(Offset(x, y), 2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

