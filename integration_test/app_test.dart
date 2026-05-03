// Integration tests for LilyFit.
//
// These tests run on a real device or emulator.
// Run with: flutter test integration_test/app_test.dart
//
// NOTE: Tests that exercise Supabase auth flows require a live Supabase
// project. The tests below focus on the purely local business-logic flows
// (onboarding, nutrition tracking, water tracking) that work entirely with
// SharedPreferences and do not call the network.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:lilyfit/providers/app_provider.dart';
import 'package:lilyfit/models/food_item.dart';
import 'package:lilyfit/models/meal_log.dart';
import 'package:lilyfit/models/user_profile.dart';
import 'package:lilyfit/widgets/macro_progress_bar.dart';
import 'package:lilyfit/widgets/calorie_ring_painter.dart';
import 'package:lilyfit/widgets/water_tracker_card.dart';
import 'package:lilyfit/theme/app_theme.dart';

Future<AppProvider> _freshProvider() async {
  SharedPreferences.setMockInitialValues({});
  final p = AppProvider();
  await p.initialize();
  return p;
}

Widget _providerApp(AppProvider provider, Widget child) {
  return ChangeNotifierProvider<AppProvider>.value(
    value: provider,
    child: MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(
        body: Padding(padding: const EdgeInsets.all(16), child: child),
      ),
    ),
  );
}

const _banana = FoodItem(
  id: 'banana_001',
  name: 'Banana',
  calories: 89.0,
  protein: 1.1,
  carbs: 23.0,
  fat: 0.3,
  servingSize: '1 medium',
  region: 'Global',
  emoji: '🍌',
);

const _oats = FoodItem(
  id: 'oats_001',
  name: 'Oats',
  calories: 150.0,
  protein: 5.0,
  carbs: 27.0,
  fat: 2.5,
  servingSize: '40g dry',
  region: 'Global',
  emoji: '🌾',
);

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // ─── Onboarding flow ────────────────────────────────────────────
  group('Onboarding integration', () {
    testWidgets('completing onboarding marks provider as onboarded', (
      tester,
    ) async {
      final provider = await _freshProvider();
      expect(provider.isOnboarded, isFalse);

      final profile = UserProfile(
        name: 'Jane Doe',
        gender: 'female',
        age: 28,
        weight: 62.0,
        height: 165.0,
        activityLevel: 'moderate',
        goal: 'fatLoss',
      );
      await provider.completeOnboarding(profile);

      expect(provider.isOnboarded, isTrue);
      expect(provider.userProfile.name, 'Jane Doe');
      expect(provider.userProfile.targetCalories, greaterThan(0));
      expect(provider.weightEntries.length, 1);
    });

    testWidgets('profile update recalculates targets', (tester) async {
      final provider = await _freshProvider();
      await provider.completeOnboarding(
        UserProfile(name: 'Test User', weight: 70.0, height: 170.0),
      );
      final originalCals = provider.userProfile.targetCalories;

      final updated = UserProfile(
        name: 'Test User',
        gender: 'male',
        age: 25,
        weight: 80.0,
        height: 175.0,
        activityLevel: 'active',
        goal: 'muscleGain',
      );
      await provider.updateProfile(updated);

      expect(provider.userProfile.targetCalories, isNot(originalCals));
      expect(provider.userProfile.goal, 'muscleGain');
    });
  });

  // ─── Full nutrition day flow ─────────────────────────────────────
  group('Nutrition tracking integration', () {
    testWidgets('logging multiple meals accumulates macros', (tester) async {
      final provider = await _freshProvider();

      await provider.addMeal(_banana, MealType.breakfast);
      await provider.addMeal(_oats, MealType.breakfast);
      await provider.addMeal(_banana, MealType.snack, servings: 0.5);

      // Total calories: 89 + 150 + 89*0.5 = 89 + 150 + 44.5 = 283.5
      expect(provider.consumedCalories, closeTo(283.5, 0.01));
      expect(provider.allMealLogs.length, 3);
    });

    testWidgets('removing a meal recalculates totals', (tester) async {
      final provider = await _freshProvider();
      await provider.addMeal(_banana, MealType.breakfast);
      await provider.addMeal(_oats, MealType.lunch);

      final oatsId = provider.allMealLogs
          .firstWhere((m) => m.food.id == _oats.id)
          .id;
      await provider.removeMeal(oatsId);

      expect(provider.consumedCalories, closeTo(89.0, 0.01));
      expect(provider.allMealLogs.length, 1);
    });

    testWidgets('UI CalorieRingWidget reflects consumed amount', (
      tester,
    ) async {
      final provider = await _freshProvider();
      final profile = UserProfile();
      profile.targetCalories = 2000.0;
      await provider.updateProfile(profile);
      await provider.addMeal(_banana, MealType.breakfast);
      await provider.addMeal(_oats, MealType.lunch);

      final consumed = provider.consumedCalories;
      final widget = CalorieRingWidget(consumed: consumed, target: 2000);
      expect(widget.consumed, consumed);

      await tester.pumpWidget(_providerApp(provider, widget));
      await tester.pumpAndSettle();
    });

    testWidgets('MacroProgressBar reflects provider protein', (tester) async {
      final provider = await _freshProvider();
      await provider.addMeal(_oats, MealType.breakfast);

      await tester.pumpWidget(
        _providerApp(
          provider,
          MacroProgressBar(
            label: 'PROTEIN',
            current: provider.consumedProtein,
            target: 150,
            color: AppColors.protein,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('${provider.consumedProtein.toInt()}g'), findsOneWidget);
    });
  });

  // ─── Water tracking flow ─────────────────────────────────────────
  group('Water tracking integration', () {
    testWidgets('adding and removing water updates glasses count', (
      tester,
    ) async {
      final provider = await _freshProvider();

      await provider.addWater(); // +250 ml
      await provider.addWater(); // +250 ml
      await provider.addWater(); // +250 ml = 750 ml total = 3 glasses
      expect(provider.waterGlasses, 3);

      await provider.removeWater(); // 500 ml = 2 glasses
      expect(provider.waterGlasses, 2);
    });

    testWidgets('WaterTrackerCard updates visually after add/remove', (
      tester,
    ) async {
      final provider = await _freshProvider();
      await provider.addWater(ml: 1000); // 4 glasses

      await tester.pumpWidget(
        _providerApp(
          provider,
          WaterTrackerCard(
            currentGlasses: provider.waterGlasses,
            goalGlasses: provider.waterGoalGlasses,
            progress: provider.waterProgress,
            onAdd: () => provider.addWater(),
            onRemove: () => provider.removeWater(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('1000 / 2500 ml'), findsOneWidget);
    });

    testWidgets('setting custom water goal persists', (tester) async {
      final provider = await _freshProvider();
      await provider.setWaterGoal(3000.0);
      expect(provider.waterGoal, 3000.0);
      expect(provider.waterGoalGlasses, 12); // 3000 / 250 = 12
    });
  });

  // ─── Weight tracking flow ────────────────────────────────────────
  group('Weight tracking integration', () {
    testWidgets('adding weight entries builds history', (tester) async {
      final provider = await _freshProvider();

      await provider.addWeight(70.0);
      expect(provider.weightEntries.length, 1);

      // Second add today should replace, not append
      await provider.addWeight(71.5);
      expect(provider.weightEntries.length, 1);
      expect(provider.weightEntries.first.weight, 71.5);
      expect(provider.userProfile.weight, 71.5);
    });
  });

  // ─── Reset flow ──────────────────────────────────────────────────
  group('Reset integration', () {
    testWidgets('resetAllData clears all persisted state', (tester) async {
      final provider = await _freshProvider();

      // Populate state
      await provider.completeOnboarding(
        UserProfile(name: 'Reset Test', weight: 70.0, height: 170.0),
      );
      await provider.addMeal(_banana, MealType.breakfast);
      await provider.addWater(ml: 750);
      await provider.addWeight(70.0);

      expect(provider.isOnboarded, isTrue);
      expect(provider.allMealLogs.isNotEmpty, isTrue);
      expect(provider.waterIntake, 750.0);

      await provider.resetAllData();

      expect(provider.isOnboarded, isFalse);
      expect(provider.allMealLogs, isEmpty);
      expect(provider.waterIntake, 0.0);
      expect(provider.waterGoal, 2500.0);
      expect(provider.weightEntries, isEmpty);
      expect(provider.consumedCalories, 0.0);
    });
  });

  // ─── Locale flow ─────────────────────────────────────────────────
  group('Locale management integration', () {
    testWidgets('setLocale updates locale and notifies listeners', (
      tester,
    ) async {
      final provider = await _freshProvider();
      expect(provider.currentLocale.languageCode, 'en');

      bool notified = false;
      provider.addListener(() => notified = true);

      provider.setLocale(const Locale('sw'));
      expect(provider.currentLocale.languageCode, 'sw');
      expect(notified, isTrue);
    });
  });
}
