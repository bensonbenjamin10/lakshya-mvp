import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:lakshya_mvp/theme/theme.dart';

/// Vimeo Video Player Widget using WebView
/// 
/// Uses Vimeo's official embed player via WebView for reliable playback.
/// This approach works with any video that has "embed anywhere" enabled.
/// 
/// Features:
/// - 16:9 aspect ratio
/// - Vimeo's native player controls
/// - Progress tracking via JavaScript bridge
/// - Fullscreen support
class VimeoPlayerWidget extends StatefulWidget {
  /// Vimeo video ID (e.g., "123456789") or full URL
  final String videoId;
  
  /// Callback when video starts playing
  final VoidCallback? onPlay;
  
  /// Callback when video is paused
  final VoidCallback? onPause;
  
  /// Callback when video ends
  final VoidCallback? onEnded;
  
  /// Callback with progress updates (0.0 - 1.0)
  final ValueChanged<double>? onProgress;
  
  /// Whether to autoplay the video
  final bool autoplay;
  
  /// Whether to loop the video
  final bool loop;

  const VimeoPlayerWidget({
    super.key,
    required this.videoId,
    this.onPlay,
    this.onPause,
    this.onEnded,
    this.onProgress,
    this.autoplay = false,
    this.loop = false,
  });

  @override
  State<VimeoPlayerWidget> createState() => _VimeoPlayerWidgetState();
}

class _VimeoPlayerWidgetState extends State<VimeoPlayerWidget> {
  late WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.neutral900)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = true;
                _hasError = false;
              });
            }
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() => _isLoading = false);
            }
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView error: ${error.description}');
            // Don't show error for minor resource loading issues
            if (error.errorType == WebResourceErrorType.unknown) return;
            if (mounted) {
              setState(() {
                _hasError = true;
                _errorMessage = 'Failed to load video';
                _isLoading = false;
              });
            }
          },
        ),
      )
      ..addJavaScriptChannel(
        'VimeoEvents',
        onMessageReceived: (JavaScriptMessage message) {
          _handleVimeoEvent(message.message);
        },
      )
      ..loadHtmlString(_buildPlayerHtml());
  }

  String _extractVideoId(String input) {
    // Handle full URLs like https://vimeo.com/123456789
    final urlPattern = RegExp(r'vimeo\.com\/(?:video\/)?(\d+)');
    final match = urlPattern.firstMatch(input);
    if (match != null) {
      return match.group(1)!;
    }
    // Handle URLs with hash
    final hashPattern = RegExp(r'vimeo\.com\/(\d+)\/');
    final hashMatch = hashPattern.firstMatch(input);
    if (hashMatch != null) {
      return hashMatch.group(1)!;
    }
    // Assume it's already a video ID
    return input.replaceAll(RegExp(r'[^\d]'), '');
  }

  String _buildPlayerHtml() {
    final videoId = _extractVideoId(widget.videoId);
    
    // Build Vimeo embed URL with parameters
    final params = <String>[
      'autopause=0',
      'badge=0',
      'byline=0',
      'portrait=0',
      'title=0',
      'color=0F4C81',
      'dnt=1',
      'responsive=1',
    ];
    
    if (widget.autoplay) params.add('autoplay=1');
    if (widget.loop) params.add('loop=1');
    
    final embedUrl = 'https://player.vimeo.com/video/$videoId?${params.join('&')}';

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
      background: #1A1A2E; 
      overflow: hidden;
    }
    .container {
      position: relative;
      width: 100%;
      padding-top: 56.25%; /* 16:9 */
      background: #1A1A2E;
    }
    iframe {
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      border: none;
    }
    .error {
      position: absolute;
      top: 50%;
      left: 50%;
      transform: translate(-50%, -50%);
      color: white;
      text-align: center;
      font-family: -apple-system, BlinkMacSystemFont, sans-serif;
    }
    .error-icon {
      font-size: 48px;
      margin-bottom: 16px;
    }
  </style>
</head>
<body>
  <div class="container">
    <iframe
      id="vimeo-player"
      src="$embedUrl"
      allow="autoplay; fullscreen; picture-in-picture; encrypted-media"
      allowfullscreen
    ></iframe>
  </div>
  <script src="https://player.vimeo.com/api/player.js"></script>
  <script>
    try {
      var iframe = document.getElementById('vimeo-player');
      var player = new Vimeo.Player(iframe);
      
      player.on('play', function() {
        VimeoEvents.postMessage('play');
      });
      
      player.on('pause', function() {
        VimeoEvents.postMessage('pause');
      });
      
      player.on('ended', function() {
        VimeoEvents.postMessage('ended');
      });
      
      player.on('timeupdate', function(data) {
        VimeoEvents.postMessage('progress:' + data.percent);
      });
      
      player.on('error', function(error) {
        VimeoEvents.postMessage('error:' + (error.message || 'Unknown error'));
      });
      
      player.ready().then(function() {
        VimeoEvents.postMessage('ready');
      }).catch(function(error) {
        VimeoEvents.postMessage('error:' + (error.message || 'Failed to load'));
      });
    } catch(e) {
      VimeoEvents.postMessage('error:' + e.message);
    }
  </script>
</body>
</html>
''';
  }

  void _handleVimeoEvent(String message) {
    if (message == 'play') {
      widget.onPlay?.call();
    } else if (message == 'pause') {
      widget.onPause?.call();
    } else if (message == 'ended') {
      widget.onEnded?.call();
    } else if (message == 'ready') {
      debugPrint('Vimeo player ready');
    } else if (message.startsWith('progress:')) {
      final progress = double.tryParse(message.substring(9)) ?? 0.0;
      widget.onProgress?.call(progress);
    } else if (message.startsWith('error:')) {
      final errorMsg = message.substring(6);
      debugPrint('Vimeo error: $errorMsg');
      if (errorMsg.contains('privacy') || errorMsg.contains('Privacy')) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Video embed restricted. Set to "Anywhere" on Vimeo.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
            children: [
              // WebView Player
              WebViewWidget(controller: _controller),
              
              // Loading overlay
              if (_isLoading)
                _buildLoadingOverlay(),
              
              // Error overlay
              if (_hasError)
                _buildErrorOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: AppColors.neutral900,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: AppColors.classicBlue,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Loading video...',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorOverlay() {
    return Container(
      color: AppColors.neutral900,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.lock_outline_rounded,
              size: 28,
              color: AppColors.warning,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Video Restricted',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _errorMessage ?? 'Set embed to "Anywhere" on Vimeo',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _hasError = false;
                _isLoading = true;
              });
              _controller.loadHtmlString(_buildPlayerHtml());
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: AppColors.classicBlue,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: AppSpacing.borderRadiusSm,
              ),
            ),
            child: const Text(
              'Retry',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
