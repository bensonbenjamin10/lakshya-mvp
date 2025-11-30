import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lakshya_mvp/theme/theme.dart';

/// OTP Verification Dialog for phone authentication
/// 
/// A Material Design 3 dialog with responsive sizing optimized for
/// mobile, tablet, and various screen densities.
class OtpVerificationDialog extends StatefulWidget {
  final String phoneNumber;
  final VoidCallback? onVerified;
  final VoidCallback? onCancel;

  const OtpVerificationDialog({
    super.key,
    required this.phoneNumber,
    this.onVerified,
    this.onCancel,
  });

  /// Show the OTP dialog and return true if verified successfully
  static Future<bool> show(
    BuildContext context, {
    required String phoneNumber,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: AppColors.neutral900.withValues(alpha: 0.6),
      builder: (context) => OtpVerificationDialog(phoneNumber: phoneNumber),
    );
    return result ?? false;
  }

  @override
  State<OtpVerificationDialog> createState() => _OtpVerificationDialogState();
}

class _OtpVerificationDialogState extends State<OtpVerificationDialog>
    with SingleTickerProviderStateMixin {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isVerifying = false;
  bool _isResending = false;
  String? _error;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _startResendCooldown();
    
    // Entry animation
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );
    _animationController.forward();
    
    // Auto-focus first field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    _cooldownTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _startResendCooldown() {
    setState(() => _resendCooldown = 60);
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCooldown > 0) {
        setState(() => _resendCooldown--);
      } else {
        timer.cancel();
      }
    });
  }

  String get _otpCode {
    return _controllers.map((c) => c.text).join();
  }

  bool get _isOtpComplete {
    return _otpCode.length == 6;
  }

  void _onOtpChanged(int index, String value) {
    if (value.length == 1 && index < 5) {
      // Move to next field
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      // Move to previous field on backspace
      _focusNodes[index - 1].requestFocus();
    }

    // Clear error when typing
    if (_error != null) {
      setState(() => _error = null);
    }

    // Auto-verify when complete
    if (_isOtpComplete) {
      _verifyOtp();
    }
  }

  void _handlePaste(String pastedText) {
    final digits = pastedText.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length >= 6) {
      for (int i = 0; i < 6; i++) {
        _controllers[i].text = digits[i];
      }
      _focusNodes[5].requestFocus();
      _verifyOtp();
    }
  }

  Future<void> _verifyOtp() async {
    if (!_isOtpComplete || _isVerifying) return;

    setState(() {
      _isVerifying = true;
      _error = null;
    });

    try {
      final response = await Supabase.instance.client.auth.verifyOTP(
        phone: widget.phoneNumber,
        token: _otpCode,
        type: OtpType.sms,
      );

      final hasSession = response.session != null || 
                         Supabase.instance.client.auth.currentSession != null;
      final currentUser = Supabase.instance.client.auth.currentUser;

      debugPrint('OTP Verify: response.session=${response.session != null}, '
          'currentSession=${Supabase.instance.client.auth.currentSession != null}, '
          'currentUser=${currentUser?.id}');

      if (hasSession || currentUser != null) {
        debugPrint('OTP Verification successful! User: ${currentUser?.id}');
        widget.onVerified?.call();
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } else {
        debugPrint('OTP Verification failed - no session');
        setState(() {
          _error = 'Verification failed. Please try again.';
          _clearOtp();
        });
      }
    } on AuthException catch (e) {
      debugPrint('OTP AuthException: ${e.message}');
      setState(() {
        _error = _getErrorMessage(e.message);
        _clearOtp();
      });
    } catch (e) {
      debugPrint('OTP Error: $e');
      setState(() {
        _error = 'An error occurred. Please try again.';
        _clearOtp();
      });
    } finally {
      if (mounted) {
        setState(() => _isVerifying = false);
      }
    }
  }

  String _getErrorMessage(String message) {
    if (message.contains('Invalid') || message.contains('invalid')) {
      return 'Invalid OTP. Please check and try again.';
    }
    if (message.contains('expired')) {
      return 'OTP has expired. Please request a new one.';
    }
    if (message.contains('rate') || message.contains('limit')) {
      return 'Too many attempts. Please wait before trying again.';
    }
    return message;
  }

  void _clearOtp() {
    for (final controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }

  Future<void> _resendOtp() async {
    if (_resendCooldown > 0 || _isResending) return;

    setState(() {
      _isResending = true;
      _error = null;
    });

    try {
      await Supabase.instance.client.auth.signInWithOtp(
        phone: widget.phoneNumber,
      );
      _startResendCooldown();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: AppSpacing.sm),
                Text('OTP sent successfully!'),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusSm),
          ),
        );
      }
    } on AuthException catch (e) {
      setState(() => _error = _getErrorMessage(e.message));
    } catch (e) {
      setState(() => _error = 'Failed to resend OTP. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final isCompact = screenWidth < 360;
    final isLandscape = screenWidth > screenHeight;
    
    // Responsive sizing
    final dialogWidth = isCompact 
        ? screenWidth * 0.95 
        : (screenWidth > 500 ? 400.0 : screenWidth * 0.88);
    
    final iconSize = isCompact ? 40.0 : 48.0;
    final otpBoxSize = isCompact ? 40.0 : (screenWidth > 400 ? 48.0 : 44.0);
    final otpFontSize = isCompact ? 20.0 : 24.0;
    final horizontalPadding = isCompact ? AppSpacing.lg : AppSpacing.xxl;
    final verticalPadding = isCompact ? AppSpacing.lg : AppSpacing.xl;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: isLandscape ? AppSpacing.lg : AppSpacing.xxl,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: dialogWidth,
            maxHeight: screenHeight * 0.9,
          ),
          child: Material(
            color: AppColors.surfaceContainerLowestLight,
            borderRadius: AppSpacing.borderRadiusXxl,
            elevation: 8,
            shadowColor: AppColors.classicBlue.withValues(alpha: 0.2),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalPadding,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header Icon with gradient background
                    _buildHeaderIcon(iconSize),
                    SizedBox(height: isCompact ? AppSpacing.lg : AppSpacing.xl),

                    // Title
                    Text(
                      'Verify Your Phone',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.neutral900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Subtitle with phone number
                    _buildSubtitle(context),
                    SizedBox(height: isCompact ? AppSpacing.xl : AppSpacing.xxl),

                    // OTP Input Grid
                    _buildOtpInput(otpBoxSize, otpFontSize),

                    // Error message
                    if (_error != null) ...[
                      const SizedBox(height: AppSpacing.lg),
                      _buildErrorMessage(context),
                    ],

                    SizedBox(height: isCompact ? AppSpacing.lg : AppSpacing.xl),

                    // Verify Button
                    _buildVerifyButton(),

                    const SizedBox(height: AppSpacing.lg),

                    // Resend section
                    _buildResendSection(context),

                    const SizedBox(height: AppSpacing.md),

                    // Cancel link
                    _buildCancelButton(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderIcon(double size) {
    return Container(
      width: size + AppSpacing.xxl,
      height: size + AppSpacing.xxl,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.classicBlue10,
            AppColors.ultramarine10,
          ],
        ),
        borderRadius: BorderRadius.circular(size),
        border: Border.all(
          color: AppColors.classicBlue20,
          width: 2,
        ),
      ),
      child: Center(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(size / 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.classicBlue.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            Icons.smartphone_rounded,
            size: size * 0.5,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildSubtitle(BuildContext context) {
    final maskedPhone = _maskPhoneNumber(widget.phoneNumber);
    return Column(
      children: [
        Text(
          'We\'ve sent a 6-digit code to',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.neutral600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: AppColors.classicBlue10,
            borderRadius: AppSpacing.borderRadiusSm,
          ),
          child: Text(
            maskedPhone,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.classicBlue,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOtpInput(double boxSize, double fontSize) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate optimal spacing based on available width
        final totalWidth = constraints.maxWidth;
        final totalBoxWidth = boxSize * 6;
        const gapWidth = AppSpacing.md; // Gap between groups of 3
        final availableSpacing = (totalWidth - totalBoxWidth - gapWidth) / 5;
        final spacing = availableSpacing.clamp(4.0, 10.0);

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // First 3 digits
            ...List.generate(3, (index) => _buildOtpBox(index, boxSize, fontSize, spacing)),
            
            // Center gap
            const SizedBox(width: gapWidth),
            
            // Last 3 digits
            ...List.generate(3, (index) => _buildOtpBox(index + 3, boxSize, fontSize, spacing)),
          ],
        );
      },
    );
  }

  Widget _buildOtpBox(int index, double size, double fontSize, double spacing) {
    final hasValue = _controllers[index].text.isNotEmpty;
    final hasFocus = _focusNodes[index].hasFocus;
    
    return Container(
      margin: EdgeInsets.only(
        right: (index == 2 || index == 5) ? 0 : spacing,
      ),
      child: SizedBox(
        width: size,
        height: size + 4, // Slightly taller for better touch target
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: _error != null
                ? AppColors.errorLight
                : hasFocus
                    ? AppColors.classicBlue10
                    : hasValue
                        ? AppColors.surfaceContainerLight
                        : AppColors.neutral50,
            borderRadius: AppSpacing.borderRadiusMd,
            border: Border.all(
              color: _error != null
                  ? AppColors.error
                  : hasFocus
                      ? AppColors.classicBlue
                      : hasValue
                          ? AppColors.classicBlue40
                          : AppColors.neutral200,
              width: hasFocus ? 2 : 1.5,
            ),
            boxShadow: hasFocus
                ? [
                    BoxShadow(
                      color: AppColors.classicBlue.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: _error != null ? AppColors.error : AppColors.neutral900,
              height: 1.2,
            ),
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(1),
            ],
            onChanged: (value) => _onOtpChanged(index, value),
            onTap: () {
              Clipboard.getData(Clipboard.kTextPlain).then((data) {
                if (data?.text != null && data!.text!.length >= 6) {
                  _handlePaste(data.text!);
                }
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _buildErrorMessage(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: AppSpacing.borderRadiusSm,
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 18,
            color: AppColors.error,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              _error!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.errorDark,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerifyButton() {
    return SizedBox(
      width: double.infinity,
      height: AppSpacing.buttonHeightLg,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: AppSpacing.borderRadiusMd,
          gradient: _isOtpComplete && !_isVerifying
              ? AppColors.primaryGradient
              : null,
          color: !_isOtpComplete || _isVerifying ? AppColors.neutral200 : null,
          boxShadow: _isOtpComplete && !_isVerifying
              ? [
                  BoxShadow(
                    color: AppColors.classicBlue.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: ElevatedButton(
          onPressed: _isOtpComplete && !_isVerifying ? _verifyOtp : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.transparent,
            disabledForegroundColor: AppColors.neutral500,
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: AppSpacing.borderRadiusMd,
            ),
          ),
          child: _isVerifying
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.neutral500,
                  ),
                )
              : const Text(
                  'Verify',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildResendSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Didn\'t receive the code? ',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.neutral600,
          ),
        ),
        if (_resendCooldown > 0)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.neutral100,
              borderRadius: AppSpacing.borderRadiusXs,
            ),
            child: Text(
              '${_resendCooldown}s',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.neutral600,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        else
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _resendOtp,
              borderRadius: AppSpacing.borderRadiusXs,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                child: Text(
                  _isResending ? 'Sending...' : 'Resend',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.classicBlue,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCancelButton(BuildContext context) {
    return TextButton(
      onPressed: () {
        widget.onCancel?.call();
        Navigator.of(context).pop(false);
      },
      style: TextButton.styleFrom(
        foregroundColor: AppColors.neutral600,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
      ),
      child: Text(
        'Cancel',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppColors.neutral600,
        ),
      ),
    );
  }

  String _maskPhoneNumber(String phone) {
    if (phone.length < 10) return phone;
    // Format: +91 98** **** 10
    final countryCode = phone.substring(0, 3);
    final first2 = phone.substring(3, 5);
    final last2 = phone.substring(phone.length - 2);
    return '$countryCode $first2** **** $last2';
  }
}
