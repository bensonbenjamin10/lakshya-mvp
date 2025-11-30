import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lakshya_mvp/providers/lead_provider.dart';
import 'package:lakshya_mvp/providers/enrollment_provider.dart';
import 'package:lakshya_mvp/models/lead.dart';
import 'package:lakshya_mvp/theme/theme.dart';
import 'package:lakshya_mvp/widgets/auth/otp_verification_dialog.dart';
import 'package:lakshya_mvp/utils/phone_utils.dart';
import 'package:lakshya_mvp/services/profile_service.dart';

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

  // Real-time validation state
  String? _nameError;
  String? _emailError;
  String? _phoneError;
  bool _hasSubmitted = false;
  bool _isSendingOtp = false;

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
  void initState() {
    super.initState();
    // Add real-time validation listeners
    _nameController.addListener(_validateName);
    _emailController.addListener(_validateEmail);
    _phoneController.addListener(_validatePhone);
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

  void _validateName() {
    if (!_hasSubmitted) return;
    final value = _nameController.text;
    setState(() {
      if (value.trim().isEmpty) {
        _nameError = 'Please enter your name';
      } else if (value.trim().length < 2) {
        _nameError = 'Name must be at least 2 characters';
      } else {
        _nameError = null;
      }
    });
  }

  void _validateEmail() {
    if (!_hasSubmitted) return;
    final value = _emailController.text;
    setState(() {
      if (value.trim().isEmpty) {
        _emailError = 'Please enter your email';
      } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
        _emailError = 'Please enter a valid email';
      } else {
        _emailError = null;
      }
    });
  }

  void _validatePhone() {
    if (!_hasSubmitted) return;
    final value = _phoneController.text;
    setState(() {
      if (value.trim().isEmpty) {
        _phoneError = 'Please enter your phone number';
      } else if (!PhoneUtils.isValidIndianPhone(value)) {
        _phoneError = 'Please enter a valid 10-digit phone number';
      } else {
        _phoneError = null;
      }
    });
  }

  bool _validateAll() {
    _hasSubmitted = true;
    _validateName();
    _validateEmail();
    _validatePhone();
    return _nameError == null && _emailError == null && _phoneError == null;
  }

  Future<void> _submitForm() async {
    if (!_validateAll()) {
      HapticFeedback.heavyImpact();
      return;
    }

    HapticFeedback.mediumImpact();
    final leadProvider = Provider.of<LeadProvider>(context, listen: false);

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final country = _countryController.text.trim();

    // Create lead first
    final lead = Lead(
      id: '',
      name: name,
      email: email,
      phone: phone,
      country: country.isEmpty ? null : country,
      inquiryType: widget.inquiryType,
      courseId: widget.courseId,
      message: _messageController.text.trim().isEmpty
          ? null
          : _messageController.text.trim(),
      source: _selectedSource,
      createdAt: DateTime.now(),
    );

    final leadSuccess = await leadProvider.submitLead(lead);

    if (!mounted) return;

    if (!leadSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: AppSpacing.sm),
              Expanded(child: Text('Something went wrong. Please try again.')),
            ],
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusSm),
        ),
      );
      return;
    }

    // For enrollment inquiries, initiate OTP flow
    if (widget.inquiryType == InquiryType.enrollment && widget.courseId != null) {
      await _handleEnrollmentWithOtp(name, email, phone, country);
    } else {
      // For non-enrollment inquiries, just show thank you message
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: AppSpacing.sm),
              Expanded(child: Text('Thank you! We\'ll get back to you soon.')),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusSm),
        ),
      );
    }
  }

  Future<void> _handleEnrollmentWithOtp(
    String name,
    String email,
    String phone,
    String country,
  ) async {
    // Format phone to E.164
    final formattedPhone = PhoneUtils.formatToE164(phone);

    setState(() => _isSendingOtp = true);

    // Store references before any async operations
    final courseId = widget.courseId!;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final goRouter = GoRouter.of(context);
    final enrollmentProvider = Provider.of<EnrollmentProvider>(context, listen: false);

    try {
      // Send OTP
      await Supabase.instance.client.auth.signInWithOtp(
        phone: formattedPhone,
      );

      if (!mounted) return;
      setState(() => _isSendingOtp = false);

      // Show OTP verification dialog (keep this dialog open in background)
      final verified = await OtpVerificationDialog.show(
        context,
        phoneNumber: formattedPhone,
      );

      if (verified) {
        // OTP verified - user is now authenticated
        debugPrint('OTP verified! Creating enrollment for course: $courseId');
        
        // Close this dialog first
        if (mounted) {
          Navigator.of(context).pop();
        }

        // Create/update profile with form data
        final profileService = ProfileService();
        final profileUpdated = await profileService.upsertProfile(
          name: name,
          email: email,
          phone: formattedPhone,
          country: country.isEmpty ? null : country,
        );
        debugPrint('Profile upsert result: $profileUpdated');

        // Create enrollment
        debugPrint('Creating enrollment for user: ${Supabase.instance.client.auth.currentUser?.id}');
        final enrollment = await enrollmentProvider.enrollInCourse(
          courseId: courseId,
          paymentRequired: false,
        );
        debugPrint('Enrollment result: ${enrollment?.id}, error: ${enrollmentProvider.error}');

        if (enrollment != null) {
          // Success - navigate to course
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text('Welcome! You\'re now enrolled in the course.'),
                  ),
                ],
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusSm),
            ),
          );

          // Navigate to course content
          goRouter.push('/student/courses/$courseId/content');
        } else {
          // Enrollment failed
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(enrollmentProvider.error ?? 'Failed to enroll. Please try again.'),
                  ),
                ],
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusSm),
            ),
          );
        }
      } else {
        // OTP verification cancelled or failed - close dialog
        if (mounted) {
          Navigator.of(context).pop();
        }
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.white),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text('Verification cancelled. Your request has been saved.'),
                ),
              ],
            ),
            backgroundColor: AppColors.classicBlue,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusSm),
          ),
        );
      }
    } on AuthException catch (e) {
      setState(() => _isSendingOtp = false);
      
      String errorMessage = 'Failed to send OTP. Please try again.';
      if (e.message.contains('rate') || e.message.contains('limit')) {
        errorMessage = 'Too many attempts. Please wait a few minutes.';
      } else if (e.message.contains('invalid') || e.message.contains('Invalid')) {
        errorMessage = 'Invalid phone number. Please check and try again.';
      } else if (e.message.contains('provider') || e.message.contains('disabled') || e.message.contains('Unsupported')) {
        errorMessage = 'Phone verification is not configured. Please contact support.';
      }

      debugPrint('OTP Auth Error: ${e.message}');

      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(errorMessage)),
            ],
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
          shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusSm),
        ),
      );
    } catch (e) {
      setState(() => _isSendingOtp = false);
      debugPrint('OTP Error: $e');
      
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: AppSpacing.sm),
              Expanded(child: Text('Failed to send OTP. Please try again.')),
            ],
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusSm),
        ),
      );
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
                      // OTP info banner for enrollment
                      if (widget.inquiryType == InquiryType.enrollment) ...[
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.classicBlue.withValues(alpha: 0.05),
                            borderRadius: AppSpacing.borderRadiusSm,
                            border: Border.all(
                              color: AppColors.classicBlue.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.phone_android_rounded,
                                color: AppColors.classicBlue,
                                size: 20,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  'We\'ll send a verification code to your phone',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppColors.classicBlue,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                      ],

                      // Name Field
                      _FormField(
                        controller: _nameController,
                        label: 'Full Name',
                        hint: 'Enter your full name',
                        icon: Icons.person_outline_rounded,
                        isRequired: true,
                        errorText: _nameError,
                        textInputAction: TextInputAction.next,
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
                        errorText: _emailError,
                        textInputAction: TextInputAction.next,
                        suffixIcon: _emailError == null &&
                                _emailController.text.isNotEmpty &&
                                _hasSubmitted
                            ? const Icon(Icons.check_circle,
                                color: AppColors.success, size: 20)
                            : null,
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Phone Field with country code
                      _buildPhoneField(context),
                      const SizedBox(height: AppSpacing.lg),

                      // Country Field
                      _FormField(
                        controller: _countryController,
                        label: 'Country',
                        hint: 'Enter your country',
                        icon: Icons.public_outlined,
                        textInputAction: TextInputAction.next,
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
                        textInputAction: TextInputAction.done,
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

  Widget _buildPhoneField(BuildContext context) {
    final hasError = _phoneError != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Phone Number',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: hasError ? AppColors.error : AppColors.neutral700,
                  ),
            ),
            Text(
              ' *',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.error,
                  ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Country code prefix
            Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.neutral100,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppSpacing.radiusSm),
                  bottomLeft: Radius.circular(AppSpacing.radiusSm),
                ),
                border: Border.all(
                  color: hasError ? AppColors.error : AppColors.neutral300,
                ),
              ),
              child: Row(
                children: [
                  Text(
                    '🇮🇳',
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    '+91',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ),
            // Phone input
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(AppSpacing.radiusSm),
                    bottomRight: Radius.circular(AppSpacing.radiusSm),
                  ),
                  boxShadow: hasError
                      ? [
                          BoxShadow(
                            color: AppColors.error.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  style: Theme.of(context).textTheme.bodyLarge,
                  decoration: InputDecoration(
                    hintText: '98765 43210',
                    hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.neutral400,
                        ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(AppSpacing.radiusSm),
                        bottomRight: Radius.circular(AppSpacing.radiusSm),
                      ),
                      borderSide: BorderSide(
                        color: hasError ? AppColors.error : AppColors.neutral300,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(AppSpacing.radiusSm),
                        bottomRight: Radius.circular(AppSpacing.radiusSm),
                      ),
                      borderSide: BorderSide(
                        color: hasError ? AppColors.error : AppColors.neutral300,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(AppSpacing.radiusSm),
                        bottomRight: Radius.circular(AppSpacing.radiusSm),
                      ),
                      borderSide: BorderSide(
                        color: hasError ? AppColors.error : AppColors.classicBlue,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: hasError
                        ? AppColors.error.withValues(alpha: 0.05)
                        : AppColors.neutral50,
                  ),
                ),
              ),
            ),
          ],
        ),
        // Error message
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: hasError
              ? Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 14,
                        color: AppColors.error,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        _phoneError!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.error,
                            ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.vertical(
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
          initialValue: _selectedSource,
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
        final isLoading = provider.isSubmitting || _isSendingOtp;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Submit Button
            SizedBox(
              height: AppSpacing.buttonHeightLg,
              child: ElevatedButton(
                onPressed: isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.classicBlue,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.neutral300,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppSpacing.borderRadiusSm,
                  ),
                  elevation: 0,
                ),
                child: isLoading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            _isSendingOtp ? 'Sending OTP...' : 'Submitting...',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            widget.inquiryType == InquiryType.enrollment
                                ? Icons.phone_android_rounded
                                : Icons.send_rounded,
                            size: 20,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            widget.inquiryType == InquiryType.enrollment
                                ? 'Verify & Enroll'
                                : 'Submit',
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

/// Reusable form field widget with real-time validation
class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool isRequired;
  final String? errorText;
  final Widget? suffixIcon;
  final TextInputAction? textInputAction;

  const _FormField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.maxLines = 1,
    this.isRequired = false,
    this.errorText,
    this.suffixIcon,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Row(
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: hasError ? AppColors.error : AppColors.neutral700,
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
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: AppSpacing.borderRadiusSm,
            boxShadow: hasError
                ? [
                    BoxShadow(
                      color: AppColors.error.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            textInputAction: textInputAction,
            style: Theme.of(context).textTheme.bodyLarge,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.neutral400,
                  ),
              prefixIcon: Icon(
                icon,
                color: hasError ? AppColors.error : AppColors.neutral500,
              ),
              suffixIcon: suffixIcon,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              border: OutlineInputBorder(
                borderRadius: AppSpacing.borderRadiusSm,
                borderSide: BorderSide(
                  color: hasError ? AppColors.error : AppColors.neutral300,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppSpacing.borderRadiusSm,
                borderSide: BorderSide(
                  color: hasError ? AppColors.error : AppColors.neutral300,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppSpacing.borderRadiusSm,
                borderSide: BorderSide(
                  color: hasError ? AppColors.error : AppColors.classicBlue,
                  width: 2,
                ),
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
              fillColor: hasError
                  ? AppColors.error.withValues(alpha: 0.05)
                  : AppColors.neutral50,
            ),
          ),
        ),
        // Error message with animation
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: hasError
              ? Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 14,
                        color: AppColors.error,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        errorText!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.error,
                            ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
