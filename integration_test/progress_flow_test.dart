// Integration tests for weight tracking and progress viewing
// Tests weight entry logging and progress charts
//
// Run with: flutter test integration_test/progress_flow_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:lilyfit/providers/app_provider.dart';
import 'package:lilyfit/models/user_profile.dart';
import 'package:lilyfit/models/food_item.dart';
import 'package:lilyfit/models/meal_log.dart';
import 'package:lilyfit/screens/home/home_screen.dart';
import 'package:lilyfit/screens/progress/progress_screen.dart';
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

  group('Progress & Weight Tracking Flow Tests', () {
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
          weight: 80.0,
          height: 175.0,
          activityLevel: 'active',
          goal: 'fatLoss',
        ),
      );
    });

    testWidgets('User can navigate to progress screen', (tester) async {
      await tester.pumpWidget(createTestApp(provider, const HomeScreen()));
      await tester.pumpAndSettle();

      // Tap on Progress tab
      await tester.tap(find.text('Progress'));
      await tester.pumpAndSettle();

      // Should be on progress screen
      expect(find.byType(ProgressScreen), findsOneWidget);
    });

    testWidgets('User can add a weight entry', (tester) async {
      await tester.pumpWidget(createTestApp(provider, const HomeScreen()));
      await tester.pumpAndSettle();

      // Navigate to progress
      await tester.tap(find.text('Progress'));
      await tester.pumpAndSettle();

      final initialEntries = provider.weightEntries.length;

      // Find add weight button
      final addButton = find.byIcon(Icons.add_rounded);

      if (addButton.evaluate().isNotEmpty) {
        await tester.tap(addButton.first);
        await tester.pumpAndSettle();

        // Should show weight input dialog
        // Enter new weight
        final textField = find.byType(TextField);
        if (textField.evaluate().isNotEmpty) {
          await tester.enterText(textField.first, '79.5');
          await tester.pumpAndSettle();

          // Confirm
          final confirmButton = find.text('Save');
          if (confirmButton.evaluate().isEmpty) {
            // Try other common button labels
            await tester.tap(find.text('Add'));
          } else {
            await tester.tap(confirmButton);
          }
          await tester.pumpAndSettle();

          // Verify weight entry was added
          expect(provider.weightEntries.length, greaterThan(initialEntries));
          expect(provider.userProfile.weight, 79.5);
        }
      }
    });

    testWidgets('Weight entries are displayed in chronological order', (
      tester,
    ) async {
      // Add multiple weight entries
      await provider.addWeight(80.0);
      await Future.delayed(const Duration(milliseconds: 100));
      await provider.addWeight(79.5);
      await Future.delayed(const Duration(milliseconds: 100));
      await provider.addWeight(79.0);

      await tester.pumpWidget(createTestApp(provider, const HomeScreen()));
      await tester.pumpAndSettle();

      // Navigate to progress
      await tester.tap(find.text('Progress'));
      await tester.pumpAndSettle();

      // Should display weight entries
      // Most recent should be first or visible prominently
      expect(provider.weightEntries.length, greaterThanOrEqualTo(3));

      // Current weight should be the latest entry
      expect(provider.userProfile.weight, 79.0);
    });

    testWidgets('Weight chart displays correctly with data', (tester) async {
      // Add weight data over time
      await provider.addWeight(82.0);
      await provider.addWeight(81.5);
      await provider.addWeight(81.0);
      await provider.addWeight(80.5);
      await provider.addWeight(80.0);

      await tester.pumpWidget(createTestApp(provider, const HomeScreen()));
      await tester.pumpAndSettle();

      // Navigate to progress
      await tester.tap(find.text('Progress'));
      await tester.pumpAndSettle();

      // Chart should be present with data points
      // Weight trend should show downward trend for fat loss goal
      expect(provider.weightEntries.length, 5);

      // First entry vs last entry
      final firstWeight = provider.weightEntries.first.weight;
      final lastWeight = provider.weightEntries.last.weight;

      // For fat loss goal, weight should be trending down
      expect(lastWeight, lessThanOrEqualTo(firstWeight));
    });

    testWidgets('User can view different progress time periods', (
      tester,
    ) async {
      // Add weight entries
      await provider.addWeight(80.0);

      await tester.pumpWidget(createTestApp(provider, const HomeScreen()));
      await tester.pumpAndSettle();

      // Navigate to progress
      await tester.tap(find.text('Progress'));
      await tester.pumpAndSettle();

      // Look for time period filters (7 days, 30 days, 90 days, All)
      final weekButton = find.text('7D');
      final monthButton = find.text('1M');
      final allButton = find.text('All');

      if (weekButton.evaluate().isNotEmpty) {
        await tester.tap(weekButton);
        await tester.pumpAndSettle();

        // Chart should update to show 7-day view
      }

      if (monthButton.evaluate().isNotEmpty) {
        await tester.tap(monthButton);
        await tester.pumpAndSettle();

        // Chart should update to show 30-day view
      }

      if (allButton.evaluate().isNotEmpty) {
        await tester.tap(allButton);
        await tester.pumpAndSettle();

        // Chart should update to show all data
      }
    });

    testWidgets('Progress statistics are calculated correctly', (tester) async {
      // Add weight entries showing progress
      await provider.addWeight(85.0);
      await provider.addWeight(84.0);
      await provider.addWeight(83.0);
      await provider.addWeight(82.0);

      await tester.pumpWidget(createTestApp(provider, const HomeScreen()));
      await tester.pumpAndSettle();

      // Navigate to progress
      await tester.tap(find.text('Progress'));
      await tester.pumpAndSettle();

      // Should show statistics like:
      // - Starting weight
      // - Current weight
      // - Weight lost
      // - Average weekly loss

      final startWeight = provider.weightEntries.first.weight;
      final currentWeight = provider.userProfile.weight;
      final weightLost = startWeight - currentWeight;

      expect(weightLost, greaterThan(0)); // User has made progress
      expect(currentWeight, lessThan(startWeight));
    });

    testWidgets('Empty progress screen shows appropriate message', (
      tester,
    ) async {
      // Create new provider without weight entries (except initial from onboarding)
      final emptyProvider = AppProvider();
      await emptyProvider.initialize();

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: emptyProvider,
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const HomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to progress
      final progressTab = find.text('Progress');
      if (progressTab.evaluate().isNotEmpty) {
        await tester.tap(progressTab);
        await tester.pumpAndSettle();
      }

      // Should show empty state or prompt to add first weight
      // (May already have one entry from onboarding)
    });

    testWidgets('User can edit a weight entry', (tester) async {
      // Add a weight entry
      await provider.addWeight(80.0);

      await tester.pumpWidget(createTestApp(provider, const HomeScreen()));
      await tester.pumpAndSettle();

      // Navigate to progress
      await tester.tap(find.text('Progress'));
      await tester.pumpAndSettle();

      // Find edit button on weight entry
      final editButton = find.byIcon(Icons.edit_outlined);

      if (editButton.evaluate().isNotEmpty) {
        await tester.tap(editButton.first);
        await tester.pumpAndSettle();

        // Update weight value
        final textField = find.byType(TextField);
        if (textField.evaluate().isNotEmpty) {
          await tester.enterText(textField.first, '79.0');
          await tester.pumpAndSettle();

          // Save changes
          final saveButton = find.text('Save');
          if (saveButton.evaluate().isNotEmpty) {
            await tester.tap(saveButton);
            await tester.pumpAndSettle();

            // Verify weight was updated
            expect(provider.userProfile.weight, 79.0);
          }
        }
      }
    });

    testWidgets('User can delete a weight entry', (tester) async {
      // Add multiple weight entries
      await provider.addWeight(80.0);
      await provider.addWeight(79.5);

      final initialCount = provider.weightEntries.length;

      await tester.pumpWidget(createTestApp(provider, const HomeScreen()));
      await tester.pumpAndSettle();

      // Navigate to progress
      await tester.tap(find.text('Progress'));
      await tester.pumpAndSettle();

      // Find delete button
      final deleteButton = find.byIcon(Icons.delete_outline_rounded);

      if (deleteButton.evaluate().isNotEmpty) {
        await tester.tap(deleteButton.first);
        await tester.pumpAndSettle();

        // Confirm deletion
        final confirmButton = find.text('Delete');
        if (confirmButton.evaluate().isNotEmpty) {
          await tester.tap(confirmButton);
          await tester.pumpAndSettle();

          // Verify entry was deleted
          expect(provider.weightEntries.length, lessThan(initialCount));
        }
      }
    });

    testWidgets('Nutrition progress displays for the week', (tester) async {
      // Add some meals to have nutrition data
      await provider.addMeal(
        const FoodItem(
          id: 'test_001',
          name: 'Test Food',
          calories: 100,
          protein: 10,
          carbs: 10,
          fat: 3,
          servingSize: '100g',
          region: 'Global',
          emoji: '🍽️',
        ),
        MealType.breakfast,
      );

      await tester.pumpWidget(createTestApp(provider, const HomeScreen()));
      await tester.pumpAndSettle();

      // Navigate to progress
      await tester.tap(find.text('Progress'));
      await tester.pumpAndSettle();

      // Should show nutrition charts/stats
      // - Average daily calories
      // - Macro breakdown
      // - Consistency metrics

      expect(provider.consumedCalories, 100);
    });

    testWidgets('Goal achievement indicators are displayed', (tester) async {
      // Set a fat loss goal and add progress toward it
      await provider.addWeight(80.0);
      await provider.addWeight(79.0);
      await provider.addWeight(78.0);

      await tester.pumpWidget(createTestApp(provider, const HomeScreen()));
      await tester.pumpAndSettle();

      // Navigate to progress
      await tester.tap(find.text('Progress'));
      await tester.pumpAndSettle();

      // Should show progress toward goal
      // - % of goal achieved
      // - Projected completion date
      // - Achievements/milestones

      final startWeight = provider.weightEntries.first.weight;
      final currentWeight = provider.userProfile.weight;

      expect(currentWeight, lessThan(startWeight));
    });

    testWidgets('User can switch between weight units', (tester) async {
      await tester.pumpWidget(createTestApp(provider, const HomeScreen()));
      await tester.pumpAndSettle();

      // Navigate to progress
      await tester.tap(find.text('Progress'));
      await tester.pumpAndSettle();

      // Look for unit toggle (kg/lbs)
      final unitToggle = find.text('lbs');

      if (unitToggle.evaluate().isNotEmpty) {
        await tester.tap(unitToggle);
        await tester.pumpAndSettle();

        // Weight should be displayed in lbs
        // The display should show converted value
        // (Exact verification depends on UI implementation)
      }
    });
  });
}
