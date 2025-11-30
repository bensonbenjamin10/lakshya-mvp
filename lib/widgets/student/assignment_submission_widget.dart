import 'package:flutter/material.dart';
import 'package:lakshya_mvp/models/course_module.dart';
import 'package:lakshya_mvp/models/student_progress.dart';
import 'package:lakshya_mvp/theme/theme.dart';

/// Optimized Assignment submission widget
/// 
/// Clean form-based design without redundant headers
class AssignmentSubmissionWidget extends StatefulWidget {
  final CourseModule module;
  final String enrollmentId;
  final StudentProgress? progress;
  final VoidCallback onSubmissionComplete;

  const AssignmentSubmissionWidget({
    super.key,
    required this.module,
    required this.enrollmentId,
    this.progress,
    required this.onSubmissionComplete,
  });

  @override
  State<AssignmentSubmissionWidget> createState() => _AssignmentSubmissionWidgetState();
}

class _AssignmentSubmissionWidgetState extends State<AssignmentSubmissionWidget> {
  final TextEditingController _submissionController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String? _selectedFile;
  bool _isSubmitting = false;
  bool _isSubmitted = false;

  @override
  void initState() {
    super.initState();
    _isSubmitted = widget.progress?.status == ProgressStatus.completed;
  }

  @override
  void dispose() {
    _submissionController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _selectFile() async {
    // In production, use file_picker package
    setState(() {
      _selectedFile = 'assignment_submission.pdf';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.attach_file_rounded, color: Colors.white, size: 18),
            const SizedBox(width: AppSpacing.sm),
            const Text('File attached successfully'),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _submitAssignment() async {
    final hasText = _submissionController.text.trim().isNotEmpty;
    final hasFile = _selectedFile != null;

    if (!hasText && !hasFile) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning_rounded, color: Colors.white, size: 18),
              const SizedBox(width: AppSpacing.sm),
              const Text('Add text or upload a file'),
            ],
          ),
          backgroundColor: AppColors.mimosaGold,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isSubmitting = false;
      _isSubmitted = true;
    });

    widget.onSubmissionComplete();
  }

  @override
  Widget build(BuildContext context) {
    if (_isSubmitted) {
      return _buildSubmittedState(context);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Submission form card
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppSpacing.borderRadiusLg,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.mimosaGold.withValues(alpha: 0.08),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.mimosaGold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.edit_document,
                        color: AppColors.mimosaGold,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Submission',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.neutral900,
                            ),
                          ),
                          Text(
                            'Write your response or upload a file',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.neutral500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Text input area
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text field
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.neutral50,
                        borderRadius: AppSpacing.borderRadiusMd,
                        border: Border.all(color: AppColors.neutral200),
                      ),
                      child: TextField(
                        controller: _submissionController,
                        focusNode: _focusNode,
                        maxLines: 8,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.6,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Write your answer here...',
                          hintStyle: TextStyle(color: AppColors.neutral400),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(AppSpacing.md),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Divider with "OR"
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                          child: Text(
                            'OR',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.neutral400,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // File upload area
                    if (_selectedFile == null)
                      _buildFileUploadButton(context)
                    else
                      _buildSelectedFile(context),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        // Submit button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton.icon(
            onPressed: _isSubmitting ? null : _submitAssignment,
            icon: _isSubmitting
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  )
                : const Icon(Icons.send_rounded, size: 20),
            label: Text(
              _isSubmitting ? 'Submitting...' : 'Submit Assignment',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.mimosaGold,
              disabledBackgroundColor: AppColors.mimosaGold.withValues(alpha: 0.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFileUploadButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _selectFile,
        borderRadius: AppSpacing.borderRadiusMd,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.neutral300,
              style: BorderStyle.solid,
            ),
            borderRadius: AppSpacing.borderRadiusMd,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_upload_rounded,
                color: AppColors.neutral500,
                size: 24,
              ),
              const SizedBox(width: AppSpacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Upload a file',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.neutral700,
                    ),
                  ),
                  Text(
                    'PDF, DOC, DOCX up to 10MB',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedFile(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.08),
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.description_rounded,
              color: AppColors.success,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedFile!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Ready to submit',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.close_rounded,
              color: AppColors.neutral500,
              size: 20,
            ),
            onPressed: () {
              setState(() => _selectedFile = null);
            },
            style: IconButton.styleFrom(
              backgroundColor: AppColors.neutral100,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmittedState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.success,
            AppColors.success.withValues(alpha: 0.85),
          ],
        ),
        borderRadius: AppSpacing.borderRadiusLg,
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Success icon
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              size: 48,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          
          Text(
            'Submitted!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Your assignment has been received',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          
          // Submission details
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: AppSpacing.borderRadiusSm,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: 16,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Submitted just now',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
