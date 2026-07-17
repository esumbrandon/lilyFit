// Represents the current subscription state for a user.
//
// Designed to be serializable to/from JSON for SharedPreferences persistence
// and eventual Supabase sync.

import 'subscription_plan.dart';

enum SubscriptionStatus {
  /// No active plan — free tier / unsubscribed
  free,

  /// Within the 7-day free trial window
  trial,

  /// Actively paying subscriber
  active,

  /// Trial or subscription has expired
  expired,

  /// Subscription cancelled but still in paid period
  cancelled,
}

class SubscriptionState {
  final SubscriptionStatus status;
  final PlanTier? activeTier;
  final BillingCycle? billingCycle;

  /// When the trial or current billing period ends
  final DateTime? expiresAt;

  /// When the trial started (used to compute remaining trial days)
  final DateTime? trialStartedAt;

  /// Opaque ID returned by the payment provider
  final String? subscriptionId;

  /// Which payment gateway processed the subscription (e.g. "stripe", "momo")
  final String? gatewayId;

  const SubscriptionState({
    this.status = SubscriptionStatus.free,
    this.activeTier,
    this.billingCycle,
    this.expiresAt,
    this.trialStartedAt,
    this.subscriptionId,
    this.gatewayId,
  });

  bool get isFree => status == SubscriptionStatus.free;
  bool get isOnTrial => status == SubscriptionStatus.trial;
  bool get isActive =>
      status == SubscriptionStatus.active || status == SubscriptionStatus.trial;
  bool get isExpired => status == SubscriptionStatus.expired;

  int get trialDaysRemaining {
    if (trialStartedAt == null) return 0;
    final trialEnd = trialStartedAt!.add(const Duration(days: 7));
    final remaining = trialEnd.difference(DateTime.now()).inDays;
    return remaining.clamp(0, 7);
  }

  bool get trialIsExpired {
    if (trialStartedAt == null) return false;
    final trialEnd = trialStartedAt!.add(const Duration(days: 7));
    return DateTime.now().isAfter(trialEnd);
  }

  SubscriptionState copyWith({
    SubscriptionStatus? status,
    PlanTier? activeTier,
    BillingCycle? billingCycle,
    DateTime? expiresAt,
    DateTime? trialStartedAt,
    String? subscriptionId,
    String? gatewayId,
  }) {
    return SubscriptionState(
      status: status ?? this.status,
      activeTier: activeTier ?? this.activeTier,
      billingCycle: billingCycle ?? this.billingCycle,
      expiresAt: expiresAt ?? this.expiresAt,
      trialStartedAt: trialStartedAt ?? this.trialStartedAt,
      subscriptionId: subscriptionId ?? this.subscriptionId,
      gatewayId: gatewayId ?? this.gatewayId,
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status.name,
    'activeTier': activeTier?.name,
    'billingCycle': billingCycle?.name,
    'expiresAt': expiresAt?.toIso8601String(),
    'trialStartedAt': trialStartedAt?.toIso8601String(),
    'subscriptionId': subscriptionId,
    'gatewayId': gatewayId,
  };

  factory SubscriptionState.fromJson(Map<String, dynamic> json) {
    return SubscriptionState(
      status: SubscriptionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SubscriptionStatus.free,
      ),
      activeTier: json['activeTier'] != null
          ? PlanTier.values.firstWhere(
              (e) => e.name == json['activeTier'],
              orElse: () => PlanTier.lite,
            )
          : null,
      billingCycle: json['billingCycle'] != null
          ? BillingCycle.values.firstWhere(
              (e) => e.name == json['billingCycle'],
              orElse: () => BillingCycle.monthly,
            )
          : null,
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt'])
          : null,
      trialStartedAt: json['trialStartedAt'] != null
          ? DateTime.tryParse(json['trialStartedAt'])
          : null,
      subscriptionId: json['subscriptionId'],
      gatewayId: json['gatewayId'],
    );
  }
}
