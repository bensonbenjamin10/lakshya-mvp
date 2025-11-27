import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Lakshya'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About Lakshya Institute',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 24),
            Text(
              'Our Mission',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            Text(
              'Lakshya Institute is a leading educational institution dedicated to delivering excellence in commerce professional courses globally. We are committed to empowering students with world-class qualifications and skills that drive successful careers.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            Text(
              'What We Offer',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            _AboutItem(
              icon: Icons.school,
              title: 'ACCA',
              description: 'Association of Chartered Certified Accountants - Globally recognized accounting qualification',
            ),
            _AboutItem(
              icon: Icons.account_balance,
              title: 'CA',
              description: 'Chartered Accountancy - Premier accounting qualification in India',
            ),
            _AboutItem(
              icon: Icons.business_center,
              title: 'CMA (US)',
              description: 'Certified Management Accountant - Leading US management accounting certification',
            ),
            _AboutItem(
              icon: Icons.workspace_premium,
              title: 'Integrated B.Com & MBA',
              description: 'Dual degree program combining commerce and business management',
            ),
            const SizedBox(height: 32),
            Text(
              'Why Choose Us',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            const _AboutItem(
              icon: Icons.star,
              title: 'Excellence',
              description: 'Proven track record of student success and high pass rates',
            ),
            const _AboutItem(
              icon: Icons.people,
              title: 'Expert Faculty',
              description: 'Learn from industry experts and experienced professionals',
            ),
            const _AboutItem(
              icon: Icons.public,
              title: 'Global Reach',
              description: 'Serving students worldwide with flexible learning options',
            ),
            const _AboutItem(
              icon: Icons.work,
              title: 'Career Support',
              description: 'Comprehensive placement assistance and career guidance',
            ),
          ],
        ),
      ),
    );
  }
}

class _AboutItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _AboutItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

