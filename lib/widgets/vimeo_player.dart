import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:lakshya_mvp/theme/theme.dart';

/// Vimeo Video Player Widget
/// 
/// Usage:
/// ```dart
/// VimeoPlayer(
///   videoId: '123456789',
///   autoPlay: false,
///   showControls: true,
/// )
/// ```
class VimeoPlayer extends StatefulWidget {
  final String videoId;
  final bool autoPlay;
  final bool loop;
  final bool showControls;
  final bool muted;
  final double aspectRatio;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final VoidCallback? onReady;
  final VoidCallback? onPlay;
  final VoidCallback? onPause;
  final VoidCallback? onEnd;

  const VimeoPlayer({
    super.key,
    required this.videoId,
    this.autoPlay = false,
    this.loop = false,
    this.showControls = true,
    this.muted = false,
    this.aspectRatio = 16 / 9,
    this.backgroundColor,
    this.borderRadius,
    this.onReady,
    this.onPlay,
    this.onPause,
    this.onEnd,
  });

  @override
  State<VimeoPlayer> createState() => _VimeoPlayerState();
}

class _VimeoPlayerState extends State<VimeoPlayer> {
  late WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(widget.backgroundColor ?? AppColors.neutral900)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() {
              _isLoading = true;
              _hasError = false;
            });
          },
          onPageFinished: (url) {
            setState(() => _isLoading = false);
            widget.onReady?.call();
          },
          onWebResourceError: (error) {
            setState(() {
              _isLoading = false;
              _hasError = true;
            });
          },
        ),
      )
      ..loadHtmlString(_buildVimeoEmbed());
  }

  String _buildVimeoEmbed() {
    final params = <String, String>{
      'autoplay': widget.autoPlay ? '1' : '0',
      'loop': widget.loop ? '1' : '0',
      'controls': widget.showControls ? '1' : '0',
      'muted': widget.muted ? '1' : '0',
      'playsinline': '1',
      'transparent': '0',
      'background': '0',
      'quality': 'auto',
      'dnt': '1', // Do not track
    };

    final queryString = params.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');

    return '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    html, body { 
      width: 100%; 
      height: 100%; 
      background: #000;
      overflow: hidden;
    }
    .video-container {
      position: relative;
      width: 100%;
      height: 100%;
    }
    iframe {
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      border: none;
    }
  </style>
</head>
<body>
  <div class="video-container">
    <iframe 
      src="https://player.vimeo.com/video/${widget.videoId}?$queryString"
      allow="autoplay; fullscreen; picture-in-picture"
      allowfullscreen>
    </iframe>
  </div>
</body>
</html>
''';
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: widget.borderRadius ?? BorderRadius.zero,
      child: AspectRatio(
        aspectRatio: widget.aspectRatio,
        child: Container(
          color: widget.backgroundColor ?? AppColors.neutral900,
          child: Stack(
            children: [
              // WebView Player
              WebViewWidget(controller: _controller),

              // Loading Indicator
              if (_isLoading)
                Container(
                  color: AppColors.neutral900,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                ),

              // Error State
              if (_hasError)
                Container(
                  color: AppColors.neutral900,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          color: AppColors.neutral400,
                          size: 48,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Video unavailable',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.neutral400,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        TextButton(
                          onPressed: () {
                            _controller.loadHtmlString(_buildVimeoEmbed());
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Video Thumbnail with Play Button Overlay
/// Tap to open video in fullscreen or modal
class VideoThumbnail extends StatelessWidget {
  final String? thumbnailUrl;
  final String videoId;
  final String? title;
  final String? duration;
  final VoidCallback? onTap;
  final double aspectRatio;
  final BorderRadius? borderRadius;

  const VideoThumbnail({
    super.key,
    this.thumbnailUrl,
    required this.videoId,
    this.title,
    this.duration,
    this.onTap,
    this.aspectRatio = 16 / 9,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => _openVideoPlayer(context),
      child: ClipRRect(
        borderRadius: borderRadius ?? AppSpacing.borderRadiusMd,
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Thumbnail Image
              if (thumbnailUrl != null)
                Image.network(
                  thumbnailUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildPlaceholder(),
                )
              else
                _buildPlaceholder(),

              // Gradient Overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),

              // Play Button
              Center(
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: AppColors.classicBlue,
                    size: 32,
                  ),
                ),
              ),

              // Title & Duration
              if (title != null || duration != null)
                Positioned(
                  left: AppSpacing.md,
                  right: AppSpacing.md,
                  bottom: AppSpacing.md,
                  child: Row(
                    children: [
                      if (title != null)
                        Expanded(
                          child: Text(
                            title!,
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      if (duration != null) ...[
                        const SizedBox(width: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.7),
                            borderRadius: AppSpacing.borderRadiusSm,
                          ),
                          child: Text(
                            duration!,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: Colors.white,
                                ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.neutral800,
      child: const Center(
        child: Icon(
          Icons.videocam_rounded,
          color: AppColors.neutral600,
          size: 48,
        ),
      ),
    );
  }

  void _openVideoPlayer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => VideoPlayerModal(
        videoId: videoId,
        title: title,
      ),
    );
  }
}

/// Fullscreen Video Player Modal
class VideoPlayerModal extends StatelessWidget {
  final String videoId;
  final String? title;

  const VideoPlayerModal({
    super.key,
    required this.videoId,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      child: Column(
        children: [
          // Handle & Close Button
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                // Drag Handle
                Expanded(
                  child: Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.neutral600,
                        borderRadius: AppSpacing.borderRadiusFull,
                      ),
                    ),
                  ),
                ),
                // Close Button
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Title
          if (title != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Text(
                title!,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
            ),

          const SizedBox(height: AppSpacing.lg),

          // Video Player
          Expanded(
            child: VimeoPlayer(
              videoId: videoId,
              autoPlay: true,
              showControls: true,
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}

