import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../models/subscription_plan.dart';
import '../../providers/subscription_provider.dart';

/// Bottom sheet that lets the user choose a payment method before confirming.
///
/// Designed to be payment-provider agnostic — add more [PaymentMethodOption]s
/// as you integrate real gateways.
class PaymentBottomSheet extends StatefulWidget {
  final SubscriptionPlan plan;
  final BillingCycle billingCycle;
  final SubscriptionProvider provider;

  const PaymentBottomSheet({
    super.key,
    required this.plan,
    required this.billingCycle,
    required this.provider,
  });

  /// Convenience helper to show the sheet.
  static Future<bool?> show(
    BuildContext context, {
    required SubscriptionPlan plan,
    required BillingCycle billingCycle,
    required SubscriptionProvider provider,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PaymentBottomSheet(
        plan: plan,
        billingCycle: billingCycle,
        provider: provider,
      ),
    );
  }

  @override
  State<PaymentBottomSheet> createState() => _PaymentBottomSheetState();
}

class _PaymentBottomSheetState extends State<PaymentBottomSheet>
    with SingleTickerProviderStateMixin {
  int? _selectedMethodIndex;
  bool _isProcessing = false;
  late AnimationController _sheetController;
  late Animation<double> _sheetAnimation;

  // ---------------------------------------------------------------------------
  // Payment method definitions
  // Add real gateway integrations here in future — just extend this list.
  // ---------------------------------------------------------------------------
  static const List<_PaymentMethod> _methods = [
    _PaymentMethod(
      id: 'card',
      label: 'Credit / Debit Card',
      subtitle: 'Visa, Mastercard, Verve',
      icon: Icons.credit_card_rounded,
      color: Color(0xFF2563EB),
      comingSoon: false,
    ),
    _PaymentMethod(
      id: 'mtn_momo',
      label: 'MTN Mobile Money',
      subtitle: 'Pay with MTN MoMo',
      icon: Icons.phone_android_rounded,
      color: Color(0xFFF59E0B),
      comingSoon: true,
    ),
    _PaymentMethod(
      id: 'orange_money',
      label: 'Orange Money',
      subtitle: 'Pay with Orange Money',
      icon: Icons.phone_android_rounded,
      color: Color(0xFFEA580C),
      comingSoon: true,
    ),
    _PaymentMethod(
      id: 'paypal',
      label: 'PayPal',
      subtitle: 'Fast & secure worldwide',
      icon: Icons.account_balance_wallet_rounded,
      color: Color(0xFF1D4ED8),
      comingSoon: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _sheetController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _sheetAnimation = CurvedAnimation(
      parent: _sheetController,
      curve: Curves.easeOutCubic,
    );
    _sheetController.forward();
  }

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    if (_selectedMethodIndex == null) return;
    if (_methods[_selectedMethodIndex!].comingSoon) return;

    HapticFeedback.mediumImpact();
    setState(() => _isProcessing = true);

    final success = await widget.provider.startFreeTrial(
      plan: widget.plan,
      billingCycle: widget.billingCycle,
    );

    if (!mounted) return;

    setState(() => _isProcessing = false);

    if (success) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.provider.errorMessage ?? 'Something went wrong.',
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkCard : AppColors.card;
    final price = widget.plan.priceFor(widget.billingCycle);
    final cycleLabel = widget.billingCycle == BillingCycle.monthly
        ? 'month'
        : 'year';

    return AnimatedBuilder(
      animation: _sheetAnimation,
      builder: (context, child) =>
          FractionallySizedBox(heightFactor: 0.9, child: child),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: bgColor.withValues(alpha: isDark ? 0.95 : 0.98),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(32),
              ),
              border: Border(
                top: BorderSide(
                  color: (isDark ? Colors.white : Colors.black).withValues(
                    alpha: 0.08,
                  ),
                  width: 1.5,
                ),
              ),
            ),
            child: Column(
              children: [
                // Drag handle
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.white : Colors.black).withValues(
                        alpha: 0.15,
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Text(
                          'Choose Payment Method',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '7-day free trial · then ${price.combinedLabel}/$cycleLabel',
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Plan summary pill
                        _PlanSummaryPill(
                          plan: widget.plan,
                          billingCycle: widget.billingCycle,
                          isDark: isDark,
                        ),

                        const SizedBox(height: 28),

                        Text(
                          'Payment Method',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                            letterSpacing: 0.5,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Payment methods list
                        ...List.generate(_methods.length, (i) {
                          final method = _methods[i];
                          final isSelected = _selectedMethodIndex == i;
                          return _PaymentMethodTile(
                            method: method,
                            isSelected: isSelected,
                            isDark: isDark,
                            onTap: method.comingSoon
                                ? null
                                : () {
                                    HapticFeedback.selectionClick();
                                    setState(() => _selectedMethodIndex = i);
                                  },
                          );
                        }),

                        const SizedBox(height: 32),

                        // Confirm CTA
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: AnimatedOpacity(
                            opacity:
                                _selectedMethodIndex != null &&
                                    !_methods[_selectedMethodIndex!].comingSoon
                                ? 1.0
                                : 0.45,
                            duration: const Duration(milliseconds: 200),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.35,
                                    ),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed:
                                    (_selectedMethodIndex != null &&
                                        !_methods[_selectedMethodIndex!]
                                            .comingSoon)
                                    ? (_isProcessing ? null : _confirm)
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                child: _isProcessing
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        'Start 7-Day Free Trial',
                                        style: GoogleFonts.nunito(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Fine print
                        Center(
                          child: Text(
                            'Cancel anytime before trial ends · No charge today',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.darkTextTertiary
                                  : AppColors.textTertiary,
                            ),
                          ),
                        ),
                      ],
                    ),
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

// ---------------------------------------------------------------------------
// Helper data class
// ---------------------------------------------------------------------------

class _PaymentMethod {
  final String id;
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool comingSoon;

  const _PaymentMethod({
    required this.id,
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.comingSoon,
  });
}

// ---------------------------------------------------------------------------
// Payment method tile
// ---------------------------------------------------------------------------

class _PaymentMethodTile extends StatelessWidget {
  final _PaymentMethod method;
  final bool isSelected;
  final bool isDark;
  final VoidCallback? onTap;

  const _PaymentMethodTile({
    required this.method,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isSelected
        ? AppColors.primary.withValues(alpha: 0.08)
        : (isDark ? AppColors.darkSurfaceMuted : AppColors.surfaceMuted);
    final borderColor = isSelected ? AppColors.primary : Colors.transparent;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: method.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(method.icon, color: method.color, size: 20),
            ),
            const SizedBox(width: 14),

            // Labels
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method.label,
                    style: GoogleFonts.nunito(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: onTap == null
                          ? (isDark
                                ? AppColors.darkTextTertiary
                                : AppColors.textTertiary)
                          : (isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary),
                    ),
                  ),
                  Text(
                    method.subtitle,
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.darkTextTertiary
                          : AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),

            // Coming soon badge or radio
            if (method.comingSoon)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Soon',
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondary,
                  ),
                ),
              )
            else
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: isSelected ? 6 : 2,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Plan summary pill inside bottom sheet
// ---------------------------------------------------------------------------

class _PlanSummaryPill extends StatelessWidget {
  final SubscriptionPlan plan;
  final BillingCycle billingCycle;
  final bool isDark;

  const _PlanSummaryPill({
    required this.plan,
    required this.billingCycle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final price = plan.priceFor(billingCycle);
    final cycleLabel = billingCycle == BillingCycle.monthly
        ? '/month'
        : '/year';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.primary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.25),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.star_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LilyFit ${plan.name}',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  ),
                ),
                Text(
                  '7-day free trial included',
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price.usdFormatted,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              Text(
                cycleLabel,
                style: GoogleFonts.nunito(
                  fontSize: 11,
                  color: isDark
                      ? AppColors.darkTextTertiary
                      : AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
