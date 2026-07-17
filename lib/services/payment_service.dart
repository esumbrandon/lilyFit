// Payment service — abstract gateway architecture for LilyFit.
//
// HOW TO ADD A NEW PAYMENT PROVIDER:
//   1. Create a class that extends [PaymentGateway] (e.g. `StripeGateway`).
//   2. Implement all abstract methods.
//   3. Register it: `PaymentService.instance.useGateway(StripeGateway(...));`
//
// The rest of the app (UI, providers) only talks to [PaymentService] and
// never needs to know which gateway is active.

import '../models/subscription_plan.dart';
import '../models/subscription_state.dart';

// ---------------------------------------------------------------------------
// Result types
// ---------------------------------------------------------------------------

enum PaymentResultStatus { success, cancelled, failed, pending }

class PaymentResult {
  final PaymentResultStatus status;
  final String? subscriptionId;
  final String? errorMessage;

  const PaymentResult({
    required this.status,
    this.subscriptionId,
    this.errorMessage,
  });

  bool get isSuccess => status == PaymentResultStatus.success;

  factory PaymentResult.success(String subscriptionId) => PaymentResult(
    status: PaymentResultStatus.success,
    subscriptionId: subscriptionId,
  );

  factory PaymentResult.cancelled() =>
      const PaymentResult(status: PaymentResultStatus.cancelled);

  factory PaymentResult.failed(String message) =>
      PaymentResult(status: PaymentResultStatus.failed, errorMessage: message);
}

// ---------------------------------------------------------------------------
// User info passed to the gateway
// ---------------------------------------------------------------------------

class PaymentUserInfo {
  final String userId;
  final String? email;
  final String? displayName;

  const PaymentUserInfo({required this.userId, this.email, this.displayName});
}

// ---------------------------------------------------------------------------
// Abstract gateway interface
// ---------------------------------------------------------------------------

/// Implement this to integrate any payment provider.
abstract class PaymentGateway {
  /// Unique identifier for this gateway (e.g. "stripe", "momo", "orange_money")
  String get gatewayId;

  /// Human-readable display name (e.g. "Stripe", "MTN Mobile Money")
  String get displayName;

  /// Starts a free trial for [plan].
  /// Returns a [PaymentResult] with a subscription ID on success.
  Future<PaymentResult> startFreeTrial({
    required SubscriptionPlan plan,
    required BillingCycle billingCycle,
    required PaymentUserInfo user,
  });

  /// Creates a paid subscription for [plan] and [cycle].
  Future<PaymentResult> subscribe({
    required SubscriptionPlan plan,
    required BillingCycle billingCycle,
    required PaymentUserInfo user,
  });

  /// Cancels the subscription with [subscriptionId].
  Future<bool> cancelSubscription(String subscriptionId);

  /// Fetches the latest subscription status from the provider.
  Future<SubscriptionState> fetchSubscriptionStatus(String userId);
}

// ---------------------------------------------------------------------------
// Stub gateway — default until a real provider is integrated
// ---------------------------------------------------------------------------

/// No-op implementation used during development.
/// Simulates a successful free trial start.
class StubPaymentGateway implements PaymentGateway {
  @override
  String get gatewayId => 'stub';

  @override
  String get displayName => 'Demo (Stub)';

  @override
  Future<PaymentResult> startFreeTrial({
    required SubscriptionPlan plan,
    required BillingCycle billingCycle,
    required PaymentUserInfo user,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    final fakeId = 'stub_trial_${user.userId}_${plan.tier.name}';
    return PaymentResult.success(fakeId);
  }

  @override
  Future<PaymentResult> subscribe({
    required SubscriptionPlan plan,
    required BillingCycle billingCycle,
    required PaymentUserInfo user,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final fakeId = 'stub_sub_${user.userId}_${plan.tier.name}';
    return PaymentResult.success(fakeId);
  }

  @override
  Future<bool> cancelSubscription(String subscriptionId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return true;
  }

  @override
  Future<SubscriptionState> fetchSubscriptionStatus(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const SubscriptionState(status: SubscriptionStatus.free);
  }
}

// ---------------------------------------------------------------------------
// PaymentService singleton — the only object the app talks to
// ---------------------------------------------------------------------------

class PaymentService {
  PaymentService._();

  static final PaymentService instance = PaymentService._();

  PaymentGateway _gateway = StubPaymentGateway();

  /// The currently active gateway.
  PaymentGateway get activeGateway => _gateway;

  /// Register a new payment gateway at runtime.
  /// Call this during app initialisation once you have a real provider:
  ///   PaymentService.instance.useGateway(StripeGateway(apiKey: '...'));
  void useGateway(PaymentGateway gateway) {
    _gateway = gateway;
  }

  Future<PaymentResult> startFreeTrial({
    required SubscriptionPlan plan,
    required BillingCycle billingCycle,
    required PaymentUserInfo user,
  }) => _gateway.startFreeTrial(
    plan: plan,
    billingCycle: billingCycle,
    user: user,
  );

  Future<PaymentResult> subscribe({
    required SubscriptionPlan plan,
    required BillingCycle billingCycle,
    required PaymentUserInfo user,
  }) => _gateway.subscribe(plan: plan, billingCycle: billingCycle, user: user);

  Future<bool> cancelSubscription(String subscriptionId) =>
      _gateway.cancelSubscription(subscriptionId);

  Future<SubscriptionState> fetchSubscriptionStatus(String userId) =>
      _gateway.fetchSubscriptionStatus(userId);
}
