import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:lakshya_mvp/providers/course_provider.dart';
import 'package:lakshya_mvp/providers/auth_provider.dart';
import 'package:lakshya_mvp/models/course.dart';
import 'package:lakshya_mvp/theme/theme.dart';
import 'package:lakshya_mvp/widgets/shared/loading_state.dart';
import 'package:lakshya_mvp/widgets/shared/error_state.dart';
import 'package:lakshya_mvp/widgets/shared/empty_state.dart';
import 'package:lakshya_mvp/widgets/shared/file_picker_widget.dart';
import 'package:lakshya_mvp/services/storage_service.dart';

/// Courses Management Screen
/// 
/// Full CRUD interface for managing courses.
/// Requires authentication.
class CoursesManagement extends StatefulWidget {
  const CoursesManagement({super.key});

  @override
  State<CoursesManagement> createState() => _CoursesManagementState();
}

class _CoursesManagementState extends State<CoursesManagement> {
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
  }

  @override
  Widget build(BuildContext context) {
    final courseProvider = Provider.of<CourseProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    // Check auth
    if (!authProvider.isAuthenticated) {
      return Scaffold(
        appBar: AppBar(title: const Text('Courses Management')),
        body: const Center(
          child: Text('Authentication Required'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Courses Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _showCourseDialog(context, courseProvider),
            tooltip: 'Add Course',
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              HapticFeedback.mediumImpact();
              courseProvider.refresh();
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: courseProvider.isLoading
          ? const LoadingState()
          :               courseProvider.error != null
                  ? ErrorState(
                      message: courseProvider.error!,
                      onRetry: () => courseProvider.refresh(),
                    )
                  : courseProvider.courses.isEmpty
                      ? EmptyState(
                          title: 'No courses yet',
                          icon: Icons.school_outlined,
                          actionLabel: 'Add Course',
                          onAction: () => _showCourseDialog(context, courseProvider),
                        )
                  : RefreshIndicator(
                      onRefresh: () => courseProvider.refresh(),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        itemCount: courseProvider.courses.length,
                        itemBuilder: (context, index) {
                          final course = courseProvider.courses[index];
                          return _CourseCard(
                            course: course,
                            onEdit: () => _showCourseDialog(
                              context,
                              courseProvider,
                              course: course,
                            ),
                            onDelete: () => _showDeleteDialog(
                              context,
                              courseProvider,
                              course,
                            ),
                          );
                        },
                      ),
                    ),
    );
  }

  void _showCourseDialog(
    BuildContext context,
    CourseProvider courseProvider, {
    Course? course,
  }) {
    showDialog(
      context: context,
      builder: (context) => _CourseFormDialog(
        course: course,
        onSave: (course) async {
          if (course.id.isEmpty) {
            // Create new course
            await courseProvider.create(course);
          } else {
            // Update existing course
            await courseProvider.update(course);
          }
        },
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    CourseProvider courseProvider,
    Course course,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Course'),
        content: Text('Are you sure you want to delete "${course.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await courseProvider.delete(course.id);
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

class _CourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CourseCard({
    required this.course,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.classicBlue.withValues(alpha: 0.1),
          child: Text(
            course.categoryName[0],
            style: const TextStyle(
              color: AppColors.classicBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(course.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${course.categoryName} • ${course.duration}'),
            if (course.isPopular)
              Chip(
                label: const Text('Popular'),
                backgroundColor: AppColors.success.withValues(alpha: 0.1),
                labelStyle: const TextStyle(
                  color: AppColors.success,
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

class _CourseFormDialog extends StatefulWidget {
  final Course? course;
  final Function(Course) onSave;

  const _CourseFormDialog({
    this.course,
    required this.onSave,
  });

  @override
  State<_CourseFormDialog> createState() => _CourseFormDialogState();
}

class _CourseFormDialogState extends State<_CourseFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController();
  final _levelController = TextEditingController();
  final _slugController = TextEditingController();
  final _highlightsController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _brochureUrlController = TextEditingController();

  CourseCategory _selectedCategory = CourseCategory.acca;
  bool _isPopular = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.course != null) {
      _titleController.text = widget.course!.title;
      _descriptionController.text = widget.course!.description;
      _durationController.text = widget.course!.duration;
      _levelController.text = widget.course!.level;
      _slugController.text = widget.course!.slug;
      _highlightsController.text = widget.course!.highlights.join('\n');
      _imageUrlController.text = widget.course!.imageUrl;
      _brochureUrlController.text = widget.course!.brochureUrl ?? '';
      _selectedCategory = widget.course!.category;
      _isPopular = widget.course!.isPopular;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _levelController.dispose();
    _slugController.dispose();
    _highlightsController.dispose();
    _imageUrlController.dispose();
    _brochureUrlController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final highlights = _highlightsController.text
        .split('\n')
        .where((h) => h.trim().isNotEmpty)
        .toList();

    final course = Course(
      id: widget.course?.id ?? '',
      slug: _slugController.text.trim(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _selectedCategory,
      duration: _durationController.text.trim(),
      level: _levelController.text.trim(),
      highlights: highlights,
      imageUrl: _imageUrlController.text.trim(),
      brochureUrl: _brochureUrlController.text.trim().isEmpty
          ? null
          : _brochureUrlController.text.trim(),
      isPopular: _isPopular,
    );

    try {
      await widget.onSave(course);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.course == null
                  ? 'Course created successfully'
                  : 'Course updated successfully',
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
                      widget.course == null
                          ? 'Create Course'
                          : 'Edit Course',
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

                      // Slug
                      TextFormField(
                        controller: _slugController,
                        decoration: const InputDecoration(
                          labelText: 'Slug *',
                          helperText: 'URL-friendly identifier (e.g., acca-foundation)',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Slug is required' : null,
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Category
                      DropdownButtonFormField<CourseCategory>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Category *',
                          border: OutlineInputBorder(),
                        ),
                        items: CourseCategory.values.map((category) {
                          final course = Course(
                            id: '',
                            slug: '',
                            title: '',
                            description: '',
                            category: category,
                            duration: '',
                            level: '',
                            highlights: [],
                            imageUrl: '',
                          );
                          return DropdownMenuItem(
                            value: category,
                            child: Text(course.categoryName),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedCategory = value);
                          }
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description *',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 4,
                        validator: (value) => value?.isEmpty ?? true
                            ? 'Description is required'
                            : null,
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Duration and Level
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _durationController,
                              decoration: const InputDecoration(
                                labelText: 'Duration',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: TextFormField(
                              controller: _levelController,
                              decoration: const InputDecoration(
                                labelText: 'Level',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Highlights
                      TextFormField(
                        controller: _highlightsController,
                        decoration: const InputDecoration(
                          labelText: 'Highlights',
                          helperText: 'One per line',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 5,
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Image Upload
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _imageUrlController,
                              decoration: const InputDecoration(
                                labelText: 'Image URL',
                                helperText: 'Or upload using file picker',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Consumer<StorageService>(
                            builder: (context, storageService, child) {
                              return FilePickerWidget.courseImage(
                                currentUrl: _imageUrlController.text.isEmpty
                                    ? null
                                    : _imageUrlController.text,
                                onFileSelected: (fileData) async {
                                  try {
                                    final courseId = widget.course?.id ?? '';
                                    if (courseId.isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Please save the course first to upload image',
                                          ),
                                          backgroundColor: AppColors.error,
                                        ),
                                      );
                                      return;
                                    }
                                    final url = await storageService.uploadCourseImage(
                                      file: fileData,
                                      courseId: courseId,
                                    );
                                    setState(() {
                                      _imageUrlController.text = url;
                                    });
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Upload failed: $e'),
                                          backgroundColor: AppColors.error,
                                        ),
                                      );
                                    }
                                  }
                                },
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Brochure URL
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _brochureUrlController,
                              decoration: const InputDecoration(
                                labelText: 'Brochure URL',
                                helperText: 'Or upload PDF using file picker',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Consumer<StorageService>(
                            builder: (context, storageService, child) {
                              return FilePickerWidget.brochure(
                                currentUrl: _brochureUrlController.text.isEmpty
                                    ? null
                                    : _brochureUrlController.text,
                                onFileSelected: (fileData) async {
                                  try {
                                    final courseId = widget.course?.id ?? '';
                                    if (courseId.isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Please save the course first to upload brochure',
                                          ),
                                          backgroundColor: AppColors.error,
                                        ),
                                      );
                                      return;
                                    }
                                    final url = await storageService.uploadBrochure(
                                      file: fileData,
                                      courseId: courseId,
                                    );
                                    setState(() {
                                      _brochureUrlController.text = url;
                                    });
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Upload failed: $e'),
                                          backgroundColor: AppColors.error,
                                        ),
                                      );
                                    }
                                  }
                                },
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Is Popular
                      CheckboxListTile(
                        title: const Text('Mark as Popular'),
                        value: _isPopular,
                        onChanged: (value) {
                          setState(() => _isPopular = value ?? false);
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
                          : Text(widget.course == null ? 'Create' : 'Update'),
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

