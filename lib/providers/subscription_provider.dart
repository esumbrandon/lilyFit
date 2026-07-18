import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/subscription_plan.dart';
import '../models/subscription_state.dart';
import '../services/payment_service.dart';

class SubscriptionProvider extends ChangeNotifier {
  static const _prefKey = 'subscription_state';

  /// Expose the single Lite plan so widgets can read pricing without an extra import.
  static SubscriptionPlan get liteDetails => SubscriptionPlans.lite;

  SubscriptionState _state = const SubscriptionState();
  bool _isLoading = false;
  String? _errorMessage;

  // UI state — which plan the user is hovering/selecting on the paywall
  PlanTier _selectedTier = PlanTier.lite;
  BillingCycle _selectedCycle = BillingCycle.monthly;

  // Getters — subscription state
  SubscriptionState get state => _state;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  // Getters — UI state
  PlanTier get selectedTier => _selectedTier;
  BillingCycle get selectedCycle => _selectedCycle;
  SubscriptionPlan get selectedPlan =>
      SubscriptionPlans.all.firstWhere((p) => p.tier == _selectedTier);

  // Convenience getters
  bool get isSubscribed => _state.isActive;
  bool get isOnTrial => _state.isOnTrial;
  bool get isFree => _state.isFree;
  PlanTier? get activeTier => _state.activeTier;
  int get trialDaysRemaining => _state.trialDaysRemaining;

  /// True when the user has full access to all app features.
  /// Covers both the 7-day free trial period and an active paid subscription.
  bool get hasAccess => _state.isActive;

  // ---------------------------------------------------------------------------
  // Initialisation
  // ---------------------------------------------------------------------------

  Future<void> initialize() async {
    await _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefKey);
      if (raw != null) {
        final json = jsonDecode(raw) as Map<String, dynamic>;
        _state = SubscriptionState.fromJson(json);

        // Auto-expire trials that have passed their 7-day window
        if (_state.isOnTrial && _state.trialIsExpired) {
          _state = _state.copyWith(status: SubscriptionStatus.expired);
          await _saveToPrefs();
        }

        notifyListeners();
      }
    } catch (e) {
      debugPrint('[SubscriptionProvider] Failed to load prefs: $e');
    }
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, jsonEncode(_state.toJson()));
    } catch (e) {
      debugPrint('[SubscriptionProvider] Failed to save prefs: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // UI actions
  // ---------------------------------------------------------------------------

  void selectTier(PlanTier tier) {
    if (_selectedTier == tier) return;
    _selectedTier = tier;
    notifyListeners();
  }

  void selectCycle(BillingCycle cycle) {
    if (_selectedCycle == cycle) return;
    _selectedCycle = cycle;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Start free trial
  // ---------------------------------------------------------------------------

  Future<bool> startFreeTrial({
    required SubscriptionPlan plan,
    required BillingCycle billingCycle,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = _currentUserInfo();

      final result = await PaymentService.instance.startFreeTrial(
        plan: plan,
        billingCycle: billingCycle,
        user: user,
      );

      if (result.isSuccess) {
        final now = DateTime.now();
        _state = SubscriptionState(
          status: SubscriptionStatus.trial,
          activeTier: plan.tier,
          billingCycle: billingCycle,
          trialStartedAt: now,
          expiresAt: now.add(const Duration(days: 7)),
          subscriptionId: result.subscriptionId,
          gatewayId: PaymentService.instance.activeGateway.gatewayId,
        );
        await _saveToPrefs();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage =
            result.errorMessage ?? 'Failed to start trial. Please try again.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'An unexpected error occurred. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Subscribe (paid)
  // ---------------------------------------------------------------------------

  Future<bool> subscribe({
    required SubscriptionPlan plan,
    required BillingCycle billingCycle,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = _currentUserInfo();

      final result = await PaymentService.instance.subscribe(
        plan: plan,
        billingCycle: billingCycle,
        user: user,
      );

      if (result.isSuccess) {
        final now = DateTime.now();
        final expiresAt = billingCycle == BillingCycle.monthly
            ? now.add(const Duration(days: 30))
            : now.add(const Duration(days: 365));

        _state = SubscriptionState(
          status: SubscriptionStatus.active,
          activeTier: plan.tier,
          billingCycle: billingCycle,
          expiresAt: expiresAt,
          subscriptionId: result.subscriptionId,
          gatewayId: PaymentService.instance.activeGateway.gatewayId,
        );
        await _saveToPrefs();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage =
            result.errorMessage ?? 'Payment failed. Please try again.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'An unexpected error occurred. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Cancel
  // ---------------------------------------------------------------------------

  Future<bool> cancelSubscription() async {
    if (_state.subscriptionId == null) return false;

    _isLoading = true;
    notifyListeners();

    final success = await PaymentService.instance.cancelSubscription(
      _state.subscriptionId!,
    );

    if (success) {
      _state = _state.copyWith(status: SubscriptionStatus.cancelled);
      await _saveToPrefs();
    }

    _isLoading = false;
    notifyListeners();
    return success;
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  PaymentUserInfo _currentUserInfo() {
    final supabaseUser = Supabase.instance.client.auth.currentUser;
    return PaymentUserInfo(
      userId: supabaseUser?.id ?? 'anonymous',
      email: supabaseUser?.email,
      displayName: supabaseUser?.userMetadata?['full_name'] as String?,
    );
  }
}
