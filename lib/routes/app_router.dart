import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lakshya_mvp/screens/home_screen.dart';
import 'package:lakshya_mvp/screens/courses_screen.dart';
import 'package:lakshya_mvp/screens/course_detail_screen.dart';
import 'package:lakshya_mvp/screens/contact_screen.dart';
import 'package:lakshya_mvp/screens/about_screen.dart';
import 'package:lakshya_mvp/widgets/app_shell.dart';

/// App routing configuration using go_router with bottom navigation shell
class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      // Main shell with bottom navigation
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          // Home branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                name: 'home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          // Courses branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/courses',
                name: 'courses',
                builder: (context, state) => const CoursesScreen(),
              ),
            ],
          ),
          // About branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/about',
                name: 'about',
                builder: (context, state) => const AboutScreen(),
              ),
            ],
          ),
          // Contact branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/contact',
                name: 'contact',
                builder: (context, state) => const ContactScreen(),
              ),
            ],
          ),
        ],
      ),
      // Course detail - outside shell (full screen)
      GoRoute(
        path: '/course/:id',
        name: 'course-detail',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final courseId = state.pathParameters['id']!;
          return CourseDetailScreen(courseId: courseId);
        },
      ),
    ],
  );
}
