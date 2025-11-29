import 'package:flutter/material.dart';
import 'package:lakshya_mvp/models/course_module.dart';
import 'package:lakshya_mvp/models/student_progress.dart';
import 'package:lakshya_mvp/theme/theme.dart';

/// Video player widget for video modules
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
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _isCompleted = widget.progress?.status == ProgressStatus.completed;
    // Simulate video duration
    _totalDuration = Duration(minutes: widget.module.durationMinutes ?? 30);
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  void _markAsComplete() {
    setState(() {
      _isCompleted = true;
      _currentPosition = _totalDuration;
    });
    widget.onProgressUpdate(ProgressStatus.completed);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Video marked as complete!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Video player placeholder
        Container(
          width: double.infinity,
          height: 250,
          decoration: BoxDecoration(
            color: AppColors.neutral900,
            borderRadius: AppSpacing.borderRadiusMd,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Video thumbnail/placeholder
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.classicBlue.withValues(alpha: 0.3),
                      AppColors.ultramarine.withValues(alpha: 0.3),
                    ],
                  ),
                  borderRadius: AppSpacing.borderRadiusMd,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                        size: 64,
                        color: Colors.white,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        widget.module.contentUrl ?? 'Video Content',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              // Play/Pause button overlay
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _togglePlayPause,
                    borderRadius: AppSpacing.borderRadiusMd,
                    child: Container(),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Video controls
        Row(
          children: [
            IconButton(
              icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
              onPressed: _togglePlayPause,
              color: AppColors.classicBlue,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress bar
                  Slider(
                    value: _currentPosition.inSeconds.toDouble(),
                    min: 0,
                    max: _totalDuration.inSeconds.toDouble(),
                    onChanged: (value) {
                      setState(() {
                        _currentPosition = Duration(seconds: value.toInt());
                      });
                    },
                    activeColor: AppColors.classicBlue,
                  ),
                  // Time indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(_currentPosition),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.neutral600,
                            ),
                      ),
                      Text(
                        _formatDuration(_totalDuration),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.neutral600,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        // Video info
        if (widget.module.contentUrl != null)
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.neutral100,
              borderRadius: AppSpacing.borderRadiusSm,
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 20, color: AppColors.neutral600),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Video URL: ${widget.module.contentUrl}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.neutral600,
                        ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: AppSpacing.lg),

        // Mark as complete button
        if (!_isCompleted)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _markAsComplete,
              icon: const Icon(Icons.check_circle),
              label: const Text('Mark Video as Complete'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              ),
            ),
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: AppSpacing.borderRadiusSm,
              border: Border.all(color: AppColors.success),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, color: AppColors.success),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Video Completed',
                  style: TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }
}

