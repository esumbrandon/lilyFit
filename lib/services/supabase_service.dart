import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';

/// Service to interact with Supabase backend
class SupabaseService {
  // Get Supabase client instance
  final _supabase = Supabase.instance.client;

  // ============ AUTHENTICATION ============

  /// Sign up a new user with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name}, // Store name in user metadata
      );

      // Check if signup was successful
      if (response.user == null) {
        throw Exception('Signup failed: ${response.session}');
      }

      return response;
    } catch (e) {
      throw Exception('Signup error: ${e.toString()}');
    }
  }

  /// Sign in existing user
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Sign out current user
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  /// Get current user ID
  String? getCurrentUserId() {
    return _supabase.auth.currentUser?.id;
  }

  /// Get current user
  User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }

  /// Check if user is logged in
  bool isLoggedIn() {
    return _supabase.auth.currentUser != null;
  }

  /// Listen to auth state changes
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  /// Send password reset email
  Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }

  // ============ USER PROFILE ============

  /// Save or update user profile
  /// Note: email is auto-synced from auth.users by database trigger
  Future<void> saveUserProfile(UserProfile profile) async {
    final userId = getCurrentUserId();
    if (userId == null) {
      throw Exception(
        'No user logged in - please check your Supabase API key and ensure authentication is working',
      );
    }

    try {
      await _supabase.from('user_profiles').upsert({
        'id': userId,
        'name': profile.name,
        // email is auto-synced by database trigger - do not set manually
        'gender': profile.gender,
        'age': profile.age,
        'weight': profile.weight,
        'height': profile.height,
        'activity_level': profile.activityLevel,
        'goal': profile.goal,
        'target_calories': profile.targetCalories,
        'target_protein': profile.targetProtein,
        'target_carbs': profile.targetCarbs,
        'target_fat': profile.targetFat,
        'weight_unit': profile.weightUnit,
        'height_unit': profile.heightUnit,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to save profile: ${e.toString()}');
    }
  }

  /// Get user profile
  Future<UserProfile?> getUserProfile() async {
    final userId = getCurrentUserId();
    if (userId == null) return null;

    final response = await _supabase
        .from('user_profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (response == null) return null;

    return UserProfile(
      name: response['name'] ?? '',
      email: response['email'] ?? '',
      gender: response['gender'] ?? 'male',
      age: response['age'] ?? 25,
      weight: (response['weight'] as num?)?.toDouble() ?? 70,
      height: (response['height'] as num?)?.toDouble() ?? 170,
      activityLevel: response['activity_level'] ?? 'moderate',
      goal: response['goal'] ?? 'maintenance',
      targetCalories: (response['target_calories'] as num?)?.toDouble() ?? 2000,
      targetProtein: (response['target_protein'] as num?)?.toDouble() ?? 150,
      targetCarbs: (response['target_carbs'] as num?)?.toDouble() ?? 200,
      targetFat: (response['target_fat'] as num?)?.toDouble() ?? 67,
      weightUnit: response['weight_unit'] ?? 'kg',
      heightUnit: response['height_unit'] ?? 'cm',
    );
  }

  /// Check if user has a profile
  Future<bool> hasProfile() async {
    final profile = await getUserProfile();
    return profile != null;
  }

  // ============ WEIGHT TRACKING ============

  /// Log weight entry
  Future<void> logWeight({
    required double weight,
    required DateTime date,
  }) async {
    final userId = getCurrentUserId();
    if (userId == null) throw Exception('No user logged in');

    await _supabase.from('weight_logs').insert({
      'user_id': userId,
      'weight': weight,
      'date': date.toIso8601String().split('T')[0],
    });
  }

  /// Get weight history
  Future<List<Map<String, dynamic>>> getWeightHistory({
    int? limit,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final userId = getCurrentUserId();
    if (userId == null) return [];

    dynamic query = _supabase
        .from('weight_logs')
        .select()
        .eq('user_id', userId);

    if (startDate != null) {
      query = query.gte('date', startDate.toIso8601String().split('T')[0]);
    }

    if (endDate != null) {
      query = query.lte('date', endDate.toIso8601String().split('T')[0]);
    }

    query = query.order('date', ascending: true);

    if (limit != null) {
      query = query.limit(limit);
    }

    final response = await query;
    return List<Map<String, dynamic>>.from(response);
  }

  /// Delete weight entry
  Future<void> deleteWeightEntry(String id) async {
    await _supabase.from('weight_logs').delete().eq('id', id);
  }

  // ============ MEAL TRACKING ============

  /// Log a meal
  Future<void> logMeal({
    required String mealType,
    required String foodName,
    required double calories,
    required double protein,
    required double carbs,
    required double fat,
    required DateTime date,
    double? servings,
  }) async {
    final userId = getCurrentUserId();
    if (userId == null) throw Exception('No user logged in');

    await _supabase.from('meal_logs').insert({
      'user_id': userId,
      'meal_type': mealType,
      'food_name': foodName,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'servings': servings ?? 1.0,
      'date': date.toIso8601String().split('T')[0],
    });
  }

  /// Get meal logs for a specific date
  Future<List<Map<String, dynamic>>> getMealLogs(DateTime date) async {
    final userId = getCurrentUserId();
    if (userId == null) return [];

    final response = await _supabase
        .from('meal_logs')
        .select()
        .eq('user_id', userId)
        .eq('date', date.toIso8601String().split('T')[0])
        .order('created_at', ascending: true);

    return List<Map<String, dynamic>>.from(response);
  }

  /// Get meal logs within date range
  Future<List<Map<String, dynamic>>> getMealLogsInRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final userId = getCurrentUserId();
    if (userId == null) return [];

    final response = await _supabase
        .from('meal_logs')
        .select()
        .eq('user_id', userId)
        .gte('date', startDate.toIso8601String().split('T')[0])
        .lte('date', endDate.toIso8601String().split('T')[0])
        .order('date', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  /// Delete a meal log
  Future<void> deleteMealLog(String id) async {
    await _supabase.from('meal_logs').delete().eq('id', id);
  }

  // ============ WORKOUT TRACKING ============

  /// Log a workout
  Future<void> logWorkout({
    required String workoutName,
    required int duration,
    required double caloriesBurned,
    required DateTime date,
    String? notes,
  }) async {
    final userId = getCurrentUserId();
    if (userId == null) throw Exception('No user logged in');

    await _supabase.from('workout_logs').insert({
      'user_id': userId,
      'workout_name': workoutName,
      'duration': duration,
      'calories_burned': caloriesBurned,
      'notes': notes,
      'date': date.toIso8601String().split('T')[0],
    });
  }

  /// Get workout logs
  Future<List<Map<String, dynamic>>> getWorkoutLogs({
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    final userId = getCurrentUserId();
    if (userId == null) return [];

    dynamic query = _supabase
        .from('workout_logs')
        .select()
        .eq('user_id', userId);

    if (startDate != null) {
      query = query.gte('date', startDate.toIso8601String().split('T')[0]);
    }

    if (endDate != null) {
      query = query.lte('date', endDate.toIso8601String().split('T')[0]);
    }

    query = query.order('date', ascending: false);

    if (limit != null) {
      query = query.limit(limit);
    }

    final response = await query;
    return List<Map<String, dynamic>>.from(response);
  }

  /// Delete a workout log
  Future<void> deleteWorkoutLog(String id) async {
    await _supabase.from('workout_logs').delete().eq('id', id);
  }

  // ============ PAYMENT TRANSACTIONS ============

  /// Create a payment transaction record
  Future<String> createPaymentTransaction({
    required double amount,
    required String currency,
    required String status,
    String? paymentMethod,
    String? receiptUrl,
    Map<String, dynamic>? metadata,
  }) async {
    final userId = getCurrentUserId();
    if (userId == null) throw Exception('No user logged in');

    final response = await _supabase
        .from('payment_transactions')
        .insert({
          'user_id': userId,
          'amount': amount,
          'currency': currency,
          'status': status,
          'payment_method': paymentMethod,
          'receipt_url': receiptUrl,
          'metadata': metadata,
        })
        .select()
        .single();

    return response['id'];
  }

  /// Update payment transaction status
  Future<void> updatePaymentStatus({
    required String transactionId,
    required String status,
    String? receiptUrl,
  }) async {
    await _supabase
        .from('payment_transactions')
        .update({
          'status': status,
          'receipt_url': receiptUrl,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', transactionId);
  }

  /// Get user's payment transactions
  Future<List<Map<String, dynamic>>> getPaymentTransactions({
    int? limit,
  }) async {
    final userId = getCurrentUserId();
    if (userId == null) return [];

    var query = _supabase
        .from('payment_transactions')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    if (limit != null) {
      query = query.limit(limit);
    }

    final response = await query;
    return List<Map<String, dynamic>>.from(response);
  }

  // ============ WATER INTAKE ============

  /// Log water intake
  Future<void> logWaterIntake({
    required double amount,
    required DateTime date,
  }) async {
    final userId = getCurrentUserId();
    if (userId == null) throw Exception('No user logged in');

    await _supabase.from('water_logs').insert({
      'user_id': userId,
      'amount': amount,
      'date': date.toIso8601String().split('T')[0],
    });
  }

  /// Get water intake for a date
  Future<double> getWaterIntake(DateTime date) async {
    final userId = getCurrentUserId();
    if (userId == null) return 0.0;

    final response = await _supabase
        .from('water_logs')
        .select('amount')
        .eq('user_id', userId)
        .eq('date', date.toIso8601String().split('T')[0]);

    if (response.isEmpty) return 0.0;

    double total = 0.0;
    for (var log in response) {
      total += (log['amount'] as num).toDouble();
    }
    return total;
  }

  // ============ REAL-TIME SUBSCRIPTIONS ============

  /// Subscribe to profile changes
  RealtimeChannel subscribeToProfile(Function(Map<String, dynamic>) onUpdate) {
    final userId = getCurrentUserId();
    if (userId == null) throw Exception('No user logged in');

    return _supabase
        .channel('profile_changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'user_profiles',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: userId,
          ),
          callback: (payload) => onUpdate(payload.newRecord),
        )
        .subscribe();
  }

  /// Unsubscribe from channel
  Future<void> unsubscribe(RealtimeChannel channel) async {
    await _supabase.removeChannel(channel);
  }
}
