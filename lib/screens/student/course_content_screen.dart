import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lakshya_mvp/providers/student_provider.dart';
import 'package:lakshya_mvp/providers/course_provider.dart';
import 'package:lakshya_mvp/widgets/shared/loading_state.dart';
import 'package:lakshya_mvp/widgets/shared/error_state.dart';
import 'package:lakshya_mvp/theme/theme.dart';

/// Course content screen showing modules for an enrolled course
class CourseContentScreen extends StatelessWidget {
  final String courseId;

  const CourseContentScreen({
    super.key,
    required this.courseId,
  });

  @override
  Widget build(BuildContext context) {
    final studentProvider = Provider.of<StudentProvider>(context);
    final courseProvider = Provider.of<CourseProvider>(context);
    final enrollment = studentProvider.getEnrollmentByCourseId(courseId);
    final course = courseProvider.courses.firstWhere(
      (c) => c.id == courseId,
      orElse: () => courseProvider.courses.first,
    );

    if (enrollment == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Course Content')),
        body: const Center(
          child: Text('You are not enrolled in this course'),
        ),
      );
    }

    final progress = studentProvider.getProgressForEnrollment(enrollment.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(course.title),
      ),
      body: studentProvider.isLoading
          ? const LoadingState(message: 'Loading course content...')
          : studentProvider.error != null
              ? ErrorState(
                  message: studentProvider.error!,
                  onRetry: () => studentProvider.refresh(),
                )
              : _buildContent(context, enrollment, progress),
    );
  }

  Widget _buildContent(
    BuildContext context,
    dynamic enrollment,
    List<dynamic> progress,
  ) {
    // TODO: Load course modules from repository
    // For now, show placeholder
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course info card
          _buildCourseInfoCard(context, enrollment),
          const SizedBox(height: AppSpacing.xl),

          // Modules section
          Text(
            'Course Modules',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppSpacing.md),

          // TODO: Show actual modules when CourseModuleRepository is created
          const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xxl),
              child: Text('Course modules will be displayed here'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseInfoCard(BuildContext context, dynamic enrollment) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Progress',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppSpacing.md),
            // Progress indicator would go here
            Text(
              '${enrollment.progressPercentage.toStringAsFixed(0)}% Complete',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.classicBlue,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

