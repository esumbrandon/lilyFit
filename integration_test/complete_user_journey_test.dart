// Complete end-to-end integration test for LilyFit
// Simulates a full user journey from first launch to active usage
//
// Run with: flutter test integration_test/complete_user_journey_test.dart

import 'package:lilyfit/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:lilyfit/providers/app_provider.dart';
import 'package:lilyfit/models/user_profile.dart';
import 'package:lilyfit/screens/onboarding/onboarding_screen.dart';
import 'package:lilyfit/screens/home/home_screen.dart';
import 'package:lilyfit/screens/dashboard/dashboard_screen.dart';
import 'package:lilyfit/screens/food_search/food_search_screen.dart';
import 'package:lilyfit/screens/food_search/food_item_card.dart';
import 'package:lilyfit/screens/progress/progress_screen.dart';
import 'package:lilyfit/screens/profile/profile_screen.dart';
import 'package:lilyfit/theme/app_theme.dart';
import 'package:lilyfit/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lilyfit/config/supabase_config.dart';

void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  SupabaseService.isTesting = true;
  try {
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );
  } catch (_) {}
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

  group('Complete User Journey - End to End', () {
    testWidgets('New user: Complete onboarding and use app for a day', (
      tester,
    ) async {
      // Clear all data to simulate first launch
      SharedPreferences.setMockInitialValues({});

      final provider = AppProvider();
      await provider.initialize();

      await tester.pumpWidget(
        createTestApp(provider, const OnboardingScreen()),
      );
      await tester.pumpAndSettle();

      // ═══════════════════════════════════════════════════════════
      // STEP 1: Complete Onboarding
      // ═══════════════════════════════════════════════════════════

      // Welcome page
      expect(find.text('LilyFit'), findsOneWidget);
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // About You (Name & Gender)
      expect(find.text('About You'), findsOneWidget);
      await tester.enterText(find.byType(TextField).first, 'Jamie Smith');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Female'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Body Metrics
      expect(find.text('Body Metrics'), findsOneWidget);
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Activity Level
      expect(find.text('Activity Level'), findsOneWidget);
      await tester.tap(find.text('Moderate'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Goal
      expect(find.text('Goal'), findsOneWidget);
      await tester.tap(find.text('Lose Weight'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Eating Style
      expect(find.text('Eating Style'), findsOneWidget);
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Daily Water Goal
      expect(find.text('Daily Water Goal'), findsOneWidget);
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Plan Summary
      expect(find.text('Your Plan is Ready! 🎉'), findsOneWidget);
      await tester.tap(find.text('Start Tracking!'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Should be on home screen now
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(provider.isOnboarded, isTrue);
      expect(provider.userProfile.name, 'Jamie Smith');

      // ═══════════════════════════════════════════════════════════
      // STEP 2: Explore Dashboard
      // ═══════════════════════════════════════════════════════════

      expect(find.byType(DashboardScreen), findsOneWidget);

      // Verify initial state
      expect(provider.consumedCalories, 0.0);
      expect(provider.waterIntake, 0.0);
      expect(provider.userProfile.targetCalories, greaterThan(0));

      // ═══════════════════════════════════════════════════════════
      // STEP 3: Log Breakfast
      // ═══════════════════════════════════════════════════════════

      await tester.tap(find.text('Food'));
      await tester.pumpAndSettle();
      expect(find.byType(FoodSearchScreen), findsOneWidget);

      // Search for oats
      await tester.enterText(find.byType(TextField).first, 'oat');
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Select Oats
      await tester.tap(find.byType(FoodItemCard).first);
      await tester.pumpAndSettle();

      // Select Breakfast
      await tester.tap(find.text('Breakfast'));
      await tester.pumpAndSettle();

      // Add to meal
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      final afterBreakfast = provider.consumedCalories;
      expect(afterBreakfast, greaterThan(0));

      // ═══════════════════════════════════════════════════════════
      // STEP 4: Add Water
      // ═══════════════════════════════════════════════════════════

      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();

      // Add water 3 times (750ml) using provider method
      await provider.addWater(ml: 250);
      await provider.addWater(ml: 250);
      await provider.addWater(ml: 250);
      await tester.pumpAndSettle();

      expect(provider.waterIntake, 750.0);
      expect(provider.waterGlasses, 3);

      // ═══════════════════════════════════════════════════════════
      // STEP 5: Log Lunch
      // ═══════════════════════════════════════════════════════════

      await tester.tap(find.text('Food'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'chicken');
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      if (find.byType(FoodItemCard).evaluate().isNotEmpty) {
        await tester.tap(find.byType(FoodItemCard).first);
        await tester.pumpAndSettle();

        await tester.tap(find.text('Lunch'));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();
      }

      final afterLunch = provider.consumedCalories;
      expect(afterLunch, greaterThan(afterBreakfast));

      // ═══════════════════════════════════════════════════════════
      // STEP 6: Add More Water
      // ═══════════════════════════════════════════════════════════

      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();

      // Add 3 more glasses (1500ml total) using provider method
      await provider.addWater(ml: 250);
      await provider.addWater(ml: 250);
      await provider.addWater(ml: 250);
      await tester.pumpAndSettle();

      expect(provider.waterIntake, 1500.0);

      // ═══════════════════════════════════════════════════════════
      // STEP 7: Log Snack
      // ═══════════════════════════════════════════════════════════

      await tester.tap(find.text('Food'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'banana');
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      await tester.tap(find.byType(FoodItemCard).first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Snack'));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // ═══════════════════════════════════════════════════════════
      // STEP 8: Log Dinner
      // ═══════════════════════════════════════════════════════════

      // Search for rice
      await tester.enterText(find.byType(TextField).first, 'rice');
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      if (find.byType(FoodItemCard).evaluate().isNotEmpty) {
        await tester.tap(find.byType(FoodItemCard).first);
        await tester.pumpAndSettle();

        await tester.tap(find.text('Dinner'));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();
      }

      // ═══════════════════════════════════════════════════════════
      // STEP 9: Complete Water Goal
      // ═══════════════════════════════════════════════════════════

      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();

      // Add water until goal is met (use provider method to avoid infinite loop)
      final remainingWater = provider.waterGoal - provider.waterIntake;
      if (remainingWater > 0) {
        await provider.addWater(ml: remainingWater);
        await tester.pumpAndSettle();
      }

      expect(provider.waterProgress, greaterThanOrEqualTo(1.0));

      // ═══════════════════════════════════════════════════════════
      // STEP 10: Check Progress
      // ═══════════════════════════════════════════════════════════

      await tester.tap(find.text('Progress'));
      await tester.pumpAndSettle();

      expect(find.byType(ProgressScreen), findsOneWidget);

      // Should have at least one weight entry (from onboarding)
      expect(provider.weightEntries.isNotEmpty, isTrue);

      // ═══════════════════════════════════════════════════════════
      // STEP 11: Add Weight Entry
      // ═══════════════════════════════════════════════════════════

      final addWeightButton = find.byIcon(Icons.add_rounded);
      if (addWeightButton.evaluate().isNotEmpty) {
        await tester.tap(addWeightButton.first);
        await tester.pumpAndSettle();

        // Enter weight
        final weightField = find.byType(TextField);
        if (weightField.evaluate().isNotEmpty) {
          await tester.enterText(weightField.first, '71.5');
          await tester.pumpAndSettle();

          // Save
          final saveButton = find.text('Save').first;
          await tester.tap(saveButton);
          await tester.pumpAndSettle();
        }
      }

      // ═══════════════════════════════════════════════════════════
      // STEP 12: View Profile & Settings
      // ═══════════════════════════════════════════════════════════

      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      expect(find.byType(ProfileScreen), findsOneWidget);
      expect(find.text('Jamie Smith'), findsOneWidget);

      // ═══════════════════════════════════════════════════════════
      // STEP 13: Verify Final State
      // ═══════════════════════════════════════════════════════════

      // User has logged multiple meals
      expect(provider.allMealLogs.length, greaterThanOrEqualTo(3));

      // User has consumed significant calories
      expect(provider.consumedCalories, greaterThan(300));

      // User has met water goal
      expect(provider.waterProgress, greaterThanOrEqualTo(1.0));

      // User has weight entries
      expect(provider.weightEntries.length, greaterThan(0));

      // Macros are tracked
      expect(provider.consumedProtein, greaterThan(0));
      expect(provider.consumedCarbs, greaterThan(0));
      expect(provider.consumedFat, greaterThan(0));

      // ═══════════════════════════════════════════════════════════
      // STEP 14: Return to Dashboard - Full Circle
      // ═══════════════════════════════════════════════════════════

      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();

      expect(find.byType(DashboardScreen), findsOneWidget);

      // Dashboard shows progress
      final calorieProgress =
          provider.consumedCalories / provider.userProfile.targetCalories;
      expect(calorieProgress, greaterThan(0));
      expect(calorieProgress, lessThanOrEqualTo(2.0)); // Reasonable upper bound
    });

    testWidgets('Returning user: Quick daily log workflow', (tester) async {
      // Setup existing user
      SharedPreferences.setMockInitialValues({});

      final provider = AppProvider();
      await provider.initialize();

      await provider.completeOnboarding(
        UserProfile(
          name: 'Returning User',
          gender: 'male',
          age: 28,
          weight: 75.0,
          height: 178.0,
          activityLevel: 'moderate',
          goal: 'maintenance',
        ),
      );

      await tester.pumpWidget(createTestApp(provider, const HomeScreen()));
      await tester.pumpAndSettle();

      // Quick workflow: Log meal → Add water → Done

      // 1. Quickly log breakfast
      await tester.tap(find.text('Food'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'eggs');
      await tester.pumpAndSettle(const Duration(milliseconds: 300));

      if (find.byType(FoodItemCard).evaluate().isNotEmpty) {
        await tester.tap(find.byType(FoodItemCard).first);
        await tester.pumpAndSettle();

        await tester.tap(find.text('Breakfast'));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();
      }

      // 2. Quick water add
      await provider.addWater(ml: 250);
      await tester.pumpAndSettle();

      // Done - quick and efficient
      expect(provider.consumedCalories, greaterThan(0));
      expect(provider.waterIntake, greaterThan(0));
    });

    testWidgets('User corrects mistake: Remove meal and re-log', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});

      final provider = AppProvider();
      await provider.initialize();

      await provider.completeOnboarding(
        UserProfile(
          name: 'Test User',
          gender: 'female',
          age: 25,
          weight: 60.0,
          height: 165.0,
        ),
      );

      await tester.pumpWidget(createTestApp(provider, const HomeScreen()));
      await tester.pumpAndSettle();

      // Log wrong meal
      await tester.tap(find.text('Food'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'banana');
      await tester.pumpAndSettle(const Duration(milliseconds: 300));

      await tester.tap(find.byType(FoodItemCard).first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Breakfast'));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();

      final caloriesWithMistake = provider.consumedCalories;
      expect(caloriesWithMistake, greaterThan(0));

      // Scroll to bring the Dismissible card fully into view (above the bottom navigation bar)
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();

      // Remove the meal by swiping the Dismissible card
      final dismissibleFinder = find.byType(Dismissible);
      if (dismissibleFinder.evaluate().isNotEmpty) {
        await tester.drag(dismissibleFinder.first, const Offset(-500.0, 0.0));
        await tester.pumpAndSettle();
      }

      // Verify removed
      expect(provider.consumedCalories, lessThan(caloriesWithMistake));

      // Log correct meal
      await tester.tap(find.text('Food'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'oat');
      await tester.pumpAndSettle(const Duration(milliseconds: 300));

      await tester.tap(find.byType(FoodItemCard).first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Breakfast'));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Now has correct meal logged
      expect(provider.consumedCalories, greaterThan(0));
    });

    testWidgets('Multi-day usage: Track progress over time', (tester) async {
      SharedPreferences.setMockInitialValues({});

      final provider = AppProvider();
      await provider.initialize();

      await provider.completeOnboarding(
        UserProfile(
          name: 'Long Term User',
          gender: 'male',
          age: 35,
          weight: 85.0,
          height: 180.0,
          activityLevel: 'active',
          goal: 'fatLoss',
        ),
      );

      // Simulate multiple days of data
      final now = DateTime.now();
      await provider.addWeight(
        85.0,
        date: now.subtract(const Duration(days: 4)),
      );
      await provider.addWeight(
        84.5,
        date: now.subtract(const Duration(days: 3)),
      );
      await provider.addWeight(
        84.0,
        date: now.subtract(const Duration(days: 2)),
      );
      await provider.addWeight(
        83.5,
        date: now.subtract(const Duration(days: 1)),
      );
      await provider.addWeight(83.0, date: now);

      await tester.pumpWidget(createTestApp(provider, const HomeScreen()));
      await tester.pumpAndSettle();

      // View progress
      await tester.tap(find.text('Progress'));
      await tester.pumpAndSettle();

      // Should show weight loss trend
      expect(provider.weightEntries.length, 5);

      final startWeight = provider.weightEntries.first.weight;
      final currentWeight = provider.userProfile.weight;
      final totalLoss = startWeight - currentWeight;

      expect(totalLoss, greaterThan(0));
      expect(currentWeight, 83.0);
      expect(totalLoss, 2.0); // Lost 2kg
    });
  });
}
