import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lakshya_mvp/models/course_module.dart';
import 'package:lakshya_mvp/models/student_progress.dart';
import 'package:lakshya_mvp/providers/student_provider.dart';
import 'package:lakshya_mvp/widgets/student/video_player_widget.dart';
import 'package:lakshya_mvp/widgets/student/assignment_submission_widget.dart';
import 'package:lakshya_mvp/widgets/student/quiz_widget.dart';
import 'package:lakshya_mvp/widgets/student/markdown_content_widget.dart';
import 'package:lakshya_mvp/widgets/shared/loading_state.dart';
import 'package:lakshya_mvp/theme/theme.dart';

/// Module detail screen with optimized layout
/// 
/// Design principles:
/// - Single source of truth for title (app bar only)
/// - Content-first approach
/// - Minimal chrome, maximum content
/// - Type-specific layouts
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
    
    final modules = studentProvider.getModulesForCourse(widget.courseId);
    _module = modules.firstWhere(
      (m) => m.id == widget.moduleId,
      orElse: () => modules.first,
    );

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
      id: '',
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

    setState(() {
      _progress = updatedProgress;
    });

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
      return _buildNotFoundState(context);
    }

    final isCompleted = _progress?.status == ProgressStatus.completed;

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      appBar: _buildAppBar(context, isCompleted),
      body: _buildContent(context),
      // Sticky bottom action for non-video content
      bottomNavigationBar: _module!.type != ModuleType.video
          ? _buildBottomAction(context, isCompleted)
          : null,
    );
  }

  Widget _buildNotFoundState(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Not Found')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: const BoxDecoration(
                color: AppColors.neutral100,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 48,
                color: AppColors.neutral400,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Module not found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.neutral600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isCompleted) {
    return AppBar(
      backgroundColor: AppColors.surfaceLight,
      elevation: 0,
      titleSpacing: 0,
      title: Row(
        children: [
          // Module type icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getModuleColor().withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getModuleIcon(),
              size: 18,
              color: _getModuleColor(),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Title
          Expanded(
            child: Text(
              _module!.title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actions: [
        if (isCompleted)
          Container(
            margin: const EdgeInsets.only(right: AppSpacing.md),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: AppColors.success,
              size: 18,
            ),
          ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (_module!.type) {
      case ModuleType.video:
        return _buildVideoLayout(context);
      case ModuleType.reading:
        return _buildReadingLayout(context);
      case ModuleType.assignment:
        return _buildAssignmentLayout(context);
      case ModuleType.quiz:
        return _buildQuizLayout(context);
      case ModuleType.liveSession:
        return _buildLiveSessionLayout(context);
    }
  }

  /// Video: Player on top, then info below
  Widget _buildVideoLayout(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Video player with padding
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              0,
              AppSpacing.screenPadding,
              AppSpacing.lg,
            ),
            child: VideoPlayerWidget(
              module: _module!,
              progress: _progress,
              onProgressUpdate: (status) => _updateProgress(status),
            ),
          ),
          
          // Info section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
            child: _buildInfoSection(context),
          ),
          
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  /// Reading: Full-height immersive reader
  Widget _buildReadingLayout(BuildContext context) {
    // Check for inline markdown content
    if (_module!.contentBody != null && _module!.contentType == ContentType.markdown) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          0,
          AppSpacing.screenPadding,
          0,
        ),
        child: MarkdownContentWidget(
          content: _module!.contentBody!,
          title: null, // Don't pass title to avoid duplication
          onComplete: () {
            if (_progress?.status != ProgressStatus.completed) {
              _updateProgress(ProgressStatus.completed);
              _showCompletionSnackbar(context);
            }
          },
        ),
      );
    }

    // URL-based reading with cleaner UI
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description (if present) - NOT the title again
          if (_module!.description != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: Text(
                _module!.description!,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.neutral600,
                  height: 1.5,
                ),
              ),
            ),
          
          // Metadata chips
          _buildMetadataChips(context),
          
          const SizedBox(height: AppSpacing.xl),
          
          // Reading material card
          _buildReadingMaterialCard(context),
        ],
      ),
    );
  }

  /// Assignment: Form-like layout
  Widget _buildAssignmentLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brief info
          if (_module!.description != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: Text(
                _module!.description!,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.neutral600,
                  height: 1.5,
                ),
              ),
            ),
          
          _buildMetadataChips(context),
          
          const SizedBox(height: AppSpacing.xl),
          
          AssignmentSubmissionWidget(
            module: _module!,
            enrollmentId: widget.enrollmentId,
            progress: _progress,
            onSubmissionComplete: () => _updateProgress(ProgressStatus.completed),
          ),
        ],
      ),
    );
  }

  /// Quiz: Clean quiz interface
  Widget _buildQuizLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_module!.description != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: Text(
                _module!.description!,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.neutral600,
                  height: 1.5,
                ),
              ),
            ),
          
          _buildMetadataChips(context),
          
          const SizedBox(height: AppSpacing.xl),
          
          QuizWidget(
            module: _module!,
            enrollmentId: widget.enrollmentId,
            progress: _progress,
            onQuizComplete: () => _updateProgress(ProgressStatus.completed),
          ),
        ],
      ),
    );
  }

  /// Live Session: Centered CTA
  Widget _buildLiveSessionLayout(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.ultramarine.withValues(alpha: 0.2),
                    AppColors.ultramarine.withValues(alpha: 0.1),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.videocam_rounded,
                size: 48,
                color: AppColors.ultramarine,
              ),
            ),
            
            const SizedBox(height: AppSpacing.xl),
            
            Text(
              'Live Session',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.ultramarine,
              ),
            ),
            
            const SizedBox(height: AppSpacing.sm),
            
            // Schedule
            if (_module!.unlockDate != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: AppColors.ultramarine.withValues(alpha: 0.1),
                  borderRadius: AppSpacing.borderRadiusSm,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.event_rounded,
                      size: 16,
                      color: AppColors.ultramarine,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      _formatDate(_module!.unlockDate!),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.ultramarine,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )
            else
              Text(
                'Session details will be shared soon',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.neutral500,
                ),
              ),
            
            const SizedBox(height: AppSpacing.xxl),
            
            FilledButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Calendar invite coming soon!'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(Icons.calendar_today_rounded),
              label: const Text('Add to Calendar'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.ultramarine,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xxl,
                  vertical: AppSpacing.md,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Info section for video content
  Widget _buildInfoSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Description
        if (_module!.description != null)
          Text(
            _module!.description!,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.neutral600,
              height: 1.5,
            ),
          ),
        
        if (_module!.description != null)
          const SizedBox(height: AppSpacing.lg),
        
        // Metadata chips
        _buildMetadataChips(context),
      ],
    );
  }

  /// Compact metadata chips
  Widget _buildMetadataChips(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        // Duration
        if (_module!.durationMinutes != null)
          _buildChip(
            context,
            Icons.schedule_rounded,
            '${_module!.durationMinutes} min',
          ),
        
        // Required/Optional
        _buildChip(
          context,
          _module!.isRequired ? Icons.star_rounded : Icons.star_outline_rounded,
          _module!.isRequired ? 'Required' : 'Optional',
        ),
        
        // Free preview
        if (_module!.isFreePreview)
          _buildChip(
            context,
            Icons.lock_open_rounded,
            'Free Preview',
            color: AppColors.success,
          ),
      ],
    );
  }

  Widget _buildChip(
    BuildContext context,
    IconData icon,
    String label, {
    Color? color,
  }) {
    final chipColor = color ?? AppColors.neutral500;
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.1),
        borderRadius: AppSpacing.borderRadiusSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: chipColor),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: chipColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Reading material card (for URL-based content)
  Widget _buildReadingMaterialCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.05),
        borderRadius: AppSpacing.borderRadiusLg,
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_stories_rounded,
              size: 40,
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Reading Material',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Tap below to open the document',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.neutral500,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Opening document...'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(Icons.open_in_new_rounded, size: 18),
            label: const Text('Open Document'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.success,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.md,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Sticky bottom action bar
  Widget _buildBottomAction(BuildContext context, bool isCompleted) {
    if (isCompleted) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.1),
          border: Border(
            top: BorderSide(color: AppColors.success.withValues(alpha: 0.2)),
          ),
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Completed',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton.icon(
            onPressed: () {
              _updateProgress(ProgressStatus.completed);
              _showCompletionSnackbar(context);
            },
            icon: const Icon(Icons.check_rounded, size: 20),
            label: const Text('Mark as Complete'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.classicBlue,
            ),
          ),
        ),
      ),
    );
  }

  void _showCompletionSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Text('${_module!.type.displayName} marked as complete!'),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusSm),
      ),
    );
  }

  Color _getModuleColor() {
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

  IconData _getModuleIcon() {
    switch (_module!.type) {
      case ModuleType.video:
        return Icons.play_circle_rounded;
      case ModuleType.reading:
        return Icons.auto_stories_rounded;
      case ModuleType.assignment:
        return Icons.assignment_rounded;
      case ModuleType.quiz:
        return Icons.quiz_rounded;
      case ModuleType.liveSession:
        return Icons.videocam_rounded;
    }
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
