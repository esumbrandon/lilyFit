import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../models/food_item.dart';
import '../models/meal_log.dart';

class AppProvider extends ChangeNotifier {
  late SharedPreferences _prefs;

  UserProfile _userProfile = UserProfile();
  bool _isOnboarded = false;
  List<MealLog> _mealLogs = [];
  double _waterIntake = 0; // mL for today
  double _waterGoal = 2500; // mL
  List<WeightEntry> _weightEntries = [];
  DateTime _selectedDate = DateTime.now();

  // ─── Getters ────────────────────────────────────────────────────
  UserProfile get userProfile => _userProfile;
  bool get isOnboarded => _isOnboarded;
  double get waterIntake => _waterIntake;
  double get waterGoal => _waterGoal;
  List<WeightEntry> get weightEntries => List.unmodifiable(_weightEntries);
  DateTime get selectedDate => _selectedDate;
  List<MealLog> get allMealLogs => List.unmodifiable(_mealLogs);

  // Today's meals filtered by selected date
  List<MealLog> get todaysMeals => _mealLogs
      .where((m) => _isSameDay(m.dateTime, _selectedDate))
      .toList();

  List<MealLog> getMealsByType(MealType type) =>
      todaysMeals.where((m) => m.mealType == type).toList();

  // Calorie / Macro totals for selected day
  double get consumedCalories =>
      todaysMeals.fold(0, (sum, m) => sum + m.totalCalories);
  double get consumedProtein =>
      todaysMeals.fold(0, (sum, m) => sum + m.totalProtein);
  double get consumedCarbs =>
      todaysMeals.fold(0, (sum, m) => sum + m.totalCarbs);
  double get consumedFat =>
      todaysMeals.fold(0, (sum, m) => sum + m.totalFat);

  double get remainingCalories =>
      (_userProfile.targetCalories - consumedCalories).clamp(0, double.infinity);
  double get calorieProgress =>
      _userProfile.targetCalories > 0
          ? (consumedCalories / _userProfile.targetCalories).clamp(0.0, 1.5)
          : 0;

  double get proteinProgress =>
      _userProfile.targetProtein > 0
          ? (consumedProtein / _userProfile.targetProtein).clamp(0.0, 1.5)
          : 0;
  double get carbsProgress =>
      _userProfile.targetCarbs > 0
          ? (consumedCarbs / _userProfile.targetCarbs).clamp(0.0, 1.5)
          : 0;
  double get fatProgress =>
      _userProfile.targetFat > 0
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

  // ─── Onboarding ────────────────────────────────────────────────
  Future<void> completeOnboarding(UserProfile profile) async {
    profile.calculateTargets();
    _userProfile = profile;
    _isOnboarded = true;
    await _prefs.setBool('isOnboarded', true);
    await _prefs.setString('userProfile', profile.encode());

    // Add initial weight entry
    if (profile.weight > 0) {
      _weightEntries.add(WeightEntry(date: DateTime.now(), weight: profile.weight));
      await _saveWeightEntries();
    }

    notifyListeners();
  }

  Future<void> updateProfile(UserProfile profile) async {
    profile.calculateTargets();
    _userProfile = profile;
    await _prefs.setString('userProfile', profile.encode());
    notifyListeners();
  }

  // ─── Meal Logging ──────────────────────────────────────────────
  Future<void> addMeal(FoodItem food, MealType mealType, {double servings = 1.0}) async {
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
    notifyListeners();
  }

  Future<void> removeWater({double ml = 250}) async {
    _waterIntake = (_waterIntake - ml).clamp(0, double.infinity);
    final today = _formatDate(DateTime.now());
    await _prefs.setDouble('water_$today', _waterIntake);
    notifyListeners();
  }

  Future<void> setWaterGoal(double ml) async {
    _waterGoal = ml;
    await _prefs.setDouble('waterGoal', ml);
    notifyListeners();
  }

  // ─── Weight Tracking ────────────────────────────────────────────
  Future<void> addWeight(double weight) async {
    final today = DateTime.now();
    // Replace today's entry if exists
    _weightEntries.removeWhere((e) => _isSameDay(e.date, today));
    _weightEntries.add(WeightEntry(date: today, weight: weight));
    _weightEntries.sort((a, b) => a.date.compareTo(b.date));

    // Update profile weight
    _userProfile.weight = weight;
    await _prefs.setString('userProfile', _userProfile.encode());
    await _saveWeightEntries();
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
}
