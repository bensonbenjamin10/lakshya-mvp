import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:lakshya_mvp/providers/video_promo_provider.dart';
import 'package:lakshya_mvp/providers/auth_provider.dart';
import 'package:lakshya_mvp/providers/course_provider.dart';
import 'package:lakshya_mvp/models/video_promo.dart';
import 'package:lakshya_mvp/models/course.dart';
import 'package:lakshya_mvp/theme/theme.dart';
import 'package:lakshya_mvp/widgets/shared/loading_state.dart';
import 'package:lakshya_mvp/widgets/shared/error_state.dart';
import 'package:lakshya_mvp/widgets/shared/empty_state.dart';

/// Videos Management Screen
/// 
/// Full CRUD interface for managing video promos.
/// Requires authentication.
class VideosManagement extends StatefulWidget {
  const VideosManagement({super.key});

  @override
  State<VideosManagement> createState() => _VideosManagementState();
}

class _VideosManagementState extends State<VideosManagement> {
  @override
  void initState() {
    super.initState();
    // Redirect mobile users to home (admin is web-only)
    if (!kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.go('/');
        }
      });
      return;
    }
    // Load admin view (includes inactive videos)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<VideoPromoProvider>(context, listen: false).loadAllForAdmin();
    });
  }

  @override
  Widget build(BuildContext context) {
    final videoProvider = Provider.of<VideoPromoProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    // Check auth
    if (!authProvider.isAuthenticated) {
      return Scaffold(
        appBar: AppBar(title: const Text('Videos Management')),
        body: const Center(
          child: Text('Authentication Required'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Videos Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _showVideoDialog(context, videoProvider),
            tooltip: 'Add Video',
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              HapticFeedback.mediumImpact();
              videoProvider.refresh();
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: videoProvider.isLoading
          ? const LoadingState()
          : videoProvider.error != null
              ? ErrorState(
                  message: videoProvider.error!,
                  onRetry: () => videoProvider.refresh(),
                )
              : videoProvider.videos.isEmpty
                  ? EmptyState(
                      title: 'No videos yet',
                      icon: Icons.video_library_outlined,
                      actionLabel: 'Add Video',
                      onAction: () => _showVideoDialog(context, videoProvider),
                    )
                  : RefreshIndicator(
                      onRefresh: () => videoProvider.refresh(),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        itemCount: videoProvider.videos.length,
                        itemBuilder: (context, index) {
                          final video = videoProvider.videos[index];
                          return _VideoCard(
                            video: video,
                            onEdit: () => _showVideoDialog(
                              context,
                              videoProvider,
                              video: video,
                            ),
                            onDelete: () => _showDeleteDialog(
                              context,
                              videoProvider,
                              video,
                            ),
                          );
                        },
                      ),
                    ),
    );
  }

  void _showVideoDialog(
    BuildContext context,
    VideoPromoProvider videoProvider, {
    VideoPromo? video,
  }) {
    showDialog(
      context: context,
      builder: (context) => _VideoFormDialog(
        video: video,
        onSave: (video) async {
          if (video.id.isEmpty) {
            await videoProvider.create(video);
          } else {
            await videoProvider.update(video);
          }
        },
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    VideoPromoProvider videoProvider,
    VideoPromo video,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Video'),
        content: Text('Are you sure you want to delete "${video.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await videoProvider.delete(video.id);
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _VideoCard extends StatelessWidget {
  final VideoPromo video;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _VideoCard({
    required this.video,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: ListTile(
        leading: Container(
          width: 80,
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.classicBlue.withValues(alpha: 0.1),
            borderRadius: AppSpacing.borderRadiusMd,
          ),
          child: const Icon(
            Icons.play_circle_outline_rounded,
            color: AppColors.classicBlue,
            size: 32,
          ),
        ),
        title: Text(video.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Vimeo ID: ${video.vimeoId}'),
            Text('Type: ${video.typeString}'),
            if (video.isFeatured)
              Chip(
                label: const Text('Featured'),
                backgroundColor: AppColors.success.withValues(alpha: 0.1),
                labelStyle: const TextStyle(
                  color: AppColors.success,
                  fontSize: 12,
                ),
                padding: EdgeInsets.zero,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            if (!video.isActive)
              Chip(
                label: const Text('Inactive'),
                backgroundColor: AppColors.error.withValues(alpha: 0.1),
                labelStyle: const TextStyle(
                  color: AppColors.error,
                  fontSize: 12,
                ),
                padding: EdgeInsets.zero,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_rounded),
              onPressed: onEdit,
              tooltip: 'Edit',
            ),
            IconButton(
              icon: const Icon(Icons.delete_rounded),
              onPressed: onDelete,
              tooltip: 'Delete',
              color: AppColors.error,
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}

class _VideoFormDialog extends StatefulWidget {
  final VideoPromo? video;
  final Function(VideoPromo) onSave;

  const _VideoFormDialog({
    this.video,
    required this.onSave,
  });

  @override
  State<_VideoFormDialog> createState() => _VideoFormDialogState();
}

class _VideoFormDialogState extends State<_VideoFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _vimeoIdController = TextEditingController();
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  final _thumbnailUrlController = TextEditingController();
  final _durationController = TextEditingController();
  final _displayOrderController = TextEditingController();

  VideoPromoType _selectedType = VideoPromoType.promo;
  String? _selectedCourseId;
  bool _isFeatured = false;
  bool _isActive = true;
  bool _isLoading = false;
  List<Course> _courses = [];

  @override
  void initState() {
    super.initState();
    if (widget.video != null) {
      _vimeoIdController.text = widget.video!.vimeoId;
      _titleController.text = widget.video!.title;
      _subtitleController.text = widget.video!.subtitle ?? '';
      _thumbnailUrlController.text = widget.video!.thumbnailUrl ?? '';
      _durationController.text = widget.video!.duration ?? '';
      _displayOrderController.text = widget.video!.displayOrder.toString();
      _selectedType = widget.video!.type;
      _selectedCourseId = widget.video!.courseId;
      _isFeatured = widget.video!.isFeatured;
      _isActive = widget.video!.isActive;
    }
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    final courseProvider = Provider.of<CourseProvider>(context, listen: false);
    await courseProvider.refresh();
    setState(() {
      _courses = courseProvider.courses;
    });
  }

  @override
  void dispose() {
    _vimeoIdController.dispose();
    _titleController.dispose();
    _subtitleController.dispose();
    _thumbnailUrlController.dispose();
    _durationController.dispose();
    _displayOrderController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final video = VideoPromo(
      id: widget.video?.id ?? '',
      vimeoId: _vimeoIdController.text.trim(),
      title: _titleController.text.trim(),
      subtitle: _subtitleController.text.trim().isEmpty
          ? null
          : _subtitleController.text.trim(),
      thumbnailUrl: _thumbnailUrlController.text.trim().isEmpty
          ? null
          : _thumbnailUrlController.text.trim(),
      duration: _durationController.text.trim().isEmpty
          ? null
          : _durationController.text.trim(),
      type: _selectedType,
      courseId: _selectedCourseId,
      isFeatured: _isFeatured,
      displayOrder: int.tryParse(_displayOrderController.text) ?? 0,
      isActive: _isActive,
    );

    try {
      await widget.onSave(video);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.video == null
                  ? 'Video created successfully'
                  : 'Video updated successfully',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 800),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    Text(
                      widget.video == null
                          ? 'Create Video'
                          : 'Edit Video',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              // Form fields
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Vimeo ID
                      TextFormField(
                        controller: _vimeoIdController,
                        decoration: const InputDecoration(
                          labelText: 'Vimeo ID *',
                          helperText: 'The numeric ID from Vimeo video URL',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Vimeo ID is required' : null,
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Title
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Title *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Title is required' : null,
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Subtitle
                      TextFormField(
                        controller: _subtitleController,
                        decoration: const InputDecoration(
                          labelText: 'Subtitle',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Type
                      DropdownButtonFormField<VideoPromoType>(
                        value: _selectedType,
                        decoration: const InputDecoration(
                          labelText: 'Type *',
                          border: OutlineInputBorder(),
                        ),
                        items: VideoPromoType.values.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type.toString().split('.').last),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedType = value);
                          }
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Course (optional)
                      DropdownButtonFormField<String>(
                        value: _selectedCourseId,
                        decoration: const InputDecoration(
                          labelText: 'Course (Optional)',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('None'),
                          ),
                          ..._courses.map((course) {
                            return DropdownMenuItem<String>(
                              value: course.id,
                              child: Text(course.title),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedCourseId = value);
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Thumbnail URL
                      TextFormField(
                        controller: _thumbnailUrlController,
                        decoration: const InputDecoration(
                          labelText: 'Thumbnail URL',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Duration
                      TextFormField(
                        controller: _durationController,
                        decoration: const InputDecoration(
                          labelText: 'Duration',
                          helperText: 'e.g., 2:30',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Display Order
                      TextFormField(
                        controller: _displayOrderController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Display Order',
                          helperText: 'Lower numbers appear first',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Is Featured
                      CheckboxListTile(
                        title: const Text('Featured Video'),
                        value: _isFeatured,
                        onChanged: (value) {
                          setState(() => _isFeatured = value ?? false);
                        },
                      ),

                      // Is Active
                      CheckboxListTile(
                        title: const Text('Active'),
                        value: _isActive,
                        onChanged: (value) {
                          setState(() => _isActive = value ?? true);
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Actions
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleSave,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(widget.video == null ? 'Create' : 'Update'),
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
}

