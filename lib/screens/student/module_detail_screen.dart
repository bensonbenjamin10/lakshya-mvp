import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lakshya_mvp/models/course_module.dart';
import 'package:lakshya_mvp/models/student_progress.dart';
import 'package:lakshya_mvp/providers/student_provider.dart';
import 'package:lakshya_mvp/widgets/student/video_player_widget.dart';
import 'package:lakshya_mvp/widgets/student/assignment_submission_widget.dart';
import 'package:lakshya_mvp/widgets/student/quiz_widget.dart';
import 'package:lakshya_mvp/widgets/shared/loading_state.dart';
import 'package:lakshya_mvp/theme/theme.dart';

/// Module detail screen showing module content based on type
class ModuleDetailScreen extends StatefulWidget {
  final String courseId;
  final String moduleId;
  final String enrollmentId;

  const ModuleDetailScreen({
    super.key,
    required this.courseId,
    required this.moduleId,
    required this.enrollmentId,
  });

  @override
  State<ModuleDetailScreen> createState() => _ModuleDetailScreenState();
}

class _ModuleDetailScreenState extends State<ModuleDetailScreen> {
  CourseModule? _module;
  StudentProgress? _progress;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadModuleData();
  }

  Future<void> _loadModuleData() async {
    final studentProvider = Provider.of<StudentProvider>(context, listen: false);
    
    // Get module from the course modules
    final modules = studentProvider.getModulesForCourse(widget.courseId);
    _module = modules.firstWhere(
      (m) => m.id == widget.moduleId,
      orElse: () => modules.first,
    );

    // Get progress for this module
    _progress = studentProvider.getModuleProgress(widget.enrollmentId, widget.moduleId);

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _updateProgress(ProgressStatus status) async {
    final studentProvider = Provider.of<StudentProvider>(context, listen: false);
    
    if (_module == null) return;

    final now = DateTime.now();
    final progress = _progress ?? StudentProgress(
      id: '', // Will be created by repository
      studentId: studentProvider.enrollments.first.studentId,
      enrollmentId: widget.enrollmentId,
      moduleId: widget.moduleId,
      status: ProgressStatus.notStarted,
      createdAt: now,
      updatedAt: now,
    );

    final updatedProgress = progress.copyWith(
      status: status,
      lastAccessedAt: now,
      completionDate: status == ProgressStatus.completed ? now : null,
    );

    // Update progress via repository
    // Note: This would typically go through StudentProvider
    // For now, we'll just update local state
    setState(() {
      _progress = updatedProgress;
    });

    // Refresh student data to update enrollment progress
    await studentProvider.refresh();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: LoadingState(message: 'Loading module...'),
      );
    }

    if (_module == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Module Not Found')),
        body: const Center(child: Text('Module not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_module!.title),
        actions: [
          if (_progress?.status == ProgressStatus.completed)
            IconButton(
              icon: const Icon(Icons.check_circle, color: AppColors.success),
              tooltip: 'Completed',
              onPressed: null,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Module header
            _buildModuleHeader(context),
            const SizedBox(height: AppSpacing.xl),

            // Module content based on type
            _buildModuleContent(context),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Module type badge
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: _getModuleTypeColor().withValues(alpha: 0.1),
            borderRadius: AppSpacing.borderRadiusSm,
            border: Border.all(color: _getModuleTypeColor().withValues(alpha: 0.3)),
          ),
          child: Text(
            _module!.type.displayName,
            style: TextStyle(
              color: _getModuleTypeColor(),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Module title
        Text(
          _module!.title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Module description
        if (_module!.description != null)
          Text(
            _module!.description!,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.neutral600,
                ),
          ),

        const SizedBox(height: AppSpacing.md),

        // Module metadata
        Row(
          children: [
            if (_module!.durationMinutes != null) ...[
              Icon(Icons.access_time, size: 16, color: AppColors.neutral500),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '${_module!.durationMinutes} minutes',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral500,
                    ),
              ),
              const SizedBox(width: AppSpacing.md),
            ],
            Icon(Icons.info_outline, size: 16, color: AppColors.neutral500),
            const SizedBox(width: AppSpacing.xs),
            Text(
              _module!.isRequired ? 'Required' : 'Optional',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.neutral500,
                  ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModuleContent(BuildContext context) {
    switch (_module!.type) {
      case ModuleType.video:
        return VideoPlayerWidget(
          module: _module!,
          progress: _progress,
          onProgressUpdate: (status) => _updateProgress(status),
        );
      case ModuleType.reading:
        return _buildReadingContent(context);
      case ModuleType.assignment:
        return AssignmentSubmissionWidget(
          module: _module!,
          enrollmentId: widget.enrollmentId,
          progress: _progress,
          onSubmissionComplete: () => _updateProgress(ProgressStatus.completed),
        );
      case ModuleType.quiz:
        return QuizWidget(
          module: _module!,
          enrollmentId: widget.enrollmentId,
          progress: _progress,
          onQuizComplete: () => _updateProgress(ProgressStatus.completed),
        );
      case ModuleType.liveSession:
        return _buildLiveSessionContent(context);
    }
  }

  Widget _buildReadingContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_module!.contentUrl != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.neutral100,
              borderRadius: AppSpacing.borderRadiusMd,
              border: Border.all(color: AppColors.neutral200),
            ),
            child: Column(
              children: [
                const Icon(Icons.article, size: 48, color: AppColors.neutral400),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Reading Material',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextButton.icon(
                  onPressed: () {
                    // Open reading URL
                    if (_module!.contentUrl != null) {
                      // In a real app, you'd use url_launcher or similar
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Opening: ${_module!.contentUrl}'),
                          action: SnackBarAction(
                            label: 'Open',
                            onPressed: () {
                              // Launch URL
                            },
                          ),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Open Reading Material'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        // Mark as complete button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              _updateProgress(ProgressStatus.completed);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reading marked as complete!')),
              );
            },
            icon: const Icon(Icons.check_circle),
            label: const Text('Mark as Complete'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLiveSessionContent(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.ultramarine.withValues(alpha: 0.1),
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: AppColors.ultramarine.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.videocam, size: 64, color: AppColors.ultramarine),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Live Session',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.ultramarine,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (_module!.unlockDate != null)
            Text(
              'Scheduled for: ${_formatDate(_module!.unlockDate!)}',
              style: Theme.of(context).textTheme.bodyMedium,
            )
          else
            Text(
              'Session details will be shared soon',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.neutral600,
                  ),
            ),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Live session link will be shared via email')),
              );
            },
            icon: const Icon(Icons.calendar_today),
            label: const Text('View Schedule'),
          ),
        ],
      ),
    );
  }

  Color _getModuleTypeColor() {
    switch (_module!.type) {
      case ModuleType.video:
        return AppColors.classicBlue;
      case ModuleType.reading:
        return AppColors.success;
      case ModuleType.assignment:
        return AppColors.mimosaGold;
      case ModuleType.quiz:
        return AppColors.vivaMagenta;
      case ModuleType.liveSession:
        return AppColors.ultramarine;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

