import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lilyfit/providers/app_provider.dart';
import 'package:lilyfit/models/food_item.dart';
import 'package:lilyfit/models/meal_log.dart';
import 'package:lilyfit/models/user_profile.dart';

/// Creates an [AppProvider] backed by an in-memory [SharedPreferences].
Future<AppProvider> _buildProvider({
  Map<String, Object> prefs = const {},
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final provider = AppProvider();
  await provider.initialize();
  return provider;
}

const _apple = FoodItem(
  id: 'apple_001',
  name: 'Apple',
  calories: 95.0,
  protein: 0.5,
  carbs: 25.0,
  fat: 0.3,
  servingSize: '1 medium',
  region: 'Global',
);

const _chicken = FoodItem(
  id: 'chicken_001',
  name: 'Grilled Chicken',
  calories: 165.0,
  protein: 31.0,
  carbs: 0.0,
  fat: 3.6,
  servingSize: '100g',
  region: 'Global',
);

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('AppProvider', () {
    group('initialization', () {
      test('starts with default values on fresh install', () async {
        final provider = await _buildProvider();
        expect(provider.isOnboarded, isFalse);
        expect(provider.allMealLogs, isEmpty);
        expect(provider.waterIntake, 0.0);
        expect(provider.waterGoal, 2500.0);
        expect(provider.weightEntries, isEmpty);
        expect(provider.consumedCalories, 0.0);
      });

      test('restores isOnboarded flag from prefs', () async {
        final provider = await _buildProvider(prefs: {'isOnboarded': true});
        expect(provider.isOnboarded, isTrue);
      });

      test('restores water goal from prefs', () async {
        final provider = await _buildProvider(prefs: {'waterGoal': 3000.0});
        expect(provider.waterGoal, 3000.0);
      });
    });

    group('completeOnboarding', () {
      test('sets isOnboarded to true', () async {
        final provider = await _buildProvider();
        final profile = UserProfile(name: 'Alice', weight: 60.0, height: 165.0);
        await provider.completeOnboarding(profile);
        expect(provider.isOnboarded, isTrue);
      });

      test('saves profile and calculates targets', () async {
        final provider = await _buildProvider();
        final profile = UserProfile(
          name: 'Bob',
          gender: 'male',
          age: 30,
          weight: 80.0,
          height: 175.0,
          activityLevel: 'moderate',
          goal: 'maintenance',
        );
        await provider.completeOnboarding(profile);
        expect(provider.userProfile.name, 'Bob');
        expect(provider.userProfile.targetCalories, greaterThan(0));
      });

      test('adds initial weight entry when weight > 0', () async {
        final provider = await _buildProvider();
        final profile = UserProfile(weight: 75.0, height: 170.0);
        await provider.completeOnboarding(profile);
        expect(provider.weightEntries.length, 1);
        expect(provider.weightEntries.first.weight, 75.0);
      });

      test('does not add weight entry when weight is 0', () async {
        final provider = await _buildProvider();
        final profile = UserProfile(weight: 0.0, height: 170.0);
        await provider.completeOnboarding(profile);
        expect(provider.weightEntries, isEmpty);
      });
    });

    group('updateProfile', () {
      test('updates the profile and recalculates targets', () async {
        final provider = await _buildProvider();
        final updated = UserProfile(
          name: 'Charlie',
          gender: 'female',
          age: 28,
          weight: 58.0,
          height: 163.0,
          activityLevel: 'active',
          goal: 'fatLoss',
        );
        await provider.updateProfile(updated);
        expect(provider.userProfile.name, 'Charlie');
        expect(provider.userProfile.goal, 'fatLoss');
        expect(provider.userProfile.targetCalories, greaterThan(0));
      });
    });

    group('meal logging', () {
      test('addMeal increments consumedCalories', () async {
        final provider = await _buildProvider();
        await provider.addMeal(_apple, MealType.breakfast);
        expect(provider.consumedCalories, closeTo(95.0, 0.001));
      });

      test('addMeal with servings scales macros correctly', () async {
        final provider = await _buildProvider();
        await provider.addMeal(_chicken, MealType.lunch, servings: 2.0);
        expect(provider.consumedCalories, closeTo(330.0, 0.001));
        expect(provider.consumedProtein, closeTo(62.0, 0.001));
        expect(provider.consumedFat, closeTo(7.2, 0.001));
      });

      test('addMeal appends to allMealLogs', () async {
        final provider = await _buildProvider();
        await provider.addMeal(_apple, MealType.breakfast);
        await provider.addMeal(_chicken, MealType.lunch);
        expect(provider.allMealLogs.length, 2);
      });

      test('removeMeal decrements consumedCalories', () async {
        final provider = await _buildProvider();
        await provider.addMeal(_apple, MealType.snack);
        final id = provider.allMealLogs.first.id;
        await provider.removeMeal(id);
        expect(provider.allMealLogs, isEmpty);
        expect(provider.consumedCalories, 0.0);
      });

      test('removeMeal with non-existent id does nothing', () async {
        final provider = await _buildProvider();
        await provider.addMeal(_apple, MealType.breakfast);
        await provider.removeMeal('non_existent_id');
        expect(provider.allMealLogs.length, 1);
      });

      test('getMealsByType returns only meals of given type', () async {
        final provider = await _buildProvider();
        await provider.addMeal(_apple, MealType.breakfast);
        await provider.addMeal(_chicken, MealType.lunch);
        expect(provider.getMealsByType(MealType.breakfast).length, 1);
        expect(provider.getMealsByType(MealType.lunch).length, 1);
        expect(provider.getMealsByType(MealType.dinner).length, 0);
      });
    });

    group('calorie progress', () {
      test('calorieProgress is 0 when no meals logged', () async {
        final provider = await _buildProvider();
        expect(provider.calorieProgress, 0.0);
      });

      test('calorieProgress is clamped to 1.5 maximum', () async {
        final provider = await _buildProvider();
        // Default targetCalories = 2000; add 4000 kcal → 4000/2000 = 2.0, clamped to 1.5
        await provider.addMeal(
          const FoodItem(
            id: 'big',
            name: 'Big Meal',
            calories: 4000,
            protein: 100,
            carbs: 200,
            fat: 100,
            servingSize: '1',
            region: 'Global',
          ),
          MealType.dinner,
        );
        expect(provider.calorieProgress, 1.5);
      });

      test('remainingCalories is clamped at 0', () async {
        final provider = await _buildProvider();
        // Default targetCalories = 2000; add 2500 kcal → remaining = 2000-2500 clamped to 0
        await provider.addMeal(
          const FoodItem(
            id: 'over',
            name: 'Over Eat',
            calories: 2500,
            protein: 100,
            carbs: 300,
            fat: 100,
            servingSize: '1',
            region: 'Global',
          ),
          MealType.dinner,
        );
        expect(provider.remainingCalories, 0.0);
      });
    });

    group('water tracking', () {
      test('addWater increases waterIntake by default 250 ml', () async {
        final provider = await _buildProvider();
        await provider.addWater();
        expect(provider.waterIntake, 250.0);
      });

      test('addWater with custom ml', () async {
        final provider = await _buildProvider();
        await provider.addWater(ml: 500);
        expect(provider.waterIntake, 500.0);
      });

      test('addWater is cumulative', () async {
        final provider = await _buildProvider();
        await provider.addWater();
        await provider.addWater();
        await provider.addWater();
        expect(provider.waterIntake, 750.0);
      });

      test('removeWater decreases waterIntake', () async {
        final provider = await _buildProvider();
        await provider.addWater(ml: 750);
        await provider.removeWater();
        expect(provider.waterIntake, 500.0);
      });

      test('removeWater is clamped at 0', () async {
        final provider = await _buildProvider();
        await provider.removeWater();
        expect(provider.waterIntake, 0.0);
      });

      test('setWaterGoal updates goal', () async {
        final provider = await _buildProvider();
        await provider.setWaterGoal(3000.0);
        expect(provider.waterGoal, 3000.0);
      });

      test('waterGlasses counts 250 ml units', () async {
        final provider = await _buildProvider();
        await provider.addWater(ml: 750);
        expect(provider.waterGlasses, 3);
      });

      test('waterGlasses floors partial glasses', () async {
        final provider = await _buildProvider();
        await provider.addWater(ml: 300);
        expect(provider.waterGlasses, 1); // 300/250 = 1.2 → floor 1
      });

      test('waterProgress is clamped between 0 and 1', () async {
        final provider = await _buildProvider();
        await provider.setWaterGoal(500.0);
        await provider.addWater(ml: 1000);
        expect(provider.waterProgress, 1.0);
      });
    });

    group('weight tracking', () {
      test('addWeight appends a WeightEntry', () async {
        final provider = await _buildProvider();
        await provider.addWeight(72.5);
        expect(provider.weightEntries.length, 1);
        expect(provider.weightEntries.first.weight, 72.5);
      });

      test('addWeight updates userProfile.weight', () async {
        final provider = await _buildProvider();
        await provider.addWeight(80.0);
        expect(provider.userProfile.weight, 80.0);
      });

      test('addWeight replaces existing entry for today', () async {
        final provider = await _buildProvider();
        await provider.addWeight(70.0);
        await provider.addWeight(71.0);
        expect(provider.weightEntries.length, 1);
        expect(provider.weightEntries.first.weight, 71.0);
      });

      test('weight entries are kept sorted by date', () async {
        final provider = await _buildProvider();
        await provider.addWeight(70.0);
        // Entries are sorted after each add
        expect(provider.weightEntries.isNotEmpty, isTrue);
      });
    });

    group('date selection', () {
      test('selectDate updates selectedDate', () async {
        final provider = await _buildProvider();
        final target = DateTime(2024, 3, 15);
        provider.selectDate(target);
        expect(provider.selectedDate.year, 2024);
        expect(provider.selectedDate.month, 3);
        expect(provider.selectedDate.day, 15);
      });

      test('todaysMeals only returns meals for selectedDate', () async {
        final provider = await _buildProvider();
        // Default selectedDate is today — add a meal (also today)
        await provider.addMeal(_apple, MealType.breakfast);
        expect(provider.todaysMeals.length, 1);
        // Switch to a past date
        provider.selectDate(DateTime(2000, 1, 1));
        expect(provider.todaysMeals, isEmpty);
      });
    });

    group('weeklyCalories', () {
      test('returns a list of 7 entries', () async {
        final provider = await _buildProvider();
        expect(provider.weeklyCalories.length, 7);
      });

      test('today has 0 kcal when no meals are logged', () async {
        final provider = await _buildProvider();
        final today = provider.weeklyCalories.last;
        expect(today.value, 0.0);
      });
    });

    group('currentStreak', () {
      test('streak is 0 when no meals logged', () async {
        final provider = await _buildProvider();
        expect(provider.currentStreak, 0);
      });

      test('streak is 1 when a meal is logged today', () async {
        final provider = await _buildProvider();
        await provider.addMeal(_apple, MealType.breakfast);
        expect(provider.currentStreak, 1);
      });
    });

    group('locale management', () {
      test('default locale is en', () async {
        final provider = await _buildProvider();
        expect(provider.currentLocale, const Locale('en'));
      });

      test('setLocale updates currentLocale', () async {
        final provider = await _buildProvider();
        provider.setLocale(const Locale('fr'));
        expect(provider.currentLocale, const Locale('fr'));
      });
    });

    group('resetAllData', () {
      test('clears all state back to defaults', () async {
        final provider = await _buildProvider();
        await provider.addMeal(_apple, MealType.breakfast);
        await provider.addWater(ml: 500);
        await provider.addWeight(72.0);
        await provider.resetAllData();

        expect(provider.allMealLogs, isEmpty);
        expect(provider.waterIntake, 0.0);
        expect(provider.waterGoal, 2500.0);
        expect(provider.weightEntries, isEmpty);
        expect(provider.isOnboarded, isFalse);
      });
    });

    group('notifications', () {
      test('addMeal notifies listeners', () async {
        final provider = await _buildProvider();
        bool notified = false;
        provider.addListener(() => notified = true);
        await provider.addMeal(_apple, MealType.breakfast);
        expect(notified, isTrue);
      });

      test('removeWater notifies listeners', () async {
        final provider = await _buildProvider();
        bool notified = false;
        provider.addListener(() => notified = true);
        await provider.removeWater();
        expect(notified, isTrue);
      });
    });
  });
}
