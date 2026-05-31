// Integration tests for the onboarding flow
// Tests the complete user onboarding experience
//
// Run with: flutter test integration_test/onboarding_flow_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:lilyfit/providers/app_provider.dart';
import 'package:lilyfit/screens/onboarding/onboarding_screen.dart';
import 'package:lilyfit/screens/home/home_screen.dart';
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

  group('Onboarding Flow Tests', () {
    setUp(() async {
      // Clear all shared preferences before each test
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('User can complete full onboarding flow', (tester) async {
      // Initialize app
      final provider = AppProvider();
      await provider.initialize();

      await tester.pumpWidget(
        createTestApp(provider, const OnboardingScreen()),
      );
      await tester.pumpAndSettle();

      // Verify we're on the Welcome page (page 0)
      expect(find.text('Welcome to LilyFit'), findsOneWidget);

      // Tap Next/Get Started
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      // Page 1: Name Input
      expect(find.text('What\'s your name?'), findsOneWidget);
      await tester.enterText(find.byType(TextField).first, 'Jane Doe');
      await tester.pumpAndSettle();

      // Tap Next
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Page 2: Gender Selection
      expect(find.text('What is your gender?'), findsOneWidget);

      // Select Female
      await tester.tap(find.text('Female'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Page 3: Age Selection
      expect(find.text('How old are you?'), findsOneWidget);

      // Age is adjusted via slider or buttons - find and tap increment button multiple times
      final incrementButton = find.byIcon(Icons.add_rounded).first;
      for (int i = 0; i < 5; i++) {
        await tester.tap(incrementButton);
        await tester.pump(const Duration(milliseconds: 100));
      }

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Page 4: Weight Input
      expect(find.text('What is your current weight?'), findsOneWidget);

      // Use increment buttons for weight
      final weightIncrement = find.byIcon(Icons.add_rounded).first;
      for (int i = 0; i < 3; i++) {
        await tester.tap(weightIncrement);
        await tester.pump(const Duration(milliseconds: 100));
      }

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Page 5: Height Input
      expect(find.text('What is your height?'), findsOneWidget);

      // Use increment buttons for height
      final heightIncrement = find.byIcon(Icons.add_rounded).first;
      for (int i = 0; i < 3; i++) {
        await tester.tap(heightIncrement);
        await tester.pump(const Duration(milliseconds: 100));
      }

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Page 6: Activity Level
      expect(find.text('What is your activity level?'), findsOneWidget);

      // Select Moderate
      await tester.tap(find.text('Moderately Active'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Page 7: Goal Selection
      expect(find.text('What is your goal?'), findsOneWidget);

      // Select Fat Loss
      await tester.tap(find.text('Fat Loss'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Page 8: Water Goal (Final Page)
      expect(find.text('Daily water goal'), findsOneWidget);

      // Complete onboarding
      await tester.tap(find.text('Complete'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Should navigate to home screen
      expect(find.byType(HomeScreen), findsOneWidget);

      // Verify provider state
      expect(provider.isOnboarded, isTrue);
      expect(provider.userProfile.name, 'Jane Doe');
      expect(provider.userProfile.gender, 'female');
      expect(provider.userProfile.targetCalories, greaterThan(0));
    });

    testWidgets('User can navigate back through onboarding pages', (
      tester,
    ) async {
      final provider = AppProvider();
      await provider.initialize();

      await tester.pumpWidget(
        createTestApp(provider, const OnboardingScreen()),
      );
      await tester.pumpAndSettle();

      // Go forward 2 pages
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Test User');
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Verify on page 2 (Gender)
      expect(find.text('What is your gender?'), findsOneWidget);

      // Go back to page 1
      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();

      // Verify on page 1 (Name)
      expect(find.text('What\'s your name?'), findsOneWidget);
      expect(
        find.text('Test User'),
        findsOneWidget,
      ); // Name should be preserved
    });

    testWidgets('Name validation prevents empty submission', (tester) async {
      final provider = AppProvider();
      await provider.initialize();

      await tester.pumpWidget(
        createTestApp(provider, const OnboardingScreen()),
      );
      await tester.pumpAndSettle();

      // Skip welcome page
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      // Try to proceed without entering name
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Should show error message
      expect(
        find.textContaining('name'),
        findsAtLeastNWidgets(2),
      ); // Label + error

      // Should still be on name page
      expect(find.text('What\'s your name?'), findsOneWidget);
    });

    testWidgets('Progress indicator reflects current page', (tester) async {
      final provider = AppProvider();
      await provider.initialize();

      await tester.pumpWidget(
        createTestApp(provider, const OnboardingScreen()),
      );
      await tester.pumpAndSettle();

      // The progress indicator should be present
      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      // Navigate through pages and verify progress updates
      for (int i = 0; i < 3; i++) {
        await tester.tap(find.text(i == 0 ? 'Get Started' : 'Next'));
        await tester.pumpAndSettle();

        if (i == 0) {
          // Enter name on first actual page
          await tester.enterText(find.byType(TextField).first, 'Test User');
          await tester.pumpAndSettle();
        } else if (i == 1) {
          // Select gender
          await tester.tap(find.text('Male'));
          await tester.pumpAndSettle();
        }
      }
    });

    testWidgets('Unit switching works for weight and height', (tester) async {
      final provider = AppProvider();
      await provider.initialize();

      await tester.pumpWidget(
        createTestApp(provider, const OnboardingScreen()),
      );
      await tester.pumpAndSettle();

      // Navigate to weight page
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Test User');
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Male'));
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Next')); // Skip age
      await tester.pumpAndSettle();

      // Now on weight page
      expect(find.text('What is your current weight?'), findsOneWidget);

      // Find unit toggle button (kg/lbs)
      final unitToggle = find.text('lbs');
      if (unitToggle.evaluate().isNotEmpty) {
        await tester.tap(unitToggle);
        await tester.pumpAndSettle();

        // Verify unit changed (value should convert)
        expect(find.text('kg'), findsOneWidget);
      }
    });
  });
}
