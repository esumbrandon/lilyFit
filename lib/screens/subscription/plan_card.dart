import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../models/subscription_plan.dart';

/// Individual plan card shown on the subscription screen.
///
/// Shows: tier badge, tagline, price (USD + XAF), features checklist, and CTA.
class PlanCard extends StatelessWidget {
  final SubscriptionPlan plan;
  final BillingCycle billingCycle;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onSelect;
  final VoidCallback onStartTrial;

  const PlanCard({
    super.key,
    required this.plan,
    required this.billingCycle,
    required this.isSelected,
    required this.isDark,
    required this.onSelect,
    required this.onStartTrial,
  });

  Color get _tierColor {
    switch (plan.tier) {
      case PlanTier.lite:
        return const Color(0xFF0EA5E9); // sky blue
    }
  }

  List<Color> get _tierGradient {
    switch (plan.tier) {
      case PlanTier.lite:
        return [const Color(0xFF0EA5E9), const Color(0xFF0284C7)];
    }
  }

  IconData get _tierIcon {
    switch (plan.tier) {
      case PlanTier.lite:
        return Icons.bolt_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final price = plan.priceFor(billingCycle);
    final cycleLabel = billingCycle == BillingCycle.monthly
        ? '/month'
        : '/year';
    final borderColor = isSelected
        ? _tierColor
        : (isDark ? AppColors.darkBorder : AppColors.border);
    final cardBg = isDark ? AppColors.darkCard : AppColors.card;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onSelect();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor, width: isSelected ? 2.0 : 1.0),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _tierColor.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Card Header ──────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(23),
                ),
                gradient: LinearGradient(
                  colors: [
                    _tierColor.withValues(alpha: isDark ? 0.18 : 0.1),
                    _tierColor.withValues(alpha: isDark ? 0.06 : 0.03),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Tier icon badge
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: _tierGradient,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: _tierColor.withValues(alpha: 0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(_tierIcon, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              plan.name,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              plan.tagline,
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
                      // Popular badge
                      if (plan.isPopular)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Popular',
                            style: GoogleFonts.nunito(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Price display
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        price.usdFormatted,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          color: _tierColor,
                          height: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4, left: 4),
                        child: Text(
                          cycleLabel,
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.darkTextTertiary
                                : AppColors.textTertiary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // XAF price label
                  Text(
                    price.xafFormatted + cycleLabel,
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                  ),

                  // Yearly savings badge
                  if (billingCycle == BillingCycle.yearly)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.success.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          'Save ${plan.yearlySavingsPercent}% vs monthly',
                          style: GoogleFonts.nunito(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.success,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── Divider ──────────────────────────────────────────────────
            Divider(
              height: 1,
              color: isDark ? AppColors.darkBorder : AppColors.border,
            ),

            // ── Features ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                children: plan.features
                    .map((f) => _FeatureRow(feature: f, isDark: isDark))
                    .toList(),
              ),
            ),

            // ── CTA ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: SizedBox(
                height: 50,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _tierGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: _tierColor.withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      onStartTrial();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Start Free Trial',
                      style: GoogleFonts.nunito(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
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
// Feature row
// ---------------------------------------------------------------------------

class _FeatureRow extends StatelessWidget {
  final PlanFeature feature;
  final bool isDark;

  const _FeatureRow({required this.feature, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          // Check / Cross icon
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: feature.included
                  ? AppColors.success.withValues(alpha: 0.12)
                  : (isDark
                        ? AppColors.darkSurfaceMuted
                        : AppColors.surfaceMuted),
              shape: BoxShape.circle,
            ),
            child: Icon(
              feature.included ? Icons.check_rounded : Icons.close_rounded,
              size: 13,
              color: feature.included
                  ? AppColors.success
                  : (isDark
                        ? AppColors.darkTextTertiary
                        : AppColors.textTertiary),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              feature.detail != null
                  ? '${feature.label} · ${feature.detail}'
                  : feature.label,
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: feature.included
                    ? (isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary)
                    : (isDark
                          ? AppColors.darkTextTertiary
                          : AppColors.textTertiary),
                decoration: feature.included ? null : TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
