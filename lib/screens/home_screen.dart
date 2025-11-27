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
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'L',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Lakshya',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
        actions: isMobile
            ? [
                IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    _showMobileMenu(context);
                  },
                ),
              ]
            : [
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
      drawer: isMobile ? _buildDrawer(context) : null,
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh courses
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Section
              const HeroSection(),

              // Popular Courses Section
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Popular Courses',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Start your journey with our top programs',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 340,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: popularCourses.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.only(
                              right: index < popularCourses.length - 1 ? 16 : 0,
                            ),
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
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => context.go('/courses'),
                        child: const Text('View All Courses'),
                      ),
                    ),
                  ],
                ),
              ),

              // Features Section
              const FeaturesSection(),

              // Testimonials Section
              const TestimonialsSection(),

              // CTA Section
              const CtaSection(),

              // Footer
              Container(
                padding: const EdgeInsets.all(24),
                color: Theme.of(context).colorScheme.primary,
                child: Column(
                  children: [
                    Text(
                      'Lakshya Institute',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Leading Institute for Commerce Professional Courses',
                      style: TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _FooterLink(
                          label: 'Courses',
                          onTap: () => context.go('/courses'),
                        ),
                        _FooterLink(
                          label: 'About',
                          onTap: () => context.go('/about'),
                        ),
                        _FooterLink(
                          label: 'Contact',
                          onTap: () => context.go('/contact'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      '© 2024 Lakshya Institute. All rights reserved.',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMobileMenu(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'L',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Lakshya Institute',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Commerce Professional Courses',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
              context.go('/');
            },
          ),
          ListTile(
            leading: const Icon(Icons.school),
            title: const Text('Courses'),
            onTap: () {
              Navigator.pop(context);
              context.go('/courses');
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About Us'),
            onTap: () {
              Navigator.pop(context);
              context.go('/about');
            },
          ),
          ListTile(
            leading: const Icon(Icons.contact_mail),
            title: const Text('Contact Us'),
            onTap: () {
              Navigator.pop(context);
              context.go('/contact');
            },
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.go('/contact');
              },
              child: const Text('Get Started'),
            ),
          ),
        ],
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _FooterLink({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      child: Text(
        label,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
