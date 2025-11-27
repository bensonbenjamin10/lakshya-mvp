import 'package:go_router/go_router.dart';
import 'package:lakshya_mvp/screens/home_screen.dart';
import 'package:lakshya_mvp/screens/courses_screen.dart';
import 'package:lakshya_mvp/screens/course_detail_screen.dart';
import 'package:lakshya_mvp/screens/contact_screen.dart';
import 'package:lakshya_mvp/screens/about_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/courses',
        name: 'courses',
        builder: (context, state) => const CoursesScreen(),
      ),
      GoRoute(
        path: '/course/:id',
        name: 'course-detail',
        builder: (context, state) {
          final courseId = state.pathParameters['id']!;
          return CourseDetailScreen(courseId: courseId);
        },
      ),
      GoRoute(
        path: '/contact',
        name: 'contact',
        builder: (context, state) => const ContactScreen(),
      ),
      GoRoute(
        path: '/about',
        name: 'about',
        builder: (context, state) => const AboutScreen(),
      ),
    ],
  );
}

