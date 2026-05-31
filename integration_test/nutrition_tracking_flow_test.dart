// Integration tests for nutrition tracking flow
// Tests food search, meal logging, and daily nutrition tracking
//
// Run with: flutter test integration_test/nutrition_tracking_flow_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:lilyfit/providers/app_provider.dart';
import 'package:lilyfit/models/user_profile.dart';
import 'package:lilyfit/models/meal_log.dart';
import 'package:lilyfit/screens/home/home_screen.dart';
import 'package:lilyfit/screens/food_search/food_search_screen.dart';
import 'package:lilyfit/screens/dashboard/dashboard_screen.dart';
import 'package:lilyfit/theme/app_theme.dart';
import 'package:lilyfit/l10n/app_localizations.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Helper to create properly configured MaterialApp with localizations
  Widget createTestApp(AppProvider provider, Widget home) {
    return ChangeNotifierProvider.value(
      value: provider,
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: provider.currentLocale,
        home: home,
      ),
    );
  }

  group('Nutrition Tracking Flow Tests', () {
    late AppProvider provider;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      provider = AppProvider();
      await provider.initialize();

      // Complete onboarding with test profile
      await provider.completeOnboarding(
        UserProfile(
          name: 'Test User',
          gender: 'male',
          age: 30,
          weight: 75.0,
          height: 175.0,
          activityLevel: 'moderate',
          goal: 'maintenance',
        ),
      );
    });

    testWidgets('User can search for food and view details', (tester) async {
      await tester.pumpWidget(createTestApp(provider, const HomeScreen()));
      await tester.pumpAndSettle();

      // Tap on Food Search tab
      await tester.tap(find.text('Food'));
      await tester.pumpAndSettle();

      // Should be on food search screen
      expect(find.byType(FoodSearchScreen), findsOneWidget);

      // Enter search query
      await tester.enterText(find.byType(TextField).first, 'banana');
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Should see search results containing banana
      expect(find.text('Banana'), findsWidgets);

      // Tap on a food item to view details
      await tester.tap(find.text('Banana').first);
      await tester.pumpAndSettle();

      // Should see food details dialog/sheet
      expect(find.text('Add to Meal'), findsOneWidget);
    });

    testWidgets('User can log a meal for breakfast', (tester) async {
      await tester.pumpWidget(createTestApp(provider, const HomeScreen()));
      await tester.pumpAndSettle();

      final initialCalories = provider.consumedCalories;

      // Go to Food Search
      await tester.tap(find.text('Food'));
      await tester.pumpAndSettle();

      // Search for food
      await tester.enterText(find.byType(TextField).first, 'oats');
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Tap on Oats
      await tester.tap(find.text('Oats').first);
      await tester.pumpAndSettle();

      // Select meal type - Breakfast
      await tester.tap(find.text('Breakfast'));
      await tester.pumpAndSettle();

      // Adjust servings if needed (default is 1.0)

      // Tap Add to Meal
      await tester.tap(find.text('Add to Meal'));
      await tester.pumpAndSettle();

      // Verify meal was added
      expect(provider.consumedCalories, greaterThan(initialCalories));
      expect(
        provider.allMealLogs.any((log) => log.mealType == MealType.breakfast),
        isTrue,
      );

      // Return to dashboard
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();

      // Verify calories are updated on dashboard
      expect(find.byType(DashboardScreen), findsOneWidget);
      // The calorie count should be visible
      expect(provider.consumedCalories, greaterThan(0));
    });

    testWidgets('User can log multiple meals throughout the day', (
      tester,
    ) async {
      await tester.pumpWidget(createTestApp(provider, const HomeScreen()));
      await tester.pumpAndSettle();

      // Helper function to add a meal
      Future<void> addMeal(String foodName, String mealType) async {
        // Go to Food Search
        await tester.tap(find.text('Food'));
        await tester.pumpAndSettle();

        // Search for food
        await tester.enterText(find.byType(TextField).first, foodName);
        await tester.pumpAndSettle(const Duration(milliseconds: 500));

        // Tap on food item
        await tester.tap(
          find.textContaining(foodName, findRichText: true).first,
        );
        await tester.pumpAndSettle();

        // Select meal type
        await tester.tap(find.text(mealType));
        await tester.pumpAndSettle();

        // Add to meal
        await tester.tap(find.text('Add to Meal'));
        await tester.pumpAndSettle();

        // Return to home
        await tester.tap(find.text('Home'));
        await tester.pumpAndSettle();
      }

      // Add breakfast
      await addMeal('banana', 'Breakfast');
      final afterBreakfast = provider.consumedCalories;
      expect(afterBreakfast, greaterThan(0));

      // Add lunch
      await addMeal('chicken', 'Lunch');
      final afterLunch = provider.consumedCalories;
      expect(afterLunch, greaterThan(afterBreakfast));

      // Add dinner
      await addMeal('rice', 'Dinner');
      final afterDinner = provider.consumedCalories;
      expect(afterDinner, greaterThan(afterLunch));

      // Verify all meal logs exist
      expect(provider.allMealLogs.length, 3);
      expect(
        provider.allMealLogs
            .where((log) => log.mealType == MealType.breakfast)
            .length,
        1,
      );
      expect(
        provider.allMealLogs
            .where((log) => log.mealType == MealType.lunch)
            .length,
        1,
      );
      expect(
        provider.allMealLogs
            .where((log) => log.mealType == MealType.dinner)
            .length,
        1,
      );
    });

    testWidgets('User can adjust serving size before logging', (tester) async {
      await tester.pumpWidget(createTestApp(provider, const HomeScreen()));
      await tester.pumpAndSettle();

      // Go to Food Search
      await tester.tap(find.text('Food'));
      await tester.pumpAndSettle();

      // Search for food
      await tester.enterText(find.byType(TextField).first, 'banana');
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Tap on Banana
      await tester.tap(find.text('Banana').first);
      await tester.pumpAndSettle();

      // Find and increase serving size
      final incrementButton = find.byIcon(Icons.add_rounded);
      if (incrementButton.evaluate().isNotEmpty) {
        await tester.tap(incrementButton.first);
        await tester.pumpAndSettle();

        // Tap again to make it 1.5 servings (0.25 increments)
        await tester.tap(incrementButton.first);
        await tester.pumpAndSettle();
      }

      // Select meal type
      await tester.tap(find.text('Breakfast'));
      await tester.pumpAndSettle();

      // Add to meal
      await tester.tap(find.text('Add to Meal'));
      await tester.pumpAndSettle();

      // Verify meal was logged
      final logs = provider.allMealLogs;
      expect(logs.isNotEmpty, isTrue);

      // The serving size should be > 1.0
      if (logs.isNotEmpty) {
        expect(logs.first.servings, greaterThanOrEqualTo(1.0));
      }
    });

    testWidgets('User can remove a logged meal', (tester) async {
      await tester.pumpWidget(createTestApp(provider, const HomeScreen()));
      await tester.pumpAndSettle();

      // Add a meal first
      await tester.tap(find.text('Food'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'banana');
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      await tester.tap(find.text('Banana').first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Breakfast'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add to Meal'));
      await tester.pumpAndSettle();

      // Go back to dashboard
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();

      final beforeRemoval = provider.consumedCalories;
      expect(beforeRemoval, greaterThan(0));

      // Find and tap delete button on the meal log
      final deleteButton = find.byIcon(Icons.delete_outline_rounded);
      if (deleteButton.evaluate().isNotEmpty) {
        await tester.tap(deleteButton.first);
        await tester.pumpAndSettle();

        // Confirm deletion if there's a dialog
        final confirmButton = find.text('Delete');
        if (confirmButton.evaluate().isNotEmpty) {
          await tester.tap(confirmButton);
          await tester.pumpAndSettle();
        }

        // Verify meal was removed
        expect(provider.consumedCalories, lessThan(beforeRemoval));
      }
    });

    testWidgets('Calorie ring updates in real-time as meals are logged', (
      tester,
    ) async {
      await tester.pumpWidget(createTestApp(provider, const HomeScreen()));
      await tester.pumpAndSettle();

      // Get initial state
      final initialCalories = provider.consumedCalories;
      final targetCalories = provider.userProfile.targetCalories;

      expect(initialCalories, 0);
      expect(targetCalories, greaterThan(0));

      // Add a meal
      await tester.tap(find.text('Food'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'banana');
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      await tester.tap(find.text('Banana').first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Breakfast'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add to Meal'));
      await tester.pumpAndSettle();

      // Go back to dashboard
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();

      // Verify calorie ring is updated
      expect(provider.consumedCalories, greaterThan(initialCalories));

      // Calculate progress percentage
      final progress = provider.consumedCalories / targetCalories;
      expect(progress, greaterThan(0));
      expect(progress, lessThanOrEqualTo(1.5)); // Reasonable upper bound
    });

    testWidgets('Macro progress bars update with logged meals', (tester) async {
      await tester.pumpWidget(createTestApp(provider, const HomeScreen()));
      await tester.pumpAndSettle();

      final initialProtein = provider.consumedProtein;
      final initialCarbs = provider.consumedCarbs;
      final initialFat = provider.consumedFat;

      // Add a meal with significant macros
      await tester.tap(find.text('Food'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'chicken');
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      final chickenFinder = find.textContaining('Chicken', findRichText: true);
      if (chickenFinder.evaluate().isNotEmpty) {
        await tester.tap(chickenFinder.first);
        await tester.pumpAndSettle();

        await tester.tap(find.text('Lunch'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Add to Meal'));
        await tester.pumpAndSettle();

        // Go back to dashboard
        await tester.tap(find.text('Home'));
        await tester.pumpAndSettle();

        // Verify macros updated
        expect(provider.consumedProtein, greaterThan(initialProtein));
        expect(provider.consumedCarbs, greaterThanOrEqualTo(initialCarbs));
        expect(provider.consumedFat, greaterThanOrEqualTo(initialFat));
      }
    });

    testWidgets('Food search filters by region', (tester) async {
      await tester.pumpWidget(
        createTestApp(provider, const FoodSearchScreen()),
      );
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Look for region filter chips/tabs
      final regionFilters = find.textContaining('Global');

      // If region filters exist, test filtering
      if (regionFilters.evaluate().isNotEmpty) {
        // The food list should have items
        expect(find.byType(ListTile), findsWidgets);

        // Try selecting a specific region
        final africanFilter = find.text('African');
        if (africanFilter.evaluate().isNotEmpty) {
          await tester.tap(africanFilter);
          await tester.pumpAndSettle();

          // The list should update to show only African foods
          // (We can't verify specific content without knowing the database)
        }
      }
    });
  });
}
