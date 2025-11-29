import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:lakshya_mvp/providers/student_provider.dart';
import 'package:lakshya_mvp/widgets/student/enrolled_course_card.dart';
import 'package:lakshya_mvp/widgets/shared/loading_state.dart';
import 'package:lakshya_mvp/widgets/shared/error_state.dart';
import 'package:lakshya_mvp/widgets/shared/empty_state.dart';
import 'package:lakshya_mvp/theme/theme.dart';

/// My Courses screen showing all enrolled courses
class MyCoursesScreen extends StatelessWidget {
  const MyCoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final studentProvider = Provider.of<StudentProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Courses'),
      ),
      body: RefreshIndicator(
        onRefresh: () => studentProvider.refresh(),
        child: studentProvider.isLoading
            ? const LoadingState(message: 'Loading your courses...')
            : studentProvider.error != null
                ? ErrorState(
                    message: studentProvider.error!,
                    onRetry: () => studentProvider.refresh(),
                  )
                : studentProvider.enrollments.isEmpty
                    ? EmptyState(
                        icon: Icons.school_outlined,
                        title: 'No Enrollments',
                        message: 'You haven\'t enrolled in any courses yet.',
                        actionLabel: 'Browse Courses',
                        onAction: () => context.go('/courses'),
                      )
                    : _buildCoursesList(context, studentProvider),
      ),
    );
  }

  Widget _buildCoursesList(
    BuildContext context,
    StudentProvider provider,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      itemCount: provider.enrollments.length,
      itemBuilder: (context, index) {
        final enrollment = provider.enrollments[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: EnrolledCourseCard(
            enrollment: enrollment,
            onTap: () {
              context.push('/student/courses/${enrollment.courseId}/content');
            },
          ),
        );
      },
    );
  }
}

