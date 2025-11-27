import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:lakshya_mvp/providers/course_provider.dart';
import 'package:lakshya_mvp/widgets/course_card.dart';
import 'package:lakshya_mvp/widgets/hero_section.dart';
import 'package:lakshya_mvp/widgets/features_section.dart';
import 'package:lakshya_mvp/widgets/testimonials_section.dart';
import 'package:lakshya_mvp/widgets/cta_section.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final courseProvider = Provider.of<CourseProvider>(context);
    final popularCourses = courseProvider.getPopularCourses();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 80,
            floating: true,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 2,
            flexibleSpace: FlexibleSpaceBar(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Lakshya',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => context.go('/courses'),
                child: const Text('Courses'),
              ),
              TextButton(
                onPressed: () => context.go('/about'),
                child: const Text('About'),
              ),
              TextButton(
                onPressed: () => context.go('/contact'),
                child: const Text('Contact'),
              ),
              const SizedBox(width: 8),
            ],
          ),

          // Hero Section
          const SliverToBoxAdapter(
            child: HeroSection(),
          ),

          // Popular Courses Section
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Popular Courses',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 320,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: popularCourses.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: CourseCard(
                            course: popularCourses[index],
                            onTap: () {
                              courseProvider.selectCourse(popularCourses[index]);
                              context.go('/course/${popularCourses[index].id}');
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: ElevatedButton(
                      onPressed: () => context.go('/courses'),
                      child: const Text('View All Courses'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Features Section
          const SliverToBoxAdapter(
            child: FeaturesSection(),
          ),

          // Testimonials Section
          const SliverToBoxAdapter(
            child: TestimonialsSection(),
          ),

          // CTA Section
          const SliverToBoxAdapter(
            child: CtaSection(),
          ),

          // Footer
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(24),
              color: Theme.of(context).colorScheme.primary,
              child: Column(
                children: [
                  Text(
                    'Lakshya Institute',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Leading Institute for Commerce Professional Courses',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () => context.go('/courses'),
                        child: const Text('Courses', style: TextStyle(color: Colors.white)),
                      ),
                      TextButton(
                        onPressed: () => context.go('/about'),
                        child: const Text('About', style: TextStyle(color: Colors.white)),
                      ),
                      TextButton(
                        onPressed: () => context.go('/contact'),
                        child: const Text('Contact', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '© 2024 Lakshya Institute. All rights reserved.',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

