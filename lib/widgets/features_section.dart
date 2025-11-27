import 'package:flutter/material.dart';

class FeaturesSection extends StatelessWidget {
  const FeaturesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final features = [
      {
        'icon': Icons.public,
        'title': 'Global Recognition',
        'description': 'Internationally recognized qualifications that open doors worldwide',
      },
      {
        'icon': Icons.school,
        'title': 'Expert Faculty',
        'description': 'Learn from industry experts and experienced professionals',
      },
      {
        'icon': Icons.work,
        'title': 'Career Support',
        'description': 'Comprehensive placement assistance and career guidance',
      },
      {
        'icon': Icons.schedule,
        'title': 'Flexible Learning',
        'description': 'Study at your own pace with online and offline options',
      },
      {
        'icon': Icons.people,
        'title': 'Strong Network',
        'description': 'Join a community of successful professionals',
      },
      {
        'icon': Icons.verified,
        'title': 'Certified Programs',
        'description': 'Accredited courses with industry-standard certifications',
      },
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      color: Colors.grey[50],
      child: Column(
        children: [
          Text(
            'Why Choose Lakshya?',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Your pathway to professional excellence',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 40),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
            ),
            itemCount: features.length,
            itemBuilder: (context, index) {
              final feature = features[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        feature['icon'] as IconData,
                        size: 48,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        feature['title'] as String,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        feature['description'] as String,
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

