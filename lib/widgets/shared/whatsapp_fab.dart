import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lakshya_mvp/theme/theme.dart';

/// WhatsApp floating action button for quick contact
class WhatsAppFab extends StatefulWidget {
  final String phoneNumber;
  final String? prefilledMessage;
  final bool showLabel;
  final bool extended;
  final String? heroTag;

  const WhatsAppFab({
    super.key,
    required this.phoneNumber,
    this.prefilledMessage,
    this.showLabel = false,
    this.extended = false,
    this.heroTag,
  });

  @override
  State<WhatsAppFab> createState() => _WhatsAppFabState();
}

class _WhatsAppFabState extends State<WhatsAppFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  // WhatsApp green color
  static const Color whatsAppGreen = Color(0xFF25D366);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openWhatsApp() async {
    // Haptic feedback
    HapticFeedback.mediumImpact();

    String url = 'https://wa.me/${widget.phoneNumber}';
    if (widget.prefilledMessage != null) {
      url += '?text=${Uri.encodeComponent(widget.prefilledMessage!)}';
    }

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open WhatsApp'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.extended) {
      return _buildExtendedFab();
    }
    return _buildRegularFab();
  }

  Widget _buildRegularFab() {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: FloatingActionButton(
          heroTag: widget.heroTag ?? 'whatsapp_fab_${widget.phoneNumber}',
          onPressed: _openWhatsApp,
          backgroundColor: whatsAppGreen,
          foregroundColor: Colors.white,
          tooltip: 'Chat on WhatsApp',
          elevation: _isHovered ? 8 : 4,
          child: const Icon(Icons.chat_rounded, size: 26),
        ),
      ),
    );
  }

  Widget _buildExtendedFab() {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: FloatingActionButton.extended(
          heroTag: widget.heroTag ?? 'whatsapp_fab_extended_${widget.phoneNumber}',
          onPressed: _openWhatsApp,
          backgroundColor: whatsAppGreen,
          foregroundColor: Colors.white,
          elevation: _isHovered ? 8 : 4,
          icon: const Icon(Icons.chat_rounded),
          label: const Text(
            'Chat with us',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

/// WhatsApp button for inline use
class WhatsAppButton extends StatelessWidget {
  final String phoneNumber;
  final String? prefilledMessage;
  final String label;
  final bool outlined;
  final double? width;

  const WhatsAppButton({
    super.key,
    required this.phoneNumber,
    this.prefilledMessage,
    this.label = 'Chat on WhatsApp',
    this.outlined = false,
    this.width,
  });

  static const Color whatsAppGreen = Color(0xFF25D366);

  Future<void> _openWhatsApp(BuildContext context) async {
    HapticFeedback.mediumImpact();

    String url = 'https://wa.me/$phoneNumber';
    if (prefilledMessage != null) {
      url += '?text=${Uri.encodeComponent(prefilledMessage!)}';
    }

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (outlined) {
      return SizedBox(
        width: width,
        height: AppSpacing.buttonHeightMd,
        child: OutlinedButton.icon(
          onPressed: () => _openWhatsApp(context),
          style: OutlinedButton.styleFrom(
            foregroundColor: whatsAppGreen,
            side: const BorderSide(color: whatsAppGreen, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: AppSpacing.borderRadiusSm,
            ),
          ),
          icon: const Icon(Icons.chat_rounded, size: 20),
          label: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      );
    }

    return SizedBox(
      width: width,
      height: AppSpacing.buttonHeightMd,
      child: ElevatedButton.icon(
        onPressed: () => _openWhatsApp(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: whatsAppGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusSm,
          ),
        ),
        icon: const Icon(Icons.chat_rounded, size: 20),
        label: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

