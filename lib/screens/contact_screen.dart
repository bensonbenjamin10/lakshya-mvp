import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lakshya_mvp/models/lead.dart';
import 'package:lakshya_mvp/widgets/lead_form_dialog.dart';
import 'package:lakshya_mvp/widgets/shared/whatsapp_fab.dart';
import 'package:lakshya_mvp/theme/theme.dart';
import 'package:lakshya_mvp/config/app_config.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

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
            _buildHeader(context),

            Padding(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // WhatsApp Quick Contact - Highlighted
                  _buildWhatsAppSection(context),
                  
                  const SizedBox(height: AppSpacing.xxl),

                  // Contact Information Section
                  Text(
                    'Contact Information',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Contact Cards
                  _ContactCard(
                    icon: Icons.email_outlined,
                    title: 'Email Us',
                    content: 'info@lakshyainstitute.com',
                    color: AppColors.classicBlue,
                    onTap: () => _launchUrl('mailto:info@lakshyainstitute.com'),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _ContactCard(
                    icon: Icons.phone_outlined,
                    title: 'Call Us',
                    content: AppConfig.contactPhone,
                    color: AppColors.success,
                    onTap: () => _launchUrl('tel:+${AppConfig.whatsAppNumber}'),
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
                      HapticFeedback.lightImpact();
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
                      HapticFeedback.lightImpact();
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
                      HapticFeedback.lightImpact();
                      showDialog(
                        context: context,
                        builder: (context) => const LeadFormDialog(
                          inquiryType: InquiryType.courseInquiry,
                        ),
                      );
                    },
                  ),

                  // Bottom padding
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: const WhatsAppFab(
        phoneNumber: AppConfig.whatsAppNumber,
        prefilledMessage: AppConfig.whatsAppDefaultMessage,
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
            vertical: AppSpacing.xxxl,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                AppColors.classicBlue10,
              ],
            ),
          ),
          child: Column(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.classicBlue.withValues(alpha: 0.1),
                  borderRadius: AppSpacing.borderRadiusMd,
                ),
                child: const Icon(
                  Icons.support_agent_rounded,
                  size: AppSpacing.iconXl,
                  color: AppColors.classicBlue,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Get in Touch',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.neutral900,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'We\'d love to hear from you.\nOur team is always here to help.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.neutral600,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              // Response time badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: AppSpacing.borderRadiusFull,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 14,
                      color: AppColors.success,
                    ),
                    SizedBox(width: AppSpacing.xs),
                    Text(
                      'Usually responds within 24 hours',
                      style: TextStyle(
                        color: AppColors.success,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Golden accent
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topRight,
                radius: 1.0,
                colors: [
                  AppColors.mimosaGold.withValues(alpha: 0.25),
                  AppColors.mimosaGold.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWhatsAppSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF25D366), Color(0xFF128C7E)],
        ),
        borderRadius: AppSpacing.borderRadiusLg,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF25D366).withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            HapticFeedback.mediumImpact();
            final url = 'https://wa.me/${AppConfig.whatsAppNumber}?text=${Uri.encodeComponent(AppConfig.whatsAppContactMessage)}';
            final uri = Uri.parse(url);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
          borderRadius: AppSpacing.borderRadiusLg,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row with icon and badge
                Row(
                  children: [
                    // WhatsApp Icon
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: AppSpacing.borderRadiusMd,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.chat_rounded,
                        color: Color(0xFF25D366),
                        size: 28,
                      ),
                    ),
                    const Spacer(),
                    // Online badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: AppSpacing.borderRadiusFull,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          const Text(
                            'Online Now',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                // Title
                Text(
                  'Chat with us on WhatsApp',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: AppSpacing.xs),
                // Description
                Text(
                  'Get instant responses to your queries. Tap to start a conversation.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        height: 1.4,
                      ),
                ),
                const SizedBox(height: AppSpacing.lg),
                // CTA Row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: AppSpacing.borderRadiusFull,
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Start Chat',
                            style: TextStyle(
                              color: Color(0xFF128C7E),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(width: AppSpacing.sm),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: Color(0xFF128C7E),
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Response time
                    Text(
                      'Avg. reply: 5 min',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
        side: const BorderSide(color: AppColors.neutral200),
      ),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
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
              const Icon(
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
