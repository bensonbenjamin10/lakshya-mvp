import 'package:flutter/material.dart';
import 'package:lakshya_mvp/models/course_module.dart';
import 'package:lakshya_mvp/models/student_progress.dart';
import 'package:lakshya_mvp/theme/theme.dart';

/// Assignment submission widget
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
    super.dispose();
  }

  Future<void> _selectFile() async {
    // In a real app, you'd use file_picker package
    setState(() {
      _selectedFile = 'assignment_submission.pdf';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('File selected: assignment_submission.pdf')),
    );
  }

  Future<void> _submitAssignment() async {
    if (_submissionController.text.trim().isEmpty && _selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a submission or upload a file')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isSubmitting = false;
      _isSubmitted = true;
    });

    widget.onSubmissionComplete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Assignment submitted successfully!'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isSubmitted) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.1),
          borderRadius: AppSpacing.borderRadiusMd,
          border: Border.all(color: AppColors.success),
        ),
        child: Column(
          children: [
            const Icon(Icons.check_circle, size: 64, color: AppColors.success),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Assignment Submitted',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Your assignment has been submitted successfully.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.neutral600,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Assignment instructions
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.mimosaGold.withValues(alpha: 0.1),
            borderRadius: AppSpacing.borderRadiusMd,
            border: Border.all(color: AppColors.mimosaGold.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.assignment, color: AppColors.mimosaGold),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Assignment Instructions',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.mimosaGold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                widget.module.description ?? 'Complete the assignment as described.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (widget.module.durationMinutes != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: AppColors.neutral600),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'Estimated time: ${widget.module.durationMinutes} minutes',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.neutral600,
                          ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        // Submission form
        Text(
          'Your Submission',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Text submission
        TextField(
          controller: _submissionController,
          maxLines: 10,
          decoration: InputDecoration(
            labelText: 'Write your submission here',
            hintText: 'Enter your assignment text...',
            border: OutlineInputBorder(
              borderRadius: AppSpacing.borderRadiusSm,
            ),
            filled: true,
            fillColor: AppColors.neutral50,
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // File upload
        OutlinedButton.icon(
          onPressed: _selectFile,
          icon: const Icon(Icons.attach_file),
          label: Text(_selectedFile ?? 'Upload File (PDF, DOC, DOCX)'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
          ),
        ),
        if (_selectedFile != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.neutral100,
              borderRadius: AppSpacing.borderRadiusSm,
            ),
            child: Row(
              children: [
                const Icon(Icons.insert_drive_file, color: AppColors.neutral600),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    _selectedFile!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () {
                    setState(() {
                      _selectedFile = null;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.xl),

        // Submit button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isSubmitting ? null : _submitAssignment,
            icon: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send),
            label: Text(_isSubmitting ? 'Submitting...' : 'Submit Assignment'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mimosaGold,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            ),
          ),
        ),
      ],
    );
  }
}

