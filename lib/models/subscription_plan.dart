// Subscription plan data model for LilyFit.
//
// Supports dual-currency pricing (USD + XAF/FCFA) for global and local markets.
// Features list is defined per tier to drive the UI without hardcoding in widgets.

enum PlanTier { lite }

enum BillingCycle { monthly, yearly }

class PlanPrice {
  /// Price in USD cents (e.g. 299 = $2.99)
  final int usdCents;

  /// Price in XAF/FCFA (e.g. 1794)
  final int xafFrancs;

  const PlanPrice({required this.usdCents, required this.xafFrancs});

  /// Formatted USD string, e.g. "$2.99"
  String get usdFormatted {
    final dollars = usdCents ~/ 100;
    final cents = usdCents % 100;
    return '\$$dollars.${cents.toString().padLeft(2, '0')}';
  }

  /// Formatted XAF string, e.g. "1,794 FCFA"
  String get xafFormatted {
    final formatted = _formatWithCommas(xafFrancs);
    return '$formatted FCFA';
  }

  /// Combined label, e.g. "$2.99 (1,794 FCFA)"
  String get combinedLabel => '$usdFormatted ($xafFormatted)';

  static String _formatWithCommas(int value) {
    final str = value.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write(',');
      buffer.write(str[i]);
    }
    return buffer.toString();
  }
}

class PlanFeature {
  final String label;
  final bool included;

  /// Optional detail shown after the label, e.g. "30 days" or "Up to 3"
  final String? detail;

  const PlanFeature({required this.label, required this.included, this.detail});
}

class SubscriptionPlan {
  final PlanTier tier;
  final String name;
  final String tagline;
  final PlanPrice monthlyPrice;
  final PlanPrice yearlyPrice;
  final List<PlanFeature> features;
  final bool isPopular;

  const SubscriptionPlan({
    required this.tier,
    required this.name,
    required this.tagline,
    required this.monthlyPrice,
    required this.yearlyPrice,
    required this.features,
    this.isPopular = false,
  });

  PlanPrice priceFor(BillingCycle cycle) =>
      cycle == BillingCycle.monthly ? monthlyPrice : yearlyPrice;

  /// Yearly savings compared to paying monthly for 12 months, as a percentage.
  int get yearlySavingsPercent {
    final monthlyTotal = monthlyPrice.usdCents * 12;
    final yearly = yearlyPrice.usdCents;
    if (monthlyTotal == 0) return 0;
    return (((monthlyTotal - yearly) / monthlyTotal) * 100).round();
  }
}

/// All available subscription plans. Single source of truth.
class SubscriptionPlans {
  static const List<SubscriptionPlan> all = [lite];

  static const SubscriptionPlan lite = SubscriptionPlan(
    tier: PlanTier.lite,
    name: 'Lite',
    tagline: 'Essential nutrition tracking',
    monthlyPrice: PlanPrice(usdCents: 299, xafFrancs: 1794),
    yearlyPrice: PlanPrice(usdCents: 2499, xafFrancs: 14994),
    features: [
      PlanFeature(label: 'Calorie & macro tracking', included: true),
      PlanFeature(label: 'Food database', included: true, detail: 'Limited'),
      PlanFeature(label: 'Water tracking', included: true),
      PlanFeature(label: 'Progress analytics', included: true, detail: 'Basic'),
      PlanFeature(label: 'Weight history', included: true, detail: '30 days'),
      PlanFeature(label: 'AI food scan', included: false),
      PlanFeature(label: 'Custom meal plans', included: false),
      PlanFeature(label: 'Export reports (PDF/CSV)', included: false),
      PlanFeature(label: 'Priority support', included: false),
      PlanFeature(label: 'Family profiles', included: false),
    ],
  );
}
