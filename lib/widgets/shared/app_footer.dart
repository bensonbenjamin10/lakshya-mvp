import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lakshya_mvp/theme/theme.dart';
import 'package:lakshya_mvp/widgets/lakshya_logo.dart';

/// Reusable app footer widget
class AppFooter extends StatelessWidget {
  final bool showSocialIcons;
  final bool showNavLinks;

  const AppFooter({
    super.key,
    this.showSocialIcons = true,
    this.showNavLinks = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.classicBlue10,
            Colors.white,
          ],
        ),
      ),
      child: Column(
        children: [
          // Brand logo
          const LakshyaLogo(height: 48),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Indian Institute of Commerce',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.classicBlue60,
                  fontWeight: FontWeight.w500,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          // Tagline
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.mimosaGold.withValues(alpha: 0.15),
              borderRadius: AppSpacing.borderRadiusFull,
            ),
            child: Text(
              'Excellence in Commerce Education',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.mimosaGold,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          if (showNavLinks) ...[
            const SizedBox(height: AppSpacing.xl),
            _buildNavLinks(context),
          ],
          if (showSocialIcons) ...[
            const SizedBox(height: AppSpacing.xl),
            _buildSocialIcons(context),
          ],
          const SizedBox(height: AppSpacing.xl),
          Divider(color: AppColors.classicBlue20, height: 1),
          const SizedBox(height: AppSpacing.md),
          Text(
            '© ${DateTime.now().year} Lakshya Institute. All rights reserved.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.neutral500,
                ),
          ),
          // Bottom padding for nav bar
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  Widget _buildNavLinks(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.lg,
      runSpacing: AppSpacing.sm,
      alignment: WrapAlignment.center,
      children: [
        _FooterLink(label: 'Home', onTap: () => context.go('/')),
        _FooterLink(label: 'Courses', onTap: () => context.go('/courses')),
        _FooterLink(label: 'About', onTap: () => context.go('/about')),
        _FooterLink(label: 'Contact', onTap: () => context.go('/contact')),
      ],
    );
  }

  Widget _buildSocialIcons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _SocialIcon(
          icon: Icons.language,
          onTap: () => _launchUrl('https://lakshyainstitute.com'),
          tooltip: 'Website',
        ),
        _SocialIcon(
          icon: Icons.email_outlined,
          onTap: () => context.go('/contact'),
          tooltip: 'Email',
        ),
        _SocialIcon(
          icon: Icons.phone_outlined,
          onTap: () => _launchUrl('tel:+91XXXXXXXXXX'),
          tooltip: 'Call',
        ),
      ],
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
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
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.classicBlue,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  const _SocialIcon({
    required this.icon,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Tooltip(
        message: tooltip,
        child: IconButton(
          onPressed: onTap,
          icon: Icon(icon, color: AppColors.classicBlue),
          style: IconButton.styleFrom(
            backgroundColor: AppColors.classicBlue.withValues(alpha: 0.1),
            padding: const EdgeInsets.all(AppSpacing.md),
          ),
        ),
      ),
    );
  }
}

