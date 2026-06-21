import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../models/food_item.dart';
import '../models/meal_log.dart';
import '../services/notification_service.dart';
import '../services/supabase_service.dart';
import '../services/connectivity_service.dart';
import '../services/offline_queue_service.dart';
import 'dart:async';

/// Represents the current background-sync state.
enum SyncStatus { idle, syncing, done }

class AppProvider extends ChangeNotifier with WidgetsBindingObserver {
  late SharedPreferences _prefs;
  final SupabaseService _supabaseService = SupabaseService();
  final ConnectivityService _connectivityService = ConnectivityService();
  final OfflineQueueService _offlineQueue = OfflineQueueService();
  StreamSubscription<bool>? _connectivitySubscription;
  Timer? _syncCompleteTimer;

  UserProfile _userProfile = UserProfile();
  bool _isOnboarded = false;
  List<MealLog> _mealLogs = [];
  double _waterIntake = 0;
  double _waterGoal = 2500;
  List<WeightEntry> _weightEntries = [];
  DateTime _selectedDate = DateTime.now();
  Locale _currentLocale = const Locale('en');
  bool _isOnline = true;
  SyncStatus _syncStatus = SyncStatus.idle;
  bool _isSyncingFromSupabase = false;
  ThemeMode _themeMode = ThemeMode.system;

  // Water Reminder Settings
  bool _waterRemindersEnabled = false;
  int _waterReminderIntervalMinutes = 60;
  int _waterReminderStartHour = 8;
  int _waterReminderStartMinute = 0;
  int _waterReminderEndHour = 22;
  int _waterReminderEndMinute = 0;

  // Getters
  UserProfile get userProfile => _userProfile;
  bool get isOnboarded => _isOnboarded;
  double get waterIntake => _waterIntake;
  double get waterGoal => _waterGoal;
  List<WeightEntry> get weightEntries => List.unmodifiable(_weightEntries);
  DateTime get selectedDate => _selectedDate;
  List<MealLog> get allMealLogs => List.unmodifiable(_mealLogs);
  Locale get currentLocale => _currentLocale;
  bool get isOnline => _isOnline;
  SyncStatus get syncStatus => _syncStatus;
  int get pendingOperationsCount => _offlineQueue.pendingCount;
  ThemeMode get themeMode => _themeMode;

  // Water reminder getters
  bool get waterRemindersEnabled => _waterRemindersEnabled;
  int get waterReminderIntervalMinutes => _waterReminderIntervalMinutes;
  int get waterReminderStartHour => _waterReminderStartHour;
  int get waterReminderStartMinute => _waterReminderStartMinute;
  int get waterReminderEndHour => _waterReminderEndHour;
  int get waterReminderEndMinute => _waterReminderEndMinute;

  // Today's meals filtered by selected date
  List<MealLog> get todaysMeals =>
      _mealLogs.where((m) => _isSameDay(m.dateTime, _selectedDate)).toList();

  List<MealLog> getMealsByType(MealType type) =>
      todaysMeals.where((m) => m.mealType == type).toList();

  // Calorie / Macro totals for selected day
  double get consumedCalories =>
      todaysMeals.fold(0, (sum, m) => sum + m.totalCalories);
  double get consumedProtein =>
      todaysMeals.fold(0, (sum, m) => sum + m.totalProtein);
  double get consumedCarbs =>
      todaysMeals.fold(0, (sum, m) => sum + m.totalCarbs);
  double get consumedFat => todaysMeals.fold(0, (sum, m) => sum + m.totalFat);

  double get remainingCalories =>
      (_userProfile.targetCalories - consumedCalories).clamp(
        0,
        double.infinity,
      );
  double get calorieProgress => _userProfile.targetCalories > 0
      ? (consumedCalories / _userProfile.targetCalories).clamp(0.0, 1.5)
      : 0;

  double get proteinProgress => _userProfile.targetProtein > 0
      ? (consumedProtein / _userProfile.targetProtein).clamp(0.0, 1.5)
      : 0;
  double get carbsProgress => _userProfile.targetCarbs > 0
      ? (consumedCarbs / _userProfile.targetCarbs).clamp(0.0, 1.5)
      : 0;
  double get fatProgress => _userProfile.targetFat > 0
      ? (consumedFat / _userProfile.targetFat).clamp(0.0, 1.5)
      : 0;

  int get waterGlasses => (_waterIntake / 250).floor();
  int get waterGoalGlasses => (_waterGoal / 250).floor();
  double get waterProgress =>
      _waterGoal > 0 ? (_waterIntake / _waterGoal).clamp(0.0, 1.0) : 0;

  int get currentStreak {
    int streak = 0;
    final now = DateTime.now();
    for (int i = 0; i < 365; i++) {
      final date = now.subtract(Duration(days: i));
      final hasMeals = _mealLogs.any((m) => _isSameDay(m.dateTime, date));
      if (hasMeals) {
        streak++;
      } else if (i > 0) {
        break;
      }
    }
    return streak;
  }

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _loadData();

    WidgetsBinding.instance.addObserver(this);

    await _connectivityService.initialize();
    _isOnline = _connectivityService.isOnline;

    await _offlineQueue.loadQueue();

    _connectivitySubscription = _connectivityService.connectivityStream.listen((
      isOnline,
    ) {
      _isOnline = isOnline;
      notifyListeners();

      if (isOnline) {
        debugPrint('Device is back online - syncing pending operations...');
        _syncWhenOnline();
      } else {
        if (_syncStatus == SyncStatus.syncing) {
          _syncStatus = SyncStatus.idle;
        }
        debugPrint('Device is offline - operations will be queued');
      }
    });

    if (_isOnline) {
      if (_offlineQueue.pendingCount > 0) {
        _syncWhenOnline();
      } else {
        syncFromSupabase();
      }
    }
  }

  /// iOS-critical: Handle app resume to re-check connectivity and sync
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      debugPrint('App resumed - re-checking connectivity and sync state');

      // Cancel any pending auto-dismiss timer from before backgrounding
      _syncCompleteTimer?.cancel();

      // If we were showing "sync done", reset it since the timer might not have fired
      // Also reset if we were stuck in syncing state (safety measure for iOS)
      if (_syncStatus == SyncStatus.done ||
          (_syncStatus == SyncStatus.syncing && !_isSyncingFromSupabase)) {
        _syncStatus = SyncStatus.idle;
        notifyListeners();
      }

      // Re-check connectivity (iOS doesn't always deliver stream events reliably)
      _connectivityService.initialize().then((_) {
        final currentOnlineState = _connectivityService.isOnline;
        if (currentOnlineState != _isOnline) {
          _isOnline = currentOnlineState;
          notifyListeners();
        }

        // If we came back online and have pending operations, sync them
        if (_isOnline &&
            _offlineQueue.pendingCount > 0 &&
            _syncStatus != SyncStatus.syncing) {
          debugPrint('Resumed with pending operations - syncing');
          _syncWhenOnline();
        }
      });
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // Cancel timer when going to background to prevent orphaned callbacks
      _syncCompleteTimer?.cancel();
    }
  }

  /// Sync pending operations when device comes back online
  Future<void> _syncWhenOnline() async {
    if (!_isOnline || !_supabaseService.isLoggedIn()) {
      return;
    }

    // Prevent concurrent sync runs — if one is already in-flight, bail out.
    if (_syncStatus == SyncStatus.syncing) {
      return;
    }

    _syncStatus = SyncStatus.syncing;
    notifyListeners();

    try {
      // Sync pending operations from offline queue
      final syncSuccess = await _offlineQueue.syncPendingOperations((
        operation,
      ) async {
        switch (operation.type) {
          case OfflineOperationType.addMeal:
            await _supabaseService.logMeal(
              mealType: operation.data['mealType'],
              foodName: operation.data['foodName'],
              calories: operation.data['calories'],
              protein: operation.data['protein'],
              carbs: operation.data['carbs'],
              fat: operation.data['fat'],
              date: DateTime.parse(operation.data['date']),
              servings: operation.data['servings'],
            );
            break;

          case OfflineOperationType.removeMeal:
            await _supabaseService.deleteMealLog(operation.data['id']);
            break;

          case OfflineOperationType.addWater:
            await _supabaseService.logWaterIntake(
              amount: operation.data['amount'],
              date: DateTime.parse(operation.data['date']),
            );
            break;

          case OfflineOperationType.addWeight:
            await _supabaseService.logWeight(
              weight: operation.data['weight'],
              date: DateTime.parse(operation.data['date']),
            );
            break;

          case OfflineOperationType.updateProfile:
            await _supabaseService.saveUserProfile(_userProfile);
            break;
        }
      });

      if (syncSuccess) {
        // After syncing pending operations successfully, sync data from Supabase
        await syncFromSupabase();
        debugPrint('Successfully synced all pending operations');

        _syncStatus = SyncStatus.done;
        notifyListeners();

        // Auto-dismiss the "Sync complete" banner after 2.5 seconds
        // Use a Timer (not Future.delayed) so we can cancel it on iOS lifecycle events
        _syncCompleteTimer?.cancel();
        _syncCompleteTimer = Timer(const Duration(milliseconds: 2500), () {
          if (_syncStatus == SyncStatus.done) {
            _syncStatus = SyncStatus.idle;
            notifyListeners();
          }
        });
      } else {
        // Some operations failed to sync - reset to idle and keep operations in queue
        debugPrint('Some operations failed to sync - will retry later');
        _syncStatus = SyncStatus.idle;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error syncing pending operations: $e');
      _syncStatus = SyncStatus.idle;
      notifyListeners();
    }
  }

  /// Force reset sync status (useful for recovering from stuck states)
  void resetSyncStatus() {
    _syncCompleteTimer?.cancel();
    _syncStatus = SyncStatus.idle;
    _isSyncingFromSupabase = false;
    notifyListeners();
    debugPrint('Sync status forcefully reset');
  }

  /// Manually retry syncing pending operations
  Future<void> retrySync() async {
    if (_isOnline && _offlineQueue.pendingCount > 0) {
      debugPrint('Manual sync retry initiated');
      await _syncWhenOnline();
    } else if (!_isOnline) {
      debugPrint('Cannot retry sync - device is offline');
    } else {
      debugPrint('No pending operations to sync');
    }
  }

  @override
  void dispose() {
    _syncCompleteTimer?.cancel();
    _connectivitySubscription?.cancel();
    _connectivityService.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _loadData() {
    _isOnboarded = _prefs.getBool('isOnboarded') ?? false;

    final savedLang = _prefs.getString('selected_language');
    if (savedLang != null) {
      _currentLocale = Locale(savedLang);
    }

    // Load theme mode preference
    final savedThemeMode = _prefs.getString('theme_mode');
    if (savedThemeMode != null) {
      switch (savedThemeMode) {
        case 'light':
          _themeMode = ThemeMode.light;
          break;
        case 'dark':
          _themeMode = ThemeMode.dark;
          break;
        case 'system':
        default:
          _themeMode = ThemeMode.system;
          break;
      }
    }

    final profileJson = _prefs.getString('userProfile');
    if (profileJson != null) {
      _userProfile = UserProfile.decode(profileJson);
    }

    final mealsJson = _prefs.getString('mealLogs');
    if (mealsJson != null) {
      try {
        final List<dynamic> list = jsonDecode(mealsJson);
        _mealLogs = list.map((e) => MealLog.fromJson(e)).toList();
      } catch (_) {
        _mealLogs = [];
      }
    }

    final today = _formatDate(DateTime.now());
    _waterIntake = _prefs.getDouble('water_$today') ?? 0;
    _waterGoal = _prefs.getDouble('waterGoal') ?? 2500;

    _waterRemindersEnabled = _prefs.getBool('waterRemindersEnabled') ?? false;
    _waterReminderIntervalMinutes =
        _prefs.getInt('waterReminderIntervalMinutes') ?? 60;
    _waterReminderStartHour = _prefs.getInt('waterReminderStartHour') ?? 8;
    _waterReminderStartMinute = _prefs.getInt('waterReminderStartMinute') ?? 0;
    _waterReminderEndHour = _prefs.getInt('waterReminderEndHour') ?? 22;
    _waterReminderEndMinute = _prefs.getInt('waterReminderEndMinute') ?? 0;

    final weightJson = _prefs.getString('weightEntries');
    if (weightJson != null) {
      try {
        final List<dynamic> list = jsonDecode(weightJson);
        _weightEntries = list.map((e) => WeightEntry.fromJson(e)).toList();
        _weightEntries.sort((a, b) => a.date.compareTo(b.date));
      } catch (_) {
        _weightEntries = [];
      }
    }

    notifyListeners();
  }

  /// Load data from Supabase when user logs in
  Future<void> syncFromSupabase() async {
    if (SupabaseService.isTesting) {
      debugPrint(
        'Testing mode: skipping syncFromSupabase to prevent local state overwrite',
      );
      return;
    }
    if (!_supabaseService.isLoggedIn()) {
      debugPrint('Not logged in, skipping Supabase sync');
      return;
    }

    // Prevent concurrent calls (e.g. pull-to-refresh racing with _syncWhenOnline)
    if (_isSyncingFromSupabase) {
      debugPrint(
        'syncFromSupabase already in progress, skipping duplicate call',
      );
      return;
    }
    _isSyncingFromSupabase = true;

    try {
      // Load meals from last 30 days
      final startDate = DateTime.now().subtract(const Duration(days: 30));
      final endDate = DateTime.now();

      final mealData = await _supabaseService.getMealLogsInRange(
        startDate: startDate,
        endDate: endDate,
      );

      // Convert Supabase meals to MealLog objects
      // Note: Supabase stores BASE nutrition values (not multiplied by servings)
      final supabaseMeals = <MealLog>[];
      for (var meal in mealData) {
        try {
          final mealType = MealType.values.firstWhere(
            (t) => t.name == meal['meal_type'],
            orElse: () => MealType.breakfast,
          );

          // These are base values from Supabase (not multiplied)
          final foodItem = FoodItem(
            id:
                meal['id']?.toString() ??
                DateTime.now().millisecondsSinceEpoch.toString(),
            name: meal['food_name'] ?? '',
            calories: (meal['calories'] as num?)?.toDouble() ?? 0,
            protein: (meal['protein'] as num?)?.toDouble() ?? 0,
            carbs: (meal['carbs'] as num?)?.toDouble() ?? 0,
            fat: (meal['fat'] as num?)?.toDouble() ?? 0,
            servingSize: '1 serving',
            emoji: '🍽️',
            region: 'general',
          );

          final servings = (meal['servings'] as num?)?.toDouble() ?? 1.0;
          final dateStr = meal['date'] as String?;
          final createdAtStr = meal['created_at'] as String?;

          DateTime logDate;
          if (dateStr != null) {
            // Parse date and ensure it's in local time
            logDate = DateTime.parse(dateStr);
            // If it's just a date (no time), set to noon local time for consistency
            if (!dateStr.contains('T')) {
              logDate = DateTime(
                logDate.year,
                logDate.month,
                logDate.day,
                12,
                0,
              );
            }
          } else if (createdAtStr != null) {
            // Parse created_at timestamp
            logDate = DateTime.parse(createdAtStr).toLocal();
          } else {
            logDate = DateTime.now();
          }

          supabaseMeals.add(
            MealLog(
              id:
                  meal['id']?.toString() ??
                  DateTime.now().millisecondsSinceEpoch.toString(),
              food: foodItem,
              mealType: mealType,
              servings: servings,
              dateTime: logDate,
            ),
          );
        } catch (e) {
          debugPrint('Error parsing meal: $e');
        }
      }

      // Properly deduplicate meals - Supabase is the source of truth
      // Use a Map with ID as key to prevent duplicates
      final mealMap = <String, MealLog>{};

      // First add local meals (these will be overwritten by Supabase data if IDs match)
      for (var meal in _mealLogs) {
        mealMap[meal.id] = meal;
      }

      // Then add/overwrite with Supabase meals (source of truth)
      for (var meal in supabaseMeals) {
        mealMap[meal.id] = meal;
      }

      // Convert back to list and save
      _mealLogs = mealMap.values.toList();
      await _saveMealLogs();

      // Load weight history
      final weightData = await _supabaseService.getWeightHistory(limit: 90);
      final supabaseWeights = <WeightEntry>[];
      for (var entry in weightData) {
        try {
          final dateStr = entry['date'] as String?;
          if (dateStr != null) {
            // Parse date and normalize to local date (no time component)
            final parsedDate = DateTime.parse(dateStr);
            final normalizedDate = DateTime(
              parsedDate.year,
              parsedDate.month,
              parsedDate.day,
            );
            supabaseWeights.add(
              WeightEntry(
                date: normalizedDate,
                weight: (entry['weight'] as num?)?.toDouble() ?? 0,
              ),
            );
          }
        } catch (e) {
          debugPrint('Error parsing weight entry: $e');
        }
      }

      // Merge weight entries - local data takes precedence over Supabase
      // (local data is more recent if user just added weight)
      final allWeights = <String, WeightEntry>{};
      // First add Supabase weights
      for (var entry in supabaseWeights) {
        final key = _formatDate(entry.date);
        allWeights[key] = entry;
      }
      // Then add local weights (will overwrite Supabase if same date)
      for (var entry in _weightEntries) {
        final key = _formatDate(entry.date);
        allWeights[key] = entry;
      }
      _weightEntries = allWeights.values.toList();
      _weightEntries.sort((a, b) => a.date.compareTo(b.date));
      await _saveWeightEntries();

      // Load today's water intake (Supabase is source of truth)
      final waterAmount = await _supabaseService.getWaterIntake(DateTime.now());
      _waterIntake = waterAmount;
      final today = _formatDate(DateTime.now());
      await _prefs.setDouble('water_$today', _waterIntake);

      notifyListeners();
      debugPrint('Successfully synced data from Supabase');
    } catch (e) {
      debugPrint('Error syncing from Supabase: $e');
      // Don't throw - keep local data if sync fails
    } finally {
      _isSyncingFromSupabase = false;
    }
  }

  // ─── Onboarding ────────────────────────────────────────────────
  Future<void> completeOnboarding(UserProfile profile) async {
    profile.calculateTargets();
    _userProfile = profile;
    _isOnboarded = true;
    await _prefs.setBool('isOnboarded', true);
    await _prefs.setString('userProfile', profile.encode());

    // Add initial weight entry
    if (profile.weight > 0) {
      _weightEntries.add(
        WeightEntry(date: DateTime.now(), weight: profile.weight),
      );
      await _saveWeightEntries();
    }

    if (_supabaseService.isLoggedIn()) {
      try {
        await _supabaseService.saveUserProfile(profile);

        if (profile.weight > 0) {
          await _supabaseService.logWeight(
            weight: profile.weight,
            date: DateTime.now(),
          );
        }
      } catch (e) {
        debugPrint('Failed to sync onboarding data to Supabase: $e');
      }
    }

    notifyListeners();
  }

  Future<void> updateProfile(UserProfile profile) async {
    profile.calculateTargets();

    // Check if weight changed
    final weightChanged = _userProfile.weight != profile.weight;
    final newWeight = profile.weight;

    _userProfile = profile;
    await _prefs.setString('userProfile', profile.encode());

    // Add weight entry if weight changed
    if (weightChanged && newWeight > 0) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Replace today's entry if exists
      _weightEntries.removeWhere((e) => _isSameDay(e.date, today));
      _weightEntries.add(WeightEntry(date: today, weight: newWeight));
      _weightEntries.sort((a, b) => a.date.compareTo(b.date));
      await _saveWeightEntries();
    }

    // Sync to Supabase if user is logged in
    if (_supabaseService.isLoggedIn()) {
      if (_isOnline) {
        try {
          await _supabaseService.saveUserProfile(profile);

          // Also log weight if it changed
          if (weightChanged && newWeight > 0) {
            final today = DateTime(
              DateTime.now().year,
              DateTime.now().month,
              DateTime.now().day,
            );
            await _supabaseService.logWeight(weight: newWeight, date: today);
          }
        } catch (e) {
          debugPrint('Failed to sync profile to Supabase: $e');
          // Queue operation for later sync
          await _offlineQueue.addOperation(
            OfflineOperationType.updateProfile,
            {},
          );

          // Queue weight log if weight changed
          if (weightChanged && newWeight > 0) {
            final today = DateTime(
              DateTime.now().year,
              DateTime.now().month,
              DateTime.now().day,
            );
            await _offlineQueue.addOperation(OfflineOperationType.addWeight, {
              'weight': newWeight,
              'date': today.toIso8601String(),
            });
          }
        }
      } else {
        // Device is offline - queue operation
        await _offlineQueue.addOperation(
          OfflineOperationType.updateProfile,
          {},
        );

        // Queue weight log if weight changed
        if (weightChanged && newWeight > 0) {
          final today = DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
          );
          await _offlineQueue.addOperation(OfflineOperationType.addWeight, {
            'weight': newWeight,
            'date': today.toIso8601String(),
          });
        }

        debugPrint('Device offline - profile update queued for sync');
      }
    }

    notifyListeners();
  }

  // ─── Meal Logging ──────────────────────────────────────────────
  Future<void> addMeal(
    FoodItem food,
    MealType mealType, {
    double servings = 1.0,
  }) async {
    final tempId = DateTime.now().millisecondsSinceEpoch.toString();
    final log = MealLog(
      id: tempId,
      food: food,
      mealType: mealType,
      servings: servings,
      dateTime: DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        DateTime.now().hour,
        DateTime.now().minute,
      ),
    );

    // Add to local storage first (with temp ID)
    _mealLogs.add(log);
    await _saveMealLogs();

    // Sync to Supabase if online, otherwise queue operation
    if (_supabaseService.isLoggedIn()) {
      if (_isOnline) {
        try {
          // Store BASE values (not multiplied) to Supabase
          // The servings field handles the multiplication
          final supabaseId = await _supabaseService.logMeal(
            mealType: mealType.name,
            foodName: food.name,
            calories: food.calories,
            protein: food.protein,
            carbs: food.carbs,
            fat: food.fat,
            date: log.dateTime,
            servings: servings,
          );

          // Update local meal with Supabase ID to prevent duplicates
          if (supabaseId != null) {
            final index = _mealLogs.indexWhere((m) => m.id == tempId);
            if (index != -1) {
              _mealLogs[index] = MealLog(
                id: supabaseId,
                food: food,
                mealType: mealType,
                servings: servings,
                dateTime: log.dateTime,
              );
              await _saveMealLogs();
            }
          }
        } catch (e) {
          // Log error but don't block the UI - data is still saved locally
          debugPrint('Failed to sync meal to Supabase: $e');
          // Queue operation for later sync
          await _offlineQueue.addOperation(OfflineOperationType.addMeal, {
            'mealType': mealType.name,
            'foodName': food.name,
            'calories': food.calories,
            'protein': food.protein,
            'carbs': food.carbs,
            'fat': food.fat,
            'date': log.dateTime.toIso8601String(),
            'servings': servings,
          });
        }
      } else {
        // Device is offline - queue operation
        await _offlineQueue.addOperation(OfflineOperationType.addMeal, {
          'mealType': mealType.name,
          'foodName': food.name,
          'calories': food.calories,
          'protein': food.protein,
          'carbs': food.carbs,
          'fat': food.fat,
          'date': log.dateTime.toIso8601String(),
          'servings': servings,
        });
        debugPrint('Device offline - meal queued for sync');
      }
    }

    notifyListeners();
  }

  Future<void> removeMeal(String id) async {
    _mealLogs.removeWhere((m) => m.id == id);
    await _saveMealLogs();

    // Also remove from Supabase if online, otherwise queue operation
    if (_supabaseService.isLoggedIn()) {
      if (_isOnline) {
        try {
          await _supabaseService.deleteMealLog(id);
        } catch (e) {
          debugPrint('Failed to delete meal from Supabase: $e');
          // Queue operation for later sync
          await _offlineQueue.addOperation(OfflineOperationType.removeMeal, {
            'id': id,
          });
        }
      } else {
        // Device is offline - queue operation
        await _offlineQueue.addOperation(OfflineOperationType.removeMeal, {
          'id': id,
        });
        debugPrint('Device offline - meal deletion queued for sync');
      }
    }

    notifyListeners();
  }

  Future<void> _saveMealLogs() async {
    final json = jsonEncode(_mealLogs.map((m) => m.toJson()).toList());
    await _prefs.setString('mealLogs', json);
  }

  // ─── Water Tracking ─────────────────────────────────────────────
  Future<void> addWater({double ml = 250}) async {
    _waterIntake += ml;
    final today = _formatDate(DateTime.now());
    await _prefs.setDouble('water_$today', _waterIntake);

    if (_supabaseService.isLoggedIn()) {
      if (_isOnline) {
        try {
          await _supabaseService.logWaterIntake(
            amount: ml,
            date: DateTime.now(),
          );
        } catch (e) {
          debugPrint('Failed to sync water intake to Supabase: $e');
          // Queue operation for later sync
          await _offlineQueue.addOperation(OfflineOperationType.addWater, {
            'amount': ml,
            'date': DateTime.now().toIso8601String(),
          });
        }
      } else {
        // Device is offline - queue operation
        await _offlineQueue.addOperation(OfflineOperationType.addWater, {
          'amount': ml,
          'date': DateTime.now().toIso8601String(),
        });
        debugPrint('Device offline - water intake queued for sync');
      }
    }

    notifyListeners();
  }

  Future<void> removeWater({double ml = 250}) async {
    _waterIntake = (_waterIntake - ml).clamp(0, double.infinity);
    final today = _formatDate(DateTime.now());
    await _prefs.setDouble('water_$today', _waterIntake);

    // Note: We don't sync removals to Supabase as it tracks individual entries
    // To properly handle this, we'd need to delete the last entry from Supabase

    notifyListeners();
  }

  Future<void> setWaterGoal(double ml) async {
    _waterGoal = ml;
    await _prefs.setDouble('waterGoal', ml);
    notifyListeners();
  }

  // ─── Water Reminder Settings ─────────────────────────────────────
  Future<void> updateWaterReminders({
    required bool enabled,
    required int intervalMinutes,
    required int startHour,
    required int startMinute,
    required int endHour,
    required int endMinute,
  }) async {
    _waterRemindersEnabled = enabled;
    _waterReminderIntervalMinutes = intervalMinutes;
    _waterReminderStartHour = startHour;
    _waterReminderStartMinute = startMinute;
    _waterReminderEndHour = endHour;
    _waterReminderEndMinute = endMinute;

    await _prefs.setBool('waterRemindersEnabled', enabled);
    await _prefs.setInt('waterReminderIntervalMinutes', intervalMinutes);
    await _prefs.setInt('waterReminderStartHour', startHour);
    await _prefs.setInt('waterReminderStartMinute', startMinute);
    await _prefs.setInt('waterReminderEndHour', endHour);
    await _prefs.setInt('waterReminderEndMinute', endMinute);

    notifyListeners();
  }

  // ─── Weight Tracking ────────────────────────────────────────────
  Future<void> addWeight(double weight, {DateTime? date}) async {
    final now = date ?? DateTime.now();
    final today = DateTime(
      now.year,
      now.month,
      now.day,
    ); // Normalize to date only
    // Replace today's entry if exists
    _weightEntries.removeWhere((e) => _isSameDay(e.date, today));
    _weightEntries.add(WeightEntry(date: today, weight: weight));
    _weightEntries.sort((a, b) => a.date.compareTo(b.date));

    // Update profile weight
    _userProfile.weight = weight;
    await _prefs.setString('userProfile', _userProfile.encode());
    await _saveWeightEntries();

    if (_supabaseService.isLoggedIn()) {
      if (_isOnline) {
        try {
          await _supabaseService.logWeight(weight: weight, date: today);
        } catch (e) {
          debugPrint('Failed to sync weight to Supabase: $e');
          // Queue operation for later sync
          await _offlineQueue.addOperation(OfflineOperationType.addWeight, {
            'weight': weight,
            'date': today.toIso8601String(),
          });
        }
      } else {
        // Device is offline - queue operation
        await _offlineQueue.addOperation(OfflineOperationType.addWeight, {
          'weight': weight,
          'date': today.toIso8601String(),
        });
        debugPrint('Device offline - weight entry queued for sync');
      }
    }

    notifyListeners();
  }

  Future<void> _saveWeightEntries() async {
    final json = jsonEncode(_weightEntries.map((w) => w.toJson()).toList());
    await _prefs.setString('weightEntries', json);
  }

  // ─── Date Selection ─────────────────────────────────────────────
  void selectDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  // ─── Reset ──────────────────────────────────────────────────────
  /// Logout - Clear all user data and reset to initial state
  Future<void> logout() async {
    // Cancel all scheduled notifications first
    try {
      await NotificationService.cancelWaterReminders();
      debugPrint('Water reminders cancelled on logout');
    } catch (e) {
      debugPrint('Error cancelling water reminders: $e');
    }

    // Sign out from Supabase
    try {
      await _supabaseService.signOut();
    } catch (e) {
      debugPrint('Error signing out from Supabase: $e');
    }

    // Clear all local data
    await _prefs.clear();
    await _offlineQueue.clearQueue();

    // Reset all state to initial values
    _userProfile = UserProfile();
    _isOnboarded = false;
    _mealLogs = [];
    _waterIntake = 0;
    _waterGoal = 2500;
    _weightEntries = [];
    _selectedDate = DateTime.now();
    _themeMode = ThemeMode.system;
    _waterRemindersEnabled = false;
    _waterReminderIntervalMinutes = 60;
    _waterReminderStartHour = 8;
    _waterReminderStartMinute = 0;
    _waterReminderEndHour = 22;
    _waterReminderEndMinute = 0;

    notifyListeners();
    debugPrint('User logged out - all data cleared');
  }

  Future<void> resetAllData() async {
    await _prefs.clear();
    await _offlineQueue.clearQueue();
    _userProfile = UserProfile();
    _isOnboarded = false;
    _mealLogs = [];
    _waterIntake = 0;
    _waterGoal = 2500;
    _weightEntries = [];
    _selectedDate = DateTime.now();
    _themeMode = ThemeMode.system;
    _waterRemindersEnabled = false;
    _waterReminderIntervalMinutes = 60;
    _waterReminderStartHour = 8;
    _waterReminderStartMinute = 0;
    _waterReminderEndHour = 22;
    _waterReminderEndMinute = 0;
    notifyListeners();
  }

  // ─── Helpers ────────────────────────────────────────────────────
  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  // Weekly calorie data for charts (last 7 days)
  List<MapEntry<DateTime, double>> get weeklyCalories {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final date = now.subtract(Duration(days: 6 - i));
      final dayCalories = _mealLogs
          .where((m) => _isSameDay(m.dateTime, date))
          .fold(0.0, (sum, m) => sum + m.totalCalories);
      return MapEntry(date, dayCalories);
    });
  }

  /// Returns daily carbs consumption for the past 30 days
  List<MapEntry<DateTime, double>> get monthlyCarbs {
    final now = DateTime.now();
    return List.generate(30, (i) {
      final date = now.subtract(Duration(days: 29 - i));
      final dayCarbs = _mealLogs
          .where((m) => _isSameDay(m.dateTime, date))
          .fold(0.0, (sum, m) => sum + m.totalCarbs);
      return MapEntry(date, dayCarbs);
    });
  }

  // ─── Locale Management ──────────────────────────────────────────
  Future<void> setLocale(
    Locale locale, {
    String? notificationTitle,
    String? notificationBody,
  }) async {
    _currentLocale = locale;
    await _prefs.setString('selected_language', locale.languageCode);

    // Reschedule water reminders with new language if they're enabled
    if (_waterRemindersEnabled &&
        notificationTitle != null &&
        notificationBody != null) {
      await NotificationService.scheduleWaterReminders(
        intervalMinutes: _waterReminderIntervalMinutes,
        startHour: _waterReminderStartHour,
        startMinute: _waterReminderStartMinute,
        endHour: _waterReminderEndHour,
        endMinute: _waterReminderEndMinute,
        notificationTitle: notificationTitle,
        notificationBody: notificationBody,
      );
    }

    notifyListeners();
  }

  // ─── Theme Management ──────────────────────────────────────────
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    String modeString;
    switch (mode) {
      case ThemeMode.light:
        modeString = 'light';
        break;
      case ThemeMode.dark:
        modeString = 'dark';
        break;
      case ThemeMode.system:
        modeString = 'system';
        break;
    }
    await _prefs.setString('theme_mode', modeString);
    notifyListeners();
  }
}
