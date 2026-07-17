import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/subscription_plan.dart';
import '../../models/subscription_state.dart';
import '../../providers/subscription_provider.dart';
import 'plan_card.dart';
import 'payment_bottom_sheet.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late List<Animation<double>> _fadeAnims;
  late List<Animation<Offset>> _slideAnims;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnims = List.generate(6, (i) {
      final start = i * 0.08;
      final end = (start + 0.4).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animController,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });

    _slideAnims = List.generate(6, (i) {
      final start = i * 0.08;
      final end = (start + 0.4).clamp(0.0, 1.0);
      return Tween<Offset>(
        begin: const Offset(0, 0.25),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _animController,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        ),
      );
    });

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Widget _animated(int index, Widget child) => FadeTransition(
    opacity: _fadeAnims[index],
    child: SlideTransition(position: _slideAnims[index], child: child),
  );

  // ---------------------------------------------------------------------------
  // Start trial flow
  // ---------------------------------------------------------------------------
  Future<void> _onStartTrial(
    BuildContext context,
    SubscriptionPlan plan,
  ) async {
    final subProvider = context.read<SubscriptionProvider>();
    subProvider.selectTier(plan.tier);

    final result = await PaymentBottomSheet.show(
      context,
      plan: plan,
      billingCycle: subProvider.selectedCycle,
      provider: subProvider,
    );

    if (result == true && context.mounted) {
      _showSuccessDialog(context, plan);
    }
  }

  void _showSuccessDialog(BuildContext context, SubscriptionPlan plan) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        backgroundColor: isDark ? AppColors.darkCard : AppColors.card,
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Trial Started! 🎉',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your 7-day free trial on LilyFit ${plan.name} has begun. Enjoy all features — no charge today!',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // close dialog
                    Navigator.pop(context); // go back to previous screen
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Get Started',
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subProvider = context.watch<SubscriptionProvider>();
    final selectedCycle = subProvider.selectedCycle;
    final selectedTier = subProvider.selectedTier;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: Stack(
        children: [
          // ── Background aura blobs ────────────────────────────────────────
          Positioned(
            top: -120,
            right: -80,
            width: 350,
            height: 350,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: isDark ? 0.18 : 0.22),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 200,
            left: -100,
            width: 250,
            height: 250,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(
                      0xFF8B5CF6,
                    ).withValues(alpha: isDark ? 0.10 : 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            right: -60,
            width: 280,
            height: 280,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.secondary.withValues(alpha: isDark ? 0.08 : 0.10),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── Main content ─────────────────────────────────────────────────
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // App bar
                SliverToBoxAdapter(
                  child: _animated(
                    0,
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.arrow_back_ios_rounded,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.textPrimary,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const Spacer(),
                          if (subProvider.isOnTrial)
                            _TrialChip(
                              daysRemaining: subProvider.trialDaysRemaining,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Header
                SliverToBoxAdapter(
                  child: _animated(
                    1,
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Trial banner
                          _TrialBanner(isDark: isDark),
                          const SizedBox(height: 20),
                          Text(
                            'Choose your plan',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Upgrade to unlock the full LilyFit experience.\nPrices shown in USD and FCFA.',
                            style: GoogleFonts.nunito(
                              fontSize: 14,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Billing cycle toggle
                SliverToBoxAdapter(
                  child: _animated(
                    2,
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                      child: _BillingCycleToggle(
                        selectedCycle: selectedCycle,
                        isDark: isDark,
                        onChanged: (cycle) {
                          HapticFeedback.selectionClick();
                          context.read<SubscriptionProvider>().selectCycle(
                            cycle,
                          );
                        },
                      ),
                    ),
                  ),
                ),

                // Plan cards
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: Column(
                      children: SubscriptionPlans.all.asMap().entries.map((
                        entry,
                      ) {
                        final i = entry.key;
                        final plan = entry.value;
                        return _animated(
                          (i + 3).clamp(0, 5),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: PlanCard(
                              plan: plan,
                              billingCycle: selectedCycle,
                              isSelected: plan.tier == selectedTier,
                              isDark: isDark,
                              onSelect: () {
                                context.read<SubscriptionProvider>().selectTier(
                                  plan.tier,
                                );
                              },
                              onStartTrial: () => _onStartTrial(context, plan),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                // Active subscription status (shown if already subscribed)
                if (subProvider.isSubscribed)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                      child: _ActiveSubscriptionCard(
                        state: subProvider.state,
                        isDark: isDark,
                        onCancel: () async {
                          final confirmed = await _confirmCancel(context);
                          if (confirmed && context.mounted) {
                            await context
                                .read<SubscriptionProvider>()
                                .cancelSubscription();
                          }
                        },
                      ),
                    ),
                  ),

                // Footer
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                    child: Column(
                      children: [
                        const _FaqItem(
                          question: 'When will I be charged?',
                          answer:
                              'After your 7-day free trial. Cancel anytime before it ends — no charge.',
                        ),
                        const _FaqItem(
                          question: 'Can I change my plan?',
                          answer:
                              'Yes! You can upgrade or downgrade at any time. Changes take effect immediately.',
                        ),
                        const _FaqItem(
                          question: 'Is my payment secure?',
                          answer:
                              'Absolutely. All payments are processed through certified, PCI-compliant gateways.',
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'By subscribing you agree to our Terms of Service and Privacy Policy. '
                          'Subscriptions renew automatically until cancelled.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.nunito(
                            fontSize: 11,
                            color: isDark
                                ? AppColors.darkTextTertiary
                                : AppColors.textTertiary,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _confirmCancel(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Cancel Subscription?',
          style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'You will lose access to all premium features at the end of your billing period.',
          style: GoogleFonts.nunito(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep Plan'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Cancel Plan',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

// ---------------------------------------------------------------------------
// Trial banner
// ---------------------------------------------------------------------------

class _TrialBanner extends StatelessWidget {
  final bool isDark;
  const _TrialBanner({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.12),
            AppColors.primary.withValues(alpha: isDark ? 0.08 : 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.card_giftcard_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '7-Day Free Trial on All Plans',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  'Try risk-free · No credit card charged today',
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Billing cycle toggle
// ---------------------------------------------------------------------------

class _BillingCycleToggle extends StatelessWidget {
  final BillingCycle selectedCycle;
  final bool isDark;
  final ValueChanged<BillingCycle> onChanged;

  const _BillingCycleToggle({
    required this.selectedCycle,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.darkSurfaceMuted : AppColors.surfaceMuted;

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _CycleTab(
              label: 'Monthly',
              isSelected: selectedCycle == BillingCycle.monthly,
              isDark: isDark,
              onTap: () => onChanged(BillingCycle.monthly),
            ),
          ),
          Expanded(
            child: _CycleTab(
              label: 'Yearly',
              badge: 'Save 30%',
              isSelected: selectedCycle == BillingCycle.yearly,
              isDark: isDark,
              onTap: () => onChanged(BillingCycle.yearly),
            ),
          ),
        ],
      ),
    );
  }
}

class _CycleTab extends StatelessWidget {
  final String label;
  final String? badge;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _CycleTab({
    required this.label,
    this.badge,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.darkCardLight : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? (isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary)
                      : (isDark
                            ? AppColors.darkTextTertiary
                            : AppColors.textTertiary),
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    badge!,
                    style: GoogleFonts.nunito(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Active subscription card
// ---------------------------------------------------------------------------

class _ActiveSubscriptionCard extends StatelessWidget {
  final SubscriptionState state;
  final bool isDark;
  final VoidCallback onCancel;

  const _ActiveSubscriptionCard({
    required this.state,
    required this.isDark,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final isOnTrial = state.isOnTrial;
    final tierName = state.activeTier?.name ?? '';
    final daysLeft = state.trialDaysRemaining;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.success.withValues(alpha: isDark ? 0.15 : 0.08),
            AppColors.success.withValues(alpha: isDark ? 0.05 : 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isOnTrial ? Icons.hourglass_top_rounded : Icons.verified_rounded,
              color: AppColors.success,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOnTrial
                      ? 'Free Trial · LilyFit ${_capitalize(tierName)}'
                      : 'Active · LilyFit ${_capitalize(tierName)}',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.success,
                  ),
                ),
                Text(
                  isOnTrial
                      ? '$daysLeft day${daysLeft == 1 ? '' : 's'} remaining in trial'
                      : 'Subscription active',
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onCancel,
            child: Text(
              'Cancel',
              style: GoogleFonts.nunito(
                fontSize: 13,
                color: AppColors.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

// ---------------------------------------------------------------------------
// Trial chip (shown in app bar when on trial)
// ---------------------------------------------------------------------------

class _TrialChip extends StatelessWidget {
  final int daysRemaining;
  const _TrialChip({required this.daysRemaining});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer_rounded, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(
            '$daysRemaining day${daysRemaining == 1 ? '' : 's'} left',
            style: GoogleFonts.nunito(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// FAQ accordion
// ---------------------------------------------------------------------------

class _FaqItem extends StatefulWidget {
  final String question;
  final String answer;

  const _FaqItem({required this.question, required this.answer});

  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _expanded = !_expanded);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.question,
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: isDark
                        ? AppColors.darkTextTertiary
                        : AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox(width: double.infinity),
          secondChild: Padding(
            padding: const EdgeInsets.only(bottom: 12, left: 4, right: 4),
            child: Text(
              widget.answer,
              style: GoogleFonts.nunito(
                fontSize: 13,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
                height: 1.6,
              ),
            ),
          ),
          crossFadeState: _expanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
        Divider(
          height: 1,
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
      ],
    );
  }
}
