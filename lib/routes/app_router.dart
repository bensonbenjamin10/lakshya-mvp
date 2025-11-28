import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lakshya_mvp/screens/splash_screen.dart';
import 'package:lakshya_mvp/screens/home_screen.dart';
import 'package:lakshya_mvp/screens/courses_screen.dart';
import 'package:lakshya_mvp/screens/course_detail_screen.dart';
import 'package:lakshya_mvp/screens/contact_screen.dart';
import 'package:lakshya_mvp/screens/about_screen.dart';
import 'package:lakshya_mvp/screens/auth/login_screen.dart';
import 'package:lakshya_mvp/screens/auth/register_screen.dart';
import 'package:lakshya_mvp/screens/admin/admin_dashboard.dart';
import 'package:lakshya_mvp/screens/admin/leads_management.dart';
import 'package:lakshya_mvp/screens/admin/lead_detail.dart';
import 'package:lakshya_mvp/screens/admin/courses_management.dart';
import 'package:lakshya_mvp/screens/admin/videos_management.dart';
import 'package:lakshya_mvp/widgets/app_shell.dart';

/// App routing configuration using go_router with custom transitions
class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    routes: [
      // Splash Screen with fade transition
      GoRoute(
        path: '/splash',
        name: 'splash',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SplashScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
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
                pageBuilder: (context, state) => CustomTransitionPage(
                  key: state.pageKey,
                  child: const HomeScreen(),
                  transitionsBuilder: _fadeTransition,
                ),
              ),
            ],
          ),
          // Courses branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/courses',
                name: 'courses',
                pageBuilder: (context, state) => CustomTransitionPage(
                  key: state.pageKey,
                  child: const CoursesScreen(),
                  transitionsBuilder: _fadeTransition,
                ),
              ),
            ],
          ),
          // About branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/about',
                name: 'about',
                pageBuilder: (context, state) => CustomTransitionPage(
                  key: state.pageKey,
                  child: const AboutScreen(),
                  transitionsBuilder: _fadeTransition,
                ),
              ),
            ],
          ),
          // Contact branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/contact',
                name: 'contact',
                pageBuilder: (context, state) => CustomTransitionPage(
                  key: state.pageKey,
                  child: const ContactScreen(),
                  transitionsBuilder: _fadeTransition,
                ),
              ),
            ],
          ),
        ],
      ),
      // Course detail - outside shell with slide transition
      GoRoute(
        path: '/course/:id',
        name: 'course-detail',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final courseId = state.pathParameters['id']!;
          return CustomTransitionPage(
            key: state.pageKey,
            child: CourseDetailScreen(courseId: courseId),
            transitionsBuilder: _slideUpTransition,
          );
        },
      ),
      // Auth routes - outside shell
      GoRoute(
        path: '/login',
        name: 'login',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final redirect = state.uri.queryParameters['redirect'];
          return CustomTransitionPage(
            key: state.pageKey,
            child: LoginScreen(redirectPath: redirect),
            transitionsBuilder: _fadeTransition,
          );
        },
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final redirect = state.uri.queryParameters['redirect'];
          return CustomTransitionPage(
            key: state.pageKey,
            child: RegisterScreen(redirectPath: redirect),
            transitionsBuilder: _fadeTransition,
          );
        },
      ),
      // Admin routes - require authentication
      GoRoute(
        path: '/admin',
        name: 'admin',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const AdminDashboard(),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: '/admin/leads',
        name: 'admin-leads',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LeadsManagement(),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: '/admin/leads/:id',
        name: 'admin-lead-detail',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final leadId = state.pathParameters['id']!;
          return CustomTransitionPage(
            key: state.pageKey,
            child: LeadDetail(leadId: leadId),
            transitionsBuilder: _slideUpTransition,
          );
        },
      ),
      GoRoute(
        path: '/admin/courses',
        name: 'admin-courses',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const CoursesManagement(),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: '/admin/videos',
        name: 'admin-videos',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const VideosManagement(),
          transitionsBuilder: _fadeTransition,
        ),
      ),
    ],
  );

  /// Fade transition for tab navigation
  static Widget _fadeTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
      ),
      child: child,
    );
  }

  /// Slide up transition for detail pages
  static Widget _slideUpTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    );

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.1),
        end: Offset.zero,
      ).animate(curvedAnimation),
      child: FadeTransition(
        opacity: curvedAnimation,
        child: child,
      ),
    );
  }

}

/// Custom page transition with configurable duration
class AppPageTransition<T> extends CustomTransitionPage<T> {
  const AppPageTransition({
    required super.child,
    super.transitionDuration = const Duration(milliseconds: 300),
    super.reverseTransitionDuration = const Duration(milliseconds: 250),
    super.transitionsBuilder = _defaultTransition,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  static Widget _defaultTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
      ),
      child: child,
    );
  }
}
