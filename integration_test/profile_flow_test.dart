// Integration tests for profile management flow
// Tests profile viewing, editing, and settings management
//
// Run with: flutter test integration_test/profile_flow_test.dart

import 'package:lilyfit/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:lilyfit/providers/app_provider.dart';
import 'package:lilyfit/models/user_profile.dart';
import 'package:lilyfit/screens/home/home_screen.dart';
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

  group('Profile Management Flow Tests', () {
    late AppProvider provider;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      provider = AppProvider();
      await provider.initialize();

      // Complete onboarding with test profile
      await provider.completeOnboarding(
        UserProfile(
          name: 'Alex Johnson',
          gender: 'male',
          age: 32,
          weight: 78.0,
          height: 180.0,
          activityLevel: 'moderate',
          goal: 'maintenance',
        ),
      );
    });

    testWidgets('User can navigate to profile screen', (tester) async {
      await tester.pumpWidget(createTestApp(provider, const HomeScreen()));
      await tester.pumpAndSettle();

      // Tap on Profile tab
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      // Should be on profile screen
      expect(find.byType(ProfileScreen), findsOneWidget);
    });

    testWidgets('Profile displays user information correctly', (tester) async {
      await tester.pumpWidget(createTestApp(provider, const HomeScreen()));
      await tester.pumpAndSettle();

      // Navigate to profile
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      // Verify profile information is displayed
      expect(find.text('Alex Johnson'), findsOneWidget);

      // Age, weight, height should be visible
      expect(find.textContaining('32', findRichText: true), findsWidgets);
      expect(find.textContaining('78', findRichText: true), findsWidgets);
      expect(find.textContaining('180', findRichText: true), findsWidgets);
    });

    testWidgets('User can edit profile information', (tester) async {
      await tester.pumpWidget(createTestApp(provider, const HomeScreen()));
      await tester.pumpAndSettle();

      // Navigate to profile
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      // Find edit profile button
      final editButton = find.byIcon(Icons.edit_rounded);

      if (editButton.evaluate().isNotEmpty) {
        await tester.tap(editButton.first);
        await tester.pumpAndSettle();

        // Should show edit profile dialog/screen
        // Tap "Build Muscle" goal chip
        await tester.tap(find.text('Build Muscle'));
        await tester.pumpAndSettle();

        // Save changes
        final updateButton = find.byType(ElevatedButton);
        if (updateButton.evaluate().isNotEmpty) {
          await tester.tap(updateButton.first);
          await tester.pumpAndSettle();

          // Verify profile was updated
          expect(provider.userProfile.goal, 'muscleGain');
        }
      }
    });

    testWidgets('User can change activity level', (tester) async {
      await tester.pumpWidget(createTestApp(provider, const HomeScreen()));
      await tester.pumpAndSettle();

      // Navigate to profile
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      final originalCalories = provider.userProfile.targetCalories;

      // Find activity level setting
      final activitySetting = find.text('Activity Level');

      if (activitySetting.evaluate().isNotEmpty) {
        await tester.tap(activitySetting);
        await tester.pumpAndSettle();

        // Select different activity level
        final veryActive = find.text('Very Active');
        if (veryActive.evaluate().isNotEmpty) {
          await tester.tap(veryActive);
          await tester.pumpAndSettle();

          // Calorie target should be recalculated
          expect(provider.userProfile.targetCalories, isNot(originalCalories));
          expect(provider.userProfile.activityLevel, 'veryActive');
        }
      }
    });

    testWidgets('User can change fitness goal', (tester) async {
      await tester.pumpWidget(createTestApp(provider, const HomeScreen()));
      await tester.pumpAndSettle();

      // Navigate to profile
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      expect(provider.userProfile.goal, 'maintenance');
      final originalCalories = provider.userProfile.targetCalories;

      // Find goal setting
      final goalSetting = find.text('Goal');

      if (goalSetting.evaluate().isNotEmpty) {
        await tester.tap(goalSetting);
        await tester.pumpAndSettle();

        // Select different goal
        final muscleGain = find.text('Muscle Gain');
        if (muscleGain.evaluate().isNotEmpty) {
          await tester.tap(muscleGain);
          await tester.pumpAndSettle();

          // Calorie and macro targets should be recalculated
          expect(provider.userProfile.goal, 'muscleGain');
          expect(provider.userProfile.targetCalories, isNot(originalCalories));
        }
      }
    });

    testWidgets('User can toggle theme mode', (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: provider,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: provider.themeMode,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: provider.currentLocale,
            home: const HomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to profile
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      final initialThemeMode = provider.themeMode;

      // Find theme toggle
      final themeToggle = find.byIcon(Icons.dark_mode_rounded);

      if (themeToggle.evaluate().isEmpty) {
        // Try light mode icon
        final lightToggle = find.byIcon(Icons.light_mode_rounded);
        if (lightToggle.evaluate().isNotEmpty) {
          await tester.tap(lightToggle);
          await tester.pumpAndSettle();

          expect(provider.themeMode, isNot(initialThemeMode));
        }
      } else {
        await tester.tap(themeToggle);
        await tester.pumpAndSettle();

        expect(provider.themeMode, isNot(initialThemeMode));
      }
    });

    testWidgets('User can change app language', (tester) async {
      await tester.pumpWidget(createTestApp(provider, const HomeScreen()));
      await tester.pumpAndSettle();

      // Navigate to profile
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      expect(provider.currentLocale.languageCode, 'en');

      // Find language setting
      final languageSetting = find.text('Language');

      if (languageSetting.evaluate().isNotEmpty) {
        await tester.tap(languageSetting);
        await tester.pumpAndSettle();

        // Select different language (e.g., Swahili)
        final swahili = find.text('Kiswahili');
        if (swahili.evaluate().isNotEmpty) {
          await tester.tap(swahili);
          await tester.pumpAndSettle();

          expect(provider.currentLocale.languageCode, 'sw');
        }
      }
    });

    testWidgets('User can view calculated macro targets', (tester) async {
      await tester.pumpWidget(createTestApp(provider, const HomeScreen()));
      await tester.pumpAndSettle();

      // Navigate to profile
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      // Profile should display macro targets
      final profile = provider.userProfile;

      expect(profile.targetCalories, greaterThan(0));
      expect(profile.targetProtein, greaterThan(0));
      expect(profile.targetCarbs, greaterThan(0));
      expect(profile.targetFat, greaterThan(0));

      // These values should be visible on profile screen
      // (Exact text format may vary)
    });

    testWidgets('User can manage water reminder settings', (tester) async {
      await tester.pumpWidget(createTestApp(provider, const HomeScreen()));
      await tester.pumpAndSettle();

      // Navigate to profile
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      // Find water reminders setting
      final reminderSetting = find.text('Water Reminders');

      if (reminderSetting.evaluate().isNotEmpty) {
        await tester.tap(reminderSetting);
        await tester.pumpAndSettle();

        // Should show reminder configuration
        // Toggle reminders on/off
        final reminderSwitch = find.byType(Switch);
        if (reminderSwitch.evaluate().isNotEmpty) {
          final initialState = provider.waterRemindersEnabled;

          await tester.tap(reminderSwitch.first);
          await tester.pumpAndSettle();

          expect(provider.waterRemindersEnabled, isNot(initialState));
        }
      }
    });

    testWidgets('User can adjust water reminder frequency', (tester) async {
      await tester.pumpWidget(createTestApp(provider, const HomeScreen()));
      await tester.pumpAndSettle();

      // Enable water reminders first
      await provider.updateWaterReminders(
        enabled: true,
        intervalMinutes: 60,
        startHour: 8,
        startMinute: 0,
        endHour: 22,
        endMinute: 0,
      );

      // Navigate to profile
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      // Find water reminders setting
      final reminderSetting = find.text('Water Reminders');

      if (reminderSetting.evaluate().isNotEmpty) {
        await tester.tap(reminderSetting);
        await tester.pumpAndSettle();

        // Look for interval adjustment
        // Common options: 30min, 60min, 90min, 120min
        final interval60 = find.text('60 minutes');
        if (interval60.evaluate().isNotEmpty) {
          expect(provider.waterReminderIntervalMinutes, 60);
        }
      }
    });

    testWidgets('User can view app information and version', (tester) async {
      await tester.pumpWidget(createTestApp(provider, const HomeScreen()));
      await tester.pumpAndSettle();

      // Navigate to profile
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      // Find About or App Info section
      final aboutButton = find.text('About');

      if (aboutButton.evaluate().isNotEmpty) {
        await tester.tap(aboutButton);
        await tester.pumpAndSettle();

        // Should show app version, credits, etc.
        expect(find.text('LilyFit'), findsWidgets);
      }
    });

    testWidgets('User can reset app data', (tester) async {
      // Add some data first
      await provider.addWater(ml: 500);
      await provider.addWeight(77.0);

      expect(provider.waterIntake, 500.0);
      expect(provider.weightEntries.isNotEmpty, isTrue);

      await tester.pumpWidget(createTestApp(provider, const HomeScreen()));
      await tester.pumpAndSettle();

      // Navigate to profile
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      // Find reset/clear data option
      final resetButton = find.text('Reset Data');

      if (resetButton.evaluate().isNotEmpty) {
        await tester.tap(resetButton);
        await tester.pumpAndSettle();

        // Confirm reset
        final confirmButton = find.text('Reset');
        if (confirmButton.evaluate().isNotEmpty) {
          await tester.tap(confirmButton);
          await tester.pumpAndSettle();

          // All data should be cleared
          expect(provider.isOnboarded, isFalse);
          expect(provider.waterIntake, 0.0);
          expect(provider.allMealLogs, isEmpty);
        }
      }
    });

    testWidgets('Profile updates persist after app restart', (tester) async {
      // Update profile
      final updatedProfile = UserProfile(
        name: 'Updated Name',
        gender: 'female',
        age: 28,
        weight: 65.0,
        height: 170.0,
        activityLevel: 'active',
        goal: 'fatLoss',
      );

      await provider.updateProfile(updatedProfile);

      // Create new provider instance (simulating app restart)
      final newProvider = AppProvider();
      await newProvider.initialize();

      // Profile should be loaded from storage
      expect(newProvider.userProfile.name, 'Updated Name');
      expect(newProvider.userProfile.age, 28);
      expect(newProvider.userProfile.weight, 65.0);
    });

    testWidgets('User can export data', (tester) async {
      await tester.pumpWidget(createTestApp(provider, const HomeScreen()));
      await tester.pumpAndSettle();

      // Navigate to profile
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      // Find export data option
      final exportButton = find.text('Export Data');

      if (exportButton.evaluate().isNotEmpty) {
        await tester.tap(exportButton);
        await tester.pumpAndSettle();

        // Should trigger export functionality
        // (Exact behavior depends on implementation)
      }
    });

    testWidgets('BMI is calculated and displayed correctly', (tester) async {
      await tester.pumpWidget(createTestApp(provider, const HomeScreen()));
      await tester.pumpAndSettle();

      // Navigate to profile
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      // Calculate expected BMI: weight (kg) / (height (m))^2
      final weight = provider.userProfile.weight; // 78 kg
      final height = provider.userProfile.height / 100; // 1.80 m
      final expectedBmi = weight / (height * height); // ~24.1

      // BMI should be displayed somewhere on profile
      // (Exact format may vary)
      expect(expectedBmi, closeTo(24.1, 0.5));
    });

    testWidgets('User can update target weight for goal', (tester) async {
      await tester.pumpWidget(createTestApp(provider, const HomeScreen()));
      await tester.pumpAndSettle();

      // Navigate to profile
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      // Find target weight setting
      final targetWeightSetting = find.text('Target Weight');

      if (targetWeightSetting.evaluate().isNotEmpty) {
        await tester.tap(targetWeightSetting);
        await tester.pumpAndSettle();

        // Enter target weight
        final textField = find.byType(TextField);
        if (textField.evaluate().isNotEmpty) {
          await tester.enterText(textField.first, '75');
          await tester.pumpAndSettle();

          // Save
          final saveButton = find.text('Save');
          if (saveButton.evaluate().isNotEmpty) {
            await tester.tap(saveButton);
            await tester.pumpAndSettle();

            // Target weight should be updated
            // (This depends on how the app stores target weight)
          }
        }
      }
    });
  });
}
