import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lakshya_mvp/models/course_module.dart';
import 'package:lakshya_mvp/models/student_progress.dart';
import 'package:lakshya_mvp/theme/theme.dart';
import 'package:lakshya_mvp/widgets/student/vimeo_player_widget.dart';

/// Video player widget for video modules
/// 
/// Features:
/// - Vimeo integration for actual video playback
/// - Fallback placeholder for non-Vimeo content
/// - 16:9 aspect ratio for proper video proportions
/// - Progress tracking with visual feedback
/// - Material Design 3 styling
class VideoPlayerWidget extends StatefulWidget {
  final CourseModule module;
  final StudentProgress? progress;
  final Function(ProgressStatus) onProgressUpdate;

  const VideoPlayerWidget({
    super.key,
    required this.module,
    this.progress,
    required this.onProgressUpdate,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  bool _isCompleted = false;
  double _watchProgress = 0.0;
  bool _hasStartedWatching = false;

  @override
  void initState() {
    super.initState();
    _isCompleted = widget.progress?.status == ProgressStatus.completed;
  }

  /// Check if the content URL is a Vimeo video
  bool get _isVimeoVideo {
    final url = widget.module.contentUrl?.toLowerCase() ?? '';
    return url.contains('vimeo.com') || 
           url.contains('vimeo') ||
           RegExp(r'^\d{6,}$').hasMatch(url); // Just a video ID
  }

  /// Extract Vimeo video ID from URL
  String? get _vimeoVideoId {
    final url = widget.module.contentUrl;
    if (url == null) return null;
    
    // Handle full URLs like https://vimeo.com/123456789
    final urlPattern = RegExp(r'vimeo\.com\/(?:video\/)?(\d+)');
    final match = urlPattern.firstMatch(url);
    if (match != null) {
      return match.group(1);
    }
    
    // Handle URLs with hash like https://vimeo.com/123456789/abc123
    final hashPattern = RegExp(r'vimeo\.com\/(\d+)\/([a-zA-Z0-9]+)');
    final hashMatch = hashPattern.firstMatch(url);
    if (hashMatch != null) {
      return hashMatch.group(1);
    }
    
    // Assume it's already a video ID if it's just numbers
    if (RegExp(r'^\d+$').hasMatch(url)) {
      return url;
    }
    
    return null;
  }

  void _onVideoProgress(double progress) {
    setState(() {
      _watchProgress = progress;
      if (!_hasStartedWatching && progress > 0) {
        _hasStartedWatching = true;
        widget.onProgressUpdate(ProgressStatus.inProgress);
      }
    });
    
    // Auto-complete when watched 90% or more
    if (progress >= 0.9 && !_isCompleted) {
      _markAsComplete();
    }
  }

  void _onVideoEnded() {
    if (!_isCompleted) {
      _markAsComplete();
    }
  }

  void _markAsComplete() {
    setState(() {
      _isCompleted = true;
    });
    widget.onProgressUpdate(ProgressStatus.completed);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: AppSpacing.sm),
            const Text('Video completed!'),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusSm),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Video player - Vimeo or placeholder
        _isVimeoVideo && _vimeoVideoId != null
            ? _buildVimeoPlayer()
            : _buildPlaceholderPlayer(),
        
        const SizedBox(height: AppSpacing.lg),
        
        // Progress indicator (only for Vimeo)
        if (_isVimeoVideo && _hasStartedWatching && !_isCompleted)
          _buildWatchProgress(),
        
        if (_isVimeoVideo && _hasStartedWatching && !_isCompleted)
          const SizedBox(height: AppSpacing.lg),
        
        // Completion section
        _buildCompletionSection(context),
      ],
    );
  }

  Widget _buildVimeoPlayer() {
    return VimeoPlayerWidget(
      videoId: _vimeoVideoId!,
      autoplay: false,
      onPlay: () {
        if (!_hasStartedWatching) {
          setState(() => _hasStartedWatching = true);
          widget.onProgressUpdate(ProgressStatus.inProgress);
        }
      },
      onProgress: _onVideoProgress,
      onEnded: _onVideoEnded,
    );
  }

  Widget _buildPlaceholderPlayer() {
    return ClipRRect(
      borderRadius: AppSpacing.borderRadiusLg,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.neutral900,
            boxShadow: [
              BoxShadow(
                color: AppColors.classicBlue.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Gradient background
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.classicBlue.withValues(alpha: 0.8),
                      AppColors.ultramarine.withValues(alpha: 0.9),
                    ],
                  ),
                ),
              ),
              // Grid pattern
              CustomPaint(
                painter: _GridPatternPainter(),
              ),
              // Content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Icon(
                        Icons.play_circle_outline_rounded,
                        size: 64,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      widget.module.title,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: AppSpacing.borderRadiusSm,
                      ),
                      child: Text(
                        'Video content coming soon',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWatchProgress() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.classicBlue10,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: AppColors.classicBlue20),
      ),
      child: Row(
        children: [
          Icon(
            Icons.play_circle_filled_rounded,
            color: AppColors.classicBlue,
            size: 24,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Watch Progress',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.classicBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${(_watchProgress * 100).toInt()}%',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.classicBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                ClipRRect(
                  borderRadius: AppSpacing.borderRadiusXs,
                  child: LinearProgressIndicator(
                    value: _watchProgress,
                    backgroundColor: AppColors.classicBlue20,
                    color: AppColors.classicBlue,
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionSection(BuildContext context) {
    if (_isCompleted) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.success.withValues(alpha: 0.1),
              AppColors.success.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: AppSpacing.borderRadiusMd,
          border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: 28,
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Video Completed!',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                  Text(
                    'You\'ve finished watching this video',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Show manual complete button for non-Vimeo or as fallback
    return SizedBox(
      width: double.infinity,
      height: AppSpacing.buttonHeightLg,
      child: ElevatedButton.icon(
        onPressed: _markAsComplete,
        icon: const Icon(Icons.check_circle_outline_rounded),
        label: Text(_isVimeoVideo ? 'Mark as Complete' : 'I\'ve Watched This'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.success,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: AppColors.success.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusMd,
          ),
        ),
      ),
    );
  }
}

/// Custom painter for decorative grid pattern on video placeholder
class _GridPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1;

    const spacing = 30.0;
    
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
