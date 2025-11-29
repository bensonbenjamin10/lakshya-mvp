import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:lakshya_mvp/providers/student_provider.dart';
import 'package:lakshya_mvp/providers/auth_provider.dart';
import 'package:lakshya_mvp/widgets/student/dashboard_stats_card.dart';
import 'package:lakshya_mvp/widgets/student/enrolled_course_card.dart';
import 'package:lakshya_mvp/widgets/shared/loading_state.dart';
import 'package:lakshya_mvp/widgets/shared/error_state.dart';
import 'package:lakshya_mvp/theme/theme.dart';

/// Student dashboard screen showing overview of enrolled courses and progress
class StudentDashboardScreen extends StatelessWidget {
  const StudentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final studentProvider = Provider.of<StudentProvider>(context);

    // Redirect to login if not authenticated
    if (!authProvider.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/login?redirect=/student/dashboard');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push('/student/profile'),
            tooltip: 'Profile',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => studentProvider.refresh(),
        child: studentProvider.isLoading
            ? const LoadingState(message: 'Loading your dashboard...')
            : studentProvider.error != null
                ? ErrorState(
                    message: studentProvider.error!,
                    onRetry: () => studentProvider.refresh(),
                  )
                : _buildContent(context, studentProvider),
      ),
    );
  }

  Widget _buildContent(BuildContext context, StudentProvider provider) {
    if (provider.enrollments.isEmpty) {
      return _buildEmptyState(context);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome section
          _buildWelcomeSection(context, provider),
          const SizedBox(height: AppSpacing.xl),

          // Statistics cards
          _buildStatisticsSection(context, provider),
          const SizedBox(height: AppSpacing.xl),

          // Enrolled courses section
          _buildEnrolledCoursesSection(context, provider),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(
    BuildContext context,
    StudentProvider provider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back!',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Continue your learning journey',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.neutral600,
              ),
        ),
      ],
    );
  }

  Widget _buildStatisticsSection(
    BuildContext context,
    StudentProvider provider,
  ) {
    return Row(
      children: [
        Expanded(
          child: DashboardStatsCard(
            title: 'Enrolled Courses',
            value: provider.totalCourses.toString(),
            icon: Icons.school_rounded,
            color: AppColors.classicBlue,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: DashboardStatsCard(
            title: 'Completed',
            value: provider.completedCourses.toString(),
            icon: Icons.check_circle_rounded,
            color: AppColors.success,
          ),
        ),
      ],
    );
  }

  Widget _buildEnrolledCoursesSection(
    BuildContext context,
    StudentProvider provider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'My Courses',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton(
              onPressed: () => context.push('/student/courses'),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        ...provider.enrollments.take(3).map((enrollment) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: EnrolledCourseCard(
              enrollment: enrollment,
              onTap: () {
                context.push('/student/courses/${enrollment.courseId}/content');
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.school_outlined,
            size: 64,
            color: AppColors.neutral400,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'No enrollments yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Browse courses and enroll to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.neutral600,
                ),
          ),
          const SizedBox(height: AppSpacing.xl),
          ElevatedButton.icon(
            onPressed: () => context.go('/courses'),
            icon: const Icon(Icons.explore_rounded),
            label: const Text('Browse Courses'),
          ),
        ],
      ),
    );
  }
}

