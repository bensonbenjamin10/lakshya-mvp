import 'package:flutter/material.dart';
import 'package:lakshya_mvp/models/lead.dart';
import 'package:lakshya_mvp/widgets/lead_form_dialog.dart';
import 'package:lakshya_mvp/theme/theme.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Us'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.xxl),
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: AppSpacing.borderRadiusMd,
                    ),
                    child: const Icon(
                      Icons.support_agent_rounded,
                      size: AppSpacing.iconXxl,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Get in Touch',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'We\'d love to hear from you.\nOur team is always here to help.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Contact Information Section
                  Text(
                    'Contact Information',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Contact Cards Grid
                  _ContactCard(
                    icon: Icons.email_outlined,
                    title: 'Email Us',
                    content: 'info@lakshyainstitute.com',
                    color: AppColors.classicBlue,
                    onTap: () {},
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _ContactCard(
                    icon: Icons.phone_outlined,
                    title: 'Call Us',
                    content: '+91-XXXXX-XXXXX',
                    color: AppColors.success,
                    onTap: () {},
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _ContactCard(
                    icon: Icons.location_on_outlined,
                    title: 'Visit Us',
                    content: 'Global Delivery - Online & Offline',
                    color: AppColors.vivaMagenta,
                    onTap: () {},
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _ContactCard(
                    icon: Icons.access_time_rounded,
                    title: 'Working Hours',
                    content: 'Mon - Sat: 9AM - 6PM',
                    color: AppColors.mimosaGold,
                    onTap: () {},
                  ),

                  const SizedBox(height: AppSpacing.xxxl),

                  // Quick Actions Section
                  Text(
                    'Quick Actions',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  _ActionButton(
                    icon: Icons.chat_bubble_outline_rounded,
                    label: 'Send Message',
                    description: 'Get in touch with our team',
                    gradient: AppColors.primaryGradient,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => const LeadFormDialog(
                          inquiryType: InquiryType.generalContact,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _ActionButton(
                    icon: Icons.description_outlined,
                    label: 'Request Brochure',
                    description: 'Download course materials',
                    gradient: AppColors.accentGradient,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => const LeadFormDialog(
                          inquiryType: InquiryType.brochureRequest,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _ActionButton(
                    icon: Icons.school_outlined,
                    label: 'Course Inquiry',
                    description: 'Ask about our programs',
                    gradient: AppColors.ctaGradient,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => const LeadFormDialog(
                          inquiryType: InquiryType.courseInquiry,
                        ),
                      );
                    },
                  ),

                  // Bottom padding for navigation bar
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
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
  final Color color;
  final VoidCallback onTap;

  const _ContactCard({
    required this.icon,
    required this.title,
    required this.content,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadiusMd,
        side: BorderSide(color: AppColors.neutral200),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppSpacing.borderRadiusMd,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: AppSpacing.borderRadiusMd,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: AppSpacing.iconMd,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      content,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.neutral500,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.neutral400,
                size: AppSpacing.iconMd,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.description,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: AppSpacing.borderRadiusMd,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: AppSpacing.borderRadiusMd,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: AppSpacing.borderRadiusSm,
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: AppSpacing.iconMd,
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: AppSpacing.borderRadiusFull,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: AppSpacing.iconSm,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
