import 'package:flutter/material.dart';
import 'package:lakshya_mvp/models/lead.dart';
import 'package:lakshya_mvp/widgets/lead_form_dialog.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Us'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Get in Touch',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Have questions? We\'d love to hear from you. Send us a message and we\'ll respond as soon as possible.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 32),

            // Contact Information Cards
            Row(
              children: [
                Expanded(
                  child: _ContactCard(
                    icon: Icons.email,
                    title: 'Email',
                    content: 'info@lakshyainstitute.com',
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _ContactCard(
                    icon: Icons.phone,
                    title: 'Phone',
                    content: '+91-XXXXX-XXXXX',
                    onTap: () {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _ContactCard(
                    icon: Icons.location_on,
                    title: 'Address',
                    content: 'Global Delivery\nOnline & Offline',
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _ContactCard(
                    icon: Icons.access_time,
                    title: 'Hours',
                    content: 'Mon - Sat: 9AM - 6PM\nSunday: Closed',
                    onTap: () {},
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // Quick Actions
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => LeadFormDialog(
                        inquiryType: InquiryType.generalContact,
                      ),
                    );
                  },
                  icon: const Icon(Icons.message),
                  label: const Text('Send Message'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => LeadFormDialog(
                        inquiryType: InquiryType.brochureRequest,
                      ),
                    );
                  },
                  icon: const Icon(Icons.description),
                  label: const Text('Request Brochure'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => LeadFormDialog(
                        inquiryType: InquiryType.courseInquiry,
                      ),
                    );
                  },
                  icon: const Icon(Icons.school),
                  label: const Text('Course Inquiry'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final VoidCallback onTap;

  const _ContactCard({
    required this.icon,
    required this.title,
    required this.content,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(
                icon,
                size: 40,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                content,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

