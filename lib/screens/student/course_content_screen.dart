import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:lakshya_mvp/providers/student_provider.dart';
import 'package:lakshya_mvp/providers/course_provider.dart';
import 'package:lakshya_mvp/models/enrollment.dart';
import 'package:lakshya_mvp/models/student_progress.dart';
import 'package:lakshya_mvp/models/course.dart';
import 'package:lakshya_mvp/widgets/shared/loading_state.dart';
import 'package:lakshya_mvp/widgets/shared/error_state.dart';
import 'package:lakshya_mvp/widgets/student/module_card.dart';
import 'package:lakshya_mvp/widgets/student/enrollment_badge.dart';
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
    Enrollment enrollment,
    List<StudentProgress> progress,
  ) {
    final studentProvider = Provider.of<StudentProvider>(context);
    final courseProvider = Provider.of<CourseProvider>(context);
    final course = courseProvider.courses.firstWhere(
      (c) => c.id == courseId,
      orElse: () => courseProvider.courses.first,
    );
    
    final modules = studentProvider.getModulesForCourse(courseId);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course info card
          _buildCourseInfoCard(context, enrollment, course),
          const SizedBox(height: AppSpacing.xl),

          // Modules section
          Text(
            'Course Modules',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppSpacing.md),

          if (modules.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xxl),
                child: Text('No modules available for this course yet.'),
              ),
            )
          else
            ...modules.map((module) {
              final moduleProgress = studentProvider.getModuleProgress(
                enrollment.id,
                module.id,
              );
              return ModuleCard(
                module: module,
                progress: moduleProgress,
                onTap: () {
                  context.push(
                    '/student/courses/$courseId/modules/${module.id}?enrollmentId=${enrollment.id}',
                  );
                },
              );
            }),
        ],
      ),
    );
  }

  Widget _buildCourseInfoCard(
    BuildContext context,
    Enrollment enrollment,
    Course course,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              course.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            EnrollmentBadge(enrollment: enrollment),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Your Progress',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            LinearProgressIndicator(
              value: enrollment.progressPercentage / 100,
              backgroundColor: AppColors.neutral200,
              color: AppColors.classicBlue,
              minHeight: 8,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${enrollment.progressPercentage.toStringAsFixed(0)}% Complete',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.neutral600,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

