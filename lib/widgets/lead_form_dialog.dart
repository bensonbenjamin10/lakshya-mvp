import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lakshya_mvp/providers/lead_provider.dart';
import 'package:lakshya_mvp/models/lead.dart';
import 'package:lakshya_mvp/theme/theme.dart';

class LeadFormDialog extends StatefulWidget {
  final String? courseId;
  final InquiryType inquiryType;

  const LeadFormDialog({
    super.key,
    this.courseId,
    required this.inquiryType,
  });

  @override
  State<LeadFormDialog> createState() => _LeadFormDialogState();
}

class _LeadFormDialogState extends State<LeadFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _countryController = TextEditingController();
  final _messageController = TextEditingController();
  LeadSource _selectedSource = LeadSource.website;

  String get _dialogTitle {
    switch (widget.inquiryType) {
      case InquiryType.enrollment:
        return 'Enroll Now';
      case InquiryType.courseInquiry:
        return 'Course Inquiry';
      case InquiryType.brochureRequest:
        return 'Request Brochure';
      case InquiryType.generalContact:
        return 'Contact Us';
    }
  }

  String get _dialogSubtitle {
    switch (widget.inquiryType) {
      case InquiryType.enrollment:
        return 'Fill in your details to start your journey';
      case InquiryType.courseInquiry:
        return 'We\'ll get back to you within 24 hours';
      case InquiryType.brochureRequest:
        return 'Get our detailed course brochure';
      case InquiryType.generalContact:
        return 'We\'d love to hear from you';
    }
  }

  IconData get _dialogIcon {
    switch (widget.inquiryType) {
      case InquiryType.enrollment:
        return Icons.school_rounded;
      case InquiryType.courseInquiry:
        return Icons.help_outline_rounded;
      case InquiryType.brochureRequest:
        return Icons.description_outlined;
      case InquiryType.generalContact:
        return Icons.mail_outline_rounded;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _countryController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final leadProvider = Provider.of<LeadProvider>(context, listen: false);

    final lead = Lead(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      country: _countryController.text.trim().isEmpty
          ? null
          : _countryController.text.trim(),
      inquiryType: widget.inquiryType,
      courseId: widget.courseId,
      message: _messageController.text.trim().isEmpty
          ? null
          : _messageController.text.trim(),
      source: _selectedSource,
      createdAt: DateTime.now(),
    );

    final success = await leadProvider.submitLead(lead);

    if (mounted) {
      if (success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: AppSpacing.sm),
                const Expanded(
                  child: Text('Thank you! We\'ll get back to you soon.'),
                ),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: AppSpacing.borderRadiusSm,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: AppSpacing.sm),
                const Expanded(
                  child: Text('Something went wrong. Please try again.'),
                ),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: AppSpacing.borderRadiusSm,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? AppSpacing.lg : AppSpacing.massive,
        vertical: AppSpacing.xxl,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadiusXl,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 480,
          maxHeight: screenSize.height * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(context),

            // Form Content
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(
                  isSmallScreen ? AppSpacing.lg : AppSpacing.xxl,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Name Field
                      _FormField(
                        controller: _nameController,
                        label: 'Full Name',
                        hint: 'Enter your full name',
                        icon: Icons.person_outline_rounded,
                        isRequired: true,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Email Field
                      _FormField(
                        controller: _emailController,
                        label: 'Email',
                        hint: 'Enter your email address',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        isRequired: true,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Phone Field
                      _FormField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        hint: 'Enter your phone number',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        isRequired: true,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Country Field
                      _FormField(
                        controller: _countryController,
                        label: 'Country',
                        hint: 'Enter your country',
                        icon: Icons.public_outlined,
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Source Dropdown
                      _buildSourceDropdown(context),
                      const SizedBox(height: AppSpacing.lg),

                      // Message Field
                      _FormField(
                        controller: _messageController,
                        label: 'Message',
                        hint: 'Any additional information or questions...',
                        icon: Icons.chat_bubble_outline_rounded,
                        maxLines: 3,
                      ),
                      const SizedBox(height: AppSpacing.xxl),

                      // Buttons
                      _buildButtons(context, isSmallScreen),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      child: Column(
        children: [
          // Close button
          Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: AppSpacing.borderRadiusFull,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: AppSpacing.iconSm,
                ),
              ),
            ),
          ),
          // Icon
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: AppSpacing.borderRadiusMd,
            ),
            child: Icon(
              _dialogIcon,
              color: Colors.white,
              size: AppSpacing.iconXl,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Title
          Text(
            _dialogTitle,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          // Subtitle
          Text(
            _dialogSubtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSourceDropdown(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How did you hear about us?',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.neutral700,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        DropdownButtonFormField<LeadSource>(
          value: _selectedSource,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.neutral500,
          ),
          dropdownColor: AppColors.neutral0,
          borderRadius: AppSpacing.borderRadiusSm,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.neutral900,
              ),
          decoration: InputDecoration(
            prefixIcon: Icon(
              _getSourceIcon(_selectedSource),
              color: AppColors.neutral500,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            border: OutlineInputBorder(
              borderRadius: AppSpacing.borderRadiusSm,
              borderSide: const BorderSide(color: AppColors.neutral300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppSpacing.borderRadiusSm,
              borderSide: const BorderSide(color: AppColors.neutral300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppSpacing.borderRadiusSm,
              borderSide:
                  const BorderSide(color: AppColors.classicBlue, width: 2),
            ),
            filled: true,
            fillColor: AppColors.neutral50,
          ),
          selectedItemBuilder: (context) {
            return LeadSource.values.map((source) {
              return Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _getSourceLabel(source),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              );
            }).toList();
          },
          items: LeadSource.values.map((source) {
            return DropdownMenuItem(
              value: source,
              child: Row(
                children: [
                  Icon(
                    _getSourceIcon(source),
                    size: AppSpacing.iconSm,
                    color: AppColors.neutral600,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(_getSourceLabel(source)),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedSource = value;
              });
            }
          },
        ),
      ],
    );
  }

  IconData _getSourceIcon(LeadSource source) {
    switch (source) {
      case LeadSource.website:
        return Icons.language_rounded;
      case LeadSource.socialMedia:
        return Icons.share_rounded;
      case LeadSource.referral:
        return Icons.people_rounded;
      case LeadSource.advertisement:
        return Icons.campaign_rounded;
      case LeadSource.other:
        return Icons.more_horiz_rounded;
    }
  }

  Widget _buildButtons(BuildContext context, bool isSmallScreen) {
    return Consumer<LeadProvider>(
      builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Submit Button
            SizedBox(
              height: AppSpacing.buttonHeightLg,
              child: ElevatedButton(
                onPressed: provider.isSubmitting ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.classicBlue,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.neutral300,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppSpacing.borderRadiusSm,
                  ),
                  elevation: 0,
                ),
                child: provider.isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.send_rounded, size: 20),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'Submit',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            // Cancel Button
            SizedBox(
              height: AppSpacing.buttonHeightMd,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.neutral600,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppSpacing.borderRadiusSm,
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.neutral600,
                      ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _getSourceLabel(LeadSource source) {
    switch (source) {
      case LeadSource.website:
        return 'Website';
      case LeadSource.socialMedia:
        return 'Social Media';
      case LeadSource.referral:
        return 'Referral';
      case LeadSource.advertisement:
        return 'Advertisement';
      case LeadSource.other:
        return 'Other';
    }
  }
}

/// Reusable form field widget with consistent styling
class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool isRequired;
  final String? Function(String?)? validator;

  const _FormField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.maxLines = 1,
    this.isRequired = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Row(
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.neutral700,
                  ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.error,
                    ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        // Input
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: Theme.of(context).textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.neutral400,
                ),
            prefixIcon: Icon(icon, color: AppColors.neutral500),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            border: OutlineInputBorder(
              borderRadius: AppSpacing.borderRadiusSm,
              borderSide: const BorderSide(color: AppColors.neutral300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppSpacing.borderRadiusSm,
              borderSide: const BorderSide(color: AppColors.neutral300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppSpacing.borderRadiusSm,
              borderSide:
                  const BorderSide(color: AppColors.classicBlue, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: AppSpacing.borderRadiusSm,
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: AppSpacing.borderRadiusSm,
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
            filled: true,
            fillColor: AppColors.neutral50,
          ),
          validator: validator,
        ),
      ],
    );
  }
}
