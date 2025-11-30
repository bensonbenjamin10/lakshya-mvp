import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:lakshya_mvp/models/course.dart';
import 'package:lakshya_mvp/models/enrollment.dart';
import 'package:lakshya_mvp/providers/enrollment_provider.dart';
import 'package:lakshya_mvp/services/payment/payment_service.dart';
import 'package:lakshya_mvp/services/payment/interfaces/payment_request.dart';
import 'package:lakshya_mvp/services/paywall_service.dart';
import 'package:lakshya_mvp/theme/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Payment sheet widget for course checkout
/// 
/// Shows pricing, trial info, and payment options
class PaymentSheet extends StatefulWidget {
  final Course course;
  final Enrollment? enrollment;
  final VoidCallback? onPaymentSuccess;
  final VoidCallback? onTrialStarted;

  const PaymentSheet({
    super.key,
    required this.course,
    this.enrollment,
    this.onPaymentSuccess,
    this.onTrialStarted,
  });

  /// Show the payment sheet as a modal bottom sheet
  static Future<bool?> show(
    BuildContext context, {
    required Course course,
    Enrollment? enrollment,
    VoidCallback? onPaymentSuccess,
    VoidCallback? onTrialStarted,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PaymentSheet(
        course: course,
        enrollment: enrollment,
        onPaymentSuccess: onPaymentSuccess,
        onTrialStarted: onTrialStarted,
      ),
    );
  }

  @override
  State<PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends State<PaymentSheet> {
  bool _isProcessing = false;
  String? _error;
  PaymentPlan _selectedPlan = PaymentPlan.full;

  @override
  Widget build(BuildContext context) {
    final accessStatus = PaywallService.checkCourseAccess(
      course: widget.course,
      enrollment: widget.enrollment,
    );

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.neutral300,
                      borderRadius: AppSpacing.borderRadiusFull,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Course info
                _buildCourseInfo(context),
                const SizedBox(height: AppSpacing.xl),

                // Pricing section
                _buildPricingSection(context),
                const SizedBox(height: AppSpacing.lg),

                // Trial banner if available
                if (accessStatus.canStartTrial) ...[
                  _buildTrialBanner(context, accessStatus),
                  const SizedBox(height: AppSpacing.lg),
                ],

                // Payment plans (if not free)
                if (!widget.course.isFree && widget.course.price > 0) ...[
                  _buildPaymentPlans(context),
                  const SizedBox(height: AppSpacing.lg),
                ],

                // Error message
                if (_error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: AppSpacing.borderRadiusSm,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.error),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            _error!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.error,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],

                // Action buttons
                _buildActionButtons(context, accessStatus),
                const SizedBox(height: AppSpacing.md),

                // Secure payment badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.lock_outline,
                      size: 14,
                      color: AppColors.neutral500,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'Secure payment powered by Razorpay',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.neutral500,
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

  Widget _buildCourseInfo(BuildContext context) {
    return Row(
      children: [
        // Course icon
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.classicBlue.withValues(alpha: 0.1),
            borderRadius: AppSpacing.borderRadiusMd,
          ),
          child: const Icon(
            Icons.school_rounded,
            color: AppColors.classicBlue,
            size: 30,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.course.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                widget.course.categoryName,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral600,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPricingSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Column(
        children: [
          // Price display
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.course.isOnSale) ...[
                // Original price (struck through)
                Text(
                  widget.course.formattedPrice,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.neutral500,
                        decoration: TextDecoration.lineThrough,
                      ),
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
              // Effective price
              Text(
                widget.course.formattedEffectivePrice,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: widget.course.isFree
                          ? AppColors.success
                          : AppColors.neutral900,
                    ),
              ),
            ],
          ),
          // Discount badge
          if (widget.course.isOnSale) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: AppSpacing.borderRadiusFull,
              ),
              child: Text(
                '${widget.course.discountPercentage}% OFF',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ],
          // Course includes
          const SizedBox(height: AppSpacing.lg),
          const Divider(),
          const SizedBox(height: AppSpacing.md),
          _buildFeatureRow(Icons.access_time, 'Duration: ${widget.course.duration}'),
          _buildFeatureRow(Icons.signal_cellular_alt, 'Level: ${widget.course.level}'),
          _buildFeatureRow(Icons.verified, 'Certificate included'),
          _buildFeatureRow(Icons.support_agent, 'Lifetime access'),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.success),
          const SizedBox(width: AppSpacing.sm),
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.neutral700,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrialBanner(BuildContext context, AccessStatus status) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.classicBlue.withValues(alpha: 0.1),
            AppColors.ultramarine.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(
          color: AppColors.classicBlue.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.classicBlue.withValues(alpha: 0.2),
                  borderRadius: AppSpacing.borderRadiusSm,
                ),
                child: const Icon(
                  Icons.card_giftcard,
                  color: AppColors.classicBlue,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${status.trialDaysAvailable}-Day Free Trial',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.classicBlue,
                          ),
                    ),
                    Text(
                      'Try the course risk-free before you buy',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.neutral600,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentPlans(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Plan',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ...PaymentPlan.values.map((plan) => _buildPlanOption(context, plan)),
      ],
    );
  }

  Widget _buildPlanOption(BuildContext context, PaymentPlan plan) {
    final isSelected = _selectedPlan == plan;
    final price = widget.course.effectivePrice;
    final installmentPrice = price / plan.installmentCount;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedPlan = plan);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.classicBlue.withValues(alpha: 0.05)
              : Colors.white,
          borderRadius: AppSpacing.borderRadiusSm,
          border: Border.all(
            color: isSelected ? AppColors.classicBlue : AppColors.neutral300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? AppColors.classicBlue : AppColors.neutral400,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan.displayName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: isSelected ? FontWeight.bold : null,
                        ),
                  ),
                  if (plan != PaymentPlan.full)
                    Text(
                      '₹${installmentPrice.toStringAsFixed(0)}/month',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.neutral600,
                          ),
                    ),
                ],
              ),
            ),
            Text(
              '₹${price.toStringAsFixed(0)}',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? AppColors.classicBlue : null,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, AccessStatus accessStatus) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Start trial button (if available)
        if (accessStatus.canStartTrial) ...[
          SizedBox(
            height: AppSpacing.buttonHeightLg,
            child: OutlinedButton(
              onPressed: _isProcessing ? null : _startFreeTrial,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.classicBlue,
                side: const BorderSide(color: AppColors.classicBlue),
                shape: RoundedRectangleBorder(
                  borderRadius: AppSpacing.borderRadiusSm,
                ),
              ),
              child: _isProcessing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      'Start ${accessStatus.trialDaysAvailable}-Day Free Trial',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],

        // Pay now button
        if (!widget.course.isFree && widget.course.price > 0)
          SizedBox(
            height: AppSpacing.buttonHeightLg,
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _initiatePayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.classicBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: AppSpacing.borderRadiusSm,
                ),
              ),
              child: _isProcessing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.payment),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'Pay ${widget.course.formattedEffectivePrice}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
            ),
          ),
      ],
    );
  }

  Future<void> _startFreeTrial() async {
    setState(() {
      _isProcessing = true;
      _error = null;
    });

    try {
      final enrollmentProvider =
          Provider.of<EnrollmentProvider>(context, listen: false);

      // Start the free trial by updating the enrollment
      final success = await enrollmentProvider.startFreeTrial(
        courseId: widget.course.id,
        trialDays: widget.course.freeTrialDays,
      );

      if (mounted) {
        if (success) {
          widget.onTrialStarted?.call();
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Your ${widget.course.freeTrialDays}-day free trial has started!',
                    ),
                  ),
                ],
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          setState(() {
            _error = enrollmentProvider.error ?? 'Failed to start trial';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _initiatePayment() async {
    setState(() {
      _isProcessing = true;
      _error = null;
    });

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        setState(() {
          _error = 'Please log in to continue';
        });
        return;
      }

      final paymentService = PaymentService();
      await paymentService.initialize();

      final request = PaymentRequest(
        courseId: widget.course.id,
        courseName: widget.course.title,
        studentId: user.id,
        studentEmail: user.email ?? '',
        studentName: user.userMetadata?['full_name'] ?? 'Student',
        amount: widget.course.effectivePrice,
        currency: widget.course.currency,
        paymentPlan: _selectedPlan,
      );

      final result = await paymentService.initiatePayment(request);

      if (mounted) {
        if (result.success) {
          // Update enrollment payment status
          final enrollmentProvider =
              Provider.of<EnrollmentProvider>(context, listen: false);
          await enrollmentProvider.markPaymentComplete(widget.course.id);

          widget.onPaymentSuccess?.call();
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text('Payment successful! Welcome to the course.'),
                  ),
                ],
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          setState(() {
            _error = result.errorMessage ?? 'Payment failed';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
}

