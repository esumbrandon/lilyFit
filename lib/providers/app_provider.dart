import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../models/food_item.dart';
import '../models/meal_log.dart';
import '../services/notification_service.dart';
import '../services/supabase_service.dart';

class AppProvider extends ChangeNotifier {
  late SharedPreferences _prefs;
  final SupabaseService _supabaseService = SupabaseService();

  UserProfile _userProfile = UserProfile();
  bool _isOnboarded = false;
  List<MealLog> _mealLogs = [];
  double _waterIntake = 0; // mL for today
  double _waterGoal = 2500; // mL
  List<WeightEntry> _weightEntries = [];
  DateTime _selectedDate = DateTime.now();
  Locale _currentLocale = const Locale('en'); // Default locale

  // ─── Water Reminder Settings ────────────────────────────────────
  bool _waterRemindersEnabled = false;
  int _waterReminderIntervalMinutes = 60;
  int _waterReminderStartHour = 8;
  int _waterReminderStartMinute = 0;
  int _waterReminderEndHour = 22;
  int _waterReminderEndMinute = 0;

  // ─── Getters ────────────────────────────────────────────────────
  UserProfile get userProfile => _userProfile;
  bool get isOnboarded => _isOnboarded;
  double get waterIntake => _waterIntake;
  double get waterGoal => _waterGoal;
  List<WeightEntry> get weightEntries => List.unmodifiable(_weightEntries);
  DateTime get selectedDate => _selectedDate;
  List<MealLog> get allMealLogs => List.unmodifiable(_mealLogs);
  Locale get currentLocale => _currentLocale;

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

  // ─── Initialization ─────────────────────────────────────────────
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _loadData();
  }

  void _loadData() {
    _isOnboarded = _prefs.getBool('isOnboarded') ?? false;

    final savedLang = _prefs.getString('selected_language');
    if (savedLang != null) {
      _currentLocale = Locale(savedLang);
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
    if (!_supabaseService.isLoggedIn()) {
      debugPrint('Not logged in, skipping Supabase sync');
      return;
    }

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
            id: meal['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
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
              logDate = DateTime(logDate.year, logDate.month, logDate.day, 12, 0);
            }
          } else if (createdAtStr != null) {
            // Parse created_at timestamp
            logDate = DateTime.parse(createdAtStr).toLocal();
          } else {
            logDate = DateTime.now();
          }

          supabaseMeals.add(MealLog(
            id: meal['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
            food: foodItem,
            mealType: mealType,
            servings: servings,
            dateTime: logDate,
          ));
        } catch (e) {
          debugPrint('Error parsing meal: $e');
        }
      }

      // Merge with local meals (keep both, deduplicate later if needed)
      _mealLogs = [...supabaseMeals, ..._mealLogs];
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
            final normalizedDate = DateTime(parsedDate.year, parsedDate.month, parsedDate.day);
            supabaseWeights.add(WeightEntry(
              date: normalizedDate,
              weight: (entry['weight'] as num?)?.toDouble() ?? 0,
            ));
          }
        } catch (e) {
          debugPrint('Error parsing weight entry: $e');
        }
      }

      // Merge weight entries
      final allWeights = <String, WeightEntry>{};
      for (var entry in [..._weightEntries, ...supabaseWeights]) {
        final key = _formatDate(entry.date);
        allWeights[key] = entry;
      }
      _weightEntries = allWeights.values.toList();
      _weightEntries.sort((a, b) => a.date.compareTo(b.date));
      await _saveWeightEntries();

      // Load today's water intake
      final waterAmount = await _supabaseService.getWaterIntake(DateTime.now());
      if (waterAmount > 0) {
        _waterIntake = waterAmount;
        final today = _formatDate(DateTime.now());
        await _prefs.setDouble('water_$today', _waterIntake);
      }

      notifyListeners();
      debugPrint('Successfully synced data from Supabase');
    } catch (e) {
      debugPrint('Error syncing from Supabase: $e');
      // Don't throw - keep local data if sync fails
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
    _userProfile = profile;
    await _prefs.setString('userProfile', profile.encode());

    // Sync to Supabase if user is logged in
    if (_supabaseService.isLoggedIn()) {
      try {
        await _supabaseService.saveUserProfile(profile);
      } catch (e) {
        debugPrint('Failed to sync profile to Supabase: $e');
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
    final log = MealLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
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
    _mealLogs.add(log);
    await _saveMealLogs();

    if (_supabaseService.isLoggedIn()) {
      try {
        // Store BASE values (not multiplied) to Supabase
        // The servings field handles the multiplication
        await _supabaseService.logMeal(
          mealType: mealType.name,
          foodName: food.name,
          calories: food.calories,
          protein: food.protein,
          carbs: food.carbs,
          fat: food.fat,
          date: log.dateTime,
          servings: servings,
        );
      } catch (e) {
        // Log error but don't block the UI - data is still saved locally
        debugPrint('Failed to sync meal to Supabase: $e');
      }
    }

    notifyListeners();
  }

  Future<void> removeMeal(String id) async {
    _mealLogs.removeWhere((m) => m.id == id);
    await _saveMealLogs();
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
      try {
        await _supabaseService.logWaterIntake(
          amount: ml,
          date: DateTime.now(),
        );
      } catch (e) {
        debugPrint('Failed to sync water intake to Supabase: $e');
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
  Future<void> addWeight(double weight) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day); // Normalize to date only
    // Replace today's entry if exists
    _weightEntries.removeWhere((e) => _isSameDay(e.date, today));
    _weightEntries.add(WeightEntry(date: today, weight: weight));
    _weightEntries.sort((a, b) => a.date.compareTo(b.date));

    // Update profile weight
    _userProfile.weight = weight;
    await _prefs.setString('userProfile', _userProfile.encode());
    await _saveWeightEntries();

    if (_supabaseService.isLoggedIn()) {
      try {
        await _supabaseService.logWeight(
          weight: weight,
          date: today,
        );
      } catch (e) {
        debugPrint('Failed to sync weight to Supabase: $e');
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
  Future<void> resetAllData() async {
    await _prefs.clear();
    _userProfile = UserProfile();
    _isOnboarded = false;
    _mealLogs = [];
    _waterIntake = 0;
    _waterGoal = 2500;
    _weightEntries = [];
    _selectedDate = DateTime.now();
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
}
